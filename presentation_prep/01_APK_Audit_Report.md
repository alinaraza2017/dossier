# Dossier: Pre-Demo Audit Report (SCD Lab Mid)

**Audited against:** `Dossier_Project_Document_new.docx` (Version 2.0, 23 sections)
**Code audited:** branch `claude/adoring-turing-zhov2p`, commit `a06648b`
**Date:** 17 Nov 2026

---

## 0. How this audit was done (read first)

| Item | Status |
|---|---|
| APK file | **Not attached.** Only the .docx came through. The approved idea deck and the user flow report were not attached either. |
| Android emulator | **Not possible here.** The container has no KVM, and `dl.google.com` (Android SDK) is blocked by the network policy. |
| What I did instead | I installed Flutter 3.38.10 (the version in the README) and built a **test harness** that runs the **unmodified app code** in a 412×892 phone-sized window, with the platform forced to Android. Then I drove it with real clicks and typing and took screenshots. |
| Static checks | `flutter analyze`: **0 issues**. `flutter test`: **24/24 passed**. |
| Not testable here | Real notifications, notification permission, exact alarms, reboot behaviour, opening links in a browser, APK size, real-device font rendering. These are marked **[code]** or **[untested]** below. |

**Evidence tags:** **[run]** = reproduced in the running app · **[code]** = verified by reading source · **[untested]** = could not verify.

Screenshots are in `presentation_prep/audit_screenshots/`. They come from a debug build, so the yellow/black overflow stripes are visible. In a release APK the same text is silently cut off.

---

## 1. Critical issues (MUST FIX before tomorrow)

| # | Feature | Actual problem | Why it matters | Suggested fix | Evidence |
|---|---|---|---|---|---|
| C1 | **AI Assistant tab (Checklist)** | The screen is a **static mock-up**. The pasted text is pre-filled, the 7 items are hard-coded, "Generate Checklist" only shows a snackbar, and "Add to Erasmus Mundus" saves **nothing**. I pasted *"birth certificate, bank statement, police clearance letter"* and got the same Passport/IELTS list. | AI is one of the main selling points. Sir only has to type different text to expose it, and a hard-coded "AI" can look dishonest. | A **working** version already exists in the code but is never used: `checklist_tab.dart` + `priority_summary_tab.dart` + `AiProvider`. Wire them into `ai_assistant_screen.dart`. | [run] A1 |
| C2 | **AI Assistant (Priority & Summary)** | Also hard-coded. It showed Erasmus as "50% complete" right after I had raised it to 67%. "Analyze" does nothing. | Same as C1. | Same fix (use `PrioritySummaryTab`). | [run] A2 |
| C3 | **Home header** | It always shows "Good morning, Alina · **Wednesday, 7 Oct 2026**". The cards under it say "Due 22 Nov · 5 days left". | Tomorrow (18 Nov) the date will be visibly wrong, and it contradicts the deadline cards on the same screen. | Use `DateTime.now()` for the date and a time-based greeting. Drop the hard-coded name, or make it a neutral "Hello". | [run] A3 |
| C4 | **Home trial banner, Settings plan card, AI usage line** | A **fresh install** says "Pro trial · 5 days left · Ends 12 Oct". 12 Oct is already in the past. Settings also shows "Alina Raza / alina.raza@gmail.com", "12 of 300 AI uses", "Last synced 9:40 AM", "4 files · 6.2 MB". **None of this is real state.** | The document says a new user starts on **Free** with no account. Sir will see Pro claims on a brand-new install. It contradicts itself, and it is the easiest thing to challenge. | Show the real state: **Free plan**, "Sign in (coming soon)", AI line without fake counts, and PRO labels that open the Pro screen. | [run] A3, A5 |
| C5 | **Pro paywall and payment sheet** | "Start 7-day free trial" only shows a snackbar and closes. The payment sheet says **"Payment completed via Google Play Billing!"** without any billing. In-app purchase, Firebase, sign-in, sync, vault upload, export and dark mode are **not implemented** in the app. `in_app_purchase`, `pdf`, `printing`, `share_plus`, `add_2_calendar`, `file_picker` and `crypto` are in `pubspec.yaml` but never imported, and there is no Firebase package at all. | A fake "payment completed" message is the riskiest thing to show a strict examiner. | Change the messages to honest ones, for example "Pro is a planned module. Billing and trial run on the server (see design)". Present Pro as **designed and prototyped, not yet integrated** (see Section 4). | [run] A8, [code] |
| C6 | **`docs/gap_report.md` in the repo** | It claims "100% Implemented & Verified", including Firebase auth, Google Play Billing, the vault, export and all 20 screens. | If Sir opens the repo, this is provably false and hurts credibility more than the missing features themselves. | Rewrite it honestly or remove it (your decision). | [code] |
| C7 | **Deadline reminders** | `requestPermissions()` exists but is **never called**. On Android 13+, `POST_NOTIFICATIONS` is a runtime permission, so reminders are probably **never shown** unless the user enables notifications manually in system settings. | Reminders are a core v1 feature. If Sir asks "show me a notification", it may fail. | Call `NotificationService.instance.requestPermissions()` once after onboarding or on first save. | [code] / [untested on device] |
| C8 | **Application Details: "Information & Links" card** | The line "Reminders: Enabled (7 days & 2 days before at 9:…" **overflows by 83 px** at 412 dp width, and more on 360 dp phones. It appears on **every** details screen. | It is a visible layout bug on the most-opened screen. | Wrap the value in `Expanded` / `Flexible`, or shorten it to "7 & 2 days before, 9:00 AM". | [run] A4 |

## 2. UI/UX improvements

| # | Feature | Problem | Why it matters | Fix | Priority | Evidence |
|---|---|---|---|---|---|---|
| U1 | Requirements order | Items appear in **random order**: Motivation Letter, Passport, CV… The demo data never sets `sortOrder`, so the list sorts by UUID. | Looks buggy; the document lists Passport first. | Set `sortOrder` in the sample data and order by `sortOrder, createdAt`. | Must fix | [run] A4 |
| U2 | Deadlines colours | 30-days-left items are **amber under "Upcoming"** on Deadlines but **blue "Later"** on Home. The document says 22+ days is **Later, blue**. | Inconsistent between screens; easy to spot. | Add a "Later" group in blue, or colour each item by its category. | Should fix | [run] A6 |
| U3 | Deadlines text | "1 requirements left" (grammar). "0 requirements left" appears where the document says "No requirements yet". | Polish. | Pluralise; show "No requirements yet". | Should fix | [run] |
| U4 | Home "See all" | Does nothing (there is a `// Switch to tab 1` comment and no code). | A dead button in a demo. | Switch to the Deadlines tab. | Should fix | [code] |
| U5 | Submitted applications | After marking one Submitted, it **disappears from Home and Deadlines**, so there is no way to reopen it. | Data seems lost to the user. | Add a collapsed "Submitted" section on Home or a Submitted filter on Deadlines. | Should fix | [run] |
| U6 | AI screen opened from Requirements | It is pushed as a new route with **no back arrow or app bar**. | Users get stuck; on the phone only the system back gesture works. | Wrap it in a `Scaffold` + `AppBar` when pushed. | Should fix | [run] |
| U7 | Fonts | Theme text uses Poppins through `google_fonts`, but many widgets use `fontFamily: 'Poppins'`, which does not match the font google_fonts registers. Those widgets fall back to Roboto, so headings and cards mix fonts. Fonts are also **downloaded at runtime**, not bundled as the document says. | Visible inconsistency (compare onboarding vs Home in A3). Offline, everything falls back. | Bundle Poppins TTFs in `assets/fonts` and register the family `Poppins` in pubspec. | Should fix | [run] |
| U8 | Launcher icon | The default **Flutter logo** (checksum matches the Flutter template). | It is the first thing Sir sees on the phone. | Generate a simple "D" / folder icon. | Should fix | [code] |
| U9 | Edit-requirement dialog | "Cancel" and a full-width "Save" are stacked oddly (the theme forces full-width buttons). | Looks unpolished. | Use `TextButton`s or set the button size in the dialog. | Minor | [run] |
| U10 | Details after Submitted | Still shows "Reminders: Enabled" although they were cancelled. | Small contradiction. | Show "Off (submitted)". | Minor | [run] |
| U11 | Margins | Add form and Settings use 16 dp side margins; the document says 20 dp. | Spec mismatch only. | Change the padding. | Minor | [run] |
| U12 | Settings switches | The Backup switch thumb is invisible (teal on teal). | Visual glitch. | Will go away when the fake rows are replaced. | Minor | [run] A5 |
| U13 | Paywall | The "Save 33%" badge is clipped by the card border. | Polish. | Move the badge inside the card. | Minor | [run] A8 |
| U14 | Vault mock | "Expires 18 Nov" next to "expires in 42 days". | Contradiction if shown. | Avoid showing it, or fix the text. | Minor | [run] A8 |

## 3. Functional bugs

| # | Feature | Problem | Why it matters | Fix | Priority | Evidence |
|---|---|---|---|---|---|---|
| B1 | **Free limit (5 active)** | Not enforced. I saved a 6th active application with no upgrade sheet. `UpgradeSheet` exists but is never opened. | It is the core business-model rule (Section 7.1). Sir may add a 6th to test it. | Before opening Add, check `activeScholarships.length >= 5` and show `UpgradeSheet`. | Must fix | [run] A7 |
| B2 | Name validation | A 1-character name ("A") is accepted. The document says 2–80 characters. | Easy validation test. | Add length rules for name (2–80), country (≤60), notes (≤1000), requirement (1–120). | Must fix (5 min) | [run] |
| B3 | Country field | Marked **required**; the document says **optional**. | Spec mismatch. | Make it optional. | Should fix | [run] A9 |
| B4 | Link field | "www.hec.gov.pk" is **rejected**; the document says "https://" is added automatically. The error text is also cut off ("e.g. https://examp…"). | Spec mismatch and annoying. | Prepend `https://` when the scheme is missing; shorten the error text. | Should fix | [run] A9 |
| B5 | Past deadline | Any past date is accepted silently. The document requires a "This date has passed. Save anyway?" confirmation. | Spec mismatch. | Show a confirm dialog on save. | Should fix | [code] |
| B6 | Delete | Confirmation works, but there is **no 5-second Undo** (document Section 18). | Spec mismatch. | Add an Undo snackbar for requirements at least. | Should fix | [run] |
| B7 | Ready to Submit | No warning when requirements are incomplete (document Section 7.1). | Spec mismatch. | Show a SnackBar warning. | Minor | [code] |
| B8 | Empty requirement add | Tapping + with an empty field does nothing and shows no message. | Minor UX. | Show an inline hint. | Minor | [run] |
| B9 | Reminder settings screen | The toggles and days are **not saved** (local `setState` only), and the reminder engine never reads them. | If Sir changes a value, leaves and comes back, it resets. | Persist them, or mark the screen as a Pro preview. | Should fix | [code] |
| B10 | Settings rows | Profile only shows a snackbar; **Sign out**, **Help**, **AI usage** do nothing; **Export** only shows a snackbar (CSV export is a *Free* feature in the document). | Dead buttons. | Either implement CSV export (feasible) or remove or relabel the rows. | Should fix | [code] |
| B11 | Unreachable screens | `TrialEndedScreen`, `Choose5Screen`, `SignInScreen`, `UpgradeSheet`, `PaymentSheet` and `ProUpgradeSheet` are **never opened** from anywhere. | The document lists them as part of the 20 screens. | Wire at least UpgradeSheet (B1); the others can be opened from Subscription & Billing as "preview". | Should fix | [code] |
| B12 | AI uses no LLM by default | Even after the C1 fix, the AI uses a **rule-based offline fallback** unless a Gemini key is compiled in with `--dart-define=GEMINI_API_KEY`. That would put the key **inside the APK**, while the document says the key stays on the server only. | Expect the question "Is this real AI?" | Present it honestly: "Gemini when configured, rule-based offline fallback otherwise; production design moves the key to a Cloud Function (`aiRequest`, already written in `functions/src`)." | Talking point | [code] |

**Verified working [run]:** onboarding (3 pages, Skip, shown only on first launch) · Load demo data · Add application · required-field validation · URL scheme validation · Edit · Delete with confirmation (cascades requirements) · status dropdown (Submitted updates counts and removes the app from urgent) · requirement add/toggle/rename/delete with confirmation · progress maths (4/6 = 67%, 4/7 = 57%, "No requirements yet" on cards) · urgent/upcoming grouping and days-left · overdue empty state · **data persists after app restart** (SQLite).

## 4. Missing requirements and inconsistencies vs Sir's document (v2.0)

The document describes **version 2.0 (Free + Dossier Pro)**. The app implements the **v1 core planner** properly and has **UI-only prototypes** of the Pro screens.

| Document area | In the app |
|---|---|
| Modules 1–3 (Applications, Requirements, Deadlines) | **Working**, with the gaps in Sections 1–3 above |
| Module 4 (AI) | Working code exists but is **not wired** (C1/C2); no server proxy, no monthly allowance |
| Module 5 (Settings) | Screen exists, mostly **static** |
| Module 6 (Account, Firebase, sync) | **Not implemented** (no Firebase packages) |
| Module 7 (Trial, Google Play Billing) | **Not implemented** in the app; Cloud Functions drafted in `functions/src/index.ts` (not deployed or connected) |
| Module 8 (Vault, PDF, calendar, CSV) | **Not implemented** (static mock-up) |
| Dark theme (Pro) | Not wired (`MaterialApp` has only `theme`) |
| Reorder requirements, To do / Done groups, attachment marker | Not implemented |
| Reminder rescheduling on time-zone change / plan change, 400-reminder cap | Not implemented (boot rescheduling is handled by the plugin receiver in the manifest) |
| 20 screens | ~13 reachable; 6 exist but are unreachable |
| Fonts bundled (Section 12.5) | Fetched at runtime |
| README "Deadlines reminder toggle", "6 filter chips" | Outdated; the current UI differs |

**Recommended framing for the viva (honest and defensible):**
"Phase 1, the core offline planner, is fully working and persisted in SQLite. Phase 2, Dossier Pro, is fully specified in the document. Its screens are prototyped in the app, and its server logic (trial, purchase verification, AI proxy) is drafted as Cloud Functions. Firebase and Play Billing integration needs a Play Console merchant account and a Firebase project, which is the next milestone."

## 5. Potential examiner objections (prepare for these)

1. "Paste a different requirement text into AI." This currently fails (C1).
2. "Add a sixth application. Where is the Free limit?" This currently fails (B1).
3. "This says Pro trial, 5 days left. Did you sign in? What is today's date?" (C3/C4)
4. "Show me the payment. Is this real Google Play Billing?" (C5)
5. "Where is Firebase? Show me `pubspec.yaml`." (C5)
6. "Your gap report says 100% done." (C6)
7. "Show me a reminder notification. Did the app ask for notification permission?" (C7)
8. "Turn off the internet. Does it still work?" Core features: yes (verified offline-first design). AI fallback: works offline after C1.
9. "Restart the app. Is the data still there?" **Yes** (verified).
10. "Why is the API key in the app? Your document says server-only." (B12)
11. "Why sqflite and not Hive or Firebase? Why Provider?"
12. "How is progress calculated, and what happens with 0 requirements?" (Computed, not stored; shows "No requirements yet".)
13. "Business model: why would a student pay Rs 499?"
14. "What does `isLocked` do? Where is Choose 5?" (B11)

## 6. Recommended fix plan (needs your approval; nothing has been changed yet)

**Tier 1, Must fix (about 2–3 hours, low risk; mostly wiring code that already exists):**
1. C1/C2: wire the real `ChecklistTab` and `PrioritySummaryTab` into the AI tab (keep the current pill design).
2. C3/C4: real date and greeting; replace the fake trial/profile/usage data with an honest **Free plan** state.
3. C5: replace fake "payment completed" and "trial started" messages with honest "Pro is coming / preview" messages.
4. C6: rewrite `docs/gap_report.md` honestly.
5. C7: request notification permission after onboarding.
6. C8 + U1: fix the overflow; fix requirement order.
7. B1 + B2: enforce the 5-active limit with the existing `UpgradeSheet`; name length 2–80.

**Tier 2, Should fix if time permits:** U2–U8, B3–B6, B9–B11 (Home "See all", Later colour, submitted section, back arrow on AI, bundled Poppins, app icon, link auto-https, past-date confirm, Undo, CSV export, wire Choose 5 / Trial ended as previews), and remove the 7 unused packages (smaller APK).

**Tier 3, Minor:** U9–U14, B7, B8.

**APK size (<25 MB):** **[untested]**, because I cannot build an APK here. Removing the unused `printing` / `pdf` / `file_picker` / `in_app_purchase` packages lowers the risk. Build with:
`flutter build apk --release --split-per-abi`
and install `app-arm64-v8a-release.apk`. Flutter apps of this size are typically around 10–20 MB per ABI; check the file size before submitting.
