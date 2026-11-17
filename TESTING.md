# Dossier — Testing Guide & Verification Checklist

This document details the automated tests, commands, test suites, and manual acceptance testing steps for **Dossier — Scholarship Application Planner**.

---

## 1. Automated Testing Commands

Execute all tests from the project root:

```bash
# Run all tests
flutter test

# Run unit tests only
flutter test test/unit/app_logic_test.dart

# Run database persistence and SQLite cascade tests
flutter test test/unit/database_test.dart

# Run widget tests
flutter test test/widget/core_widgets_test.dart
```

### Static Analysis Command:
```bash
flutter analyze
```
*Current result: 0 errors, 0 warnings (Clean).*

### Code Formatting:
```bash
dart format lib test
```

---

## 2. Test Suite Breakdown

### Suite 1: `test/unit/app_logic_test.dart`
- **Test 1:** Deadline Today Classification — Verifies that a deadline today calculates as 0 days remaining, is marked `Urgent` (not overdue), and displays `"Due today"`.
- **Test 2:** Urgent Deadline Classification — Verifies that 1–7 days remaining calculates as `Urgent` (e.g. `"5 days left"`).
- **Test 3:** Due Soon Classification — Verifies that 8–21 days remaining calculates as `Due Soon` (e.g. `"15 days left"`).
- **Test 4:** Later Deadline Classification — Verifies that 22+ days remaining calculates as `Later`.
- **Test 5:** Overdue Classification — Verifies that dates prior to today with non-submitted status calculate as `Overdue` (e.g. `"7 days overdue"`).
- **Test 6:** Submitted Classification Precedence — Verifies that applications marked `Submitted` are excluded from `Urgent` or `Overdue` classifications regardless of date.
- **Test 7:** Reminder Time Scheduling — Verifies 7-day and 2-day offsets calculate scheduled times at 9:00 AM local time, and that past dates return null.
- **Test 8:** Required Fields Validator — Verifies whitespace-only strings and empty strings are rejected.
- **Test 9:** URL Validator — Verifies optional nulls are accepted, valid `http://` and `https://` URLs pass, and invalid schemes or formats are flagged.
- **Test 10:** AI Checklist Rule-Based Extraction — Verifies parsing of comma-separated items and numeric splits (e.g., `"two recommendation letters"` into `"Recommendation Letter 1"` and `"Recommendation Letter 2"`).
- **Test 11:** AI Priority Algorithm — Verifies nearest deadlines with lower progress are ranked first.
- **Test 12:** AI Progress Summary Synthesis — Verifies multi-application progress summary generation.

### Suite 2: `test/unit/database_test.dart`
- **Test 1:** Scholarship CRUD — Insert, query all, update status, and delete records via `sqflite_common_ffi` in-memory database.
- **Test 2:** Requirements Cascade Deletion — Verifies inserting multiple requirements, toggling completion, aggregating progress (3 of 6), and verifies that deleting a scholarship automatically removes child requirements.
- **Test 3:** Zero-Requirements Progress Handling — Verifies that scholarships with 0 requirements do not cause division-by-zero errors.

### Suite 3: `test/widget/core_widgets_test.dart`
- **Test 1:** `AppButton` — Verifies button rendering and tap callbacks.
- **Test 2:** `EmptyState` — Verifies empty state illustration, title, description, and action button.
- **Test 3:** `StatusChip` — Verifies urgency chips and workflow status chips.
- **Test 4:** `ProgressIndicatorCard` — Verifies progress percentage calculations and text.
- **Test 5:** `ConfirmationDialog` — Verifies modal dialog rendering and confirm/cancel returns.

---

## 3. Manual Acceptance Testing Procedure

Follow these steps for a complete manual walk-through during an evaluation or demonstration:

### Step 1: First-Time Launch & Onboarding
1. Open the app on an Android device or emulator.
2. Confirm the Splash Screen displays the **Dossier** branding and tagline.
3. Swipe through the 3 Onboarding slides (*All Scholarships in One Place*, *Track Every Requirement*, *Stay Ahead of Deadlines*).
4. Tap **"Get Started"** to navigate to the Home Dashboard.
5. Close and reopen the app: verify Onboarding is skipped on subsequent launches.

### Step 2: Creating a Scholarship Application
1. On the Home Dashboard, tap the Floating Action Button (**"Add Application"**).
2. Attempt to save with empty fields: verify that validation error messages appear.
3. Enter:
   - **Name:** *Erasmus Mundus*
   - **Country:** *Europe*
   - **Deadline:** Select a date 5 days in the future.
   - **Link:** `https://erasmus-plus.ec.europa.eu`
   - **Status:** *In Progress*
   - **Reminders:** Enabled
4. Tap **"Save Application"**. Confirm a success snackbar appears and the application card is rendered on the Dashboard.

### Step 3: Requirements Management
1. Tap the newly created *Erasmus Mundus* card to open **Application Details**.
2. Tap **"View Requirements Checklist"**.
3. In the input field, enter *"Academic Transcript"* and tap **Add (+)**.
4. Add *"Passport"* and *"IELTS Certificate"*.
5. Tap the checkbox for *"Passport"*:
   - Confirm it gets a teal checkmark.
   - Confirm the text is displayed in muted grey with strikethrough.
   - Confirm the progress card updates immediately to `1 of 3 (33%)`.
6. Return to Home Dashboard: confirm the card also shows `1 of 3 (33%)`.

### Step 4: AI Checklist Generation
1. In the Requirements screen, tap **"Generate Checklist with AI"**.
2. Paste the following text into the prompt box:
   > *"Applicants must provide a valid passport, academic transcript, IELTS certificate, CV, motivation letter and two recommendation letters."*
3. Tap **"Generate Checklist"**.
4. Review the extracted items. Edit or remove an item if desired.
5. Tap **"Save Checklist to Scholarship"**.
6. Verify all items are saved directly into the scholarship checklist.

### Step 5: AI Priority and Summary
1. Tap the **AI Assistant** tab in the bottom navigation bar.
2. Select the **Priority & Summary** tab.
3. Tap **"Which Application Should I Work On First?"**:
   - Verify the ranked priority list appears with concise explanations based on deadline proximity and remaining requirements.
4. Tap **"Summarize My Progress"**:
   - Verify that a 2–3 sentence overview of active applications is generated.

### Step 6: Deadlines & Reminder Synchronization
1. Tap the **Deadlines** tab in the bottom navigation bar.
2. Verify filter chips (*All*, *Urgent*, *Due Soon*, *Later*, *Overdue*, *Submitted*):
   - Tap **"Urgent"**: only applications within 0–7 days are shown.
   - Tap **"All"**: all applications appear sorted chronologically.
3. Toggle the **Reminders** switch on a card: verify the setting updates immediately.

### Step 7: Application Completion & Deletion
1. Open the application details.
2. Change status to **"Submitted"**:
   - Verify the chip turns green.
   - Verify it is excluded from Urgent/Overdue counts on Home and Deadlines.
3. Tap the **Delete** icon:
   - Confirm the warning dialog appears.
   - Confirm deletion: verify the application and its requirements are removed from SQLite.
