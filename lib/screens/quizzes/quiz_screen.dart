import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/quiz_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/widgets/empty_state_widget.dart';
import 'package:learning_setu/widgets/loading_widget.dart';

/// Interactive quiz interface displaying one question at a time with radio options,
/// progress indication, unanswered validation, exit confirmation, and submission flow.
class QuizScreen extends StatefulWidget {
  final String? classId;
  final String? subjectId;
  final String? topicId;
  final String? topicName;
  final String? studentId;
  final String? remedialActionId;

  const QuizScreen({
    super.key,
    this.classId,
    this.subjectId,
    this.topicId,
    this.topicName,
    this.studentId,
    this.remedialActionId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _initialized = false;
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadQuestions();
      _initialized = true;
    }
  }

  Future<void> _loadQuestions() async {
    final quizProv = context.read<QuizProvider>();
    final studentProv = context.read<StudentProvider>();
    final authProv = context.read<AuthProvider>();

    final effectiveStudent = studentProv.selectedStudent;
    final effectiveClassId =
        widget.classId ?? effectiveStudent?.classId ?? 'class_3a_s1';
    final effectiveSubjectId = widget.subjectId ?? 'subject_math';
    final effectiveTopicId = widget.topicId ?? 'topic_math_add';

    final user = authProv.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final teacherSubjectIds = (isTeacher && user?.subjectIds != null) ? user!.subjectIds! : <String>[];
    if (isTeacher && teacherSubjectIds.isNotEmpty && !teacherSubjectIds.contains(effectiveSubjectId)) {
      return;
    }

    final hasQuestions = await quizProv.loadQuestions(
      classId: effectiveClassId,
      subjectId: effectiveSubjectId,
      topicId: effectiveTopicId,
    );

    if (hasQuestions) {
      quizProv.startQuiz();
    }
  }

  Future<bool> _confirmExit() async {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isGu ? 'ક્વિઝમાંથી બહાર નીકળવું છે?' : 'Exit Quiz?'),
        content: Text(
          isGu
              ? 'શું તમને ખાતરી છે? તમારી પ્રગતિ ગુમાવાઈ જશે.'
              : 'Are you sure? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isGu ? 'ક્વિઝ ચાલુ રાખો' : 'Continue Quiz'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(isGu ? 'બહાર નીકળો' : 'Exit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  Future<void> _handleSubmit() async {
    final quizProv = context.read<QuizProvider>();
    final studentProv = context.read<StudentProvider>();
    final authProv = context.read<AuthProvider>();

    final effectiveStudentId =
        widget.studentId ?? studentProv.selectedStudent?.id ?? 'student_1';
    final effectiveSubjectId = widget.subjectId ?? 'subject_math';
    final effectiveTopicId = widget.topicId ?? 'topic_math_add';

    final user = authProv.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final teacherSubjectIds = (isTeacher && user?.subjectIds != null) ? user!.subjectIds! : <String>[];
    if (isTeacher && teacherSubjectIds.isNotEmpty && !teacherSubjectIds.contains(effectiveSubjectId)) {
      final isGu = Localizations.localeOf(context).languageCode == 'gu';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGu
                ? 'તમે ફક્ત તમારા સોંપાયેલા વિષય માટે જ ક્વિઝ સબમિટ કરી શકો છો.'
                : 'You can only supervise and submit quizzes for your assigned subjects.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final attempt = await quizProv.submitQuiz(
      studentId: effectiveStudentId,
      subjectId: effectiveSubjectId,
      topicId: effectiveTopicId,
      remedialActionId: widget.remedialActionId,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (attempt != null) {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.quizResult,
          arguments: {'attempt': attempt, 'questions': quizProv.questions},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(quizProv.error ?? 'Failed to submit quiz'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizProv = context.watch<QuizProvider>();
    final authProv = context.watch<AuthProvider>();
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final l10n = AppLocalizations.of(context);

    final user = authProv.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final teacherSubjectIds = (isTeacher && user?.subjectIds != null) ? user!.subjectIds! : <String>[];
    final effectiveSubjectId = widget.subjectId ?? 'subject_math';

    if (isTeacher && teacherSubjectIds.isNotEmpty && !teacherSubjectIds.contains(effectiveSubjectId)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.topicName ?? (isGu ? 'ક્વિઝ મૂલ્યાંકન' : 'Quiz Assessment')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 56,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isGu ? 'પરવાનગી પ્રતિબંધિત (View-Only)' : 'Permission Restricted (View-Only)',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isGu
                      ? 'તમે અન્ય શિક્ષકના વિષય માટે ક્વિઝ સુપરવાઇઝ અથવા સબમિટ કરી શકતા નથી. તમારી પાસે ફક્ત જોવાની પરવાનગી છે.'
                      : 'You cannot supervise or submit quizzes for other subjects. You have view-only access.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(isGu ? 'પાછા જાઓ' : 'Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (quizProv.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(isGu ? 'પ્રેક્ટિસ ક્વિઝ' : 'Practice Quiz')),
        body: LoadingWidget(
          message:
              isGu ? 'ક્વિઝ પ્રશ્નો લોડ થઈ રહ્યા છે...' : 'Loading quiz questions...',
        ),
      );
    }

    if (quizProv.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(isGu ? 'પ્રેક્ટિસ ક્વિઝ' : 'Practice Quiz')),
        body: EmptyStateWidget(
          icon: Icons.quiz_outlined,
          title: isGu ? 'કોઈ પ્રશ્નો મળ્યા નથી' : 'No Questions Found',
          message: isGu
              ? 'આ વિષયાંગ માટે હજુ સુધી કોઈ પ્રશ્નો ઉપલબ્ધ નથી.'
              : 'No quiz questions are available for this curriculum topic yet.',
          actionLabel: isGu ? 'પાછા જાઓ' : 'Go Back',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    final currentQuestion = quizProv.currentQuestion;
    final currentIndex = quizProv.currentQuestionIndex;
    final totalQuestions = quizProv.questions.length;
    final isLast = quizProv.isLastQuestion;
    final hasAnswered = quizProv.hasAnsweredCurrent;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _confirmExit();
        if (shouldPop && context.mounted) {
          quizProv.resetQuiz();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.topicName ?? (isGu ? 'ક્વિઝ મૂલ્યાંકન' : 'Quiz Assessment')),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: isGu ? 'ક્વિઝ રદ કરો' : 'Cancel Quiz',
            onPressed: () async {
              final shouldPop = await _confirmExit();
              if (shouldPop && context.mounted) {
                quizProv.resetQuiz();
                Navigator.pop(context);
              }
            },
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Previous button
                if (currentIndex > 0)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(l10n?.previous ?? (isGu ? 'પાછળ' : 'Prev')),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(90, 48),
                    ),
                    onPressed: () => quizProv.previousQuestion(),
                  )
                else
                  const SizedBox.shrink(),

                if (currentIndex > 0) const SizedBox(width: 12),

                // Next or Submit Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: !hasAnswered || _isSubmitting
                        ? null
                        : isLast
                        ? _handleSubmit
                        : () => quizProv.nextQuestion(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: isLast
                          ? Colors.green.shade700
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLast
                                    ? (isGu ? 'ક્વિઝ સબમિટ કરો' : 'Submit Quiz')
                                    : (isGu ? 'આગળનો પ્રશ્ન' : 'Next Question'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isLast
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: currentQuestion == null
            ? Center(child: Text(isGu ? 'પ્રશ્ન ઉપલબ્ધ નથી' : 'Question unavailable'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress Indicator Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isGu
                              ? 'પ્રશ્ન ${currentIndex + 1} / $totalQuestions'
                              : 'Question ${currentIndex + 1} of $totalQuestions',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Diff: ${currentQuestion.difficulty.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: quizProv.progress,
                        minHeight: 8,
                        backgroundColor: AppColors.dividerColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Question Card
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.dividerColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          currentQuestion.questionText,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Select the correct answer:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4 Radio-style Option Cards
                    ...List.generate(currentQuestion.options.length, (
                      optIndex,
                    ) {
                      final optionText = currentQuestion.options[optIndex];
                      final isSelected = quizProv.selectedAnswer == optIndex;
                      final optionLetters = ['A', 'B', 'C', 'D'];
                      final letter = optIndex < optionLetters.length
                          ? optionLetters[optIndex]
                          : '${optIndex + 1}';

                      return Card(
                        elevation: isSelected ? 2 : 0.5,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isSelected
                            ? AppColors.primaryContainer.withOpacity(0.4)
                            : theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            quizProv.selectAnswer(optIndex);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 14.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surfaceVariant,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
