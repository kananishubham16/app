import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/models/quiz_model.dart';
import 'package:learning_setu/repositories/quiz_repository.dart';

class MockQuizRepository implements QuizRepository {
  @override
  Future<List<QuizQuestion>> getQuestions({
    required String classId,
    required String subjectId,
    required String topicId,
  }) async {
    final topicQuestions = MockData.quizQuestions
        .where((q) => q.topicId == topicId)
        .toList();

    if (topicQuestions.isEmpty) {
      return [];
    }

    // Try matching specific class or class prefix (e.g. class_3 matching class_3a_s1)
    final classMatches = topicQuestions.where((q) {
      if (q.classId.isEmpty) return true;
      if (q.classId == classId) return true;
      if (classId.contains(q.classId) || q.classId.contains(classId))
        return true;
      return false;
    }).toList();

    if (classMatches.length >= 5) {
      return classMatches;
    }

    // If class-specific questions are fewer than 5, include all topic questions to guarantee at least 5 questions
    final combined = [...classMatches];
    for (final q in topicQuestions) {
      if (!combined.any((c) => c.id == q.id)) {
        combined.add(q);
      }
    }
    return combined;
  }

  @override
  Future<void> saveAttempt(QuizAttempt attempt) async {
    MockData.quizAttempts.add(attempt);
  }

  @override
  Future<List<QuizAttempt>> getAttemptsByStudent(String studentId) async {
    return MockData.quizAttempts
        .where((a) => a.studentId == studentId)
        .toList();
  }

  @override
  Future<List<QuizAttempt>> getAttemptsByStudentAndTopic(
    String studentId,
    String topicId,
  ) async {
    return MockData.quizAttempts
        .where((a) => a.studentId == studentId && a.topicId == topicId)
        .toList();
  }
}
