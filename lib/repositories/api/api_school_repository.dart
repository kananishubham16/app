import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/repositories/school_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';

class ApiSchoolRepository implements SchoolRepository {
  final ApiClient client;

  ApiSchoolRepository({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<List<SchoolModel>> getSchoolsByBlock(String blockId) async {
    final res = await client.get('schools', queryParameters: {'blockId': blockId});
    if (res is List) {
      return res.map((item) => SchoolModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<SchoolModel?> getSchool(String schoolId) async {
    try {
      final res = await client.get('schools/$schoolId');
      if (res != null) {
        return SchoolModel.fromJson(res as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Future<List<ClassModel>> getClassesBySchool(String schoolId) async {
    final res = await client.get('classes', queryParameters: {'schoolId': schoolId});
    if (res is List) {
      return res.map((item) => ClassModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<ClassModel?> getClass(String classId) async {
    try {
      final res = await client.get('classes/$classId');
      if (res != null) {
        return ClassModel.fromJson(res as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Future<BlockModel?> getBlock(String blockId) async {
    try {
      final res = await client.get('blocks/$blockId');
      if (res != null) {
        return BlockModel.fromJson(res as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Future<List<SubjectModel>> getSubjects({String? classId}) async {
    final res = await client.get('subjects', queryParameters: {
      if (classId != null && classId.isNotEmpty) 'classId': classId,
    });
    if (res is List) {
      return res.map((item) => SubjectModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
