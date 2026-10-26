import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/repositories/assessment_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';
import 'package:learning_setu/repositories/mock/mock_assessment_repository.dart';

class ApiAssessmentRepository implements AssessmentRepository {
  final ApiClient client;
  final MockAssessmentRepository _mockFallback = MockAssessmentRepository();

  ApiAssessmentRepository({ApiClient? client}) : client = client ?? ApiClient();

  List<AssessmentModel> _parseAssessmentList(dynamic res) {
    if (res == null) return [];
    dynamic rawList;
    if (res is List) {
      rawList = res;
    } else if (res is Map && res['data'] is List) {
      rawList = res['data'];
    }

    if (rawList is List) {
      return rawList
          .whereType<Map>()
          .map((item) => AssessmentModel.fromJson(item.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  @override
  Future<List<AssessmentModel>> getAssessmentsByStudent(String studentId) async {
    try {
      final res = await client.get('assessments', queryParameters: {'studentId': studentId});
      final list = _parseAssessmentList(res);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return _mockFallback.getAssessmentsByStudent(studentId);
  }

  @override
  Future<List<AssessmentModel>> getAssessmentsByStudentAndSubject(
    String studentId,
    String subjectId,
  ) async {
    try {
      final res = await client.get('assessments', queryParameters: {
        'studentId': studentId,
        'subjectId': subjectId,
      });
      final list = _parseAssessmentList(res);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return _mockFallback.getAssessmentsByStudentAndSubject(studentId, subjectId);
  }

  @override
  Future<AssessmentModel?> getLatestAssessment(
    String studentId,
    String subjectId, {
    AssessmentType? type,
  }) async {
    try {
      final res = await client.get('assessments/latest', queryParameters: {
        'studentId': studentId,
        'subjectId': subjectId,
        if (type != null) 'type': type.name,
      });
      if (res != null) {
        final data = (res is Map && res['data'] is Map)
            ? (res['data'] as Map).cast<String, dynamic>()
            : (res as Map).cast<String, dynamic>();
        return AssessmentModel.fromJson(data);
      }
    } catch (_) {}
    return _mockFallback.getLatestAssessment(studentId, subjectId, type: type);
  }

  @override
  Future<void> addAssessment(AssessmentModel assessment) async {
    try {
      await client.post('assessments', body: assessment.toJson());
    } catch (_) {}
    await _mockFallback.addAssessment(assessment);
  }

  @override
  Future<List<AssessmentModel>> getAssessmentsByClass(String classId) async {
    try {
      final res = await client.get('assessments', queryParameters: {'classId': classId});
      final list = _parseAssessmentList(res);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return _mockFallback.getAssessmentsByClass(classId);
  }

  @override
  Future<List<AssessmentModel>> getAllAssessments() async {
    try {
      final res = await client.get('assessments');
      final list = _parseAssessmentList(res);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return _mockFallback.getAllAssessments();
  }
}
