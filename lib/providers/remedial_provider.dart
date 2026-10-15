import 'package:flutter/foundation.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/repositories/remedial_repository.dart';
import 'package:learning_setu/services/storage_service.dart';

class RemedialProvider extends ChangeNotifier {
  final RemedialRepository _remedialRepo;
  final StorageService _storageService;

  List<RemedialAction> _remedials = [];
  bool _isLoading = false;
  String? _error;
  StorageService get storageService => _storageService;

  RemedialProvider(this._remedialRepo, this._storageService);

  List<RemedialAction> get remedials => _remedials;
  List<RemedialAction> get pendingRemedials => _remedials
      .where(
        (r) =>
            r.status == RemedialStatus.assigned ||
            r.status == RemedialStatus.inProgress,
      )
      .toList();
  List<RemedialAction> get completedRemedials =>
      _remedials.where((r) => r.status == RemedialStatus.completed).toList();
  List<RemedialAction> get needsFollowUpRemedials => _remedials
      .where((r) => r.status == RemedialStatus.needsFollowUp)
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRemedialsByStudent(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _remedials = await _remedialRepo.getRemedialsByStudent(studentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load remedial actions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRemedialsBySchool(String schoolId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _remedials = await _remedialRepo.getRemedialsBySchool(schoolId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load remedial actions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRemedial(RemedialAction action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _remedialRepo.addRemedial(action);
      _remedials.add(action);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add remedial action: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(String id, RemedialStatus status) async {
    try {
      await _remedialRepo.updateRemedialStatus(id, status);
      final index = _remedials.indexWhere((r) => r.id == id);
      if (index >= 0) {
        _remedials[index] = _remedials[index].copyWith(status: status);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update status: $e';
      notifyListeners();
      return false;
    }
  }

  List<RemedialAction> getByStudent(String studentId) {
    return _remedials.where((r) => r.studentId == studentId).toList();
  }
}
