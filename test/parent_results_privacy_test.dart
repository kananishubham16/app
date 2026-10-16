import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:learning_setu/screens/results/results_screen.dart';
import 'package:learning_setu/services/ai_analysis_service.dart';
import 'package:learning_setu/services/performance_service.dart';
import 'package:learning_setu/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildParentApp({
    required Widget child,
    required AuthProvider authProv,
    required UserModel parentUser,
    String? initialStudentId,
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
          prov.loadStudentsByIds(parentUser.childrenIds ?? ['student_1']);
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
          prov.loadAssessmentsByStudent(initialStudentId ?? 'student_1');
          return prov;
        }),
        ChangeNotifierProvider(create: (_) => QuizProvider(mockQuizRepo, storage)),
        ChangeNotifierProvider(create: (_) => RemedialProvider(mockRemedialRepo, storage)),
        ChangeNotifierProvider(create: (_) => PerformanceProvider(perfService)),
        ChangeNotifierProvider(create: (_) => ParentReviewProvider(storage)),
      ],
      child: MaterialApp(
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

  group('Parent Results Privacy & Student Scoping Tests', () {
    testWidgets('Parent in ResultsScreen strictly sees only their child results and never all classes', (tester) async {
      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.parent);
      });
      final parentUser = authProv.currentUser!;

      await tester.pumpWidget(
        buildParentApp(
          child: const ResultsScreen(studentId: 'student_1'),
          authProv: authProv,
          parentUser: parentUser,
          initialStudentId: 'student_1',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify "All Classes" dropdown option is NOT present for parent
      expect(find.text('All Classes'), findsNothing);
      expect(find.text('બધા વર્ગો'), findsNothing);

      // Should show Aarav Kumar (student_1)
      expect(find.textContaining('Aarav Kumar'), findsWidgets);

      // Verify that other students (e.g. Diya Sharma / student_2, Kabir Joshi / student_4) are NOT shown
      expect(find.textContaining('Kabir Joshi'), findsNothing);
      expect(find.textContaining('Sneha Mehta'), findsNothing);
    });

    testWidgets('Parent with multi-children can only view their own linked children', (tester) async {
      final storage = StorageService();
      final authProv = AuthProvider(MockAuthRepository(), storage);
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.parent);
      });
      final parentUser = authProv.currentUser!;

      await tester.pumpWidget(
        buildParentApp(
          child: const ResultsScreen(studentId: 'student_1'),
          authProv: authProv,
          parentUser: parentUser,
          initialStudentId: 'student_1',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Class dropdown like "3-A" or "All Classes" should NOT exist
      expect(find.text('All Classes'), findsNothing);

      // Should show Aarav Kumar (student_1)
      expect(find.textContaining('Aarav Kumar'), findsWidgets);

      // Other students not linked to this parent (e.g. student_3 Sneha, student_4 Kabir) must NOT appear
      expect(find.textContaining('Sneha Mehta'), findsNothing);
      expect(find.textContaining('Kabir Joshi'), findsNothing);
    });
  });
}
