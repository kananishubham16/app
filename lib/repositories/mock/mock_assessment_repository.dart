import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/repositories/assessment_repository.dart';

class MockAssessmentRepository implements AssessmentRepository {
  @override
  Future<List<AssessmentModel>> getAssessmentsByStudent(
    String studentId,
  ) async {
    return MockData.assessments.where((a) => a.studentId == studentId).toList();
  }

  @override
  Future<List<AssessmentModel>> getAssessmentsByStudentAndSubject(
    String studentId,
    String subjectId,
  ) async {
    return MockData.assessments
        .where((a) => a.studentId == studentId && a.subjectId == subjectId)
        .toList();
  }

  @override
  Future<AssessmentModel?> getLatestAssessment(
    String studentId,
    String subjectId, {
    AssessmentType? type,
  }) async {
    final list = MockData.assessments.where((a) {
      final matches = a.studentId == studentId && a.subjectId == subjectId;
      if (type != null) {
        return matches && a.type == type;
      }
      return matches;
    }).toList();

    if (list.isEmpty) return null;
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.first;
  }

  @override
  Future<void> addAssessment(AssessmentModel assessment) async {
    MockData.assessments.insert(0, assessment);
  }

  @override
  Future<List<AssessmentModel>> getAssessmentsByClass(String classId) async {
    final studentIds = MockData.students
        .where((s) => s.classId == classId)
        .map((s) => s.id)
        .toSet();
    return MockData.assessments
        .where((a) => studentIds.contains(a.studentId))
        .toList();
  }

  @override
  Future<List<AssessmentModel>> getAllAssessments() async {
    return List.from(MockData.assessments);
  }
}
