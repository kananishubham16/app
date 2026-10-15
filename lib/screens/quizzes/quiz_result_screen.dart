import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/quiz_model.dart';
import 'package:learning_setu/providers/quiz_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/services/bilingual_notification_service.dart';
import 'package:learning_setu/widgets/performance_indicator.dart';

/// Screen presenting the quiz scoring outcome, educational mastery status,
/// pedagogical gap disclaimers, and comprehensive answer-by-answer review with explanations.
class QuizResultScreen extends StatelessWidget {
  final QuizAttempt? attempt;
  final List<QuizQuestion>? questions;

  const QuizResultScreen({super.key, this.attempt, this.questions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizProv = context.watch<QuizProvider>();

    final effectiveAttempt = attempt ?? quizProv.lastAttempt;
    final effectiveQuestions = questions ?? quizProv.questions;

    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    if (effectiveAttempt == null) {
      return Scaffold(
        appBar: AppBar(title: Text(isGu ? 'ક્વિઝ પરિણામો' : 'Quiz Results')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isGu
                    ? 'તાજેતરનો કોઈ ક્વિઝ પ્રયાસ મળ્યો નથી.'
                    : 'No recent quiz attempt found.',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isGu ? 'પાછા જાઓ' : 'Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final double percentage = effectiveAttempt.percentage;
    final bool passed = effectiveAttempt.passedThreshold; // >= 70%
    final PerformanceLevel level = PerformanceClassification.classify(
      percentage,
    );

    return PopScope(
      canPop: true,
      onPopInvoked: (_) => quizProv.resetQuiz(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isGu ? 'ક્વિઝ મૂલ્યાંકન પરિણામો' : 'Quiz Assessment Results'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: isGu
                  ? 'વાલીને સંદેશ મોકલો (Bilingual)'
                  : 'Forward to Parent (Bilingual)',
              onPressed: () {
                final studentProv = context.read<StudentProvider>();
                final schoolProv = context.read<SchoolProvider>();

                final student = studentProv.students
                    .where((s) => s.id == effectiveAttempt.studentId)
                    .firstOrNull;

                final subject = schoolProv.subjects
                    .where((s) => s.id == effectiveAttempt.subjectId)
                    .firstOrNull;

                final studentName = student?.name ?? 'વિદ્યાર્થી';
                final className = student?.className ?? 'Class 3';
                final subjectName = subject?.name ?? 'Quiz';
                final schoolName = student?.schoolName ?? 'GPS Sector 7 Primary School';
                final recipientPhone = student?.parentPhone ?? '+91 98765 43213';
                final recipientName = student?.parentName ?? studentName;

                final bilingualMessage =
                    BilingualNotificationService.buildBilingualQuizMessage(
                  studentName: studentName,
                  className: className,
                  subjectName: subjectName,
                  score: effectiveAttempt.correctAnswers,
                  totalQuestions: effectiveAttempt.totalQuestions,
                  schoolName: schoolName,
                );

                BilingualNotificationService.showMessageModal(
                  context: context,
                  title: isGu
                      ? 'વાલીને ક્વિઝ પરિણામ મોકલો'
                      : 'Forward Quiz Result to Parent',
                  recipientName: recipientName,
                  recipientPhone: recipientPhone,
                  message: bilingualMessage,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.check_rounded),
              tooltip: isGu ? 'પૂર્ણ' : 'Done',
              onPressed: () {
                quizProv.resetQuiz();
                Navigator.pop(context);
              },
            ),
          ],
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
                if (!passed)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(isGu ? 'ફરી ક્વિઝ આપો' : 'Retry Quiz'),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRouter.quiz,
                          arguments: {
                            'studentId': effectiveAttempt.studentId,
                            'subjectId': effectiveAttempt.subjectId,
                            'topicId': effectiveAttempt.topicId,
                            'remedialActionId':
                                effectiveAttempt.remedialActionId,
                          },
                        );
                      },
                    ),
                  ),
                if (!passed) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      quizProv.resetQuiz();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isGu ? 'વિદ્યાર્થી પર પાછા જાઓ' : 'Back to Student',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Score Overview Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Circular Score Badge
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: (percentage / 100.0).clamp(0.0, 1.0),
                              strokeWidth: 10,
                              backgroundColor: AppColors.dividerColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.getPerformanceColor(level),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${percentage.round()}%',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getPerformanceColor(level),
                                ),
                              ),
                              Text(
                                '${effectiveAttempt.correctAnswers}/${effectiveAttempt.totalQuestions}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      PerformanceIndicator(
                        level: level,
                        percentage: percentage,
                        size: 13,
                      ),
                      const SizedBox(height: 16),

                      // Reassessment Status Message Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: passed
                              ? Colors.green.shade50
                              : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: passed
                                ? Colors.green.shade300
                                : Colors.amber.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              passed
                                  ? Icons.verified_rounded
                                  : Icons.info_outline_rounded,
                              color: passed
                                  ? Colors.green.shade800
                                  : Colors.amber.shade900,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    passed
                                        ? 'Ready for reassessment'
                                        : 'Further practice recommended',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: passed
                                          ? Colors.green.shade900
                                          : Colors.amber.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    passed
                                        ? 'Score meets benchmark. Teacher can schedule official reassessment.'
                                        : 'Mastery score below 70%. Review learning objectives before reattempting.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: passed
                                          ? Colors.green.shade800
                                          : Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prominent Forward to Parent button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isGu
                                  ? 'વાલીને પરિણામ મોકલો (Free SMS)'
                                  : 'Forward Result to Parent (Free SMS)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            final studentProv = context.read<StudentProvider>();
                            final schoolProv = context.read<SchoolProvider>();

                            final student = studentProv.students
                                .where((s) => s.id == effectiveAttempt.studentId)
                                .firstOrNull;

                            final subject = schoolProv.subjects
                                .where((s) => s.id == effectiveAttempt.subjectId)
                                .firstOrNull;

                            final studentName = student?.name ?? 'વિદ્યાર્થી';
                            final className = student?.className ?? 'Class 3';
                            final subjectName = subject?.name ?? 'Quiz';
                            final schoolName = student?.schoolName ?? 'GPS Sector 7 Primary School';
                            final recipientPhone = student?.parentPhone ?? '+91 70169 81997';
                            final recipientName = student?.parentName ?? studentName;

                            final bilingualMessage =
                                BilingualNotificationService.buildBilingualQuizMessage(
                              studentName: studentName,
                              className: className,
                              subjectName: subjectName,
                              score: effectiveAttempt.correctAnswers,
                              totalQuestions: effectiveAttempt.totalQuestions,
                              schoolName: schoolName,
                            );

                            BilingualNotificationService.showMessageModal(
                              context: context,
                              title: isGu
                                  ? 'વાલીને ક્વિઝ પરિણામ મોકલો'
                                  : 'Forward Quiz Result to Parent',
                              recipientName: recipientName,
                              recipientPhone: recipientPhone,
                              message: bilingualMessage,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Educational Caution Note
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 20,
                      color: Colors.blue.shade800,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'One quiz does not automatically resolve a learning gap. Continuous classroom practice and teacher observation are essential.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detailed Answer Review Section
              Text(
                'Answer Review (${effectiveAttempt.answers.length} Questions)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              if (effectiveQuestions.isEmpty)
                Text(
                  isGu
                      ? 'કોઈ પ્રશ્ન સમીક્ષા ઉપલબ્ધ નથી.'
                      : 'No question review available.',
                )
              else
                ...List.generate(effectiveQuestions.length, (index) {
                  final question = effectiveQuestions[index];
                  final answer = effectiveAttempt.answers
                      .where((a) => a.questionId == question.id)
                      .firstOrNull;

                  final bool isCorrect = answer?.isCorrect ?? false;
                  final int userSelectedIndex = answer?.selectedIndex ?? -1;
                  final int correctIndex = question.correctAnswerIndex;

                  return Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCorrect
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  isCorrect
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                  color: isCorrect
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Q${index + 1}. ${question.questionText}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // Option Review
                          ...List.generate(question.options.length, (optIdx) {
                            final optText = question.options[optIdx];
                            final isUserPick = optIdx == userSelectedIndex;
                            final isTargetCorrect = optIdx == correctIndex;

                            Color? optColor;
                            IconData? optIcon;

                            if (isTargetCorrect) {
                              optColor = Colors.green.shade700;
                              optIcon = Icons.check_circle_rounded;
                            } else if (isUserPick && !isCorrect) {
                              optColor = Colors.red.shade700;
                              optIcon = Icons.cancel_rounded;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: optColor != null
                                    ? optColor.withOpacity(0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: optColor != null
                                    ? Border.all(
                                        color: optColor.withOpacity(0.4),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  if (optIcon != null)
                                    Icon(optIcon, size: 16, color: optColor)
                                  else
                                    const SizedBox(width: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      optText,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            isTargetCorrect || isUserPick
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color:
                                            optColor ?? AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isUserPick)
                                    Text(
                                      '(Your answer)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            optColor ?? AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),

                          // Pedagogical Explanation
                          if (question.explanation.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.lightbulb_rounded,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Explanation: ${question.explanation}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
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
