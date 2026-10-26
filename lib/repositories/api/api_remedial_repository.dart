import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/repositories/remedial_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';
import 'package:learning_setu/repositories/mock/mock_remedial_repository.dart';

class ApiRemedialRepository implements RemedialRepository {
  final ApiClient client;
  final MockRemedialRepository _mockFallback = MockRemedialRepository();

  ApiRemedialRepository({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<List<RemedialAction>> getRemedialsByStudent(String studentId) async {
    try {
      final res = await client.get('remedials', queryParameters: {'studentId': studentId});
      if (res is List) {
        final list = res.map((item) => RemedialAction.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockFallback.getRemedialsByStudent(studentId);
  }

  @override
  Future<List<RemedialAction>> getRemedialsByClass(String classId) async {
    try {
      final res = await client.get('remedials', queryParameters: {'classId': classId});
      if (res is List) {
        final list = res.map((item) => RemedialAction.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockFallback.getRemedialsByClass(classId);
  }

  @override
  Future<List<RemedialAction>> getRemedialsBySchool(String schoolId) async {
    try {
      final res = await client.get('remedials', queryParameters: {'schoolId': schoolId});
      if (res is List) {
        final list = res.map((item) => RemedialAction.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockFallback.getRemedialsBySchool(schoolId);
  }

  @override
  Future<void> addRemedial(RemedialAction action) async {
    try {
      await client.post('remedials', body: action.toJson());
    } catch (_) {}
    await _mockFallback.addRemedial(action);
  }

  @override
  Future<void> updateRemedialStatus(String id, RemedialStatus status) async {
    try {
      await client.patch('remedials/$id/status', body: {'status': status.name});
    } catch (_) {}
    await _mockFallback.updateRemedialStatus(id, status);
  }

  @override
  Future<List<RemedialAction>> getPendingRemedials({String? studentId}) async {
    try {
      final res = await client.get('remedials', queryParameters: {
        if (studentId != null && studentId.isNotEmpty) 'studentId': studentId,
        'pendingOnly': true,
      });
      if (res is List) {
        final list = res.map((item) => RemedialAction.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockFallback.getPendingRemedials(studentId: studentId);
  }
}
