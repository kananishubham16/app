import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/repositories/student_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';
import 'package:learning_setu/repositories/mock/mock_student_repository.dart';

class ApiStudentRepository implements StudentRepository {
  final ApiClient client;
  final MockStudentRepository _mockFallback = MockStudentRepository();

  ApiStudentRepository({ApiClient? client}) : client = client ?? ApiClient();

  List<StudentModel> _parseStudentList(dynamic res) {
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
          .map((item) => StudentModel.fromJson(item.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  @override
  Future<List<StudentModel>> getStudentsByClass(String classId) async {
    try {
      final res = await client.get('students', queryParameters: {
        'classId': classId,
        'className': classId,
      });
      final list = _parseStudentList(res);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return _mockFallback.getStudentsByClass(classId);
  }

  @override
  Future<List<StudentModel>> getStudentsBySchool(String schoolId) async {
    try {
      final res = await client.get('students', queryParameters: {'schoolId': schoolId});
      final list = _parseStudentList(res);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return _mockFallback.getStudentsBySchool(schoolId);
  }

  @override
  Future<List<StudentModel>> getStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final res = await client.get('students', queryParameters: {'ids': ids.join(',')});
      final list = _parseStudentList(res);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return _mockFallback.getStudentsByIds(ids);
  }

  @override
  Future<StudentModel?> getStudent(String studentId) async {
    try {
      final res = await client.get('students/$studentId');
      if (res != null) {
        final data = (res is Map && res['data'] is Map)
            ? (res['data'] as Map).cast<String, dynamic>()
            : (res as Map).cast<String, dynamic>();
        return StudentModel.fromJson(data);
      }
    } catch (_) {}
    return _mockFallback.getStudent(studentId);
  }

  @override
  Future<List<StudentModel>> searchStudents(String query, {String? classId}) async {
    try {
      final res = await client.get('students', queryParameters: {
        'search': query,
        'query': query,
        if (classId != null && classId.isNotEmpty) 'className': classId,
      });
      final list = _parseStudentList(res);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return _mockFallback.searchStudents(query, classId: classId);
  }
}
