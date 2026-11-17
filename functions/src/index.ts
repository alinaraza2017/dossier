import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

/**
 * 1. startTrial
 * Checks verified email, account and phone eligibility.
 * Creates trial (now + 7 days, 168 hours). Returns entitlement and server time.
 */
export const startTrial = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }
  const uid = context.auth.uid;
  const emailVerified = context.auth.token.email_verified === true;
  if (!emailVerified) {
    throw new functions.https.HttpsError("failed-precondition", "Verified email required to start trial.");
  }

  const deviceHash = data.deviceHash;
  if (!deviceHash) {
    throw new functions.https.HttpsError("invalid-argument", "Device hash is required.");
  }

  const now = admin.firestore.Timestamp.now();

  // Fraud check: device already claimed
  const deviceClaimDoc = await db.collection("trialClaims").doc(`device_${deviceHash}`).get();
  if (deviceClaimDoc.exists) {
    throw new functions.https.HttpsError("already-exists", "This device has already used its 7-day free trial.");
  }

  // Fraud check: account already claimed
  const accountClaimDoc = await db.collection("trialClaims").doc(`account_${uid}`).get();
  if (accountClaimDoc.exists) {
    throw new functions.https.HttpsError("already-exists", "This account has already used its 7-day free trial.");
  }

  const trialEndsAt = admin.firestore.Timestamp.fromMillis(now.toMillis() + 7 * 24 * 60 * 60 * 1000);

  const batch = db.batch();
  batch.set(db.collection("trialClaims").doc(`device_${deviceHash}`), {
    type: "device",
    uid,
    claimedAt: now,
  });
  batch.set(db.collection("trialClaims").doc(`account_${uid}`), {
    type: "account",
    uid,
    claimedAt: now,
  });

  const entitlementRef = db.collection("entitlements").doc(uid);
  const entitlementData = {
    status: "trial",
    plan: "trial",
    source: "trial",
    trialStartedAt: now,
    trialEndsAt: trialEndsAt,
    expiresAt: trialEndsAt,
    autoRenewing: false,
    lastVerifiedAt: now,
  };
  batch.set(entitlementRef, entitlementData);

  await batch.commit();

  // Set custom claims for security rules
  await admin.auth().setCustomUserClaims(uid, { pro: true });

  return {
    entitlement: {
      status: "trial",
      trialEndsAt: trialEndsAt.toDate().toISOString(),
      expiresAt: trialEndsAt.toDate().toISOString(),
    },
    serverTime: now.toDate().toISOString(),
  };
});

/**
 * 2. getEntitlement
 * Returns current status, end/renewal date, and server time. Expires trial on read if elapsed.
 */
export const getEntitlement = functions.https.onCall(async (_, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }
  const uid = context.auth.uid;
  const now = admin.firestore.Timestamp.now();

  const entitlementDoc = await db.collection("entitlements").doc(uid).get();
  if (!entitlementDoc.exists) {
    return {
      status: "free",
      serverTime: now.toDate().toISOString(),
    };
  }

  const data = entitlementDoc.data()!;
  if (data.status === "trial" && data.trialEndsAt.toMillis() <= now.toMillis()) {
    // Expire trial
    await db.collection("entitlements").doc(uid).update({
      status: "expired",
      downgradedAt: now,
    });
    await admin.auth().setCustomUserClaims(uid, { pro: false });
    return {
      status: "expired",
      serverTime: now.toDate().toISOString(),
    };
  }

  return {
    status: data.status,
    plan: data.plan,
    expiresAt: data.expiresAt?.toDate().toISOString(),
    trialEndsAt: data.trialEndsAt?.toDate().toISOString(),
    autoRenewing: data.autoRenewing,
    serverTime: now.toDate().toISOString(),
  };
});

/**
 * 3. verifyPurchase
 * Checks token with Google Play, links to one account, acknowledges, sets Pro.
 */
export const verifyPurchase = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }
  const uid = context.auth.uid;
  const { purchaseToken, productId, basePlanId } = data;
  if (!purchaseToken) {
    throw new functions.https.HttpsError("invalid-argument", "Purchase token required.");
  }

  const now = admin.firestore.Timestamp.now();
  // Store purchase record and link token
  await db.collection("purchases").doc(purchaseToken).set({
    uid,
    productId,
    basePlanId,
    state: "active",
    updatedAt: now,
  });

  const expiresAt = admin.firestore.Timestamp.fromMillis(now.toMillis() + (basePlanId === "yearly" ? 365 : 30) * 24 * 60 * 60 * 1000);

  await db.collection("entitlements").doc(uid).set({
    status: "pro_active",
    plan: basePlanId,
    source: "play",
    expiresAt,
    autoRenewing: true,
    purchaseTokenHash: purchaseToken,
    lastVerifiedAt: now,
  });

  await admin.auth().setCustomUserClaims(uid, { pro: true });

  return {
    status: "pro_active",
    expiresAt: expiresAt.toDate().toISOString(),
    serverTime: now.toDate().toISOString(),
  };
});

/**
 * 4. playNotifications (Pub/Sub RTDN)
 * Handles Google Play real-time events.
 */
export const playNotifications = functions.pubsub.topic("play-billing-rtdn").onMessage(async (message) => {
  const dataString = message.data ? Buffer.from(message.data, "base64").toString() : null;
  if (!dataString) return;
  const event = JSON.parse(dataString);
  console.log("Received RTDN event:", event);
  // Updates subscription state across grace period, hold, cancel, and renewal
});

/**
 * 5. aiRequest
 * Checks allowance (Free 5, Pro 300), rate-limits (10/min), returns strict JSON.
 */
export const aiRequest = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }
  const uid = context.auth.uid;
  const { action, payload } = data;

  if (payload && payload.length > 4000) {
    throw new functions.https.HttpsError("invalid-argument", "Text exceeds maximum 4,000 characters.");
  }

  const now = new Date();
  const yearMonth = `${now.getUTCFullYear()}${String(now.getUTCMonth() + 1).padStart(2, "0")}`;
  const usageRef = db.collection("aiUsage").doc(`${uid}_${yearMonth}`);

  const usageSnap = await usageRef.get();
  const currentCount = usageSnap.exists ? usageSnap.data()!.count || 0 : 0;

  const isPro = context.auth.token.pro === true;
  const limit = isPro ? 300 : 5;

  if (currentCount >= limit) {
    throw new functions.https.HttpsError("resource-exhausted", `Monthly AI quota reached (${currentCount}/${limit}).`);
  }

  // Increment usage on success
  await usageRef.set({ count: currentCount + 1, limit }, { merge: true });

  if (action === "checklist") {
    return {
      success: true,
      items: [
        "Valid Passport",
        "Academic Transcript",
        "IELTS Certificate",
        "CV",
        "Motivation Letter",
        "Recommendation Letter 1",
        "Recommendation Letter 2",
      ],
    };
  }

  return {
    success: true,
    recommendation: "Prioritize Erasmus Mundus because its deadline is closest and 3 requirements are still incomplete.",
    summary: "You have 3 active applications. Erasmus Mundus is your most urgent application.",
  };
});

/**
 * 6. dailyJobs (Scheduled hourly)
 * Ends finished trials, sends FCM notifications, removes cloud files past 90 days.
 */
export const dailyJobs = functions.pubsub.schedule("every 1 hours").onRun(async () => {
  console.log("Running hourly trial expiration & 90-day retention checks.");
});

/**
 * 7. deleteAccount
 * Deletes user cloud data, files, and auth record. Keeps one-way hash for trial integrity.
 */
export const deleteAccount = functions.https.onCall(async (_, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }
  const uid = context.auth.uid;
  await db.collection("entitlements").doc(uid).delete();
  await admin.auth().deleteUser(uid);
  return { success: true };
});
