class QuizQuestion {
  final String id;
  final String classId;
  final String subjectId;
  final String topicId;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.classId,
    required this.subjectId,
    required this.topicId,
    required this.difficulty,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'subjectId': subjectId,
    'topicId': topicId,
    'difficulty': difficulty,
    'questionText': questionText,
    'options': options,
    'correctAnswerIndex': correctAnswerIndex,
    'explanation': explanation,
  };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] as String,
    classId: json['classId'] as String,
    subjectId: json['subjectId'] as String,
    topicId: json['topicId'] as String,
    difficulty: json['difficulty'] as String,
    questionText: json['questionText'] as String,
    options: (json['options'] as List).cast<String>(),
    correctAnswerIndex: json['correctAnswerIndex'] as int,
    explanation: json['explanation'] as String,
  );
}

class QuizAttempt {
  final String id;
  final String studentId;
  final String subjectId;
  final String topicId;
  final DateTime date;
  final List<QuizAnswer> answers;
  final int totalQuestions;
  final int correctAnswers;
  final String? remedialActionId;

  const QuizAttempt({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.topicId,
    required this.date,
    required this.answers,
    required this.totalQuestions,
    required this.correctAnswers,
    this.remedialActionId,
  });

  double get percentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
  bool get passedThreshold => percentage >= 70;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'subjectId': subjectId,
    'topicId': topicId,
    'date': date.toIso8601String(),
    'answers': answers.map((a) => a.toJson()).toList(),
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'remedialActionId': remedialActionId,
  };

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
    id: json['id'] as String,
    studentId: json['studentId'] as String,
    subjectId: json['subjectId'] as String,
    topicId: json['topicId'] as String,
    date: DateTime.parse(json['date'] as String),
    answers: (json['answers'] as List)
        .map((a) => QuizAnswer.fromJson(a as Map<String, dynamic>))
        .toList(),
    totalQuestions: json['totalQuestions'] as int,
    correctAnswers: json['correctAnswers'] as int,
    remedialActionId: json['remedialActionId'] as String?,
  );
}

class QuizAnswer {
  final String questionId;
  final int selectedIndex;
  final bool isCorrect;

  const QuizAnswer({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'selectedIndex': selectedIndex,
    'isCorrect': isCorrect,
  };

  factory QuizAnswer.fromJson(Map<String, dynamic> json) => QuizAnswer(
    questionId: json['questionId'] as String,
    selectedIndex: json['selectedIndex'] as int,
    isCorrect: json['isCorrect'] as bool,
  );
}
