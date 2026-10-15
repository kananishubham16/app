import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/repositories/school_repository.dart';

class MockSchoolRepository implements SchoolRepository {
  @override
  Future<List<SchoolModel>> getSchoolsByBlock(String blockId) async {
    return MockData.schools.where((s) => s.blockId == blockId).toList();
  }

  @override
  Future<SchoolModel?> getSchool(String schoolId) async {
    try {
      return MockData.schools.firstWhere((s) => s.id == schoolId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ClassModel>> getClassesBySchool(String schoolId) async {
    return MockData.classes.where((c) => c.schoolId == schoolId).toList();
  }

  @override
  Future<ClassModel?> getClass(String classId) async {
    try {
      return MockData.classes.firstWhere((c) => c.id == classId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BlockModel?> getBlock(String blockId) async {
    try {
      return MockData.blocks.firstWhere((b) => b.id == blockId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SubjectModel>> getSubjects({String? classId}) async {
    if (classId == null || classId.isEmpty) {
      return MockData.subjects;
    }
    final filtered = MockData.subjects.where((s) {
      return s.applicableClassIds.isEmpty ||
          s.applicableClassIds.contains(classId) ||
          s.applicableClassIds.any(
            (cid) => classId.contains(cid) || cid.contains(classId),
          );
    }).toList();

    return filtered.isNotEmpty ? filtered : MockData.subjects;
  }
}
