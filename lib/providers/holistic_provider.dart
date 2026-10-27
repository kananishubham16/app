import 'package:flutter/foundation.dart';
import 'package:learning_setu/models/holistic_evaluation_model.dart';
import 'package:learning_setu/services/storage_service.dart';

class HolisticProvider with ChangeNotifier {
  final StorageService _storageService;
  Map<String, HolisticEvaluationModel> _evaluations = {};
  bool _isLoading = false;

  HolisticProvider(this._storageService) {
    loadEvaluations();
  }

  bool get isLoading => _isLoading;
  List<HolisticEvaluationModel> get evaluations => _evaluations.values.toList();

  static final List<HolisticEvaluationModel> _seedEvaluations = [
    HolisticEvaluationModel(
      studentId: 'student_1',
      practiceGrit: 84.0,
      learningConsistency: 88.0,
      engagementCuriosity: 82.0,
      teamworkEmpathy: 86.0,
      coCurricular: 80.0,
      teacherNotes:
          'Aarav shows remarkable perseverance during math problem-solving and actively supports his peers in group activities.',
      badges: [
        CharacterBadge(
          id: 'b1_aarav',
          badgeKey: 'curious_mind',
          title: 'Curious Questioner',
          titleGu: 'જિજ્ઞાસુ વિદ્યાર્થી',
          iconName: 'lightbulb_outline',
          awardedBy: 'Anita Sharma',
          awardedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        CharacterBadge(
          id: 'b2_aarav',
          badgeKey: 'team_player',
          title: 'Team Player & Empathy',
          titleGu: 'સહકાર અને ટીમવર્ક',
          iconName: 'handshake_outlined',
          awardedBy: 'Anita Sharma',
          awardedAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ],
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HolisticEvaluationModel(
      studentId: 'student_2',
      practiceGrit: 92.0,
      learningConsistency: 95.0,
      engagementCuriosity: 90.0,
      teamworkEmpathy: 88.0,
      coCurricular: 85.0,
      teacherNotes:
          'Diya is exceptionally consistent, punctual, and approaches every assignment with high enthusiasm and creativity.',
      badges: [
        CharacterBadge(
          id: 'b1_diya',
          badgeKey: 'high_effort',
          title: 'High Effort & Grit',
          titleGu: 'ખંત અને સાતત્યપૂર્ણ પ્રયાસ',
          iconName: 'track_changes_outlined',
          awardedBy: 'Anita Sharma',
          awardedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        CharacterBadge(
          id: 'b2_diya',
          badgeKey: 'creative_thinker',
          title: 'Creative Thinker',
          titleGu: 'સર્જનાત્મક વિચારસરણી',
          iconName: 'palette_outlined',
          awardedBy: 'Anita Sharma',
          awardedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    HolisticEvaluationModel(
      studentId: 'student_3',
      practiceGrit: 72.0,
      learningConsistency: 78.0,
      engagementCuriosity: 80.0,
      teamworkEmpathy: 75.0,
      coCurricular: 88.0,
      teacherNotes:
          'Kabir has vibrant energy and shows keen curiosity in sports and outdoor exploration.',
      badges: [
        CharacterBadge(
          id: 'b1_kabir',
          badgeKey: 'active_sport',
          title: 'Energetic & Well-being',
          titleGu: 'ઉત્સાહી અને શારીરિક સુદ્રઢતા',
          iconName: 'sports_volleyball_outlined',
          awardedBy: 'Vikram Rathod',
          awardedAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ],
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  Future<void> loadEvaluations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loaded = await _storageService.loadHolisticEvaluations();
      if (loaded.isEmpty) {
        _evaluations = {
          for (final e in _seedEvaluations) e.studentId: e,
        };
        await _storageService.saveHolisticEvaluations(_evaluations.values.toList());
      } else {
        _evaluations = {
          for (final e in loaded) e.studentId: e,
        };
      }
    } catch (e) {
      debugPrint('Error loading holistic evaluations: $e');
      _evaluations = {
        for (final e in _seedEvaluations) e.studentId: e,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  HolisticEvaluationModel getEvaluationForStudent(String studentId) {
    if (_evaluations.containsKey(studentId)) {
      return _evaluations[studentId]!;
    }
    // Return a default initial evaluation
    final defaultEval = HolisticEvaluationModel(
      studentId: studentId,
      practiceGrit: 75.0,
      learningConsistency: 80.0,
      engagementCuriosity: 75.0,
      teamworkEmpathy: 78.0,
      coCurricular: 75.0,
      teacherNotes: 'Consistently shows effort in daily activities.',
      badges: const [],
      updatedAt: DateTime.now(),
    );
    _evaluations[studentId] = defaultEval;
    return defaultEval;
  }

  /// Automatically update Effort (Grit) and Consistency without manual form filling
  Future<void> autoUpdateMetrics({
    required String studentId,
    int completedRemedials = 0,
    int totalRemedials = 0,
    int attendedDays = 22,
    int totalWorkingDays = 25,
  }) async {
    final existing = getEvaluationForStudent(studentId);

    // Effort score calculated based on completion rate and dedication
    double calculatedGrit = existing.practiceGrit;
    if (totalRemedials > 0) {
      final completionRate = (completedRemedials / totalRemedials) * 100.0;
      calculatedGrit = (existing.practiceGrit * 0.4 + completionRate * 0.6)
          .clamp(50.0, 100.0);
    } else if (completedRemedials > 0) {
      calculatedGrit = (existing.practiceGrit + completedRemedials * 2)
          .clamp(50.0, 100.0);
    }

    // Consistency score based on attendance / regular activity
    double calculatedConsistency = existing.learningConsistency;
    if (totalWorkingDays > 0) {
      final attRate = (attendedDays / totalWorkingDays) * 100.0;
      calculatedConsistency = (existing.learningConsistency * 0.3 + attRate * 0.7)
          .clamp(50.0, 100.0);
    }

    final updated = existing.copyWith(
      practiceGrit: double.parse(calculatedGrit.toStringAsFixed(1)),
      learningConsistency: double.parse(calculatedConsistency.toStringAsFixed(1)),
      updatedAt: DateTime.now(),
    );

    _evaluations[studentId] = updated;
    await _storageService.saveHolisticEvaluations(_evaluations.values.toList());
    notifyListeners();
  }

  /// 1-Tap Positive Shout-Out Character Badge Awarding
  Future<void> awardBadge({
    required String studentId,
    required String badgeKey,
    required String teacherName,
    String? note,
  }) async {
    final existing = getEvaluationForStudent(studentId);

    final template = CharacterBadge.availableTemplates.firstWhere(
      (t) => t['key'] == badgeKey,
      orElse: () => CharacterBadge.availableTemplates.first,
    );

    final newBadge = CharacterBadge(
      id: 'badge_${DateTime.now().millisecondsSinceEpoch}',
      badgeKey: template['key'] ?? 'high_effort',
      title: template['title'] ?? 'High Effort',
      titleGu: template['titleGu'] ?? 'પરિશ્રમી પ્રયાસ',
      iconName: template['icon'] ?? 'star',
      awardedBy: teacherName,
      awardedAt: DateTime.now(),
    );

    // Boost corresponding trait scores slightly for positive reinforcement
    double updatedGrit = existing.practiceGrit;
    double updatedConsistency = existing.learningConsistency;
    double updatedCuriosity = existing.engagementCuriosity;
    double updatedTeamwork = existing.teamworkEmpathy;
    double updatedCoCurricular = existing.coCurricular;

    switch (newBadge.badgeKey) {
      case 'high_effort':
        updatedGrit = (updatedGrit + 3.0).clamp(0.0, 100.0);
        break;
      case 'curious_mind':
        updatedCuriosity = (updatedCuriosity + 4.0).clamp(0.0, 100.0);
        break;
      case 'team_player':
        updatedTeamwork = (updatedTeamwork + 4.0).clamp(0.0, 100.0);
        break;
      case 'creative_thinker':
        updatedCuriosity = (updatedCuriosity + 3.0).clamp(0.0, 100.0);
        updatedCoCurricular = (updatedCoCurricular + 3.0).clamp(0.0, 100.0);
        break;
      case 'active_sport':
        updatedCoCurricular = (updatedCoCurricular + 5.0).clamp(0.0, 100.0);
        updatedConsistency = (updatedConsistency + 2.0).clamp(0.0, 100.0);
        break;
    }

    final updatedBadges = List<CharacterBadge>.from(existing.badges)
      ..insert(0, newBadge);

    final updatedEval = existing.copyWith(
      practiceGrit: double.parse(updatedGrit.toStringAsFixed(1)),
      learningConsistency: double.parse(updatedConsistency.toStringAsFixed(1)),
      engagementCuriosity: double.parse(updatedCuriosity.toStringAsFixed(1)),
      teamworkEmpathy: double.parse(updatedTeamwork.toStringAsFixed(1)),
      coCurricular: double.parse(updatedCoCurricular.toStringAsFixed(1)),
      teacherNotes: note != null && note.isNotEmpty ? note : existing.teacherNotes,
      badges: updatedBadges,
      updatedAt: DateTime.now(),
    );

    _evaluations[studentId] = updatedEval;
    await _storageService.saveHolisticEvaluations(_evaluations.values.toList());
    notifyListeners();
  }

  /// Reset demo evaluations
  Future<void> resetToDefault() async {
    _evaluations = {
      for (final e in _seedEvaluations) e.studentId: e,
    };
    await _storageService.saveHolisticEvaluations(_evaluations.values.toList());
    notifyListeners();
  }
}
