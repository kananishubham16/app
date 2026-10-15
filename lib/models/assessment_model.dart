enum AssessmentType { regular, remedialQuiz }

class AssessmentModel {
  final String id;
  final String studentId;
  final String subjectId;
  final AssessmentType type;
  final DateTime date;
  final double totalMarks;
  final double obtainedMarks;
  final List<TopicScore> topicScores;
  final String? notes;

  const AssessmentModel({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.type,
    required this.date,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.topicScores,
    this.notes,
  });

  double get percentage =>
      totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'subjectId': subjectId,
    'type': type.name,
    'date': date.toIso8601String(),
    'totalMarks': totalMarks,
    'obtainedMarks': obtainedMarks,
    'topicScores': topicScores.map((t) => t.toJson()).toList(),
    'notes': notes,
  };

  factory AssessmentModel.fromJson(Map<String, dynamic> json) =>
      AssessmentModel(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        subjectId: json['subjectId'] as String,
        type: AssessmentType.values.byName(json['type'] as String),
        date: DateTime.parse(json['date'] as String),
        totalMarks: (json['totalMarks'] as num).toDouble(),
        obtainedMarks: (json['obtainedMarks'] as num).toDouble(),
        topicScores: (json['topicScores'] as List)
            .map((t) => TopicScore.fromJson(t as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
      );
}

class TopicScore {
  final String topicId;
  final String topicName;
  final double totalMarks;
  final double obtainedMarks;

  const TopicScore({
    required this.topicId,
    required this.topicName,
    required this.totalMarks,
    required this.obtainedMarks,
  });

  double get percentage =>
      totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'topicId': topicId,
    'topicName': topicName,
    'totalMarks': totalMarks,
    'obtainedMarks': obtainedMarks,
  };

  factory TopicScore.fromJson(Map<String, dynamic> json) => TopicScore(
    topicId: json['topicId'] as String,
    topicName: json['topicName'] as String,
    totalMarks: (json['totalMarks'] as num).toDouble(),
    obtainedMarks: (json['obtainedMarks'] as num).toDouble(),
  );
}
