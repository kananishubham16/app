import 'package:learning_setu/models/remedial_model.dart';

abstract class RemedialRepository {
  Future<List<RemedialAction>> getRemedialsByStudent(String studentId);
  Future<List<RemedialAction>> getRemedialsByClass(String classId);
  Future<List<RemedialAction>> getRemedialsBySchool(String schoolId);
  Future<void> addRemedial(RemedialAction action);
  Future<void> updateRemedialStatus(String id, RemedialStatus status);
  Future<List<RemedialAction>> getPendingRemedials({String? studentId});
}
