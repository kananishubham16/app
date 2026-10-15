import 'package:flutter/foundation.dart';
import 'package:learning_setu/models/quiz_model.dart';
import 'package:learning_setu/repositories/quiz_repository.dart';
import 'package:learning_setu/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class QuizProvider extends ChangeNotifier {
  final QuizRepository _quizRepo;
  final StorageService _storageService;

  List<QuizQuestion> _questions = [];
  List<QuizAttempt> _attempts = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  Map<String, int> _answers = {}; // questionId -> selectedIndex
  bool _isLoading = false;
  bool _isQuizActive = false;
  QuizAttempt? _lastAttempt;
  String? _error;
  StorageService get storageService => _storageService;

  QuizProvider(this._quizRepo, this._storageService);

  List<QuizQuestion> get questions => _questions;
  List<QuizAttempt> get attempts => _attempts;
  int get currentQuestionIndex => _currentQuestionIndex;
  int? get selectedAnswer => _selectedAnswer;
  bool get isLoading => _isLoading;
  bool get isQuizActive => _isQuizActive;
  QuizAttempt? get lastAttempt => _lastAttempt;
  String? get error => _error;
  QuizQuestion? get currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
      ? _questions[_currentQuestionIndex]
      : null;
  bool get isLastQuestion => _currentQuestionIndex >= _questions.length - 1;
  double get progress =>
      _questions.isEmpty ? 0 : (_currentQuestionIndex + 1) / _questions.length;
  bool get hasAnsweredCurrent => _selectedAnswer != null;

  Future<bool> loadQuestions({
    required String classId,
    required String subjectId,
    required String topicId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _quizRepo.getQuestions(
        classId: classId,
        subjectId: subjectId,
        topicId: topicId,
      );
      _questions.shuffle();
      if (_questions.length > 5) {
        _questions = _questions.sublist(0, 5);
      }
      _isLoading = false;
      notifyListeners();
      return _questions.isNotEmpty;
    } catch (e) {
      _error = 'Failed to load questions: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void startQuiz() {
    _currentQuestionIndex = 0;
    _selectedAnswer = null;
    _answers = {};
    _isQuizActive = true;
    _lastAttempt = null;
    notifyListeners();
  }

  void selectAnswer(int index) {
    _selectedAnswer = index;
    notifyListeners();
  }

  void nextQuestion() {
    if (_selectedAnswer != null && currentQuestion != null) {
      _answers[currentQuestion!.id] = _selectedAnswer!;
    }
    if (!isLastQuestion) {
      _currentQuestionIndex++;
      _selectedAnswer = _answers[_questions[_currentQuestionIndex].id];
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      if (_selectedAnswer != null && currentQuestion != null) {
        _answers[currentQuestion!.id] = _selectedAnswer!;
      }
      _currentQuestionIndex--;
      _selectedAnswer = _answers[_questions[_currentQuestionIndex].id];
      notifyListeners();
    }
  }

  Future<QuizAttempt?> submitQuiz({
    required String studentId,
    required String subjectId,
    required String topicId,
    String? remedialActionId,
  }) async {
    if (_selectedAnswer != null && currentQuestion != null) {
      _answers[currentQuestion!.id] = _selectedAnswer!;
    }

    List<QuizAnswer> quizAnswers = [];
    int correct = 0;

    for (final question in _questions) {
      final selected = _answers[question.id];
      if (selected != null) {
        final isCorrect = selected == question.correctAnswerIndex;
        if (isCorrect) correct++;
        quizAnswers.add(
          QuizAnswer(
            questionId: question.id,
            selectedIndex: selected,
            isCorrect: isCorrect,
          ),
        );
      }
    }

    final attempt = QuizAttempt(
      id: const Uuid().v4(),
      studentId: studentId,
      subjectId: subjectId,
      topicId: topicId,
      date: DateTime.now(),
      answers: quizAnswers,
      totalQuestions: _questions.length,
      correctAnswers: correct,
      remedialActionId: remedialActionId,
    );

    try {
      await _quizRepo.saveAttempt(attempt);
      _lastAttempt = attempt;
      _isQuizActive = false;
      _attempts.add(attempt);
      notifyListeners();
      return attempt;
    } catch (e) {
      _error = 'Failed to save quiz attempt: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> loadAttempts(String studentId) async {
    try {
      _attempts = await _quizRepo.getAttemptsByStudent(studentId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load attempts: $e';
      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _selectedAnswer = null;
    _answers = {};
    _isQuizActive = false;
    _lastAttempt = null;
    _questions = [];
    notifyListeners();
  }
}
