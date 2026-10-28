import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning_setu/models/holistic_evaluation_model.dart';
import 'package:learning_setu/providers/holistic_provider.dart';
import 'package:learning_setu/services/storage_service.dart';
import 'package:learning_setu/widgets/holistic_growth_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HolisticEvaluationModel Unit Tests', () {
    test('Calculates composite score correctly across 5 pillars', () {
      final eval = HolisticEvaluationModel(
        studentId: 'test_s1',
        practiceGrit: 90.0,          // 25% = 22.5
        learningConsistency: 80.0,   // 25% = 20.0
        engagementCuriosity: 70.0,   // 20% = 14.0
        teamworkEmpathy: 80.0,       // 15% = 12.0
        coCurricular: 80.0,          // 15% = 12.0
        updatedAt: DateTime.now(),
      );

      // Expected = 22.5 + 20.0 + 14.0 + 12.0 + 12.0 = 80.5
      expect(eval.compositeScore, closeTo(80.5, 0.1));
    });

    test('Returns localized status in English and Gujarati', () {
      final highEval = HolisticEvaluationModel(
        studentId: 'high_1',
        practiceGrit: 95.0,
        learningConsistency: 95.0,
        engagementCuriosity: 95.0,
        teamworkEmpathy: 95.0,
        coCurricular: 95.0,
        updatedAt: DateTime.now(),
      );

      expect(highEval.getLocalizedStatus(false), contains('Exemplary'));
      expect(highEval.getLocalizedStatus(true), contains('સર્વાંગી ઉત્કૃષ્ટ વિકાસ'));

      final needEval = HolisticEvaluationModel(
        studentId: 'need_1',
        practiceGrit: 40.0,
        learningConsistency: 50.0,
        engagementCuriosity: 45.0,
        teamworkEmpathy: 50.0,
        coCurricular: 40.0,
        updatedAt: DateTime.now(),
      );

      expect(needEval.getLocalizedStatus(false), contains('Emerging'));
      expect(needEval.getLocalizedStatus(true), contains('પ્રોત્સાહનની જરૂરિયાત'));
    });

    test('Serialization round-trip toJson and fromJson preserves data and badges', () {
      final original = HolisticEvaluationModel(
        studentId: 'test_s2',
        practiceGrit: 85.5,
        learningConsistency: 91.0,
        engagementCuriosity: 77.0,
        teamworkEmpathy: 88.0,
        coCurricular: 82.0,
        teacherNotes: 'Excellent participation in team projects.',
        badges: [
          CharacterBadge(
            id: 'b_test1',
            badgeKey: 'curious_mind',
            title: 'Curious Questioner',
            titleGu: 'જિજ્ઞાસુ વિદ્યાર્થી',
            iconName: 'lightbulb_outline',
            awardedBy: 'Mrs. Patel',
            awardedAt: DateTime.parse('2026-10-25T10:00:00.000Z'),
          ),
        ],
        updatedAt: DateTime.parse('2026-10-26T12:00:00.000Z'),
      );

      final json = original.toJson();
      final restored = HolisticEvaluationModel.fromJson(json);

      expect(restored.studentId, original.studentId);
      expect(restored.practiceGrit, original.practiceGrit);
      expect(restored.learningConsistency, original.learningConsistency);
      expect(restored.engagementCuriosity, original.engagementCuriosity);
      expect(restored.teamworkEmpathy, original.teamworkEmpathy);
      expect(restored.coCurricular, original.coCurricular);
      expect(restored.teacherNotes, original.teacherNotes);
      expect(restored.badges.length, 1);
      expect(restored.badges.first.badgeKey, 'curious_mind');
      expect(restored.badges.first.titleGu, 'જિજ્ઞાસુ વિદ્યાર્થી');
      expect(restored.badges.first.awardedBy, 'Mrs. Patel');
    });
  });

  group('HolisticProvider Unit Tests', () {
    late StorageService storageService;
    late HolisticProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      provider = HolisticProvider(storageService);
      await provider.loadEvaluations();
    });

    test('Initializes with seed data for demo students', () {
      final eval1 = provider.getEvaluationForStudent('student_1');
      expect(eval1.studentId, 'student_1');
      expect(eval1.badges.isNotEmpty, true);
      expect(eval1.practiceGrit, greaterThan(80.0));
    });

    test('1-tap Award Badge correctly adds badge and reinforces trait score', () async {
      final initial = provider.getEvaluationForStudent('student_1');
      final initialGrit = initial.practiceGrit;
      final initialBadgeCount = initial.badges.length;

      await provider.awardBadge(
        studentId: 'student_1',
        badgeKey: 'high_effort',
        teacherName: 'Anita Sharma',
        note: 'Superb grit in solving fractions worksheet!',
      );

      final updated = provider.getEvaluationForStudent('student_1');
      expect(updated.badges.length, initialBadgeCount + 1);
      expect(updated.badges.first.badgeKey, 'high_effort');
      expect(updated.badges.first.awardedBy, 'Anita Sharma');
      expect(updated.practiceGrit, greaterThan(initialGrit));
      expect(updated.teacherNotes, 'Superb grit in solving fractions worksheet!');
    });

    test('Multiple selective badge awarding adds all badges and boosts scores', () async {
      final initial = provider.getEvaluationForStudent('student_1');
      final initialBadgeCount = initial.badges.length;
      final initialCuriosity = initial.engagementCuriosity;
      final initialTeamwork = initial.teamworkEmpathy;

      await provider.awardBadges(
        studentId: 'student_1',
        badgeKeys: ['curious_mind', 'team_player'],
        teacherName: 'Anita Sharma',
        note: 'Exceptional group leadership and questions in science!',
      );

      final updated = provider.getEvaluationForStudent('student_1');
      expect(updated.badges.length, initialBadgeCount + 2);
      expect(updated.badges[0].badgeKey, 'team_player');
      expect(updated.badges[1].badgeKey, 'curious_mind');
      expect(updated.engagementCuriosity, greaterThan(initialCuriosity));
      expect(updated.teamworkEmpathy, greaterThan(initialTeamwork));
      expect(updated.teacherNotes, 'Exceptional group leadership and questions in science!');
    });

    test('Auto-updates Practice Grit and Consistency from attendance/remedials', () async {
      await provider.autoUpdateMetrics(
        studentId: 'student_1',
        completedRemedials: 5,
        totalRemedials: 5,
        attendedDays: 24,
        totalWorkingDays: 25,
      );

      final updated = provider.getEvaluationForStudent('student_1');
      expect(updated.learningConsistency, greaterThanOrEqualTo(85.0));
      expect(updated.practiceGrit, greaterThanOrEqualTo(85.0));
    });
  });

  group('HolisticGrowthCard Widget Tests', () {
    late StorageService storageService;
    late HolisticProvider holisticProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      holisticProvider = HolisticProvider(storageService);
      await holisticProvider.loadEvaluations();
    });

    Widget createTestableWidget({
      required String studentId,
      bool isTeacher = false,
      String? teacherName,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<HolisticProvider>.value(
            value: holisticProvider,
            child: SingleChildScrollView(
              child: HolisticGrowthCard(
                studentId: studentId,
                isTeacher: isTeacher,
                teacherName: teacherName,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Renders 360 Holistic Card header, composite score, and trait bars', (tester) async {
      await tester.pumpWidget(createTestableWidget(studentId: 'student_1'));
      await tester.pumpAndSettle();

      expect(find.text('360° Holistic Growth & Character'), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
      expect(find.textContaining('NEP 2020'), findsOneWidget);

      // Trait rows
      expect(find.text('Practice Grit & Effort'), findsOneWidget);
      expect(find.text('Learning Consistency'), findsOneWidget);
      expect(find.text('Classroom Curiosity'), findsOneWidget);
      expect(find.text('Teamwork & Empathy'), findsOneWidget);
      expect(find.text('Co-Curricular & Sports'), findsOneWidget);

      // Existing badges rendered
      expect(find.text('Character Shout-Out Badges'), findsOneWidget);
      expect(find.text('Curious Questioner'), findsOneWidget);
      expect(find.text('Team Player & Empathy'), findsOneWidget);
    });

    testWidgets('Displays + Award Badge button for teachers and opens bottom sheet', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          studentId: 'student_1',
          isTeacher: true,
          teacherName: 'Anita Sharma',
        ),
      );
      await tester.pumpAndSettle();

      final awardButton = find.text('+ Award Badge');
      expect(awardButton, findsOneWidget);

      await tester.tap(awardButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet opened
      expect(find.text('1-Tap Character Shout-Out Badge'), findsOneWidget);
      expect(find.text('Award Badge'), findsOneWidget);

      // Tap 'Award Badge' inside bottom sheet
      await tester.tap(find.text('Award Badge'));
      await tester.pumpAndSettle();

      // Bottom sheet closed and snackbar or update rendered
      expect(find.text('1-Tap Character Shout-Out Badge'), findsNothing);
    });
  });
}
