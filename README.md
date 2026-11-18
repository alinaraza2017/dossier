# Dossier — Scholarship Application Planner

> "Plan your scholarships. Track your applications. Never miss a deadline."

**Course:** Software Construction and Development (FA23-BSE-015)  
**Target Platform:** Flutter Mobile Application (Android-first)  
**Status:** Phase 1 (core offline planner, Free plan) implemented; Phase 2 (Dossier Pro) designed with preview screens. See `docs/gap_report.md`.  
**Architecture:** Feature-driven MVVM with Provider, Local SQLite (`sqflite`), Local Notifications (`flutter_local_notifications`), and Calm Academic Design System.

---

## 1. Project Title and Purpose

**Dossier** is a personal mobile scholarship application planner designed to help undergraduate, master's, and PhD students systematically organize scholarship applications in one unified workspace.

Students often apply to several prestigious opportunities concurrently (e.g., Erasmus Mundus, DAAD, Stipendium Hungaricum, Fulbright). Keeping track of scattered document checklists, distinct submission portals, and approaching deadlines across emails, spreadsheets, and chat messages leads to missed deadlines and incomplete packages.

**Dossier solves this by providing:**
- A single place for all scholarship details, links, notes, and deadlines.
- Requirement tracking with real-time percentage progress calculations.
- Intelligent deadline categorization (Urgent, Due Soon, Later, Overdue, Submitted).
- Local reminders delivered 7 days and 2 days prior to deadlines at 9:00 AM without requiring an active internet connection.
- Focused, 3-feature AI Assistance for requirement extraction, workflow prioritization, and progress summaries.

---

## 2. Core Features (MVP)

1. **Splash & Onboarding:**
   - Calm Academic branding with app tagline.
   - Three guided introduction slides explaining the value proposition.
   - Skip and completion states persisted in local settings.
2. **Home Dashboard:**
   - 3 live summary cards: Total Applications, Urgent Applications (0–7 days), and Upcoming Deadlines (within 21 days).
   - Chronologically sorted active scholarships and submitted applications.
   - Visual progress bars and days-left status chips.
   - Prominent Floating Action Button for adding applications.
3. **Application Management (Add / Edit / Details):**
   - Full CRUD support stored in local SQLite database.
   - Native date picker with past/future date handling.
   - Validated optional application links with external browser launching.
   - 4 application lifecycle workflow states: *Not Started*, *In Progress*, *Ready to Submit*, *Submitted*.
   - Safe deletion with cascading requirement removal.
4. **Requirements Checklist:**
   - Document and task checklists for every individual scholarship.
   - Immediate toggle saving with visual strikethrough and progress recalculation.
   - Inline creation, rename dialogs, and deletion confirmations.
   - Integrated "Generate Checklist with AI" shortcut.
5. **Deadlines Overview:**
   - Working filter chips: *All*, *Urgent* (0–7 days), *Due soon* (8–21), *Later* (22+), *Overdue*, *Submitted*.
   - Calendar date calculations normalized to midnight.
6. **Local Deadline Reminders:**
   - Automated scheduling for 7 days and 2 days before deadline at 9:00 AM local time.
   - Deterministic notification IDs (`scholarshipId * 10 + offset`).
   - Automatically cancels when deadlines change, reminders are disabled, or scholarships are submitted/deleted.
7. **AI Assistant (3 Focused Features):**
   - **Checklist Generator:** Turns pasted requirements text into clean, editable checklist items.
   - **Application Priority:** Analyzes active deadlines and remaining tasks to recommend which application to work on first.
   - **Progress Summary:** Generates an encouraging, concise 2–3 sentence overview of overall application health.
   - **Offline Deterministic Fallbacks:** All 3 features work completely offline via built-in deterministic algorithms if an API key is absent or internet is unavailable.

---

## 3. Technology Stack

- **Framework:** Flutter 3.38 (Dart 3.10)
- **UI Components:** Material 3 with customized Calm Academic theme
- **Typography:** Poppins (bundled in `assets/fonts`, works offline)
- **State Management:** `provider` (ChangeNotifier)
- **Local Persistence:** SQLite via `sqflite`
- **Notifications:** `flutter_local_notifications` and `timezone`
- **Network / AI:** `http`
- **External URL Launching:** `url_launcher`
- **Testing:** `flutter_test`, `sqflite_common_ffi`

---

## 4. Calm Academic Design System

| Role | Hex Code | Purpose |
|---|---|---|
| Primary Blue | `#1F4E79` | App bar accents, primary buttons, active tabs |
| Secondary Teal | `#2A9D8F` | Progress bars, completed checkmarks, AI accents |
| Background | `#F5F7FA` | Soft grey-blue screen background |
| Card & Surface | `#FFFFFF` | Cards, input fields, navigation bar |
| Main Text | `#1C2733` | Headings and primary copy |
| Secondary Text | `#5F6B7A` | Captions, hints, subtitles |
| Border | `#DDE3EA` | Subtle card borders, dividers, empty tracks |
| Light Blue | `#E7EEF6` | Selected chip backgrounds, highlights |
| Success Green | `#2E9E5B` | Submitted applications, complete state |
| Warning Amber | `#E8A33D` | Due soon status chip |
| Error Red | `#D64545` | Urgent, overdue, and destructive confirmations |

---

## 5. Project Folder Architecture

```text
lib/
├── main.dart                          # Application entry point
├── app/
│   ├── app.dart                       # MultiProvider and MaterialApp root
│   ├── app_routes.dart                # Named route generator
│   └── app_theme.dart                 # Calm Academic ThemeData & Poppins styling
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Centralized brand and chip colors
│   │   └── app_strings.dart           # UI text constants
│   ├── utils/
│   │   ├── date_utils.dart            # Calendar normalization, classification & reminders
│   │   └── validators.dart            # Form, URL, and required field validation
│   └── widgets/
│       ├── app_button.dart            # Reusable primary/secondary/text buttons
│       ├── app_text_field.dart        # Form fields with top-aligned labels
│       ├── confirmation_dialog.dart   # Destructive action confirmation dialogs
│       ├── empty_state.dart           # Standard empty state illustrations and CTAs
│       ├── error_view.dart            # Error boundary view with retry action
│       ├── loading_view.dart          # Centered progress view
│       ├── progress_indicator_card.dart# Application progress card
│       └── status_chip.dart           # Urgency and lifecycle status chips
├── data/
│   ├── database/
│   │   ├── app_database.dart          # SQLite singleton with test injection
│   │   └── database_migrations.dart  # Versioned table schemas & PRAGMA foreign_keys
│   ├── models/
│   │   ├── requirement.dart           # Requirement entity with copyWith & map serialization
│   │   └── scholarship.dart           # Scholarship entity with date helpers
│   └── repositories/
│       ├── requirement_repository.dart# SQLite CRUD for requirements and progress aggregation
│       └── scholarship_repository.dart# SQLite CRUD for scholarships with cascading deletes
├── features/
│   ├── ai_assistant/
│   │   ├── ai_assistant_screen.dart   # Dual-tab container with API key settings dialog
│   │   ├── checklist_tab.dart         # Requirement extraction and safe save flow
│   │   └── priority_summary_tab.dart  # Work-on-first ranking & progress summary
│   ├── applications/
│   │   ├── add_application_screen.dart# Unified form for creating and editing applications
│   │   ├── application_details_screen.dart # Information card, links, and preview
│   │   └── widgets/
│   │       ├── application_form.dart
│   │       └── application_status_selector.dart
│   ├── deadlines/
│   │   └── deadlines_screen.dart      # Filter chips and deadline reminder toggle
│   ├── home/
│   │   ├── home_screen.dart           # Dashboard, 3 metrics cards, sample data loader
│   │   └── widgets/
│   │       ├── scholarship_card.dart
│   │       ├── summary_card.dart
│   │       └── upcoming_deadline_card.dart
│   ├── navigation/
│   │   └── main_navigation.dart       # Persistent IndexedStack bottom navigation
│   ├── onboarding/
│   │   ├── onboarding_screen.dart     # 3-slide introduction with page indicators
│   │   └── splash_screen.dart         # Startup initialization and navigation gate
│   └── requirements/
│       ├── requirements_screen.dart   # Interactive checklist with inline addition
│       └── widgets/
│           └── requirement_item.dart
├── providers/
│   ├── ai_provider.dart               # State for all 3 AI features
│   ├── deadline_provider.dart         # Filter selection and chronological sorting
│   ├── requirement_provider.dart      # Requirement checklist management
│   └── scholarship_provider.dart      # Scholarship state, metrics & reminder syncing
└── services/
    ├── ai_service.dart                # Configurable Gemini/OpenAI client & deterministic fallbacks
    ├── local_settings_service.dart    # SharedPreferences for onboarding & AI settings
    ├── notification_service.dart      # flutter_local_notifications scheduling & cancellation
    └── url_service.dart               # url_launcher helper for external links
```

---

## 6. How SQLite Storage Works

The local database `dossier_app.db` maintains two tables with foreign-key enforcement enabled (`PRAGMA foreign_keys = ON`):

1. **`scholarships` Table:**
   - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
   - `name`: TEXT NOT NULL
   - `country`: TEXT NOT NULL
   - `deadline`: TEXT NOT NULL (ISO-8601 YYYY-MM-DD)
   - `link`: TEXT (optional)
   - `status`: TEXT NOT NULL ('Not Started', 'In Progress', 'Ready to Submit', 'Submitted')
   - `notes`: TEXT (optional)
   - `remindersOn`: INTEGER NOT NULL DEFAULT 1
   - `createdAt`: TEXT NOT NULL
2. **`requirements` Table:**
   - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
   - `scholarshipId`: INTEGER NOT NULL (FOREIGN KEY REFERENCES scholarships(id) ON DELETE CASCADE)
   - `title`: TEXT NOT NULL
   - `isDone`: INTEGER NOT NULL DEFAULT 0

**Progress is calculated dynamically** using SQL aggregate queries (`completed / total * 100`). It is never stored as a stale column. Deleting a scholarship deletes its associated requirements automatically.

---

## 7. AI Features and Security

### The 3 Features:
1. **Checklist Generator:** Parses pasted unstructured requirements and outputs discrete document items. Items can be edited, added, removed, and assigned to any scholarship before confirmation.
2. **Application Priority:** Takes active applications and ranks them according to deadline proximity and uncompleted requirements with concise explanations.
3. **Progress Summary:** Produces 2–3 natural language sentences summarizing application progress and the single most critical next action.

### Security and Fallback Policy:
- **Zero Secret Bundling:** No API key is hardcoded in source code.
- **In-App & Env Configuration:** A Gemini key can be supplied via `.env` or using the in-app AI Settings button (stored in private device `SharedPreferences`).
- **Deterministic Offline Fallbacks:** If no API key is provided or the device is offline, Dossier uses deterministic algorithms:
  - Regex clause extraction for checklists.
  - Urgency & remaining requirement weighting for priority ordering.
  - Template-based dynamic synthesis for progress summaries.
  Every feature is 100% testable and demonstratable without internet access.

---

## 8. Automated Testing

Run all unit, database, and widget tests with:

```bash
flutter test
```

### Verified Test Suites:
- `test/unit/app_logic_test.dart`:
  - Deadline classification (Urgent, Due Soon, Later, Overdue, Submitted).
  - Normalization of dates to midnight (due today = 0 days = Urgent, not Overdue).
  - Form and URL validators.
  - Deterministic AI fallback algorithms.
- `test/unit/database_test.dart`:
  - In-memory SQLite CRUD operations for scholarships.
  - Requirement batch insertion and progress counts.
  - Foreign key cascading deletion.
- `test/widget/core_widgets_test.dart`:
  - `AppButton` callbacks and loading state.
  - `EmptyState` display and action button.
  - `StatusChip` category color rendering.
  - `ProgressIndicatorCard` percentage rounding.
  - `ConfirmationDialog` cancel and confirm actions.

**Result:** `20 of 20 tests passed successfully`.

---

## 9. Running the Application

### In VS Code or Antigravity:
1. Open the project folder.
2. Run `flutter pub get`.
3. Launch an Android emulator or connect an Android physical device.
4. Press `F5` or execute:
   ```bash
   flutter run
   ```

### First-Time Demo:
On the Home screen, tap the top-right menu (three dots) and select **"Load Sample Data"** to immediately populate the app with Alina's demo scholarships (*Erasmus Mundus*, *DAAD Scholarship*, and *Stipendium Hungaricum*).

---

## 10. Android Build & Java Note

Flutter 3.38 is fully configured with Android SDK 36.0.0. When compiling Gradle on systems with Java 25 (e.g., from Android Studio JBR 25), Gradle 8.14 requires Java 17 to Java 21:
```bash
# If building standalone APK with Gradle:
flutter config --jdk-dir="<PATH_TO_JDK_17_OR_21>"
flutter build apk --debug
```
For standard development and emulator runs, execute `flutter run`.
