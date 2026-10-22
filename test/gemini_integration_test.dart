import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learning_setu/services/ai_analysis_service.dart';
import 'package:learning_setu/services/gemini_service.dart';
import 'package:learning_setu/models/performance_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Gemini API Integration Tests', () {
    test('Test Case 1: .env loads GEMINI_API_KEY correctly', () async {
      await dotenv.load(fileName: '.env').catchError((_) {});
      final key = dotenv.env['GEMINI_API_KEY'];
      expect(key, isNotNull, reason: 'GEMINI_API_KEY must exist in .env');
      expect(key!.isNotEmpty, isTrue, reason: 'GEMINI_API_KEY must not be empty');
    });

    test('Test Case 2: AiAnalysisService resolves API key from environment', () async {
      await dotenv.load(fileName: '.env').catchError((_) {});
      final service = AiAnalysisService();
      final key = await service.getApiKey();
      expect(key, isNotNull);
      expect(key, equals(dotenv.env['GEMINI_API_KEY']));
    });

    test('Test Case 3: GeminiService instantiates properly', () {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'test_key';
      final gemini = GeminiService(apiKey: apiKey);
      expect(gemini.model, isNotNull);
    });

    test('Test Case 4: Student AI Analysis generates valid diagnostics and actions', () async {
      await dotenv.load(fileName: '.env').catchError((_) {});
      final service = AiAnalysisService();

      final result = await service.generateStudentAnalysis(
        studentId: 'test_student_1',
        overallPercentage: 58.5,
        weakTopics: ['2-digit Subtraction with Borrowing', 'Word Problems'],
        subjectsAssessed: 4,
        totalSubjects: 4,
        subjectPerformances: [
          SubjectPerformance(
            subjectId: 'math',
            subjectName: 'Mathematics',
            latestPercentage: 45.0,
            level: PerformanceLevel.average,
            topicPerformances: const [],
          ),
          SubjectPerformance(
            subjectId: 'gujarati',
            subjectName: 'Gujarati',
            latestPercentage: 72.0,
            level: PerformanceLevel.strong,
            topicPerformances: const [],
          ),
        ],
        languageCode: 'en',
      );

      // Verify diagnostics contract
      expect(result.summary, isNotEmpty);
      expect(result.recommendedActions, isNotEmpty);
      expect(result.recommendedActions.length, greaterThanOrEqualTo(2));
      expect(result.modelName, isNotEmpty);
    });

    test('Test Case 5: Gujarati Language Localization returns valid Gujarati output', () async {
      await dotenv.load(fileName: '.env').catchError((_) {});
      final service = AiAnalysisService();

      final result = await service.generateStudentAnalysis(
        studentId: 'test_student_2',
        overallPercentage: 35.0,
        weakTopics: ['શબ્દ પરિચય', 'સરવાળા'],
        subjectsAssessed: 3,
        totalSubjects: 4,
        subjectPerformances: const [],
        languageCode: 'gu',
      );

      expect(result.summary, isNotEmpty);
      expect(result.recommendedActions, isNotEmpty);
      // Verify Gujarati characters are present
      final hasGujaratiChars = RegExp(r'[\u0A80-\u0AFF]').hasMatch(result.summary);
      expect(hasGujaratiChars, isTrue, reason: 'Output should contain Gujarati text when languageCode is gu');
    });

    test('Test Case 6: Institutional School BRC Analysis generates recommendations', () async {
      await dotenv.load(fileName: '.env').catchError((_) {});
      final service = AiAnalysisService();

      final result = await service.generateSchoolAnalysis(
        schoolId: 'sch_gandhinagar_01',
        schoolName: 'Gandhinagar Primary School No. 1',
        overallPercentage: 62.4,
        coveragePercentage: 88.0,
        remedialCompletionRate: 74.0,
        criticalGapTopics: ['Division', 'Fraction Simplification'],
        totalClasses: 8,
        languageCode: 'en',
      );

      expect(result.summary, isNotEmpty);
      expect(result.recommendedActions, isNotEmpty);
      expect(result.recommendedActions.length, greaterThanOrEqualTo(3));
    });
  });
}
