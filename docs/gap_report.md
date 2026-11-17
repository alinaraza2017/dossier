# Dossier: Implementation Status vs Project Document (v2.0)

**Reference:** `Dossier_Project_Document.docx` (Version 2.0: Free + Dossier Pro)
**Updated:** 17 Nov 2026
**Summary:** Phase 1 (the core offline planner, Free plan) is implemented and tested.
Phase 2 (Dossier Pro: accounts, cloud sync, server trial, Google Play Billing,
vault, PDF/calendar export, dark mode) is specified in the document. Its screens
are prototyped as design previews, and its server logic is drafted in
`functions/src/index.ts`. It is **not integrated** into this build.

---

## Phase 1: implemented (works offline, no account)

| Area | Document section | Status |
|---|---|---|
| Splash, 3-page onboarding (first launch only) | §8 screens 1–2 | Done |
| Home: greeting, today's date, plan card, Active/Urgent/Submitted counts, upcoming and submitted lists | §8 screen 3 | Done |
| Add / edit / delete application, 4 statuses, field rules (name 2–80, country ≤60 optional, notes ≤1000, auto `https://`, past-date confirmation, duplicate warning) | §7.1 | Done |
| Delete with confirmation + 5-second Undo (applications and requirements) | §18 | Done |
| Free limit: 5 active applications, Upgrade sheet at the limit (adding or re-opening a Submitted one) | §7.1, §18, Flow 10 | Done |
| Requirements checklist: add, rename, tick, delete, progress (done ÷ total, "No requirements yet" when empty), ≤120 chars, ≤50 items | §7.2 | Done (reorder: not yet) |
| Deadlines: Urgent 0–7, Due soon 8–21, Later 22+, Overdue, Submitted; working filter chips | §7.3 | Done |
| Local reminders 7 and 2 days before at 9:00 AM; cancelled on delete or Submitted; rescheduled on edit; global on/off in Settings; Android 13+ permission request; boot receiver | §7.3 | Done (time-zone-change rescheduling: not yet) |
| AI Assistant: checklist generator (review, edit, skip duplicates, add to an application), priority order + progress summary in one "Analyze" | §7.4, §14 | Done: Gemini when an API key is configured, otherwise an offline rule-based engine |
| Settings: plan card, reminders, AI info, CSV export (Free), clear data (type DELETE), subscription and Pro previews, help and privacy | §17 | Done for Free-plan items |
| SQLite with versioned migration, UUID ids, soft-delete columns | §21.4 | Done |
| Bundled Poppins font, Calm Academic colours, 4-tab navigation | §11–12 | Done |
| Unit and widget tests (date rules, validators, DB CRUD + cascade, progress, AI fallback, duplicate skip, CSV) | §21.7 | 30 tests passing |

## Phase 2: designed, not integrated

| Area | Document section | Current state |
|---|---|---|
| Firebase Auth (anonymous, Google, email), account linking | §7.6 | Sign-in screen is a design preview |
| Cloud backup and sync (Firestore) | §7.6 | Not implemented; `firestore.rules` drafted |
| 7-day server trial, trial notifications, Trial ended, Choose 5 | §16 | Screens are previews; `startTrial` / `getEntitlement` / `dailyJobs` drafted |
| Google Play Billing, purchase verification, RTDN states | §16.4–16.6 | Paywall and payment sheet are previews; `verifyPurchase` / `playNotifications` drafted |
| AI server proxy with monthly allowance (5 / 300) | §14.3 | `aiRequest` drafted; the app calls Gemini directly or runs offline |
| Document vault, PDF report, calendar export | §7.8 | Vault screen is a preview |
| Dark theme, custom reminder days and time | §12.3, §7.3 | Shown as locked PRO options |

**Why split this way:** Phase 2 needs a Firebase project, a Google Play Console
merchant account and a published app track before billing can be tested. The
Free plan is fully useful on its own, as the document requires.
