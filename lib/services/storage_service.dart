import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/quiz_model.dart';
import 'package:learning_setu/models/remedial_model.dart';

class StorageService {
  static const String _assessmentsKey = 'local_assessments';
  static const String _quizAttemptsKey = 'local_quiz_attempts';
  static const String _remedialsKey = 'local_remedials';
  static const String _currentUserKey = 'current_user';

  // Save assessments
  Future<void> saveAssessments(List<AssessmentModel> assessments) async {
    final prefs = await SharedPreferences.getInstance();
    final json = assessments.map((a) => a.toJson()).toList();
    await prefs.setString(_assessmentsKey, jsonEncode(json));
  }

  Future<List<AssessmentModel>> loadAssessments() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_assessmentsKey);
    if (str == null) return [];
    final list = jsonDecode(str) as List;
    return list
        .map((j) => AssessmentModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // Save quiz attempts
  Future<void> saveQuizAttempts(List<QuizAttempt> attempts) async {
    final prefs = await SharedPreferences.getInstance();
    final json = attempts.map((a) => a.toJson()).toList();
    await prefs.setString(_quizAttemptsKey, jsonEncode(json));
  }

  Future<List<QuizAttempt>> loadQuizAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_quizAttemptsKey);
    if (str == null) return [];
    final list = jsonDecode(str) as List;
    return list
        .map((j) => QuizAttempt.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // Save remedials
  Future<void> saveRemedials(List<RemedialAction> remedials) async {
    final prefs = await SharedPreferences.getInstance();
    final json = remedials.map((a) => a.toJson()).toList();
    await prefs.setString(_remedialsKey, jsonEncode(json));
  }

  Future<List<RemedialAction>> loadRemedials() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_remedialsKey);
    if (str == null) return [];
    final list = jsonDecode(str) as List;
    return list
        .map((j) => RemedialAction.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // Save current user ID
  Future<void> saveCurrentUser(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, userId);
    }
  }

  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Reset all demo data
  Future<void> resetDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_assessmentsKey);
    await prefs.remove(_quizAttemptsKey);
    await prefs.remove(_remedialsKey);
    await prefs.remove(_currentUserKey);
  }
}
