import 'package:learning_setu/models/assessment_model.dart';

abstract class AssessmentRepository {
  Future<List<AssessmentModel>> getAssessmentsByStudent(String studentId);
  Future<List<AssessmentModel>> getAssessmentsByStudentAndSubject(
    String studentId,
    String subjectId,
  );
  Future<AssessmentModel?> getLatestAssessment(
    String studentId,
    String subjectId, {
    AssessmentType? type,
  });
  Future<void> addAssessment(AssessmentModel assessment);
  Future<List<AssessmentModel>> getAssessmentsByClass(String classId);
  Future<List<AssessmentModel>> getAllAssessments();
}
