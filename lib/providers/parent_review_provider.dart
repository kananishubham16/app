import 'package:flutter/foundation.dart';
import 'package:learning_setu/models/parent_review_model.dart';
import 'package:learning_setu/services/storage_service.dart';

class ParentReviewProvider with ChangeNotifier {
  final StorageService _storageService;
  List<ParentReviewModel> _reviews = [];
  bool _isLoading = false;

  ParentReviewProvider(this._storageService) {
    loadReviews();
  }

  List<ParentReviewModel> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;

  /// Default seed reviews for demo purposes so that teachers can immediately
  /// observe their assigned subject's parent reviews upon login.
  static final List<ParentReviewModel> _seedReviews = [
    ParentReviewModel(
      id: 'review_aarav_math',
      studentId: 'student_1',
      subjectId: 'subject_math',
      parentName: "Ramesh Patel (Father)",
      reviewText: "Aarav is practicing single-digit additions enthusiastically at home every evening. However, he is having trouble understanding borrowing in 2-digit subtraction. Could teacher please give him extra attention on subtraction in class?",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isAcknowledged: true,
      acknowledgedBy: 'Anita Sharma',
    ),
    ParentReviewModel(
      id: 'review_aarav_guj',
      studentId: 'student_1',
      subjectId: 'subject_guj',
      parentName: "Ramesh Patel (Father)",
      reviewText: "Aarav loves reading Gujarati stories from his textbook aloud before bedtime. His pronunciation has improved a lot thanks to classroom reading exercises.",
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      isAcknowledged: false,
    ),
    ParentReviewModel(
      id: 'review_diya_math',
      studentId: 'student_2',
      subjectId: 'subject_math',
      parentName: "Meena Shah (Mother)",
      reviewText: "Diya finds multiplication tables enjoyable with flashcards. We practice for 15 minutes after dinner.",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isAcknowledged: false,
    ),
  ];

  Future<void> loadReviews() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loaded = await _storageService.loadParentReviews();
      if (loaded.isEmpty) {
        _reviews = List.from(_seedReviews);
        await _storageService.saveParentReviews(_reviews);
      } else {
        _reviews = loaded;
      }
    } catch (e) {
      debugPrint('Error loading parent reviews: $e');
      if (_reviews.isEmpty) {
        _reviews = List.from(_seedReviews);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ParentReviewModel? getReview(String studentId, String subjectId) {
    return _reviews.where(
      (r) => r.studentId == studentId && r.subjectId == subjectId,
    ).firstOrNull;
  }

  List<ParentReviewModel> getReviewsForStudent(String studentId) {
    return _reviews.where((r) => r.studentId == studentId).toList();
  }

  List<ParentReviewModel> getReviewsForSubject(String subjectId) {
    return _reviews.where((r) => r.subjectId == subjectId).toList();
  }

  Future<void> submitOrUpdateReview({
    required String studentId,
    required String subjectId,
    required String parentName,
    required String reviewText,
  }) async {
    final existingIndex = _reviews.indexWhere(
      (r) => r.studentId == studentId && r.subjectId == subjectId,
    );

    final now = DateTime.now();

    if (existingIndex >= 0) {
      final existing = _reviews[existingIndex];
      _reviews[existingIndex] = existing.copyWith(
        parentName: parentName,
        reviewText: reviewText,
        updatedAt: now,
        isAcknowledged: false, // reset acknowledgement on new update
      );
    } else {
      final newReview = ParentReviewModel(
        id: 'review_${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        subjectId: subjectId,
        parentName: parentName,
        reviewText: reviewText,
        createdAt: now,
        isAcknowledged: false,
      );
      _reviews.insert(0, newReview);
    }

    notifyListeners();
    await _storageService.saveParentReviews(_reviews);
  }

  Future<void> toggleAcknowledge(String reviewId, String teacherName) async {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index >= 0) {
      final existing = _reviews[index];
      final newAcknowledged = !existing.isAcknowledged;
      _reviews[index] = existing.copyWith(
        isAcknowledged: newAcknowledged,
        acknowledgedBy: newAcknowledged ? teacherName : null,
      );
      notifyListeners();
      await _storageService.saveParentReviews(_reviews);
    }
  }
}
