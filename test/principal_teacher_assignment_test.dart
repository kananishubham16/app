import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/mock_data/mock_data.dart';
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
import 'package:learning_setu/screens/results/results_screen.dart';
import 'package:learning_setu/screens/students/student_detail_screen.dart';
import 'package:learning_setu/screens/subjects/subjects_screen.dart';
import 'package:learning_setu/services/ai_analysis_service.dart';
import 'package:learning_setu/services/performance_service.dart';
import 'package:learning_setu/services/storage_service.dart';
import 'package:learning_setu/widgets/assigned_teacher_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildPrincipalApp({
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
          return prov;
        }),
        ChangeNotifierProvider(create: (_) {
          final prov = AssessmentProvider(mockAssessRepo, storage);
          prov.loadAllAssessments();
          return prov;
        }),
        ChangeNotifierProvider(create: (_) => QuizProvider(mockQuizRepo, storage)),
        ChangeNotifierProvider(create: (_) => RemedialProvider(mockRemedialRepo, storage)),
        ChangeNotifierProvider(create: (_) => PerformanceProvider(perfService)),
        ChangeNotifierProvider(create: (_) => ParentReviewProvider(storage)),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('gu')],
        home: child,
      ),
    );
  }

  group('AssignedTeacherBadge Component Tests', () {
    testWidgets('renders full badge on narrow 320px viewport without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final teacher = MockData.demoUsers.firstWhere((u) => u.role == UserRole.teacher);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: AssignedTeacherBadge(
                  teacher: teacher,
                  labelPrefix: 'સોંપાયેલ શિક્ષક',
                  showPhone: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining(teacher.name), findsOneWidget);
      if (teacher.phone.isNotEmpty) {
        expect(find.text(teacher.phone), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders compact badge without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final teacher = MockData.demoUsers.firstWhere((u) => u.role == UserRole.teacher);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 250,
                child: AssignedTeacherBadge(
                  teacher: teacher,
                  compact: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining(teacher.name), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Principal Role Assigned Teacher Visibility Tests', () {
    testWidgets('ResultsScreen displays assigned teacher details for Principal on 360px viewport', (tester) async {
      tester.view.physicalSize = const Size(360, 750);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.principal);
      });

      await tester.pumpWidget(
        buildPrincipalApp(
          child: const ResultsScreen(),
          authProv: authProv,
          locale: const Locale('gu'),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify that assessment records are displayed
      expect(find.byType(Card), findsWidgets);

      // Verify that teacher indicator appears for Principal
      expect(find.textContaining('શિક્ષક:'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SubjectsScreen displays assigned teacher for Principal on 320px viewport', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.principal);
      });

      await tester.pumpWidget(
        buildPrincipalApp(
          child: const SubjectsScreen(),
          authProv: authProv,
          locale: const Locale('gu'),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify AssignedTeacherBadge is present
      expect(find.byType(AssignedTeacherBadge), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StudentDetailScreen displays Class Teacher & Subject Teachers for Principal', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.principal);
      });

      final student = MockData.students.first;

      await tester.pumpWidget(
        buildPrincipalApp(
          child: StudentDetailScreen(studentId: student.id, student: student),
          authProv: authProv,
          locale: const Locale('gu'),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify AssignedTeacherBadge appears
      expect(find.byType(AssignedTeacherBadge), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
