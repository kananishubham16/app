import 'package:flutter/widgets.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

class SubjectModel {
  final String id;
  final String name;
  final String description;
  final String iconName; // Material icon name
  final List<TopicModel> topics;
  final List<String> applicableClassIds;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.topics,
    required this.applicableClassIds,
  });

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return name;
    switch (id) {
      case 'subject_math':
        return l10n.mathematics;
      case 'subject_guj':
        return l10n.gujarati;
      case 'subject_eng':
        return l10n.english;
      case 'subject_evs':
        return l10n.environmentalStudies;
      default:
        return name;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconName': iconName,
    'topics': topics.map((t) => t.toJson()).toList(),
    'applicableClassIds': applicableClassIds,
  };

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    iconName: json['iconName'] as String,
    topics: (json['topics'] as List)
        .map((t) => TopicModel.fromJson(t as Map<String, dynamic>))
        .toList(),
    applicableClassIds: (json['applicableClassIds'] as List).cast<String>(),
  );
}

class TopicModel {
  final String id;
  final String name;
  final String subjectId;
  final List<String> learningObjectives;
  final int orderIndex;

  const TopicModel({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.learningObjectives,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subjectId': subjectId,
    'learningObjectives': learningObjectives,
    'orderIndex': orderIndex,
  };

  factory TopicModel.fromJson(Map<String, dynamic> json) => TopicModel(
    id: json['id'] as String,
    name: json['name'] as String,
    subjectId: json['subjectId'] as String,
    learningObjectives: (json['learningObjectives'] as List).cast<String>(),
    orderIndex: json['orderIndex'] as int,
  );
}
