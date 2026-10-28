import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/repositories/student_repository.dart';

class MockStudentRepository implements StudentRepository {
  @override
  Future<List<StudentModel>> getStudentsByClass(String classId) async {
    return MockData.students.where((s) => s.classId == classId).toList();
  }

  @override
  Future<List<StudentModel>> getStudentsBySchool(String schoolId) async {
    return MockData.students.where((s) => s.schoolId == schoolId).toList();
  }

  @override
  Future<List<StudentModel>> getStudentsByIds(List<String> ids) async {
    final idSet = ids.toSet();
    return MockData.students.where((s) => idSet.contains(s.id)).toList();
  }

  @override
  Future<StudentModel?> getStudent(String studentId) async {
    try {
      return MockData.students.firstWhere(
        (s) => s.id == studentId || s.studentId == studentId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<StudentModel>> searchStudents(
    String query, {
    String? classId,
  }) async {
    final q = query.trim().toLowerCase();
    return MockData.students.where((s) {
      final matchesQuery =
          q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.studentId.toLowerCase().contains(q);
      if (classId != null && classId.isNotEmpty) {
        return matchesQuery && s.classId == classId;
      }
      return matchesQuery;
    }).toList();
  }

  @override
  Future<StudentModel> addStudent(StudentModel student) async {
    MockData.students.insert(0, student);
    return student;
  }
}
