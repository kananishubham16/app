import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/repositories/remedial_repository.dart';

class MockRemedialRepository implements RemedialRepository {
  @override
  Future<List<RemedialAction>> getRemedialsByStudent(String studentId) async {
    return MockData.remedialActions
        .where((r) => r.studentId == studentId)
        .toList();
  }

  @override
  Future<List<RemedialAction>> getRemedialsByClass(String classId) async {
    final studentIds = MockData.students
        .where((s) => s.classId == classId)
        .map((s) => s.id)
        .toSet();
    return MockData.remedialActions
        .where((r) => studentIds.contains(r.studentId))
        .toList();
  }

  @override
  Future<List<RemedialAction>> getRemedialsBySchool(String schoolId) async {
    final studentIds = MockData.students
        .where((s) => s.schoolId == schoolId)
        .map((s) => s.id)
        .toSet();
    return MockData.remedialActions
        .where((r) => studentIds.contains(r.studentId))
        .toList();
  }

  @override
  Future<void> addRemedial(RemedialAction action) async {
    MockData.remedialActions.insert(0, action);
  }

  @override
  Future<void> updateRemedialStatus(String id, RemedialStatus status) async {
    final index = MockData.remedialActions.indexWhere((r) => r.id == id);
    if (index >= 0) {
      MockData.remedialActions[index] = MockData.remedialActions[index]
          .copyWith(status: status);
    }
  }

  @override
  Future<List<RemedialAction>> getPendingRemedials({String? studentId}) async {
    return MockData.remedialActions.where((r) {
      final isPending =
          r.status == RemedialStatus.assigned ||
          r.status == RemedialStatus.inProgress;
      if (studentId != null) {
        return isPending && r.studentId == studentId;
      }
      return isPending;
    }).toList();
  }
}
