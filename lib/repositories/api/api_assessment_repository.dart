import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/repositories/assessment_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';

class ApiAssessmentRepository implements AssessmentRepository {
  final ApiClient client;

  ApiAssessmentRepository({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<List<AssessmentModel>> getAssessmentsByStudent(String studentId) async {
    final res = await client.get('assessments', queryParameters: {'studentId': studentId});
    if (res is List) {
      return res.map((item) => AssessmentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<AssessmentModel>> getAssessmentsByStudentAndSubject(
    String studentId,
    String subjectId,
  ) async {
    final res = await client.get('assessments', queryParameters: {
      'studentId': studentId,
      'subjectId': subjectId,
    });
    if (res is List) {
      return res.map((item) => AssessmentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
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
        return AssessmentModel.fromJson(res as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Future<void> addAssessment(AssessmentModel assessment) async {
    await client.post('assessments', body: assessment.toJson());
  }

  @override
  Future<List<AssessmentModel>> getAssessmentsByClass(String classId) async {
    final res = await client.get('assessments', queryParameters: {'classId': classId});
    if (res is List) {
      return res.map((item) => AssessmentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<AssessmentModel>> getAllAssessments() async {
    final res = await client.get('assessments');
    if (res is List) {
      return res.map((item) => AssessmentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
