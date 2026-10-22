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
import 'package:learning_setu/screens/quizzes/quiz_screen.dart';
import 'package:learning_setu/screens/remedial/assign_remedial_screen.dart';
import 'package:learning_setu/screens/results/add_assessment_screen.dart';
import 'package:learning_setu/screens/subjects/subject_detail_screen.dart';
import 'package:learning_setu/services/ai_analysis_service.dart';
import 'package:learning_setu/services/performance_service.dart';
import 'package:learning_setu/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTeacherApp({
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
          return prov;
        }),
        ChangeNotifierProvider(create: (_) {
          final prov = RemedialProvider(mockRemedialRepo, storage);
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
        home: child,
      ),
    );
  }

  testWidgets('Maths teacher viewing Gujarati SubjectDetailScreen sees View-Only notice and cannot edit', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockAuthRepo = MockAuthRepository();
    final authProv = AuthProvider(mockAuthRepo, StorageService());
    await tester.runAsync(() async {
      await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher');
    });

    final gujaratiSubject = MockData.subjects.firstWhere((s) => s.id == 'subject_guj');

    await tester.pumpWidget(
      buildTeacherApp(
        authProv: authProv,
        child: SubjectDetailScreen(
          subject: gujaratiSubject,
          studentId: 'student_1',
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 1. View-Only notice badge should be visible
    expect(find.textContaining('માત્ર વાંચવા માટે (અન્ય વિષય શિક્ષક)'), findsOneWidget);

    // 2. Assign remedial button (સોંપો) should NOT be visible
    expect(find.text('સોંપો'), findsNothing);

    // 3. Informative view-only banner should be present instead of interactive Supervise Quiz
    expect(find.textContaining('માત્ર વાંચવા માટે: તમે આ વિષયના સોંપાયેલ શિક્ષક નથી'), findsOneWidget);
  });

  testWidgets('Maths teacher viewing Maths SubjectDetailScreen has full interactive rights', (tester) async {
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockAuthRepo = MockAuthRepository();
    final authProv = AuthProvider(mockAuthRepo, StorageService());
    await tester.runAsync(() async {
      await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher');
    });

    final mathSubject = MockData.subjects.firstWhere((s) => s.id == 'subject_math');

    await tester.pumpWidget(
      buildTeacherApp(
        authProv: authProv,
        child: SubjectDetailScreen(
          subject: mathSubject,
          studentId: 'student_1',
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 1. Should NOT show "માત્ર વાંચવા માટે (અન્ય વિષય શિક્ષક)" badge
    expect(find.textContaining('માત્ર વાંચવા માટે (અન્ય વિષય શિક્ષક)'), findsNothing);

    // 2. Interactive Supervise Quiz button containing 'ક્વિઝ' should be visible
    expect(find.textContaining('ક્વિઝ'), findsWidgets);

    // 3. Assign remedial button (સોંપો) should be visible
    expect(find.text('સોંપો'), findsOneWidget);
  });

  testWidgets('Maths teacher opening AddAssessmentScreen for Gujarati sees Permission Restricted screen', (tester) async {
    final mockAuthRepo = MockAuthRepository();
    final authProv = AuthProvider(mockAuthRepo, StorageService());
    await tester.runAsync(() async {
      await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher');
    });

    await tester.pumpWidget(
      buildTeacherApp(
        authProv: authProv,
        child: const AddAssessmentScreen(
          studentId: 'student_1',
          subjectId: 'subject_guj',
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify restricted screen
    expect(find.text('પરવાનગી પ્રતિબંધિત (View-Only)'), findsOneWidget);
    expect(find.textContaining('તમે અન્ય શિક્ષકના વિષય માટે નવું મૂલ્યાંકન અથવા ગુણ ઉમેરી શકતા નથી'), findsOneWidget);
  });

  testWidgets('Maths teacher opening AssignRemedialScreen for Gujarati sees Permission Restricted screen', (tester) async {
    final mockAuthRepo = MockAuthRepository();
    final authProv = AuthProvider(mockAuthRepo, StorageService());
    await tester.runAsync(() async {
      await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher');
    });

    await tester.pumpWidget(
      buildTeacherApp(
        authProv: authProv,
        child: const AssignRemedialScreen(
          studentId: 'student_1',
          subjectId: 'subject_guj',
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify restricted screen
    expect(find.text('પરવાનગી પ્રતિબંધિત (View-Only)'), findsOneWidget);
    expect(find.textContaining('તમે અન્ય શિક્ષકના વિષય માટે ઉપચારાત્મક કાર્ય સોંપી શકતા નથી'), findsOneWidget);
  });

  testWidgets('Maths teacher opening QuizScreen for Gujarati sees Permission Restricted screen', (tester) async {
    final mockAuthRepo = MockAuthRepository();
    final authProv = AuthProvider(mockAuthRepo, StorageService());
    await tester.runAsync(() async {
      await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher');
    });

    await tester.pumpWidget(
      buildTeacherApp(
        authProv: authProv,
        child: const QuizScreen(
          studentId: 'student_1',
          subjectId: 'subject_guj',
          topicId: 'topic_guj_read',
          topicName: 'વાંચન સમજ',
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify restricted screen
    expect(find.text('પરવાનગી પ્રતિબંધિત (View-Only)'), findsOneWidget);
    expect(find.textContaining('તમે અન્ય શિક્ષકના વિષય માટે ક્વિઝ સુપરવાઇઝ અથવા સબમિટ કરી શકતા નથી'), findsOneWidget);
  });

  testWidgets('Gujarati teacher opening AssignRemedialScreen sees ONLY Gujarati in dropdown and not unassigned subjects', (tester) async {
    final mockAuthRepo = MockAuthRepository();
    final authProv = AuthProvider(mockAuthRepo, StorageService());
    await tester.runAsync(() async {
      await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher_guj');
    });

    await tester.pumpWidget(
      buildTeacherApp(
        authProv: authProv,
        child: const AssignRemedialScreen(studentId: 'student_1'),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final menuItems = tester.widgetList<DropdownMenuItem<String>>(find.byType(DropdownMenuItem<String>));
    final itemValues = menuItems.map((m) => m.value).toList();

    // Gujarati teacher must have 'subject_guj', but not other subjects
    expect(itemValues, contains('subject_guj'));
    expect(itemValues.contains('subject_math'), isFalse);
    expect(itemValues.contains('subject_eng'), isFalse);
    expect(itemValues.contains('subject_evs'), isFalse);
  });

  testWidgets('Gujarati teacher opening AddAssessmentScreen sees ONLY Gujarati in dropdown and not unassigned subjects', (tester) async {
    final mockAuthRepo = MockAuthRepository();
    final authProv = AuthProvider(mockAuthRepo, StorageService());
    await tester.runAsync(() async {
      await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher_guj');
    });

    await tester.pumpWidget(
      buildTeacherApp(
        authProv: authProv,
        child: const AddAssessmentScreen(studentId: 'student_1'),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final menuItems = tester.widgetList<DropdownMenuItem<String>>(find.byType(DropdownMenuItem<String>));
    final itemValues = menuItems.map((m) => m.value).toList();

    expect(itemValues, contains('subject_guj'));
    expect(itemValues.contains('subject_math'), isFalse);
    expect(itemValues.contains('subject_eng'), isFalse);
    expect(itemValues.contains('subject_evs'), isFalse);
  });

  testWidgets('Math & English teacher sees only Math and English in AssignRemedial dropdown', (tester) async {
    final mockAuthRepo = MockAuthRepository();
    final authProv = AuthProvider(mockAuthRepo, StorageService());
    await tester.runAsync(() async {
      await authProv.demoLogin(UserRole.teacher, userId: 'user_teacher');
    });

    await tester.pumpWidget(
      buildTeacherApp(
        authProv: authProv,
        child: const AssignRemedialScreen(studentId: 'student_1'),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final subjectDropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>).at(1),
    );
    final itemValues = subjectDropdown.items!.map((m) => m.value).toList();

    expect(itemValues, containsAll(['subject_math', 'subject_eng']));
    expect(itemValues.contains('subject_guj'), isFalse);
    expect(itemValues.contains('subject_evs'), isFalse);
  });

  testWidgets('Teacher with no assigned subjects sees No Assigned Subjects screen on AssignRemedial and AddAssessment', (tester) async {
    final customRepo = _CustomTeacherAuthRepo(
      const UserModel(
        id: 'user_teacher_no_sub',
        name: 'New Teacher',
        email: 'new@demo.com',
        phone: '1234567890',
        role: UserRole.teacher,
        subjectIds: [],
      ),
    );
    final authProv = AuthProvider(customRepo, StorageService());
    await tester.runAsync(() async {
      await authProv.demoLogin(UserRole.teacher);
    });

    // 1. AssignRemedialScreen
    await tester.pumpWidget(
      buildTeacherApp(
        authProv: authProv,
        child: const AssignRemedialScreen(studentId: 'student_1'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('કોઈ સોંપાયેલ વિષય નથી'), findsOneWidget);

    // 2. AddAssessmentScreen
    await tester.pumpWidget(
      buildTeacherApp(
        authProv: authProv,
        child: const AddAssessmentScreen(studentId: 'student_1'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('કોઈ સોંપાયેલ વિષય નથી'), findsOneWidget);
  });
}

class _CustomTeacherAuthRepo extends MockAuthRepository {
  final UserModel customUser;
  _CustomTeacherAuthRepo(this.customUser);

  @override
  Future<UserModel?> demoLogin(UserRole role, {String? userId}) async {
    return customUser;
  }
}
