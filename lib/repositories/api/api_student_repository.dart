import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/repositories/student_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';

class ApiStudentRepository implements StudentRepository {
  final ApiClient client;

  ApiStudentRepository({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<List<StudentModel>> getStudentsByClass(String classId) async {
    final res = await client.get('students', queryParameters: {'classId': classId});
    if (res is List) {
      return res.map((item) => StudentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<StudentModel>> getStudentsBySchool(String schoolId) async {
    final res = await client.get('students', queryParameters: {'schoolId': schoolId});
    if (res is List) {
      return res.map((item) => StudentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<StudentModel>> getStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final res = await client.get('students', queryParameters: {'ids': ids.join(',')});
    if (res is List) {
      return res.map((item) => StudentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<StudentModel?> getStudent(String studentId) async {
    try {
      final res = await client.get('students/$studentId');
      if (res != null) {
        return StudentModel.fromJson(res as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Future<List<StudentModel>> searchStudents(String query, {String? classId}) async {
    final res = await client.get('students', queryParameters: {
      'query': query,
      if (classId != null && classId.isNotEmpty) 'classId': classId,
    });
    if (res is List) {
      return res.map((item) => StudentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
