import 'package:learning_setu/models/student_model.dart';

abstract class StudentRepository {
  Future<List<StudentModel>> getStudentsByClass(String classId);
  Future<List<StudentModel>> getStudentsBySchool(String schoolId);
  Future<List<StudentModel>> getStudentsByIds(List<String> ids);
  Future<StudentModel?> getStudent(String studentId);
  Future<List<StudentModel>> searchStudents(String query, {String? classId});
}
