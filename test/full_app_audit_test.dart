import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/models/models.dart';
import 'package:learning_setu/providers/assessment_provider.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/locale_provider.dart';
import 'package:learning_setu/providers/parent_review_provider.dart';
import 'package:learning_setu/providers/performance_provider.dart';
import 'package:learning_setu/providers/quiz_provider.dart';
import 'package:learning_setu/providers/remedial_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/repositories/mock/mock_assessment_repository.dart';
import 'package:learning_setu/repositories/mock/mock_auth_repository.dart';
import 'package:learning_setu/repositories/mock/mock_quiz_repository.dart';
import 'package:learning_setu/repositories/mock/mock_remedial_repository.dart';
import 'package:learning_setu/repositories/mock/mock_school_repository.dart';
import 'package:learning_setu/repositories/mock/mock_student_repository.dart';
import 'package:learning_setu/screens/auth/login_screen.dart';
import 'package:learning_setu/screens/auth/welcome_screen.dart';
import 'package:learning_setu/screens/dashboards/brc_dashboard.dart';
import 'package:learning_setu/screens/dashboards/parent_dashboard.dart';
import 'package:learning_setu/screens/dashboards/principal_dashboard.dart';
import 'package:learning_setu/screens/dashboards/teacher_dashboard.dart';
import 'package:learning_setu/screens/performance/performance_screen.dart';
import 'package:learning_setu/screens/profile/profile_screen.dart';
import 'package:learning_setu/screens/profile/settings_screen.dart';
import 'package:learning_setu/screens/quizzes/quiz_result_screen.dart';
import 'package:learning_setu/screens/quizzes/quiz_screen.dart';
import 'package:learning_setu/screens/remedial/assign_remedial_screen.dart';
import 'package:learning_setu/screens/remedial/remedial_screen.dart';
import 'package:learning_setu/screens/results/add_assessment_screen.dart';
import 'package:learning_setu/screens/results/results_screen.dart';
import 'package:learning_setu/screens/students/student_detail_screen.dart';
import 'package:learning_setu/screens/subjects/subjects_screen.dart';
import 'package:learning_setu/services/ai_analysis_service.dart';
import 'package:learning_setu/services/performance_service.dart';
import 'package:learning_setu/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestApp({
    required Widget child,
    required AuthProvider authProv,
    Locale locale = const Locale('gu'),
  }) {
    final mockStudentRepo = MockStudentRepository();
    final mockSchoolRepo = MockSchoolRepository();
    final mockAssessRepo = MockAssessmentRepository();
    final mockQuizRepo = MockQuizRepository();
    final mockRemedialRepo = MockRemedialRepository();
    final storage = StorageService();
    final aiService = AiAnalysisService();
    final perfService = PerformanceService(mockAssessRepo, mockSchoolRepo, aiService: aiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<AuthProvider>.value(value: authProv),
        ChangeNotifierProvider(create: (_) {
          final prov = StudentProvider(mockStudentRepo);
          prov.loadStudentsBySchool('school_1');
          return prov;
        }),
        ChangeNotifierProvider(create: (_) {
          final prov = SchoolProvider(mockSchoolRepo);
          prov.loadSubjects();
          prov.loadClassesBySchool('school_1');
          prov.loadSchoolsByBlock('block_1');
          return prov;
        }),
        ChangeNotifierProvider(create: (_) => AssessmentProvider(mockAssessRepo, storage)),
        ChangeNotifierProvider(create: (_) {
          final prov = RemedialProvider(mockRemedialRepo, storage);
          prov.loadRemedialsBySchool('school_1');
          prov.loadRemedialsByStudent('student_1');
          return prov;
        }),
        ChangeNotifierProvider(create: (_) => ParentReviewProvider(storage)),
        ChangeNotifierProvider(create: (_) => PerformanceProvider(perfService)),
        ChangeNotifierProvider(create: (_) => QuizProvider(mockQuizRepo, storage)),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('gu', ''),
        ],
        onGenerateRoute: AppRouter.generateRoute,
        home: child,
      ),
    );
  }

  // =========================================================================
  // PASS 1: COMPREHENSIVE ROUTE & SCREEN INSTANTIATION AUDIT
  // =========================================================================
  group('Pass 1: Complete Screen Lifecycle & Route Integrity Audit', () {
    testWidgets('Every core screen renders cleanly without exceptions for Teacher', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher');
      });

      final screens = <Widget>[
        const WelcomeScreen(),
        const LoginScreen(role: UserRole.teacher),
        const TeacherDashboard(),
        const SubjectsScreen(),
        const ResultsScreen(),
        const PerformanceScreen(studentId: 'student_1'),
        const RemedialScreen(studentId: 'student_1'),
        const ProfileScreen(),
        const SettingsScreen(),
        const QuizResultScreen(),
      ];

      for (final screen in screens) {
        await tester.pumpWidget(createTestApp(child: screen, authProv: authProv));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull, reason: 'Failed rendering ${screen.runtimeType}');
      }
    });

    testWidgets('Principal and BRC Dashboards render without exceptions', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);

      // Principal
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.principal);
      });
      await tester.pumpWidget(createTestApp(child: const PrincipalDashboard(), authProv: authProv));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);

      // BRC
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.brc);
      });
      await tester.pumpWidget(createTestApp(child: const BrcDashboard(), authProv: authProv));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Parent Portal renders cleanly without exceptions', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.parent, userId: 'user_parent');
      });

      await tester.pumpWidget(createTestApp(child: const ParentDashboard(), authProv: authProv));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });
  });

  // =========================================================================
  // PASS 2: DEEP MULTI-ROLE SECURITY & PRIVACY VERIFICATION
  // =========================================================================
  group('Pass 2: Deep Multi-Role Permissions & Privacy Verification', () {
    testWidgets('Parent CANNOT assign remedials and gets Unauthorized screen on direct route', (tester) async {
      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.parent, userId: 'user_parent');
      });

      // 1. Direct route to AssignRemedialScreen
      await tester.pumpWidget(
        createTestApp(
          child: const AssignRemedialScreen(studentId: 'student_1'),
          authProv: authProv,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('અનધિકૃત ઍક્સેસ'), findsOneWidget);
      expect(find.textContaining('માત્ર શિક્ષકો જ વિદ્યાર્થીઓ માટે ઉપચારાત્મક કાર્યો સોંપી શકે છે'), findsOneWidget);
    });

    testWidgets('Teacher viewing foreign subject is restricted from adding marks or quiz', (tester) async {
      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);
      // 'user_teacher' teaches Math & English, NOT Gujarati
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher');
      });

      // Add assessment for Gujarati
      await tester.pumpWidget(
        createTestApp(
          child: const AddAssessmentScreen(studentId: 'student_1', subjectId: 'subject_guj'),
          authProv: authProv,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('પરવાનગી પ્રતિબંધિત (View-Only)'), findsOneWidget);

      // Quiz for Gujarati
      await tester.pumpWidget(
        createTestApp(
          child: const QuizScreen(
            studentId: 'student_1',
            subjectId: 'subject_guj',
            topicId: 'topic_guj_read',
            topicName: 'વાંચન સમજ',
          ),
          authProv: authProv,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('પરવાનગી પ્રતિબંધિત (View-Only)'), findsOneWidget);
    });

    testWidgets('Parent in ResultsScreen strictly sees only their child', (tester) async {
      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.parent, userId: 'user_parent');
      });

      await tester.pumpWidget(createTestApp(child: const ResultsScreen(), authProv: authProv));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Class dropdown filter should NOT exist for parent
      expect(find.text('વર્ગ પસંદ કરો'), findsNothing);
      expect(find.text('બધા વર્ગ'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  // =========================================================================
  // PASS 3: VIEWPORT OVERFLOW STRESS TEST (320px, 360px, 412px in Gujarati)
  // =========================================================================
  group('Pass 3: Mobile Viewport Overflow Stress Tests', () {
    final viewports = <Size>[
      const Size(320, 568), // Ultra-narrow iPhone SE / budget Android
      const Size(360, 640), // Standard Android
      const Size(412, 915), // High-density modern Android
    ];

    for (final size in viewports) {
      testWidgets('StudentDetailScreen renders without overflow on ${size.width}x${size.height} in Gujarati', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final storage = StorageService();
        final authProv = AuthProvider(MockAuthRepository(), storage);
        await tester.runAsync(() async {
          await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher');
        });

        await tester.pumpWidget(
          createTestApp(
            child: const StudentDetailScreen(studentId: 'student_1'),
            authProv: authProv,
            locale: const Locale('gu'),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
