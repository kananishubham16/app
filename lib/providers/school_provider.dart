import 'package:flutter/foundation.dart';
import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/repositories/school_repository.dart';

class SchoolProvider extends ChangeNotifier {
  final SchoolRepository _schoolRepo;

  List<SchoolModel> _schools = [];
  List<ClassModel> _classes = [];
  List<SubjectModel> _subjects = [];
  ClassModel? _selectedClass;
  SchoolModel? _selectedSchool;
  bool _isLoading = false;
  String? _error;

  SchoolProvider(this._schoolRepo);

  List<SchoolModel> get schools => _schools;
  List<ClassModel> get classes => _classes;
  List<SubjectModel> get subjects => _subjects;
  ClassModel? get selectedClass => _selectedClass;
  SchoolModel? get selectedSchool => _selectedSchool;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectClass(ClassModel? cls) {
    _selectedClass = cls;
    notifyListeners();
  }

  void selectSchool(SchoolModel? school) {
    _selectedSchool = school;
    notifyListeners();
  }

  Future<void> loadSchoolsByBlock(String blockId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _schools = await _schoolRepo.getSchoolsByBlock(blockId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load schools: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClassesBySchool(String schoolId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _classes = await _schoolRepo.getClassesBySchool(schoolId);
      if (_classes.isNotEmpty && _selectedClass == null) {
        _selectedClass = _classes.first;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load classes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubjects({String? classId}) async {
    try {
      _subjects = await _schoolRepo.getSubjects(classId: classId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load subjects: $e';
      notifyListeners();
    }
  }
}
