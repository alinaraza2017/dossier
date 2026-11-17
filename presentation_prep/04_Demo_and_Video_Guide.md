# Dossier: Live Demo and YouTube Video Guide

Every step below was run in the fixed app. The tests used the same Flutter code in a phone-sized window, not a physical phone. Steps marked **(check on phone)** use Android features I could not test here, so try them once on your phone tonight.

---

## A. Tonight: build and install the APK

1. Pull the latest code from branch `claude/adoring-turing-zhov2p`.
2. Build a small APK for your phone:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release --split-per-abi
   ```
3. Use `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. This APK suits almost every modern phone.
   **Check that the file is under 25 MB.** I removed 7 unused packages and replaced google_fonts with a bundled font to keep it small, but I could not build the APK here.
4. Uninstall any old Dossier from the phone first, then install the new APK.
5. **(check on phone)**: the new launcher icon (blue "D") appears, and on first launch Android asks for notification permission.
6. Practise the full demo once. Then reset for the real demo:
   - Android Settings → Apps → Dossier → Storage → **Clear storage**. This brings back onboarding and an empty Home.
   - Settings → Clear data on this phone (type `DELETE`) only clears applications. Onboarding will not show again.

**Keep ready:** phone charged, Do Not Disturb on, brightness up, the phone's date and time correct, and this text copied to the clipboard (for the AI step):

```
Applicants must submit a CV, a passport copy, a bank statement and two recommendation letters.
```

---

## B. How to introduce the app (about 20 seconds)

> "Sir, ab main live demo dikhati hoon. Yeh actual APK hai jo phone par installed hai. Main fresh install se start kar rahi hoon, taake first-time user ka poora flow nazar aaye. Saara data phone par SQLite mein save hota hai aur app internet ke bina bhi chalti hai."

---

## C. Live demo sequence (7–8 minutes)

| # | Do this | Say / point out | Expected result |
|---|---|---|---|
| 1 | Open Dossier | "Splash, phir onboarding sirf pehli dafa." | Splash, then onboarding page 1 |
| 2 | Next → Next → **Get Started** → **Allow** notifications | "Android 13+ par reminders ke liye permission." | Home, empty state |
| 3 | Point at the header and plan card | "Real date. Free plan, 0 of 5 active, no account." | "Free plan · 0 of 5 active" |
| 4 | Tap **Load Demo Scholarships** | "Realistic sample data, deadlines aaj se 5, 15, 30 din." | 3 active, 1 urgent; cards with chips and progress |
| 5 | Tap **+**, then **Save Application** on the empty form | "Validation." | "Scholarship name is required" |
| 6 | Type `A` in Name, then Save | "Name 2 se 80 characters." | "Use at least 2 characters" |
| 7 | Name `Fulbright`, Country `USA`, Link `fulbrightonline.org`, choose **In Progress**, Save | "Link mein https khud lag jata hai. Country optional hai." | Green "Scholarship application saved"; Fulbright card with "No requirements yet" |
| 8 | Tap **Erasmus Mundus** | "Details: status, progress, reminders 7 aur 2 din pehle 9 baje, link." | Details screen |
| 9 | Tap the link **(check on phone)** | "Link browser mein khulta hai." | Browser opens erasmus-plus.ec.europa.eu |
| 10 | Back → **View Requirements Checklist** → tick **CV** | "Progress foran update." | 50% → 67% |
| 11 | Type `Financial Statement` → **+** | "Add requirement." | 7 items, 57% |
| 12 | Delete Financial Statement → **Delete** → tap **Undo** | "Confirmation, phir 5 second ka Undo." | Item comes back |
| 13 | Tap **Generate Checklist with AI** → paste the clipboard text → **Generate Checklist** | "AI pasted text ko items mein todta hai. Offline mode bhi kaam karta hai." | 5 items: CV, Passport Copy, Bank Statement, Recommendation Letter 1, 2 |
| 14 | Scroll → **Save Checklist to Scholarship** | "Pehle se maujood items skip." | "Added 4 to Erasmus Mundus · 1 already existed and were skipped" |
| 15 | Back arrow → see the list | | New items at the bottom of the checklist |
| 16 | Bottom tab **AI Assistant** → **Priority & Summary** → **Analyze My Applications** | "Ek click mein order aur summary, real data se." | #1 Erasmus "5d left", reason text, summary card |
| 17 | Tap **#1 Erasmus** | "Recommendation se seedha application." | Erasmus details open |
| 18 | Tab **Deadlines** → tap **Urgent**, **Due soon**, **Later**, **All** | "Urgent 0–7, Due soon 8–21, Later 22+; colour ke saath label." | Groups filter correctly |
| 19 | Home → **+** → add `Chevening`, Save | | "Free plan · 5 of 5 active" |
| 20 | Tap **+** again | "Free plan ki limit, business model ka rule." | **Upgrade sheet**: "You have 5 active applications" |
| 21 | **Try Pro free for 7 days** → show the paywall → **Start 7-day free trial** | "Pricing Rs 499 / Rs 3,999. Trial aur billing server par hoti hai; yeh Phase 2 hai." | Snackbar: "Preview: Dossier Pro … is Phase 2 and is not active in this build." |
| 22 | Close → open **Stipendium Hungaricum** → Status → **Submitted** | "Submitted count nahi hoti, reminders cancel." | "Marked as Submitted…"; Home shows "Submitted (1)", 4 of 5 active |
| 23 | Tap **+** | "Ab add ho sakti hai." | Add form opens (no sheet) → back |
| 24 | Tab **Settings** | "Real state: Free plan, no account." | Settings |
| 25 | **Reminders** → switch Deadline reminders **off** → back → on again | "Setting save hoti hai; off karne par saare reminders cancel." | Snackbar "All deadline reminders cancelled." |
| 26 | **Export data (CSV)** **(check on phone)** | "User apna data own karta hai." | Android share sheet with `dossier_export_<date>.csv` |
| 27 | **Subscription & billing** → scroll to **Pro design previews** → open **Trial ended** | "Phase 2 screens ka design." | Preview screens |
| 28 | Close Dossier from recent apps, then open again | "Persistence." | All data still there; onboarding does not show |
| 29 | Optional: Airplane mode on → add a requirement and run **Analyze** | "Offline-first." | Works offline |

**If Sir asks you to show a notification:** reminders fire at 9:00 AM, 7 and 2 days before a deadline, so one cannot appear instantly.
Say so honestly, and show step 25 plus the reminders line on the details screen. Explain that scheduling uses `flutter_local_notifications` with exact alarms and a boot receiver, and that the time calculation is covered by unit tests.
Do not change the phone's clock during the demo.

**If something goes wrong:** stay calm and use the back arrow or a bottom tab. If data gets messy: Settings → Clear data → `DELETE` → Load Demo Scholarships.

---

## D. YouTube video: what to record, in order

**Tool:** Android's built-in screen recorder (Quick Settings → Screen record, with "Microphone" on). Or, from a laptop, `scrcpy --record dossier_demo.mp4`. Keep the phone in portrait.
**Length:** 5–7 minutes. Speak the same lines as in the live demo. Start from a fresh install (Clear storage).

| Part | Time | Record |
|---|---|---|
| 1. Intro | 0:00–0:30 | Your voice over the launcher icon: name, reg. no., "Dossier: Scholarship Application Planner", the problem in one sentence |
| 2. First launch | 0:30–1:00 | Steps 1–4 (onboarding, permission, empty Home, Load Demo) |
| 3. Add application | 1:00–2:00 | Steps 5–7 (validation, then save Fulbright) |
| 4. Details and checklist | 2:00–3:00 | Steps 8, 10–12 (progress, add, Undo) |
| 5. AI | 3:00–4:15 | Steps 13–17 (checklist with duplicate skip, Analyze, open #1) |
| 6. Deadlines | 4:15–4:45 | Step 18 |
| 7. Business model in the app | 4:45–5:45 | Steps 19–23 (limit, Upgrade sheet, Pro screen with the Phase 2 message, Submitted frees a slot) |
| 8. Settings and persistence | 5:45–6:30 | Steps 24–28 |
| 9. Closing | 6:30–6:50 | "Phase 1 complete, Phase 2 next: Firebase and Google Play Billing. Thank you." |

**Upload settings**
- Visibility: **Unlisted** (anyone with the link can watch).
- Title: `Dossier: Scholarship Application Planner (Flutter) | SCD Lab Mid | FA23-BSE-015`
- Description:
  ```
  Dossier helps students organise scholarship applications: deadlines, requirement checklists, progress, offline reminders and an AI assistant.
  Built with Flutter, Provider and SQLite (offline-first).
  Course: Software Construction and Development. Submitted to: Dr. Tahseen Riaz Abbasi.
  ```
- After uploading, paste the link on the last slide of the deck (it says "add before submission"). Also add it to the README if Sir wants it there.

---

## E. Five-minute pre-demo checklist

- [ ] Fresh install / Clear storage done
- [ ] Notifications allowed
- [ ] AI sample text copied to the clipboard
- [ ] Phone date and time correct
- [ ] Link opens a browser **(check on phone)**
- [ ] CSV share sheet opens **(check on phone)**
- [ ] APK file size noted (under 25 MB)
- [ ] YouTube link added to the last slide
