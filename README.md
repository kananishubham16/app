# Learning Setu (લર્નિંગ સેતુ) 🌉
> **Smart Tracking and Remedial Action System for Student Learning Gaps in Primary Schools**  
> **SFIC Hackathon 2026** • **Problem ID: PS000060**

---

## 🌟 Executive Summary
**Learning Setu** is an education-focused Dart & Flutter application engineered to diagnose early foundational learning gaps in primary school children, assign targeted classroom and home remedial actions, supervise mini-quizzes, and track student recovery over time.

Built with **Flutter Material 3**, **Provider state management**, and **Repository pattern architecture**, Learning Setu enables seamless local evaluation for hackathon juries and is ready for production backend integration.

---

## 👥 Demo User Access & Credentials

The application includes full local authentication simulation with a **"Try Demo"** 1-tap quick login for all 4 primary education stakeholders:

| Role | Demo Email | Password | Scope & Responsibilities |
|---|---|---|---|
| **Primary School Teacher** | `teacher@demo.com` | `demo123` | Class selection, student diagnostics, assessment logging, remedial assignment & quiz supervision. |
| **School Principal** | `principal@demo.com` | `demo123` | School-wide mastery overview, class & subject comparative performance, remedial completion & gap alerts. |
| **Block Resource Coordinator (BRC)** | `brc@demo.com` | `demo123` | Cluster/block overview across multiple schools, assessment coverage %, support-need school targeting. |
| **Parent** | `parent@demo.com` | `demo123` | Linked child view exclusively, supportive home practice instructions, direct quiz launch, progress tracking. |

> ℹ️ *Note: Production systems must enforce authentication and role-based access control (RBAC) securely on the backend server. Students do not have independent logins; their activities are guided through teacher and parent interfaces.*

---

## 🚀 Setup & Run Commands

### Prerequisites
- **Flutter SDK**: 3.27+ (or 3.47+ stable)
- **Dart SDK**: 3.13+
- **Android Studio / VS Code** with Flutter extensions, or Android device / emulator.

### Quick Start
```bash
# 1. Navigate to the project directory
cd d:\hackathon\sfic\learning_setu

# 2. Fetch project dependencies
flutter pub get

# 3. Verify code quality (0 errors)
flutter analyze --no-fatal-infos --no-fatal-warnings

# 4. Run automated test suite (all tests passing)
flutter test

# 5. Launch app on connected device / emulator
flutter run
```

---

## 📊 Scoring & Calculation Rules

The prototype applies transparent, reproducible, and objective educational rules:

### 1. Prototype Thresholds
- 🔴 **Weak (< 40.0%)**: Indicates critical conceptual gap requiring immediate targeted remedial intervention.
- 🟡 **Average (40.0% – 69.9%)**: Indicates developing competency; needs reinforcement practice.
- 🟢 **Strong (≥ 70.0%)**: Demonstrates conceptual mastery; eligible for advanced activities.
- ⚪ **Not Assessed**: Subject or topic has no recorded regular assessment data.
*(Note: These thresholds are configurable prototype values for demonstration and do not dictate government education policy).*

### 2. Scoring Formulation
- **Assessment Percentage**: $\text{Percentage} = \frac{\text{Obtained Marks}}{\text{Maximum Marks}} \times 100$
- **Overall Performance**: The arithmetic mean of the latest valid **regular assessments** across assessed subjects only.
- **Unassessed Exclusion & Coverage**: Unassessed subjects are strictly excluded from the mean score and surfaced as coverage metrics (e.g. *"3 of 4 subjects assessed"*).
- **Separation of Remedial Scores**: Remedial practice quizzes are tracked independently from regular classroom benchmarks to prevent distortion of foundational baseline data.
- **Improvement Metrics**: Measured in delta percentage points against baseline attempts; shows *"Insufficient data"* if fewer than two compatible evaluations exist.
- **Rule-Based Diagnostic Summaries**: Diagnostic narratives and recommended actions are synthesized using deterministic rule engines, not external non-deterministic blackbox AI APIs.

---

## 🎯 Hackathon Demonstration Flow

Follow this end-to-end evaluation scenario to demonstrate the full reactive loop:

1. **Role Selection & Login**:
   - Launch app ➡️ On Welcome Screen, toggle language between **English** and **Gujarati (ગુજરાતી)**.
   - Tap **Primary School Teacher** ➡️ Click **Try Demo** to log in as Anita Sharma.
2. **Identify Learning Gap**:
   - On the Teacher Dashboard, select class **Class 3 - A**.
   - Tap on student **Aarav Kumar** (`STU-3A-001`).
   - Observe Aarav's Subject Overview: Mathematics is flagged **Weak (35.0%)**.
   - Under Topic Gaps, observe **Subtraction** flagged as critical.
3. **Assign Remedial Action**:
   - Tap **Assign Practice** on Aarav's profile.
   - Select Subject **Mathematics** ➡️ Topic **Subtraction**.
   - Choose Activity: *"Practise subtraction using objects"*.
   - Toggle **Include Quiz Verification** to `ON`. Set due date and add teacher note.
   - Tap **Save Remedial Action**.
4. **Supervised Student Quiz**:
   - From the student detail or remedial list, tap **Start Quiz** for Subtraction.
   - The student takes a 5-question multiple choice quiz with instant visual feedback and explanation for each question.
   - On completion, view the **Quiz Results**: score percentage, benchmark status (*"Ready for reassessment"* if $\ge 70\%$ or *"Further practice recommended"* if $< 70\%$).
5. **Multi-Stakeholder Sync**:
   - Open drawer ➡️ **Logout**.
   - Log in as **Parent** (`parent@demo.com`) ➡️ View Aarav Kumar's home dashboard reflecting the newly completed quiz and updated activity status.
   - Log in as **Principal** (`principal@demo.com`) ➡️ View school-wide remedial completion percentages updating in real time.
   - Log in as **BRC** (`brc@demo.com`) ➡️ View block-level coverage and cluster remediation progress.

---

## 🏗️ Architecture & Project Organization

The codebase follows clean architecture principles with complete separation of concerns:

```
lib/
├── app/
│   ├── app_router.dart          # Centralized route generation & arguments
│   └── theme.dart               # Material 3 education theme & AppColors
├── l10n/
│   ├── app_en.arb               # English localization resources
│   ├── app_gu.arb               # Gujarati localization resources
│   └── app_localizations.dart   # Auto-generated localization delegates
├── mock_data/
│   └── mock_data.dart           # Coherent 30-student, 3-school, 60+ question dataset
├── models/
│   ├── assessment_model.dart    # Assessment & TopicScore models
│   ├── performance_model.dart   # Classification logic & StudentPerformanceSummary
│   ├── quiz_model.dart          # QuizQuestion, QuizAttempt, QuizAnswer
│   ├── remedial_model.dart      # RemedialAction & RemedialStatus
│   ├── school_model.dart        # School, Block, Class models
│   ├── student_model.dart       # Student records & parent linkage
│   └── user_model.dart          # UserModel & UserRole definitions
├── providers/
│   ├── auth_provider.dart       # Local session & demo authentication
│   ├── student_provider.dart    # Student queries & selected student state
│   ├── assessment_provider.dart # Assessment history & entry state
│   ├── quiz_provider.dart       # Interactive quiz engine & attempt history
│   ├── remedial_provider.dart   # Task assignment & status management
│   ├── performance_provider.dart# Diagnostic summary state
│   ├── school_provider.dart     # Class/School/Block hierarchy state
│   └── locale_provider.dart     # Dynamic EN/GU runtime language switcher
├── repositories/
│   ├── *_repository.dart        # Abstract repository contracts
│   └── mock/                    # In-memory implementations using MockData
├── screens/
│   ├── auth/                    # WelcomeScreen & LoginScreen
│   ├── dashboards/              # Teacher, Principal, BRC, Parent Dashboards & Shell
│   ├── performance/             # Student Performance Analysis Screen
│   ├── profile/                 # User Profile & Settings (Reset Data)
│   ├── quizzes/                 # QuizScreen & QuizResultScreen
│   ├── remedial/                # RemedialScreen & AssignRemedialScreen
│   ├── results/                 # ResultsScreen & AddAssessmentScreen
│   ├── students/                # StudentDetailScreen
│   └── subjects/                # SubjectsScreen & SubjectDetailScreen
├── services/
│   ├── performance_service.dart # Deterministic diagnostic analysis calculations
│   └── storage_service.dart     # SharedPreferences local persistence & reset
├── widgets/                     # Reusable M3 UI components (StatCard, PercentageBar, etc.)
└── main.dart                    # Application bootstrap & Provider hierarchy
```

---

## 🔌 Future Backend Integration Points

All data access is mediated through abstract repository interfaces (`AuthRepository`, `StudentRepository`, `AssessmentRepository`, `QuizRepository`, `RemedialRepository`, `SchoolRepository`).

To transition this frontend from local demo mode to an enterprise cloud backend:
1. **Implement HTTP/REST or GraphQL Repositories**: Replace `lib/repositories/mock/*` with implementations communicating with your REST API (e.g., `Dio` or `http`).
2. **JWT Token Storage**: Store auth tokens securely using `flutter_secure_storage` inside `StorageService`.
3. **Role-Based Routing**: Hook server authentication claims directly into `AuthProvider`.
4. **Curriculum Sync**: Dynamically load syllabus and question banks via `SchoolRepository.getSubjects()`.

---

## ✅ Quality & Verification Checklist
- [x] Flutter Material 3 with accessible typography and touch targets $\ge 48\text{dp}$.
- [x] Zero compilation errors across entire codebase.
- [x] 100% test pass rate for all unit & business logic tests (`flutter test`).
- [x] Code formatted according to official Dart standards (`dart format`).
- [x] Bilingual support (English + Gujarati) via Flutter Localization infrastructure.
- [x] Responsive tablet and phone layout adaptation.
- [x] Offline-first local storage and state persistence via `shared_preferences`.
- [x] Reset Demo Data functionality with confirmation dialog.
