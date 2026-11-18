# Dossier: Viva / Examiner Question Bank

Every technical answer was checked against the code on branch `claude/adoring-turing-zhov2p`.
Format: **Q** question → **A** answer (simple, correct) → **Dossier example** → **Follow-up** that Sir might ask next.
Short Roman Urdu lines are included where they help you say it naturally.

---

## 1. Problem, solution and target audience

**Q1. What problem does Dossier solve?**
A: Students applying to several scholarships lose track of deadlines, required documents and progress, because the information is spread across tabs, notes, WhatsApp, sheets and emails.
Dossier: one list of applications, each with a deadline, checklist, progress % and reminders.
Follow-up: *"Why not just use Google Sheets?"* Sheets has no deadline reminders, no per-scholarship checklist with automatic progress, no urgent/overdue view, and it is clumsy on a phone. Dossier is built around this one job and works offline.

**Q2. Is Dossier a scholarship search engine?**
A: No. It is a personal planner. The student adds scholarships by hand; it does not scrape websites. Discovery is listed as a future improvement.
Follow-up: *"Wouldn't scraping be more useful?"* Scraping is fragile, often against website terms, and data goes stale. The planning problem exists no matter where the student found the scholarship.

**Q3. Who are the target users?**
A: Master's/PhD applicants, final-year undergraduates, students applying to five or more scholarships, and students without a counsellor.
Dossier: the sample user Alina applies to Erasmus Mundus, DAAD and Stipendium Hungaricum.
Follow-up: *"How do you know they need it?"* Answer honestly: it comes from our own experience and peers' experience of the scattered-information problem. A formal user survey is a good next step; we have not run one.

**Q4. What is the unique value compared to a to-do app?**
A: The domain model: every requirement belongs to a scholarship with a deadline. So the app can compute progress per application, classify urgency (0–7, 8–21, 22+ days, overdue), schedule deadline-relative reminders, and rank priorities.

---

## 2. Features and user flows

**Q5. Show the first-time user flow.**
A: Splash → onboarding (3 pages, first launch only) → Home → Add Application → details → Save → Application Details.
Dossier: onboarding is shown once because `onboarding_completed` is saved in `shared_preferences`.

**Q6. How is progress calculated?**
A: completed ÷ total × 100, rounded. It is computed when needed and never stored, so it can't go out of sync. With 0 requirements the app shows "No requirements yet" instead of 0%.
Dossier: Erasmus 3 of 6 = 50%. Ticking CV gives 4/6 = 67%.
Follow-up: *"Why not store it in the database?"* Storing derived data creates update anomalies: you would have to update it on every tick, add and delete.

**Q7. What do the four statuses mean, and do they affect anything?**
A: Not Started, In Progress, Ready to Submit, Submitted. Submitted is special: it cancels the application's reminders, removes it from urgent/overdue, and it does not count toward the Free limit. Choosing Ready to Submit with incomplete requirements shows a warning but is allowed.

**Q8. How are deadlines classified?**
A: In whole calendar days in the phone's time zone: urgent 0–7, due soon 8–21, later 22+, overdue below 0 (unless Submitted). "Due today" for 0 days, "1 day left" for 1.
Dossier: `AppDateUtils.daysRemaining` normalises both dates to midnight before subtracting, so the time of day doesn't change the count.
Follow-up: *"Why normalise to midnight?"* Without it, at 11 PM a deadline "tomorrow" would be 0.04 days away and could show as today.

**Q9. Walk me through the AI checklist flow.**
A: Paste text → Generate → review/edit/remove items → choose the application → Save. Items that already exist (same name, ignoring case and spaces) are skipped, and the app tells you how many. Nothing is saved without confirmation.
Dossier: "Added 4 to Erasmus Mundus · 1 already existed and were skipped".

**Q10. What happens when a Free user adds a 6th active application?**
A: The Upgrade sheet opens instead of the form, with Try Pro, Manage my applications, or Not now. Re-opening a Submitted application at the limit is blocked the same way.
Dossier: `openAddApplication()` checks `activeScholarships.length >= ScholarshipProvider.freeActiveLimit` (5).
Follow-up: *"Can't a user bypass it by editing the database?"* On a rooted phone, yes, because Phase 1 is local only. In Phase 2 the limit matters for sync and Pro features, which are enforced on the server. Be honest that local-only checks are not tamper-proof.

**Q11. What does Undo do technically?**
A: Before deleting, the app reads the application and its requirements. Undo re-inserts the same rows with the same UUIDs and re-schedules reminders.
Dossier: `deleteScholarshipWithBackup()` and `restoreScholarship()`; 5-second SnackBar.

---

## 3. Business model

**Q12. Explain your business model.**
A: Freemium subscription. Free forever: 5 active applications, fixed reminders, 5 AI uses a month, CSV export. Dossier Pro: unlimited applications, custom reminders, 300 AI uses, backup and sync, document vault, PDF and calendar export, dark mode. Rs 499 a month or Rs 3,999 a year, with a 7-day trial and no card.
"Free plan akela bhi useful hai; Pro un ke liye hai jo bohat jagah apply karte hain."

**Q13. Why is the limit 5?**
A: Most students apply to a handful at a time, so 5 keeps Free genuinely useful. Heavy applicants (the people with the most deadlines to lose) hit it, and that is the value moment for Pro. Submitted ones don't count, so finishing applications frees slots.
Follow-up: *"Did you research this number?"* Honest answer: it is a design decision from the document, not market research. It is easy to tune later.

**Q14. Why yearly at Rs 3,999?**
A: About Rs 333 a month, a 33% saving. The yearly plan is shown first and selected by default because scholarship seasons last months, and yearly improves retention.
Follow-up: *"Google's fee?"* Google Play keeps a 15% service fee on subscriptions, so prices must cover that plus cloud and AI costs.

**Q15. Why no ads?**
A: The app holds personal academic plans; ads would reduce trust and clutter a calm, focused UI. Revenue comes only from subscriptions, and no data is sold.

**Q16. Why must payments go through Google Play?**
A: Google Play policy requires Play Billing for digital subscriptions sold in an app. It also means card details are entered in Google's sheet; Dossier never sees them.

**Q17. How does the trial avoid abuse?**
A: The server starts and ends it, using server time only. One trial per account and per phone (hashed email and phone ID kept even after account deletion). Changing the clock or reinstalling doesn't help, and the entitlement can be written only by Cloud Functions.
Follow-up: *"Is this implemented?"* The rules are designed and the Cloud Functions are drafted in `functions/src/index.ts`. They are not deployed or connected yet; that is Phase 2.

**Q18. What are your costs?**
A: Google Play developer account, Firebase/Cloud usage, AI API calls (capped by the monthly allowance), Play's service fee, and development time.

---

## 4. UI/UX decisions

**Q19. Why this colour scheme?**
A: Deep blue for trust and education, teal for progress and AI, gold only for Pro, and red/amber/green for urgent/soon/done, because people already understand those. Colour always comes with a text label for colour-blind users.

**Q20. Why bottom navigation with four tabs?**
A: The four top-level destinations are used constantly, and bottom tabs are reachable with a thumb. Any application is two taps from Home. Detail screens open on top with a back arrow.

**Q21. Why is the font bundled?**
A: Earlier the font was downloaded at runtime by `google_fonts`, so offline it fell back to Roboto and some widgets mixed fonts. Now Poppins TTFs are in `assets/fonts` and registered in `pubspec.yaml`, so the app looks the same offline.

**Q22. How do you handle empty states?**
A: Home shows "No scholarship applications yet" with a Load Demo button; Deadlines shows "No applications yet…"; the checklist shows "No requirements yet"; AI shows "Ready to generate".

---

## 5. Architecture and technology stack

**Q23. Describe the architecture.**
A: Layered, with feature folders: Presentation (Flutter screens) → State (Provider `ChangeNotifier`s) → Data (repositories → SQLite via `sqflite`). Services sit beside these: notifications, AI, settings, export, URL.
Dossier: `lib/features/*`, `lib/providers/*`, `lib/data/repositories/*`, `lib/services/*`.
Follow-up: *"Is it MVVM?"* It is close: providers act as view-models (screens watch them, providers call repositories). "MVVM-style with Provider" is accurate.

**Q24. Why Flutter?**
A: One Dart codebase for Android now and iOS later, fast UI development with hot reload, Material 3 built in, and good plugins for SQLite and notifications.
Follow-up: *"Flutter vs native Kotlin?"* Native gives deeper platform access, but we would need a second app for iOS. Our needs (forms, lists, local DB, notifications) are well covered by Flutter.

**Q25. Why Provider and not Bloc/Riverpod?**
A: The state is simple (lists, counts, loading flags). Provider is lightweight, officially recommended for this scale, and easy to explain and test.
Follow-up: *"When would you switch?"* With complex async flows and sync in Phase 2, Riverpod or Bloc could give better testability and less boilerplate.

**Q26. How does a screen update when data changes?**
A: The provider changes its list, then calls `notifyListeners()`. Widgets using `context.watch<…>()` rebuild. For example, ticking a requirement calls `refreshProgressFor()` and the Home card updates.

**Q27. What packages do you use?**
A: provider, sqflite, path, path_provider, flutter_local_notifications, timezone, intl, http, url_launcher, shared_preferences, uuid, flutter_secure_storage (Phase 2 entitlement cache), share_plus (CSV). Dev: flutter_test, sqflite_common_ffi.
Follow-up: *"Why remove pdf/printing/in_app_purchase?"* They weren't used yet; unused native libraries only increase APK size. They come back when Phase 2 features are built.

---

## 6. Database and data persistence

**Q28. Why SQLite and not SharedPreferences, Hive or Firebase?**
A: The data is relational (one scholarship has many requirements) and needs queries, ordering and cascade delete. SharedPreferences is for small key-value settings only. Firebase needs internet and an account, and we wanted offline-first with no account.
Dossier: settings like onboarding and the reminders switch are in SharedPreferences; applications are in SQLite.

**Q29. What are the tables and the relationship?**
A: `scholarships` (id UUID PK, name, country, deadline, link, status, notes, remindersOn, reminderOffsets, reminderTime, isLocked, createdAt, updatedAt, deletedAt) and `requirements` (id, scholarshipId FK, title, isDone, sortOrder, documentId, timestamps). One-to-many with `ON DELETE CASCADE`. Version 2 also creates `documents` and `settings` tables for Phase 2.

**Q30. Why UUIDs instead of auto-increment IDs?**
A: Items created offline on different phones must never clash when synced later (Phase 2). UUIDs are globally unique without a server.

**Q31. How do you handle database upgrades?**
A: `openDatabase(version: 2, onCreate, onUpgrade)`. `onUpgrade` migrates version 1 data in place into the new tables (new columns with defaults), so no data is lost.

**Q32. Does the cascade delete actually work in SQLite?**
A: Only if foreign keys are enabled, and SQLite has them off by default. `DatabaseMigrations.onConfigure` runs `PRAGMA foreign_keys = ON`. The repository also deletes requirements inside a transaction. A unit test checks the cascade.

**Q33. How is the requirement order kept?**
A: Each requirement has `sortOrder`; the query orders by `sortOrder, createdAt, rowid`. New items get max + 1.
Follow-up (honest): before the fix, demo items had sortOrder 0 and appeared in random UUID order. I found and fixed this during testing.

---

## 7. Offline functionality

**Q34. What works offline?**
A: Everything in Phase 1: adding and editing, checklist, progress, deadlines, reminders, Settings, CSV export, and AI in offline mode. Only opening a link (browser) and Gemini need internet.

**Q35. How does AI work offline?**
A: If no API key is configured, or the request fails or times out (15 s), `AiService` uses rule-based logic. The checklist splits text on commas, semicolons, "and" and new lines, strips lead-ins like "Applicants must provide a valid", and expands "two recommendation letters" into 1 and 2. Priority sorts by days left, then progress. The summary is built from counts.
Follow-up: *"So is it really AI?"* With a key, it calls Google Gemini (`gemini-2.5-flash` by default) and asks for strict JSON. Without one, it is a deterministic fallback, and the UI says "offline mode". I don't present the fallback as an LLM.

**Q36. Do reminders need internet?**
A: No. They are local notifications scheduled on the phone with `zonedSchedule`, and they fire even if the app is closed.

---

## 8. Notifications

**Q37. How are reminders scheduled?**
A: When an application is saved, `NotificationService.syncRemindersForScholarship` first cancels its old reminders, then schedules 7 and 2 days before the deadline at 9:00 AM. Times already in the past are skipped. It uses exact alarms, falling back to inexact if exact alarms are not allowed.

**Q38. How do you cancel the right notifications?**
A: Each notification ID is derived from the scholarship ID and the offset, so the app can recompute and cancel exactly those IDs.

**Q39. What about phone restart and Android 13 permission?**
A: The manifest registers the plugin's boot receiver, so scheduled reminders survive a reboot. On Android 13+, the app requests `POST_NOTIFICATIONS` after onboarding.
Follow-up (honest): time-zone-change rescheduling and the 400-reminder cap from the document are not implemented yet.

---

## 9. Validation and error handling

**Q40. What validation rules exist?**
A: Name 2–80 characters (required). Country optional, up to 60. Notes up to 1,000. Link optional, http/https; "https://" is added if missing. Requirement 1–120 characters, max 50 per application. A past deadline needs confirmation; a duplicate name + deadline shows a warning.
Dossier: `Validators.validateName`, `normalizeUrl`; tests in `test/unit/phase1_rules_test.dart`.

**Q41. How do you prevent double saves?**
A: The form has an `_isSaving` flag; the button shows loading and ignores repeated taps. The AI save has `_isSavingToDb`.

**Q42. What happens if a database operation fails?**
A: Providers catch the exception, set an error message and rethrow to the screen, which shows a red SnackBar ("Failed to save application: …"). Splash errors still navigate to Home.

---

## 10. Testing

**Q43. How did you test the app?**
A: There are 34 automated tests: unit tests for date rules and reminder times, validators, SQLite CRUD with cascade delete (in-memory DB via `sqflite_common_ffi`), AI extraction and priority, duplicate skip and CSV escaping, plus widget tests for core widgets. `flutter analyze` reports 0 issues. I also tested every user flow manually end to end, including restart persistence.

**Q44. Did testing find real bugs?**
A: Yes, for example:
- the AI Assistant screen in use was a static mock-up; the real implementation existed but was not wired in;
- priority crashed because UUID IDs were cast to `int`;
- the extractor dropped "CV" because of a length filter;
- the Details screen overflowed by 83 px;
- the Deadlines filter chips did not filter;
- the Free limit was not enforced.
All are fixed and covered where possible.
"Testing ka faida yahi hai: in mein se kuch bugs demo mein foran nazar aa jate."

**Q45. What isn't tested automatically?**
A: Real notification delivery, the share sheet and opening links on a device. Those were checked manually or need a device test.

---

## 11. Security and privacy

**Q46. Where is user data stored and who can see it?**
A: Only on the phone in the app's private SQLite database. There is no account, no server, no analytics and no ads in Phase 1.

**Q47. Is the Gemini API key safe?**
A: If one is compiled in with `--dart-define`, it can be extracted from the APK, so it is not safe for production. That is why the document's design moves AI behind a Cloud Function (`aiRequest`) with the key in Secret Manager. The demo build uses offline mode, so no key ships.

**Q48. What data goes to the AI?**
A: Only the pasted requirement text, or each application's name, days left and progress. Never notes, links or documents.

**Q49. What permissions does the app use?**
A: Internet, post notifications, schedule/use exact alarm, receive boot completed, vibrate. No contacts, location or camera.

**Q50. How will Phase 2 stop someone unlocking Pro by editing the app?**
A: The entitlement lives in a server-only Firestore collection (rules: `allow write: if false` for clients). Backup, vault and AI are checked on the server, and App Check blocks fake clients. A local cache only keeps Pro working offline until its end time.

---

## 12. Limitations and future improvements

**Q51. What are the current limitations?**
A: Phase 2 is not integrated (no account, sync, trial, billing, vault, PDF or calendar, dark mode). Requirements can't be reordered. Reminders are not rescheduled on a time-zone change. The Free limit is enforced only locally.

**Q52. What's next?**
A: Firebase sign-in and sync, then the server trial and Google Play Billing tested with license testers. Then the document's list: scholarship discovery, iOS, home-screen widget, shared view for counsellors, essay helper, Urdu, and student discount codes.

**Q53. Why didn't you build Phase 2 already?**
A: It needs a Firebase project, a Google Play Console merchant account and a published test track before purchases can be tested. A fake purchase would be misleading, so the Pro screens are clearly labelled previews.
"Main ne jaan boojh kar fake payment nahi dikhaya; preview label honest hai."

---

## 13. Alternatives and design decisions

**Q54. Why offline-first instead of cloud-first?**
A: Reminders and planning must work without internet (students are often on poor connections), no account means zero friction to start, and privacy is better. The cloud is added as an optional Pro backup.

**Q55. Why compute urgency on the phone and not store it?**
A: Urgency changes every day; a stored value would be wrong tomorrow. It is a pure function of the deadline and today's date.

**Q56. Why a fixed 9:00 AM reminder on Free?**
A: It is simple, predictable and avoids night-time notifications. Custom days and time are a Pro convenience.

**Q57. Why one "Analyze" button for priority and summary?**
A: Both use the same input (names, days left, progress), so one request is cheaper and counts as one AI use (document Section 14).

---

## 14. Development process and use of AI tools

**Q58. How did you develop the app?**
A: Document first (requirements, flows, screens, rules), then the core planner (data model → repositories → providers → screens), then AI, then Settings and the Pro designs. Test and fix after each part.

**Q59. Did you use AI tools while developing?**
Answer truthfully, based on what you actually did. A safe, honest framing if you used them:
"Yes, as an assistant: for code suggestions, reviewing, and finding bugs. Every change was run, tested and understood by me. For example, an AI-assisted audit found that the AI screen was a mock-up and the Free limit wasn't enforced. I fixed those and added tests."
Follow-up: *"Then what is your contribution?"* The idea, the requirements document, the design decisions (offline-first, freemium rules, flows), and verifying and testing that everything works. Be ready to explain any file Sir opens.

**Q60. Sir opens `docs/gap_report.md`.**
A: It is an honest status table: Phase 1 implemented and tested; Phase 2 designed, with preview screens and drafted server code. (An older version overstated completion; it was corrected.)


## 15. FYP Idea Breakdown points (Sir's template)

**Q61. What is your domain, sub-domain and industry?**
A: Domain: Mobile (Android, Flutter). Sub-domain: Generative AI / NLP; an LLM extracts checklists from text, ranks priorities and writes summaries. Industry: Education (EdTech, scholarship applications).
Follow-up: *"Is AI the core, or just a feature?"* The core is the planner (tracking deadlines and requirements). AI is the assistive layer that saves typing and helps prioritise. The app is fully useful without it, which is why it also works offline.

**Q62. Who are the actors?**
A: The primary actor is the Student (Free user, or Pro subscriber in Phase 2). System actors: the AI service (Gemini), Google Play Billing (Phase 2) and Android's notification scheduler. There is no admin, because an admin panel is out of scope in the document.
Follow-up: *"Why no admin?"* There is no shared content to moderate. Each student only manages their own private data.

**Q63. What is your selling mode?**
A: Freemium subscription sold through Google Play: Free forever; Pro at Rs 499 a month or Rs 3,999 a year, with a no-card 7-day trial. No ads, no data selling.

**Q64. Define your scope boundary.**
A: In scope: application management, checklist, deadlines and reminders, the 3 AI features, Settings (Phase 1, working); accounts and sync, Pro trial and billing, vault and export (Phase 2). Out of scope: scraping or a scholarship database, admin panel or web version, a general chatbot, payments outside Google Play, iOS release for now.

**Q65. Explain your tech stack as frontend, backend, database and middleware.**
A:
- Frontend: Flutter/Dart with Provider.
- Backend: none in Phase 1 (on-device logic); Phase 2 uses Firebase Cloud Functions (Node.js 20, TypeScript).
- Database: SQLite (sqflite) plus shared_preferences; Phase 2 adds Firestore and Firebase Storage.
- Middleware: the repository layer, the http client for AI, and the notification plugin; Phase 2 adds Firebase SDKs and the Play Billing Library.
Follow-up: *"Where is the middleware exactly?"* Between the UI and data: providers call repositories, so screens never write SQL. Between the app and external services: AiService wraps the Gemini REST call, and NotificationService wraps the Android alarm and notification APIs.

**Q66. Which third-party APIs do you use?**
A: Google Gemini (generateContent REST API, optional with a key), plus Android OS services (notifications, alarms, share sheet, browser). Phase 2: Firebase Auth/Firestore/Storage/FCM, Google Play Billing, Play Developer API and Real-time Developer Notifications.

**Q67. Are you using an LLM, RAG, LLaMA, LangChain or a dataset?**
A: An LLM (Google Gemini 2.5 Flash) with prompt engineering and strict JSON output, plus a rule-based NLP fallback. No RAG, because there is no knowledge base to retrieve from; the input is the student's own pasted text. No LLaMA, because self-hosting needs a GPU server and costs more. No LangChain, because each task is a single prompt with no chains or agents. No dataset, because we use a pre-trained model and do not train anything.
Follow-up: *"How do you stop the LLM hallucinating items?"* The prompt says to extract only items from the given text, as a JSON array of short names (max 30, each under 60 characters). The app parses and validates the JSON. And the student always reviews and edits the list before saving.
Follow-up: *"When would RAG make sense?"* In the future "scholarship discovery" feature: retrieving matching scholarships from a curated database before the LLM explains them.

**Q68. What are your major constraints?**
A: Internet for the LLM (handled with the offline fallback). Google Play Billing being mandatory, with its 15% fee. Android 13 notification permission and Android 12 exact-alarm limits. App size under 25 MB. AI cost and rate limits (handled with the monthly allowance). Privacy. And Phase 2 needing a Firebase project, a Play Console merchant account, and semester time.

**Q69. What related systems exist, and why build Dossier?**
A: Spreadsheets, to-do/notes apps (Google Tasks, Todoist, Notion), scholarship portals (HEC scholarship pages, DAAD database, ScholarshipPortal), and Common App. Portals help you find scholarships but don't track your applications. To-do apps lack the scholarship model (per-application progress, urgency, requirement extraction). Common App only covers its member US colleges. Dossier is a planner for any scholarship from any source, offline, with an AI checklist.
Follow-up: *"Couldn't Notion do this with a template?"* Partly, but it has no deadline-relative reminders per application, no automatic urgency groups, and no AI extraction tuned for requirements. It also needs an account and internet to sync.

---

## Quick-recall facts

| Item | Value |
|---|---|
| Free limit | 5 active (Submitted don't count) |
| Reminders (Free) | 7 and 2 days before, 9:00 AM |
| Urgency | 0–7 urgent · 8–21 due soon · 22+ later · <0 overdue |
| Prices | Rs 499 / month · Rs 3,999 / year (≈ Rs 333/month, save 33%) |
| Trial | 7 days = 168 h, no card, once per account and phone |
| AI allowance (design) | Free 5 / Pro 300 per month; resets on the 1st (UTC) |
| Tests | 34 passing · `flutter analyze` 0 issues |
| DB | SQLite, version 2, UUIDs, FK cascade |
| Flutter / Dart | 3.38 / 3.10 |
| Breakdown | Mobile · GenAI/NLP · Education · Student actor · Freemium via Google Play |
