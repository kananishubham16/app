import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/repositories/school_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';
import 'package:learning_setu/repositories/mock/mock_school_repository.dart';

class ApiSchoolRepository implements SchoolRepository {
  final ApiClient client;
  final MockSchoolRepository _mockFallback = MockSchoolRepository();

  ApiSchoolRepository({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<List<SchoolModel>> getSchoolsByBlock(String blockId) async {
    try {
      final res = await client.get('schools', queryParameters: {'blockId': blockId});
      if (res is List) {
        final list = res.map((item) => SchoolModel.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockFallback.getSchoolsByBlock(blockId);
  }

  @override
  Future<SchoolModel?> getSchool(String schoolId) async {
    try {
      final res = await client.get('schools/$schoolId');
      if (res != null) {
        return SchoolModel.fromJson(res as Map<String, dynamic>);
      }
    } catch (_) {}
    return _mockFallback.getSchool(schoolId);
  }

  @override
  Future<List<ClassModel>> getClassesBySchool(String schoolId) async {
    try {
      final res = await client.get('classes', queryParameters: {'schoolId': schoolId});
      if (res is List) {
        final list = res.map((item) => ClassModel.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockFallback.getClassesBySchool(schoolId);
  }

  @override
  Future<ClassModel?> getClass(String classId) async {
    try {
      final res = await client.get('classes/$classId');
      if (res != null) {
        return ClassModel.fromJson(res as Map<String, dynamic>);
      }
    } catch (_) {}
    return _mockFallback.getClass(classId);
  }

  @override
  Future<BlockModel?> getBlock(String blockId) async {
    try {
      final res = await client.get('blocks/$blockId');
      if (res != null) {
        return BlockModel.fromJson(res as Map<String, dynamic>);
      }
    } catch (_) {}
    return _mockFallback.getBlock(blockId);
  }

  @override
  Future<List<SubjectModel>> getSubjects({String? classId}) async {
    try {
      final res = await client.get('subjects', queryParameters: {
        if (classId != null && classId.isNotEmpty) 'classId': classId,
      });
      if (res is List) {
        final list = res.map((item) => SubjectModel.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockFallback.getSubjects(classId: classId);
  }
}
