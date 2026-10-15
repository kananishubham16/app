import 'package:flutter/widgets.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

enum PerformanceLevel { weak, average, strong, notAssessed }

class PerformanceClassification {
  static const double weakThreshold = 40.0;
  static const double averageThreshold = 70.0;

  /// NOTE: These are prototype/demo thresholds for illustration.
  /// They do not represent official education policy.
  static PerformanceLevel classify(double? percentage) {
    if (percentage == null) return PerformanceLevel.notAssessed;
    if (percentage < weakThreshold) return PerformanceLevel.weak;
    if (percentage < averageThreshold) return PerformanceLevel.average;
    return PerformanceLevel.strong;
  }

  static String label(PerformanceLevel level) {
    switch (level) {
      case PerformanceLevel.weak:
        return 'Weak';
      case PerformanceLevel.average:
        return 'Average';
      case PerformanceLevel.strong:
        return 'Strong';
      case PerformanceLevel.notAssessed:
        return 'Not Assessed';
    }
  }

  static String getLocalizedLabel(
    BuildContext context,
    PerformanceLevel level,
  ) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return label(level);
    switch (level) {
      case PerformanceLevel.weak:
        return l10n.weak;
      case PerformanceLevel.average:
        return l10n.average;
      case PerformanceLevel.strong:
        return l10n.strong;
      case PerformanceLevel.notAssessed:
        return l10n.notAssessed;
    }
  }

  static String iconName(PerformanceLevel level) {
    switch (level) {
      case PerformanceLevel.weak:
        return 'trending_down';
      case PerformanceLevel.average:
        return 'trending_flat';
      case PerformanceLevel.strong:
        return 'trending_up';
      case PerformanceLevel.notAssessed:
        return 'help_outline';
    }
  }
}

class SubjectPerformance {
  final String subjectId;
  final String subjectName;
  final double? latestPercentage;
  final PerformanceLevel level;
  final DateTime? assessmentDate;
  final List<TopicPerformance> topicPerformances;

  const SubjectPerformance({
    required this.subjectId,
    required this.subjectName,
    this.latestPercentage,
    required this.level,
    this.assessmentDate,
    required this.topicPerformances,
  });

  Map<String, dynamic> toJson() => {
    'subjectId': subjectId,
    'subjectName': subjectName,
    'latestPercentage': latestPercentage,
    'level': level.name,
    'assessmentDate': assessmentDate?.toIso8601String(),
    'topicPerformances': topicPerformances.map((t) => t.toJson()).toList(),
  };

  factory SubjectPerformance.fromJson(Map<String, dynamic> json) =>
      SubjectPerformance(
        subjectId: json['subjectId'] as String,
        subjectName: json['subjectName'] as String,
        latestPercentage: (json['latestPercentage'] as num?)?.toDouble(),
        level: PerformanceLevel.values.byName(json['level'] as String),
        assessmentDate: json['assessmentDate'] != null
            ? DateTime.parse(json['assessmentDate'] as String)
            : null,
        topicPerformances: (json['topicPerformances'] as List)
            .map((t) => TopicPerformance.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

class TopicPerformance {
  final String topicId;
  final String topicName;
  final double? percentage;
  final PerformanceLevel level;

  const TopicPerformance({
    required this.topicId,
    required this.topicName,
    this.percentage,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
    'topicId': topicId,
    'topicName': topicName,
    'percentage': percentage,
    'level': level.name,
  };

  factory TopicPerformance.fromJson(Map<String, dynamic> json) =>
      TopicPerformance(
        topicId: json['topicId'] as String,
        topicName: json['topicName'] as String,
        percentage: (json['percentage'] as num?)?.toDouble(),
        level: PerformanceLevel.values.byName(json['level'] as String),
      );
}

class StudentPerformanceSummary {
  final String studentId;
  final double? overallPercentage;
  final PerformanceLevel overallLevel;
  final int subjectsAssessed;
  final int totalSubjects;
  final List<SubjectPerformance> subjectPerformances;
  final List<String> weakTopics;
  final String plainLanguageSummary;
  final List<String> recommendedActions;
  final bool isAiGenerated;
  final String? aiModel;

  const StudentPerformanceSummary({
    required this.studentId,
    this.overallPercentage,
    required this.overallLevel,
    required this.subjectsAssessed,
    required this.totalSubjects,
    required this.subjectPerformances,
    required this.weakTopics,
    required this.plainLanguageSummary,
    required this.recommendedActions,
    this.isAiGenerated = true,
    this.aiModel = 'Gemini 1.5 Flash',
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'overallPercentage': overallPercentage,
    'overallLevel': overallLevel.name,
    'subjectsAssessed': subjectsAssessed,
    'totalSubjects': totalSubjects,
    'subjectPerformances': subjectPerformances.map((s) => s.toJson()).toList(),
    'weakTopics': weakTopics,
    'plainLanguageSummary': plainLanguageSummary,
    'recommendedActions': recommendedActions,
    'isAiGenerated': isAiGenerated,
    'aiModel': aiModel,
  };

  factory StudentPerformanceSummary.fromJson(Map<String, dynamic> json) =>
      StudentPerformanceSummary(
        studentId: json['studentId'] as String,
        overallPercentage: (json['overallPercentage'] as num?)?.toDouble(),
        overallLevel: PerformanceLevel.values.byName(
          json['overallLevel'] as String,
        ),
        subjectsAssessed: json['subjectsAssessed'] as int,
        totalSubjects: json['totalSubjects'] as int,
        subjectPerformances: (json['subjectPerformances'] as List)
            .map((s) => SubjectPerformance.fromJson(s as Map<String, dynamic>))
            .toList(),
        weakTopics: (json['weakTopics'] as List).cast<String>(),
        plainLanguageSummary: json['plainLanguageSummary'] as String,
        recommendedActions: (json['recommendedActions'] as List).cast<String>(),
        isAiGenerated: json['isAiGenerated'] as bool? ?? true,
        aiModel: json['aiModel'] as String? ?? 'Gemini 1.5 Flash',
      );
}

/// Model representing class-level aggregated performance within a school.
class ClassPerformanceSummary {
  final String classId;
  final String className;
  final String section;
  final String schoolId;
  final String schoolName;
  final double averagePercentage;
  final PerformanceLevel level;
  final int learnersCount;
  final double coveragePercentage;

  const ClassPerformanceSummary({
    required this.classId,
    required this.className,
    required this.section,
    required this.schoolId,
    required this.schoolName,
    required this.averagePercentage,
    required this.level,
    required this.learnersCount,
    required this.coveragePercentage,
  });

  String get displayName => '$className - $section';

  Map<String, dynamic> toJson() => {
    'classId': classId,
    'className': className,
    'section': section,
    'schoolId': schoolId,
    'schoolName': schoolName,
    'averagePercentage': averagePercentage,
    'level': level.name,
    'learnersCount': learnersCount,
    'coveragePercentage': coveragePercentage,
  };

  factory ClassPerformanceSummary.fromJson(Map<String, dynamic> json) =>
      ClassPerformanceSummary(
        classId: json['classId'] as String,
        className: json['className'] as String,
        section: json['section'] as String,
        schoolId: json['schoolId'] as String,
        schoolName: json['schoolName'] as String,
        averagePercentage: (json['averagePercentage'] as num).toDouble(),
        level: PerformanceLevel.values.byName(json['level'] as String),
        learnersCount: json['learnersCount'] as int,
        coveragePercentage: (json['coveragePercentage'] as num).toDouble(),
      );
}

/// Model representing an institutional learning gap identified across a school or block cluster.
class InstitutionalGap {
  final String topicName;
  final String subjectName;
  final double deficiencyRate; // Percentage of assessed tests needing remediation
  final String severity; // 'High Priority', 'Moderate', 'Managed'
  final String recommendedIntervention;

  const InstitutionalGap({
    required this.topicName,
    required this.subjectName,
    required this.deficiencyRate,
    required this.severity,
    required this.recommendedIntervention,
  });

  Map<String, dynamic> toJson() => {
    'topicName': topicName,
    'subjectName': subjectName,
    'deficiencyRate': deficiencyRate,
    'severity': severity,
    'recommendedIntervention': recommendedIntervention,
  };

  factory InstitutionalGap.fromJson(Map<String, dynamic> json) =>
      InstitutionalGap(
        topicName: json['topicName'] as String,
        subjectName: json['subjectName'] as String,
        deficiencyRate: (json['deficiencyRate'] as num).toDouble(),
        severity: json['severity'] as String,
        recommendedIntervention: json['recommendedIntervention'] as String,
      );
}

/// Comprehensive institutional performance summary tailored for BRC Officers and administrators.
/// Aggregates school-level metrics with zero individual student data.
class SchoolPerformanceSummary {
  final String schoolId; // 'all' for block-wide aggregate, or specific school ID
  final String schoolName;
  final String blockName;
  final double overallPercentage;
  final PerformanceLevel overallLevel;
  final double coveragePercentage;
  final double remedialCompletionRate;
  final int totalClasses;
  final int totalLearnersAssessed;
  final List<SubjectPerformance> subjectPerformances;
  final List<ClassPerformanceSummary> classPerformances;
  final List<InstitutionalGap> criticalGaps;
  final String plainLanguageSummary;
  final List<String> recommendedActions;
  final bool isAiGenerated;
  final String aiModel;

  const SchoolPerformanceSummary({
    required this.schoolId,
    required this.schoolName,
    required this.blockName,
    required this.overallPercentage,
    required this.overallLevel,
    required this.coveragePercentage,
    required this.remedialCompletionRate,
    required this.totalClasses,
    required this.totalLearnersAssessed,
    required this.subjectPerformances,
    required this.classPerformances,
    required this.criticalGaps,
    required this.plainLanguageSummary,
    required this.recommendedActions,
    this.isAiGenerated = true,
    this.aiModel = 'Gemini 1.5 Flash',
  });

  Map<String, dynamic> toJson() => {
    'schoolId': schoolId,
    'schoolName': schoolName,
    'blockName': blockName,
    'overallPercentage': overallPercentage,
    'overallLevel': overallLevel.name,
    'coveragePercentage': coveragePercentage,
    'remedialCompletionRate': remedialCompletionRate,
    'totalClasses': totalClasses,
    'totalLearnersAssessed': totalLearnersAssessed,
    'subjectPerformances': subjectPerformances.map((s) => s.toJson()).toList(),
    'classPerformances': classPerformances.map((c) => c.toJson()).toList(),
    'criticalGaps': criticalGaps.map((g) => g.toJson()).toList(),
    'plainLanguageSummary': plainLanguageSummary,
    'recommendedActions': recommendedActions,
    'isAiGenerated': isAiGenerated,
    'aiModel': aiModel,
  };

  factory SchoolPerformanceSummary.fromJson(Map<String, dynamic> json) =>
      SchoolPerformanceSummary(
        schoolId: json['schoolId'] as String,
        schoolName: json['schoolName'] as String,
        blockName: json['blockName'] as String,
        overallPercentage: (json['overallPercentage'] as num).toDouble(),
        overallLevel: PerformanceLevel.values.byName(
          json['overallLevel'] as String,
        ),
        coveragePercentage: (json['coveragePercentage'] as num).toDouble(),
        remedialCompletionRate: (json['remedialCompletionRate'] as num).toDouble(),
        totalClasses: json['totalClasses'] as int,
        totalLearnersAssessed: json['totalLearnersAssessed'] as int,
        subjectPerformances: (json['subjectPerformances'] as List)
            .map((s) => SubjectPerformance.fromJson(s as Map<String, dynamic>))
            .toList(),
        classPerformances: (json['classPerformances'] as List)
            .map((c) => ClassPerformanceSummary.fromJson(c as Map<String, dynamic>))
            .toList(),
        criticalGaps: (json['criticalGaps'] as List)
            .map((g) => InstitutionalGap.fromJson(g as Map<String, dynamic>))
            .toList(),
        plainLanguageSummary: json['plainLanguageSummary'] as String,
        recommendedActions: (json['recommendedActions'] as List).cast<String>(),
        isAiGenerated: json['isAiGenerated'] as bool? ?? true,
        aiModel: json['aiModel'] as String? ?? 'Gemini 1.5 Flash',
      );
}

