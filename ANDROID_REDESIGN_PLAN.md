# Learning Setu: Android-Mobile-Only Redesign Architecture & Execution Plan

## 1. Problem Statement & Mission
The user requires a **comprehensive redesign** of the Learning Setu application tailored specifically for **Android mobile devices** (portrait form factors ranging from compact 320dp up to standard 412dp+). The goal is total layout perfection:
- **Zero layout overflows** across both English and Gujarati (which is ~30–50% wider).
- **Android Material 3 standards**: System-integrated status bar, edge-to-edge support, elevation overlays, tactile touch targets (>=48dp), responsive typography.
- **Intrinsic Mobile Layouts**: Replace rigid GridViews with flexible vertical Column/ListView layouts or dynamic auto-scaling layout adapters that eliminate fixed aspect-ratio clipping.
- **Preserve 100% Functionality**: 4 user roles (Teacher, Principal, BRC, Parent), state management via Provider, mock repositories, assessment logging, remedial workflows, adaptive quizzes, AI diagnostics, Fast2SMS messaging.

---

## 2. Key Android Redesign Pillars

### Pillar A: System Bar Integration & Screen Constraints
- Configure `SystemChrome.setSystemUIOverlayStyle` in `main.dart` for crisp Material 3 status and navigation bars.
- Force portrait orientation (`DeviceOrientation.portraitUp`, `DeviceOrientation.portraitDown`) as standard for dedicated phone-first UX.
- Ensure every view is properly padded or enclosed with `SafeArea` so content is never occluded by cameras, punch-holes, or gesture bars.

### Pillar B: Typography & Material 3 Theme Adaptation (`theme.dart`)
- Adjust text scale factor resilience.
- Button styles with minimum touch target sizing: `minimumSize: const Size(0, 48)`.
- Use `FilledButton`, `ElevatedButton`, `OutlinedButton`, and `IconButton` with ripple feedback (`InkWell`).
- Unified card styling with subtle elevation and Android M3 surface tones.

### Pillar C: Navigation Experience (`dashboard_shell.dart`)
- Android Material 3 `NavigationBar` with haptic feedback.
- Clean modal bottom sheets and custom Android action dialogs.
- `PopScope` integration for consistent Android hardware/gesture back button handling.

### Pillar D: Core Screen Mobile Redesigns
1. **Welcome Screen (`welcome_screen.dart`)**:
   - Single-column card stack for mobile devices.
   - Clean app bar with quick language toggle chip.
   - Distinct role cards with high touch contrast and clear role descriptions.
2. **Login Screen (`login_screen.dart`)**:
   - Scrollable with automatic keyboard adjustment (`windowSoftInputMode="adjustResize"`).
   - Touch-friendly input fields with clear error semantics.
   - 1-click demo login buttons with role switching tabs.
3. **Teacher Dashboard (`teacher_dashboard.dart`)**:
   - Sticky class selector dropdown with proper flex constraints.
   - Quick Action buttons organized in mobile 2-column or full-width buttons.
   - Subject cards list organized vertically without fixed aspect ratio clipping.
   - Student roster with instant search, badges, and smooth scroll.
4. **Principal Dashboard (`principal_dashboard.dart`)**:
   - Institutional KPI metric grid scaled for mobile.
   - Class-wise performance cards with collapsible/expandable metrics.
   - Actionable remediation alerts and grade benchmarks.
5. **BRC Dashboard (`brc_dashboard.dart`)**:
   - Cluster-level overview card.
   - School list cards with wrapped buttons for "Schedule Visit" and "View Analytics" ensuring zero overflow on narrow devices.
   - Draggable scrollable bottom sheet for deep school analytics.
6. **Parent Dashboard (`parent_dashboard.dart`)**:
   - Friendly child switcher.
   - Prominent activity cards with simple "Start Quiz" or "Mark Done" buttons.
   - Recent results list with color-coded mastery pills.
7. **Detail & Action Screens**:
   - `student_detail_screen.dart`: Clear demographic header, mastery chips, quick intervention bar.
   - `subjects_screen.dart` & `subject_detail_screen.dart`: Vertical subject cards with topic breakdown.
   - `results_screen.dart` & `add_assessment_screen.dart`: Keyboard-safe forms, topic mark inputs with validation.
   - `quiz_screen.dart` & `quiz_result_screen.dart`: Distraction-free question card, touch-friendly option tiles, result summary with parent forward modal.
   - `profile_screen.dart` & `settings_screen.dart`: Simple mobile settings list with language toggle and SMS testing.

---

## 3. Implementation Steps & Verification
1. Refactor `lib/main.dart` and `lib/app/theme.dart` for Android orientation locking and edge-to-edge UI.
2. Update `dashboard_shell.dart` with Android navigation semantics.
3. Refactor all screens systematically with full intrinsic sizing.
4. Run `flutter analyze` to ensure 0 static analysis issues.
5. Run full test suite with viewport stress tests on 320x568, 360x640, and 393x852 in both English and Gujarati.
6. Verify and push to Git.
