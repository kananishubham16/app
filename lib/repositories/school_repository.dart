import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/models/subject_model.dart';

abstract class SchoolRepository {
  Future<List<SchoolModel>> getSchoolsByBlock(String blockId);
  Future<SchoolModel?> getSchool(String schoolId);
  Future<List<ClassModel>> getClassesBySchool(String schoolId);
  Future<ClassModel?> getClass(String classId);
  Future<BlockModel?> getBlock(String blockId);
  Future<List<SubjectModel>> getSubjects({String? classId});
}
