import 'package:learning_setu/models/quiz_model.dart';
import 'package:learning_setu/repositories/quiz_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';
import 'package:learning_setu/repositories/mock/mock_quiz_repository.dart';

class ApiQuizRepository implements QuizRepository {
  final ApiClient client;
  final MockQuizRepository _mockFallback = MockQuizRepository();

  ApiQuizRepository({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<List<QuizQuestion>> getQuestions({
    required String classId,
    required String subjectId,
    required String topicId,
  }) async {
    try {
      final res = await client.get('quizzes/questions', queryParameters: {
        'topicId': topicId,
        'classId': classId,
        'subjectId': subjectId,
      });
      if (res is List) {
        final list = res.map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockFallback.getQuestions(classId: classId, subjectId: subjectId, topicId: topicId);
  }

  @override
  Future<void> saveAttempt(QuizAttempt attempt) async {
    try {
      await client.post('quizzes/attempts', body: attempt.toJson());
    } catch (_) {}
    await _mockFallback.saveAttempt(attempt);
  }

  @override
  Future<List<QuizAttempt>> getAttemptsByStudent(String studentId) async {
    try {
      final res = await client.get('quizzes/attempts', queryParameters: {'studentId': studentId});
      if (res is List) {
        final list = res.map((item) => QuizAttempt.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockFallback.getAttemptsByStudent(studentId);
  }

  @override
  Future<List<QuizAttempt>> getAttemptsByStudentAndTopic(
    String studentId,
    String topicId,
  ) async {
    try {
      final res = await client.get('quizzes/attempts', queryParameters: {
        'studentId': studentId,
        'topicId': topicId,
      });
      if (res is List) {
        final list = res.map((item) => QuizAttempt.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockFallback.getAttemptsByStudentAndTopic(studentId, topicId);
  }
}
