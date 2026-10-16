class ParentReviewModel {
  final String id;
  final String studentId;
  final String subjectId;
  final String parentName;
  final String reviewText;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isAcknowledged;
  final String? acknowledgedBy;

  const ParentReviewModel({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.parentName,
    required this.reviewText,
    required this.createdAt,
    this.updatedAt,
    this.isAcknowledged = false,
    this.acknowledgedBy,
  });

  ParentReviewModel copyWith({
    String? id,
    String? studentId,
    String? subjectId,
    String? parentName,
    String? reviewText,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAcknowledged,
    String? acknowledgedBy,
  }) {
    return ParentReviewModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      parentName: parentName ?? this.parentName,
      reviewText: reviewText ?? this.reviewText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'subjectId': subjectId,
    'parentName': parentName,
    'reviewText': reviewText,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isAcknowledged': isAcknowledged,
    'acknowledgedBy': acknowledgedBy,
  };

  factory ParentReviewModel.fromJson(Map<String, dynamic> json) => ParentReviewModel(
    id: json['id'] as String,
    studentId: json['studentId'] as String,
    subjectId: json['subjectId'] as String,
    parentName: json['parentName'] as String? ?? 'Parent',
    reviewText: json['reviewText'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    isAcknowledged: json['isAcknowledged'] as bool? ?? false,
    acknowledgedBy: json['acknowledgedBy'] as String?,
  );
}
