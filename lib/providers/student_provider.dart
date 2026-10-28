import 'package:flutter/foundation.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/repositories/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository _studentRepo;

  List<StudentModel> _students = [];
  StudentModel? _selectedStudent;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  StudentProvider(this._studentRepo);

  List<StudentModel> get students => _searchQuery.isEmpty
      ? _students
      : _students
            .where(
              (s) =>
                  s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  s.studentId.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();
  StudentModel? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectStudent(StudentModel? student) {
    _selectedStudent = student;
    notifyListeners();
  }

  Future<void> loadStudentsByClass(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _studentRepo.getStudentsByClass(classId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load students: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentsBySchool(String schoolId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _studentRepo.getStudentsBySchool(schoolId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load students: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentsByIds(List<String> ids) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _studentRepo.getStudentsByIds(ids);
      if (_students.isNotEmpty && _selectedStudent == null) {
        _selectedStudent = _students.first;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load students: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudent(String studentId) async {
    try {
      final student = await _studentRepo.getStudent(studentId);
      if (student != null) {
        _selectedStudent = student;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load student: $e';
      notifyListeners();
    }
  }

  Future<StudentModel> addStudent(StudentModel student) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _studentRepo.addStudent(student);
      _students.insert(0, created);
      _isLoading = false;
      notifyListeners();
      return created;
    } catch (e) {
      _error = 'Failed to add student: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
