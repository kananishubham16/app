enum RemedialStatus { assigned, inProgress, completed, needsFollowUp }

class RemedialAction {
  final String id;
  final String studentId;
  final String subjectId;
  final String topicId;
  final String topicName;
  final String activityDescription;
  final bool hasQuiz;
  final DateTime assignedDate;
  final DateTime dueDate;
  final RemedialStatus status;
  final String? teacherNote;
  final String? parentInstruction;

  const RemedialAction({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.topicId,
    required this.topicName,
    required this.activityDescription,
    required this.hasQuiz,
    required this.assignedDate,
    required this.dueDate,
    required this.status,
    this.teacherNote,
    this.parentInstruction,
  });

  RemedialAction copyWith({
    String? id,
    String? studentId,
    String? subjectId,
    String? topicId,
    String? topicName,
    String? activityDescription,
    bool? hasQuiz,
    DateTime? assignedDate,
    DateTime? dueDate,
    RemedialStatus? status,
    String? teacherNote,
    String? parentInstruction,
  }) => RemedialAction(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    subjectId: subjectId ?? this.subjectId,
    topicId: topicId ?? this.topicId,
    topicName: topicName ?? this.topicName,
    activityDescription: activityDescription ?? this.activityDescription,
    hasQuiz: hasQuiz ?? this.hasQuiz,
    assignedDate: assignedDate ?? this.assignedDate,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    teacherNote: teacherNote ?? this.teacherNote,
    parentInstruction: parentInstruction ?? this.parentInstruction,
  );

  String get statusDisplayName {
    switch (status) {
      case RemedialStatus.assigned:
        return 'Assigned';
      case RemedialStatus.inProgress:
        return 'In Progress';
      case RemedialStatus.completed:
        return 'Completed';
      case RemedialStatus.needsFollowUp:
        return 'Needs Follow-up';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'subjectId': subjectId,
    'topicId': topicId,
    'topicName': topicName,
    'activityDescription': activityDescription,
    'hasQuiz': hasQuiz,
    'assignedDate': assignedDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'status': status.name,
    'teacherNote': teacherNote,
    'parentInstruction': parentInstruction,
  };

  factory RemedialAction.fromJson(Map<String, dynamic> json) => RemedialAction(
    id: json['id'] as String,
    studentId: json['studentId'] as String,
    subjectId: json['subjectId'] as String,
    topicId: json['topicId'] as String,
    topicName: json['topicName'] as String,
    activityDescription: json['activityDescription'] as String,
    hasQuiz: (json['hasQuiz'] as bool?) ?? false,
    assignedDate: DateTime.parse(json['assignedDate'] as String),
    dueDate: DateTime.parse(json['dueDate'] as String),
    status: RemedialStatus.values.byName(json['status'] as String),
    teacherNote: json['teacherNote'] as String?,
    parentInstruction: json['parentInstruction'] as String?,
  );
}
