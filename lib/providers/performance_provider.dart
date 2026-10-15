import 'package:flutter/foundation.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/services/performance_service.dart';

class PerformanceProvider extends ChangeNotifier {
  final PerformanceService _performanceService;

  StudentPerformanceSummary? _summary;
  SchoolPerformanceSummary? _schoolSummary;
  bool _isLoading = false;
  bool _isAiAnalyzing = false;
  String? _error;

  PerformanceProvider(this._performanceService);

  StudentPerformanceSummary? get summary => _summary;
  SchoolPerformanceSummary? get schoolSummary => _schoolSummary;
  bool get isLoading => _isLoading;
  bool get isAiAnalyzing => _isAiAnalyzing;
  String? get error => _error;
  PerformanceService get performanceService => _performanceService;

  Future<void> loadPerformance(
    String studentId, {
    String languageCode = 'en',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _performanceService.getStudentPerformance(
        studentId,
        languageCode: languageCode,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load performance: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchoolPerformance(
    String schoolId, {
    String languageCode = 'en',
    bool forceRefresh = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schoolSummary = await _performanceService.getSchoolPerformance(
        schoolId,
        languageCode: languageCode,
        forceRefresh: forceRefresh,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load school performance: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> regenerateAiAnalysis(
    String studentId, {
    String languageCode = 'en',
  }) async {
    _isAiAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _performanceService.getStudentPerformance(
        studentId,
        languageCode: languageCode,
        forceRefresh: true,
      );
      _isAiAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to regenerate AI analysis: $e';
      _isAiAnalyzing = false;
      notifyListeners();
    }
  }

  void clear() {
    _summary = null;
    _schoolSummary = null;
    _error = null;
    _isAiAnalyzing = false;
    notifyListeners();
  }
}

