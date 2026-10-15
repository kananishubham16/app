import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_setu/models/models.dart';
import 'package:learning_setu/repositories/mock/mock_assessment_repository.dart';
import 'package:learning_setu/repositories/mock/mock_quiz_repository.dart';
import 'package:learning_setu/repositories/mock/mock_school_repository.dart';
import 'package:learning_setu/services/ai_analysis_service.dart';
import 'package:learning_setu/services/performance_service.dart';
import 'package:learning_setu/services/storage_service.dart';
import 'package:learning_setu/services/fast2sms_service.dart';
import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/providers/quiz_provider.dart';
import 'package:learning_setu/providers/assessment_provider.dart';
import 'package:learning_setu/widgets/stat_card.dart';
import 'package:learning_setu/screens/dashboards/brc_dashboard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Classification Boundaries Tests', () {
    test('Classifies null percentage as notAssessed', () {
      expect(
        PerformanceClassification.classify(null),
        PerformanceLevel.notAssessed,
      );
      expect(
        PerformanceClassification.label(PerformanceLevel.notAssessed),
        'Not Assessed',
      );
    });

    test('Classifies strictly below 40% as weak', () {
      expect(PerformanceClassification.classify(0.0), PerformanceLevel.weak);
      expect(PerformanceClassification.classify(39.9), PerformanceLevel.weak);
      expect(PerformanceClassification.label(PerformanceLevel.weak), 'Weak');
    });

    test('Classifies boundary 40.0% up to 69.9% as average', () {
      expect(
        PerformanceClassification.classify(40.0),
        PerformanceLevel.average,
      );
      expect(
        PerformanceClassification.classify(55.0),
        PerformanceLevel.average,
      );
      expect(
        PerformanceClassification.classify(69.99),
        PerformanceLevel.average,
      );
      expect(
        PerformanceClassification.label(PerformanceLevel.average),
        'Average',
      );
    });

    test('Classifies boundary 70.0% and above as strong', () {
      expect(PerformanceClassification.classify(70.0), PerformanceLevel.strong);
      expect(PerformanceClassification.classify(85.5), PerformanceLevel.strong);
      expect(
        PerformanceClassification.classify(100.0),
        PerformanceLevel.strong,
      );
      expect(
        PerformanceClassification.label(PerformanceLevel.strong),
        'Strong',
      );
    });
  });

  group('2. Unassessed Subjects & Overall Performance Calculation Tests', () {
    late MockAssessmentRepository assessmentRepo;
    late MockSchoolRepository schoolRepo;
    late PerformanceService performanceService;

    setUp(() {
      assessmentRepo = MockAssessmentRepository();
      schoolRepo = MockSchoolRepository();
      performanceService = PerformanceService(assessmentRepo, schoolRepo);
    });

    test('Handles student with zero assessments gracefully', () async {
      // Create a test student ID with no assessments
      final summary = await performanceService.getStudentPerformance(
        'non_existent_student',
      );

      expect(summary.subjectsAssessed, 0);
      expect(summary.totalSubjects, greaterThan(0));
      expect(summary.overallPercentage, isNull);
      expect(summary.overallLevel, PerformanceLevel.notAssessed);
      expect(
        summary.plainLanguageSummary,
        contains('No assessments recorded yet'),
      );
    });

    test('Calculates overall mean across only assessed subjects and excludes remedial quizzes', () async {
      // Mock student_1 (Aarav Kumar) has assessments
      final summary = await performanceService.getStudentPerformance(
        'student_1',
      );

      expect(summary.subjectsAssessed, greaterThan(0));
      expect(summary.totalSubjects, equals(4)); // 4 core subjects
      expect(summary.overallPercentage, isNotNull);

      // Verify that the overall percentage matches the average of assessed subjects
      final assessed = summary.subjectPerformances
          .where((s) => s.latestPercentage != null)
          .map((s) => s.latestPercentage!)
          .toList();

      expect(assessed.length, summary.subjectsAssessed);
      final expectedMean = assessed.reduce((a, b) => a + b) / assessed.length;
      expect(summary.overallPercentage, closeTo(expectedMean, 0.01));
    });

    test('Coverage accurately reflects assessed vs unassessed subjects', () async {
      final summary = await performanceService.getStudentPerformance(
        'student_1',
      );
      expect(summary.subjectsAssessed <= summary.totalSubjects, isTrue);
      expect(
        summary.plainLanguageSummary,
        contains(
          '${summary.subjectsAssessed} of ${summary.totalSubjects} subjects assessed',
        ),
      );
    });
  });

  group('3. Weak-Topic Question Selection Tests', () {
    late MockQuizRepository quizRepo;

    setUp(() {
      quizRepo = MockQuizRepository();
    });

    test('Retrieves at least 5 questions for demonstrated weak topic (subtraction)', () async {
      final questions = await quizRepo.getQuestions(
        classId: 'class_3',
        subjectId: 'subject_math',
        topicId: 'topic_math_sub',
      );

      expect(questions.length, greaterThanOrEqualTo(5));
      for (final q in questions) {
        expect(q.topicId, 'topic_math_sub');
        expect(q.options.length, 4);
        expect(q.correctAnswerIndex, inInclusiveRange(0, 3));
        expect(q.explanation.isNotEmpty, isTrue);
      }
    });

    test(
      'Returns empty list when topic has no questions without crashing',
      () async {
        final questions = await quizRepo.getQuestions(
          classId: 'class_99',
          subjectId: 'unknown',
          topicId: 'unknown',
        );

        expect(questions, isEmpty);
      },
    );
  });

  group('4. Saving Quiz Attempts & State Updates Tests', () {
    late MockQuizRepository quizRepo;
    late StorageService storageService;
    late QuizProvider quizProvider;

    setUp(() {
      quizRepo = MockQuizRepository();
      storageService = StorageService();
      quizProvider = QuizProvider(quizRepo, storageService);
    });

    test('Loads questions, records answers, and submits quiz attempt calculating percentage and pass threshold', () async {
      final loaded = await quizProvider.loadQuestions(
        classId: 'class_3',
        subjectId: 'subject_math',
        topicId: 'topic_math_sub',
      );

      expect(loaded, isTrue);
      expect(quizProvider.questions.isNotEmpty, isTrue);

      quizProvider.startQuiz();
      expect(quizProvider.isQuizActive, isTrue);
      expect(quizProvider.currentQuestionIndex, 0);

      // Answer question 0
      quizProvider.selectAnswer(
        quizProvider.currentQuestion!.correctAnswerIndex,
      );
      expect(quizProvider.hasAnsweredCurrent, isTrue);

      // Move to next and answer correctly
      quizProvider.nextQuestion();
      if (!quizProvider.isLastQuestion) {
        quizProvider.selectAnswer(
          quizProvider.currentQuestion!.correctAnswerIndex,
        );
      }

      // Submit quiz
      final attempt = await quizProvider.submitQuiz(
        studentId: 'student_1',
        subjectId: 'subject_math',
        topicId: 'topic_math_sub',
      );

      expect(attempt, isNotNull);
      expect(quizProvider.isQuizActive, isFalse);
      expect(quizProvider.lastAttempt, equals(attempt));
      expect(attempt!.studentId, 'student_1');
      expect(attempt.totalQuestions, equals(quizProvider.questions.length));
      expect(attempt.correctAnswers, greaterThanOrEqualTo(1));

      // Threshold check: 70%
      if (attempt.percentage >= 70.0) {
        expect(attempt.passedThreshold, isTrue);
      } else {
        expect(attempt.passedThreshold, isFalse);
      }
    });
  });

  group('5. Role Authorization & Teacher Assigned Subjects Tests', () {
    test('Teacher model preserves assigned subject IDs', () {
      const teacher = UserModel(
        id: 'user_teacher',
        name: 'Anita Sharma',
        email: 'teacher@demo.com',
        phone: '9876543210',
        role: UserRole.teacher,
        schoolId: 'school_1',
        classIds: ['class_3a_s1', 'class_4a_s1'],
        subjectIds: ['subject_math', 'subject_english'],
      );

      expect(teacher.subjectIds, isNotNull);
      expect(teacher.subjectIds!.length, 2);
      expect(teacher.subjectIds, contains('subject_math'));
      expect(teacher.subjectIds, contains('subject_english'));
      expect(teacher.subjectIds, isNot(contains('subject_guj')));

      // Test serialization & deserialization with subjectIds
      final json = teacher.toJson();
      final revived = UserModel.fromJson(json);
      expect(revived.subjectIds, equals(teacher.subjectIds));
    });

    test('Dropdown safety guard returns null instead of throwing on invalid ID', () {
      final sampleStudents = [
        const StudentModel(
          id: 'student_1',
          name: 'Aarav Patel',
          studentId: 'STD-301',
          classId: 'class_3a_s1',
          className: 'Class 3-A',
          section: 'A',
          schoolId: 'school_1',
          schoolName: 'Primary School 1',
        ),
      ];

      // Simulate the dropdown guard used across screens
      String? invalidStudentId = 'student_nonexistent';
      final effectiveId = sampleStudents.any((s) => s.id == invalidStudentId)
          ? invalidStudentId
          : null;

      expect(effectiveId, isNull);

      String? validStudentId = 'student_1';
      final validEffectiveId = sampleStudents.any((s) => s.id == validStudentId)
          ? validStudentId
          : null;

      expect(validEffectiveId, equals('student_1'));
    });

    test('Teacher only sees tasks and remedials belonging to their assigned subjects', () {
      final teacherGuj = MockData.demoUsers.firstWhere((u) => u.id == 'user_teacher_guj');
      expect(teacherGuj.subjectIds, equals(['subject_guj']));

      // Filter all mock remedial tasks using the teacher's assigned subjects
      final gujTasks = MockData.remedialActions
          .where((r) => teacherGuj.subjectIds!.contains(r.subjectId))
          .toList();

      expect(gujTasks, isNotEmpty);
      for (final task in gujTasks) {
        expect(task.subjectId, equals('subject_guj'));
      }

      // Verify that non-Gujarati tasks (Math, English, EVS) are completely excluded
      expect(gujTasks.any((t) => t.subjectId == 'subject_math'), isFalse);
      expect(gujTasks.any((t) => t.subjectId == 'subject_evs'), isFalse);
      expect(gujTasks.any((t) => t.subjectId == 'subject_english' || t.subjectId == 'subject_eng'), isFalse);
    });
  });

  group('6. AI-Powered Analysis Tests', () {
    late MockAssessmentRepository assessmentRepo;
    late MockSchoolRepository schoolRepo;
    late AiAnalysisService aiService;
    late PerformanceService performanceService;

    setUp(() {
      assessmentRepo = MockAssessmentRepository();
      schoolRepo = MockSchoolRepository();
      aiService = AiAnalysisService();
      performanceService = PerformanceService(
        assessmentRepo,
        schoolRepo,
        aiService: aiService,
      );
    });

    test('Generates AI diagnostic summary with model attribution and actions', () async {
      final summary = await performanceService.getStudentPerformance('student_1');

      expect(summary.isAiGenerated, isTrue);
      expect(summary.aiModel, isNotNull);
      expect(summary.plainLanguageSummary, isNotEmpty);
      expect(summary.recommendedActions, isNotEmpty);
      expect(summary.plainLanguageSummary, contains('Based on the latest regular assessments'));
      // Aarav has weak topics in math (subtraction)
      if (summary.weakTopics.isNotEmpty) {
        expect(summary.plainLanguageSummary, contains('Priority learning gaps'));
      }
    });

    test('Generates localized Gujarati AI diagnostics when languageCode is gu', () async {
      final summary = await performanceService.getStudentPerformance(
        'student_1',
        languageCode: 'gu',
      );

      expect(summary.isAiGenerated, isTrue);
      expect(summary.plainLanguageSummary, contains('તાજેતરના નિયમિત મૂલ્યાંકનો પર આધારિત'));
      expect(summary.recommendedActions.first, matches(RegExp(r'[\u0A80-\u0AFF]')));
    });

    test('AI service handles unassessed students gracefully in both languages', () async {
      final enSummary = await performanceService.getStudentPerformance(
        'non_existent_student',
        languageCode: 'en',
      );
      expect(enSummary.plainLanguageSummary, contains('No assessments recorded yet'));

      final guSummary = await performanceService.getStudentPerformance(
        'non_existent_student',
        languageCode: 'gu',
      );
      expect(guSummary.plainLanguageSummary, contains('હજુ સુધી કોઈ મૂલ્યાંકન નોંધાયેલ નથી'));
    });
  });

  group('7. BRC School Analytics Tests', () {
    test('All block schools have valid classes, students, and derivable metrics', () {
      for (final school in MockData.schools) {
        final schoolClasses = MockData.classes
            .where((c) => c.schoolId == school.id)
            .toList();
        final schoolStudents = MockData.students
            .where((s) => s.schoolId == school.id)
            .toList();

        expect(schoolClasses, isNotEmpty, reason: '${school.name} should have classes');
        expect(schoolStudents, isNotEmpty, reason: '${school.name} should have students');

        final studentIds = schoolStudents.map((s) => s.id).toSet();
        final schoolAssessments = MockData.assessments
            .where((a) => studentIds.contains(a.studentId) && a.type == AssessmentType.regular)
            .toList();

        expect(schoolAssessments, isNotEmpty, reason: '${school.name} should have regular assessments');

        final avgScore = schoolAssessments.map((a) => a.percentage).reduce((a, b) => a + b) /
            schoolAssessments.length;
        expect(avgScore, greaterThan(0.0));
        expect(avgScore, lessThanOrEqualTo(100.0));
      }
    });
  });

  group('8. Fast2SMS Automated Messaging Service Tests', () {
    test('Cleans Indian phone numbers to 10 digits properly', () {
      expect(Fast2SmsService.cleanIndianPhoneNumber('+91 98765 43210'), '9876543210');
      expect(Fast2SmsService.cleanIndianPhoneNumber('919876543210'), '9876543210');
      expect(Fast2SmsService.cleanIndianPhoneNumber('09876543210'), '9876543210');
      expect(Fast2SmsService.cleanIndianPhoneNumber('98765-43210'), '9876543210');
    });

    test('Validates missing API key and invalid phone length', () async {
      final service = Fast2SmsService();
      // Test missing key
      final resultNoKey = await service.sendSms(
        phone: '9876543210',
        message: 'Test message',
      );
      expect(resultNoKey.success, isFalse);
      expect(resultNoKey.message, contains('API key is not configured'));

      // Test invalid phone number with key
      final resultBadPhone = await service.sendSms(
        phone: '12345',
        message: 'Test message',
        apiKeyOverride: 'test_key',
      );
      expect(resultBadPhone.success, isFalse);
      expect(resultBadPhone.message, contains('Expected 10 digits'));
    });

    test('Routes textbelt key without requiring Fast2SMS key', () async {
      final service = Fast2SmsService(apiKey: 'textbelt');
      final key = await service.getApiKey();
      expect(key, 'textbelt');
    });
  });

  group('9. Mobile Layout & Responsiveness Tests', () {
    testWidgets('StatCard renders without overflow in tight 160x135 mobile cell', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 160,
              height: 135,
              child: StatCard(
                title: 'Students Needing Support',
                value: '18',
                subtitle: 'Below 40% threshold',
                icon: Icons.warning_amber_rounded,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('18'), findsOneWidget);
      expect(find.text('Students Needing Support'), findsOneWidget);
      expect(find.text('Below 40% threshold'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('10. BRC School Visit & Calendar Reminder Tests', () {
    test('BrcSchoolVisit model holds all inspection parameters', () {
      final scheduledDate = DateTime(2026, 11, 20, 10, 30);
      final visit = BrcSchoolVisit(
        id: 'visit_1',
        schoolId: 'school_1',
        schoolName: 'GPS Sector 7 Primary School',
        schoolAddress: 'Sector 7, Gandhinagar',
        dateTime: scheduledDate,
        purpose: 'Remedial Teaching & FLN Review',
        reminderTiming: '1 day before (09:00 AM)',
        notes: 'Check Class 3 Math remediation records.',
      );

      expect(visit.id, 'visit_1');
      expect(visit.schoolId, 'school_1');
      expect(visit.schoolName, 'GPS Sector 7 Primary School');
      expect(visit.schoolAddress, 'Sector 7, Gandhinagar');
      expect(visit.dateTime, scheduledDate);
      expect(visit.purpose, 'Remedial Teaching & FLN Review');
      expect(visit.reminderTiming, '1 day before (09:00 AM)');
      expect(visit.notes, contains('Class 3 Math'));
    });
  });

  group('11. Results Section Class Filter Tests', () {
    test('Format class model into 3-A and 4-A labels', () {
      final class3A = MockData.classes.firstWhere((c) => c.name == 'Class 3' && c.section == 'A');
      final class4A = MockData.classes.firstWhere((c) => c.name == 'Class 4' && c.section == 'A');

      String formatClassLabel(ClassModel c) {
        final clean = c.name.replaceAll(RegExp(r'Class\s*', caseSensitive: false), '').trim();
        if (c.section.isNotEmpty) {
          return '$clean-${c.section}';
        }
        return clean;
      }

      expect(formatClassLabel(class3A), '3-A');
      expect(formatClassLabel(class4A), '4-A');
    });

    test('AssessmentProvider loads all assessments and filters by class', () async {
      final repo = MockAssessmentRepository();
      final storage = StorageService();
      final prov = AssessmentProvider(repo, storage);

      await prov.loadAllAssessments();
      expect(prov.assessments.isNotEmpty, isTrue);

      await prov.loadAssessmentsByClass('class_3a_s1');
      expect(prov.assessments.isNotEmpty, isTrue);
      final class3Students = MockData.students.where((s) => s.classId == 'class_3a_s1').map((s) => s.id).toSet();
      for (final a in prov.assessments) {
        expect(class3Students.contains(a.studentId), isTrue);
      }
    });
  });
}
