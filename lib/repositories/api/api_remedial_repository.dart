import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/repositories/remedial_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';

class ApiRemedialRepository implements RemedialRepository {
  final ApiClient client;

  ApiRemedialRepository({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<List<RemedialAction>> getRemedialsByStudent(String studentId) async {
    final res = await client.get('remedials', queryParameters: {'studentId': studentId});
    if (res is List) {
      return res.map((item) => RemedialAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<RemedialAction>> getRemedialsByClass(String classId) async {
    final res = await client.get('remedials', queryParameters: {'classId': classId});
    if (res is List) {
      return res.map((item) => RemedialAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<RemedialAction>> getRemedialsBySchool(String schoolId) async {
    final res = await client.get('remedials', queryParameters: {'schoolId': schoolId});
    if (res is List) {
      return res.map((item) => RemedialAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<void> addRemedial(RemedialAction action) async {
    await client.post('remedials', body: action.toJson());
  }

  @override
  Future<void> updateRemedialStatus(String id, RemedialStatus status) async {
    await client.patch('remedials/$id/status', body: {'status': status.name});
  }

  @override
  Future<List<RemedialAction>> getPendingRemedials({String? studentId}) async {
    final res = await client.get('remedials', queryParameters: {
      if (studentId != null && studentId.isNotEmpty) 'studentId': studentId,
      'pendingOnly': true,
    });
    if (res is List) {
      return res.map((item) => RemedialAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
