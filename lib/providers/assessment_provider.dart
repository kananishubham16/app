import 'package:flutter/foundation.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/repositories/assessment_repository.dart';
import 'package:learning_setu/services/storage_service.dart';

class AssessmentProvider extends ChangeNotifier {
  final AssessmentRepository _assessmentRepo;
  final StorageService _storageService;

  List<AssessmentModel> _assessments = [];
  bool _isLoading = false;
  String? _error;

  AssessmentProvider(this._assessmentRepo, this._storageService);

  List<AssessmentModel> get assessments => _assessments;
  List<AssessmentModel> get regularAssessments =>
      _assessments.where((a) => a.type == AssessmentType.regular).toList();
  List<AssessmentModel> get remedialAssessments =>
      _assessments.where((a) => a.type == AssessmentType.remedialQuiz).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  StorageService get storageService => _storageService;

  Future<void> loadAssessmentsByStudent(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assessments = await _assessmentRepo.getAssessmentsByStudent(studentId);
      _assessments.sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load assessments: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAssessmentsByClass(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assessments = await _assessmentRepo.getAssessmentsByClass(classId);
      _assessments.sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load class assessments: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllAssessments({List<String>? classIds}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (classIds != null && classIds.isNotEmpty) {
        final List<AssessmentModel> all = [];
        for (final cid in classIds) {
          final list = await _assessmentRepo.getAssessmentsByClass(cid);
          all.addAll(list);
        }
        _assessments = all;
      } else {
        _assessments = await _assessmentRepo.getAllAssessments();
      }
      _assessments.sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load assessments: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAssessment(AssessmentModel assessment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _assessmentRepo.addAssessment(assessment);
      _assessments.insert(0, assessment);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add assessment: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<AssessmentModel> getBySubject(String subjectId) {
    return _assessments.where((a) => a.subjectId == subjectId).toList();
  }

  List<AssessmentModel> filterAssessments({
    String? studentId,
    String? subjectId,
    DateTime? fromDate,
    DateTime? toDate,
    AssessmentType? type,
  }) {
    return _assessments.where((a) {
      if (studentId != null && a.studentId != studentId) return false;
      if (subjectId != null && a.subjectId != subjectId) return false;
      if (type != null && a.type != type) return false;
      if (fromDate != null && a.date.isBefore(fromDate)) return false;
      if (toDate != null && a.date.isAfter(toDate)) return false;
      return true;
    }).toList();
  }
}
