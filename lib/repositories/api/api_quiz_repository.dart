import 'package:learning_setu/models/quiz_model.dart';
import 'package:learning_setu/repositories/quiz_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';

class ApiQuizRepository implements QuizRepository {
  final ApiClient client;

  ApiQuizRepository({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<List<QuizQuestion>> getQuestions({
    required String classId,
    required String subjectId,
    required String topicId,
  }) async {
    final res = await client.get('quizzes/questions', queryParameters: {
      'topicId': topicId,
      'classId': classId,
      'subjectId': subjectId,
    });
    if (res is List) {
      return res.map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<void> saveAttempt(QuizAttempt attempt) async {
    await client.post('quizzes/attempts', body: attempt.toJson());
  }

  @override
  Future<List<QuizAttempt>> getAttemptsByStudent(String studentId) async {
    final res = await client.get('quizzes/attempts', queryParameters: {'studentId': studentId});
    if (res is List) {
      return res.map((item) => QuizAttempt.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<QuizAttempt>> getAttemptsByStudentAndTopic(
    String studentId,
    String topicId,
  ) async {
    final res = await client.get('quizzes/attempts', queryParameters: {
      'studentId': studentId,
      'topicId': topicId,
    });
    if (res is List) {
      return res.map((item) => QuizAttempt.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
