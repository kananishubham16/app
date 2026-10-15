import 'package:learning_setu/models/quiz_model.dart';

abstract class QuizRepository {
  Future<List<QuizQuestion>> getQuestions({
    required String classId,
    required String subjectId,
    required String topicId,
  });
  Future<void> saveAttempt(QuizAttempt attempt);
  Future<List<QuizAttempt>> getAttemptsByStudent(String studentId);
  Future<List<QuizAttempt>> getAttemptsByStudentAndTopic(
    String studentId,
    String topicId,
  );
}
