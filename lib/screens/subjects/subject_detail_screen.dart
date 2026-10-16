import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/providers/assessment_provider.dart';
import 'package:learning_setu/providers/performance_provider.dart';
import 'package:learning_setu/providers/remedial_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/widgets/empty_state_widget.dart';
import 'package:learning_setu/widgets/percentage_bar.dart';
import 'package:learning_setu/widgets/performance_indicator.dart';
import 'package:learning_setu/widgets/parent_review_box.dart';

/// Detailed view for a specific subject, covering syllabus topics, learning objectives,
/// topic-wise student performance, suggested remedial interventions, and quick quiz launching.
class SubjectDetailScreen extends StatefulWidget {
  final String? subjectId;
  final String? studentId;
  final SubjectModel? subject;

  const SubjectDetailScreen({
    super.key,
    this.subjectId,
    this.studentId,
    this.subject,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadData();
      _initialized = true;
    }
  }

  Future<void> _loadData() async {
    final schoolProv = context.read<SchoolProvider>();
    final assessProv = context.read<AssessmentProvider>();
    final perfProv = context.read<PerformanceProvider>();
    final remedialProv = context.read<RemedialProvider>();

    if (schoolProv.subjects.isEmpty) {
      await schoolProv.loadSubjects();
    }

    final student = _resolveStudent();
    if (student != null) {
      await Future.wait([
        assessProv.loadAssessmentsByStudent(student.id),
        perfProv.loadPerformance(student.id),
        remedialProv.loadRemedialsByStudent(student.id),
      ]);
    }
  }

  StudentModel? _resolveStudent() {
    final studentProv = context.watch<StudentProvider>();
    if (widget.studentId != null) {
      final match = studentProv.students
          .where((s) => s.id == widget.studentId)
          .firstOrNull;
      if (match != null) return match;
    }
    return studentProv.selectedStudent;
  }

  SubjectModel? _resolveSubject() {
    if (widget.subject != null) return widget.subject;
    final schoolProv = context.watch<SchoolProvider>();
    final targetId = widget.subjectId ?? 'subject_math';
    return schoolProv.subjects.where((s) => s.id == targetId).firstOrNull;
  }

  IconData _getSubjectIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'calculate':
        return Icons.calculate_rounded;
      case 'translate':
        return Icons.translate_rounded;
      case 'language':
        return Icons.language_rounded;
      case 'eco':
        return Icons.eco_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  String _getSuggestedActivity(String topicName) {
    final nameLower = topicName.toLowerCase();
    if (nameLower.contains('addition')) {
      return 'Practice single & 2-digit sums with colorful counting beads or flashcards.';
    } else if (nameLower.contains('subtraction')) {
      return 'Use physical counters and real-life shopkeeper roleplay for borrowing concepts.';
    } else if (nameLower.contains('multiplication')) {
      return 'Recite 2x-5x tables rhythmically and solve repeated addition grid worksheets.';
    } else if (nameLower.contains('division')) {
      return 'Practice sharing 12 marbles equally among 3-4 friends.';
    } else if (nameLower.contains('fraction')) {
      return 'Fold paper circles into halves and quarters to visualize numerators.';
    } else if (nameLower.contains('letter') || nameLower.contains('મૂળાક્ષર')) {
      return 'Trace letters on sand/slate and match consonants with vowel sounds.';
    } else if (nameLower.contains('word') || nameLower.contains('શબ્દો')) {
      return 'Picture-to-word matching cards and daily 5-word spelling practice.';
    } else if (nameLower.contains('reading') || nameLower.contains('વાંચન')) {
      return 'Shared reading of short Gujarati folktales with voice modulation.';
    } else if (nameLower.contains('phonics')) {
      return 'Clap for short vowel sounds and practice rhyming word triads (cat, bat, mat).';
    } else if (nameLower.contains('plant')) {
      return 'Label a live potted plant in the school garden with root, stem, leaf tags.';
    } else if (nameLower.contains('water')) {
      return 'Illustrate the water cycle chart and list 3 daily water-saving actions at home.';
    }
    return 'Complete targeted practice exercises and review illustrated flashcards.';
  }

  @override
  Widget build(BuildContext context) {
    final subject = _resolveSubject();
    final student = _resolveStudent();

    if (subject == null) {
      return Scaffold(
        appBar: AppBar(title: Text(Localizations.localeOf(context).languageCode == 'gu' ? 'વિષયની વિગતો' : 'Subject Details')),
        body: EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: Localizations.localeOf(context).languageCode == 'gu' ? 'વિષય મળ્યો નથી' : 'Subject Not Found',
          message: Localizations.localeOf(context).languageCode == 'gu' ? 'વિનંતી કરેલ વિષયની માહિતી હાલમાં ઉપલબ્ધ નથી.' : 'The requested subject information is currently unavailable.',
        ),
      );
    }

    final assessProv = context.watch<AssessmentProvider>();
    final perfProv = context.watch<PerformanceProvider>();
    final remedialProv = context.watch<RemedialProvider>();

    final subjectAssessments = assessProv.getBySubject(subject.id);
    final latestAssessment = subjectAssessments.isNotEmpty
        ? subjectAssessments.first
        : null;

    final SubjectPerformance? subjectPerf = perfProv
        .summary
        ?.subjectPerformances
        .where((sp) => sp.subjectId == subject.id)
        .firstOrNull;

    // Filter remedials for this subject and student
    final subjectRemedials = student != null
        ? remedialProv
              .getByStudent(student.id)
              .where((r) => r.subjectId == subject.id)
              .toList()
        : <RemedialAction>[];

    // Find weakest topic in this subject
    TopicModel? weakestTopic;
    if (subjectPerf != null && subjectPerf.topicPerformances.isNotEmpty) {
      final weakPerformances = subjectPerf.topicPerformances
          .where((tp) => tp.level == PerformanceLevel.weak)
          .toList();

      if (weakPerformances.isNotEmpty) {
        final weakPerf = weakPerformances.first;
        weakestTopic = subject.topics
            .where((t) => t.id == weakPerf.topicId)
            .firstOrNull;
      }
    }
    weakestTopic ??= subject.topics.isNotEmpty ? subject.topics.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.getLocalizedName(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            _buildSubjectHeader(subject),
            const SizedBox(height: 16),

            if (student != null) ...[
              _buildStudentContextCard(student, latestAssessment, subjectPerf),
              const SizedBox(height: 12),
              ParentReviewBox(
                studentId: student.id,
                subjectId: subject.id,
                subjectName: subject.getLocalizedName(context),
              ),
              const SizedBox(height: 16),
            ],

            // "Practice Weak Topics" Banner Button
            if (student != null && weakestTopic != null) ...[
              _buildPracticeBanner(
                context,
                student,
                subject,
                weakestTopic,
                subjectPerf,
              ),
              const SizedBox(height: 20),
            ],

            // Topics list with learning objectives
            _buildTopicsSection(subject, subjectPerf),
            const SizedBox(height: 20),

            // Remedial Actions related to this subject
            if (student != null) ...[
              _buildSubjectRemedialsSection(
                context,
                student,
                subject,
                subjectRemedials,
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectHeader(SubjectModel subject) {
    final theme = Theme.of(context);
    final iconData = _getSubjectIcon(subject.iconName);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(iconData, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.getLocalizedName(context),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${subject.topics.length} ${Localizations.localeOf(context).languageCode == 'gu' ? "અભ્યાસક્રમ વિષયો • ધોરણ ૩ અને ૪" : "Curriculum Topics • Grades 3 & 4"}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentContextCard(
    StudentModel student,
    AssessmentModel? latestAssessment,
    SubjectPerformance? subjectPerf,
  ) {
    final theme = Theme.of(context);
    final level = subjectPerf?.level ?? PerformanceLevel.notAssessed;
    final dateStr = latestAssessment != null
        ? DateFormat('dd MMM yyyy').format(latestAssessment.date)
        : (Localizations.localeOf(context).languageCode == 'gu' ? 'કંઈ નોંધાયેલ નથી' : 'None recorded');

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${student.name} • ${student.className} (${student.section})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PerformanceIndicator(
                  level: level,
                  percentage: subjectPerf?.latestPercentage,
                  size: 11,
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'gu' ? 'તાજેતરનો મૂલ્યાંકન સ્કોર' : 'Latest Assessment Score',
                        style: theme.textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        latestAssessment != null
                            ? '${latestAssessment.obtainedMarks.toStringAsFixed(0)} / ${latestAssessment.totalMarks.toStringAsFixed(0)} (${latestAssessment.percentage.toStringAsFixed(0)}%)'
                            : (Localizations.localeOf(context).languageCode == 'gu' ? 'હજુ સુધી મૂલ્યાંકન નથી થયું' : 'Not assessed yet'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.getPerformanceColor(level),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'gu' ? 'મૂલ્યાંકન તારીખ' : 'Assessment Date',
                        style: theme.textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeBanner(
    BuildContext context,
    StudentModel student,
    SubjectModel subject,
    TopicModel topic,
    SubjectPerformance? subjectPerf,
  ) {
    final TopicPerformance? topicPerf = subjectPerf?.topicPerformances
        .where((tp) => tp.topicId == topic.id)
        .firstOrNull;

    final isWeak = topicPerf?.level == PerformanceLevel.weak;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isWeak
            ? Colors.red.shade50
            : AppColors.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWeak
              ? Colors.red.shade300
              : AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWeak ? Icons.warning_amber_rounded : Icons.quiz_rounded,
                color: isWeak ? Colors.red.shade700 : AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Localizations.localeOf(context).languageCode == 'gu' ? (isWeak ? 'પગલાં જરૂરી: નબળો વિષય ઓળખાયો' : 'લક્ષિત પ્રેક્ટિસ ક્વિઝ') : (isWeak ? 'Action Needed: Weak Topic Detected' : 'Targeted Practice Quiz'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isWeak ? Colors.red.shade900 : AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isWeak
                ? (Localizations.localeOf(context).languageCode == 'gu' ? 'વિદ્યાર્થી "${topic.name}" માં મુશ્કેલી અનુભવી રહ્યો છે. ૫ પ્રશ્નોની ક્વિઝ સાથે ખ્યાલ મજબૂત કરો.' : 'Student is struggling with "${topic.name}". Reinforce concept with a 5-question targeted quiz.')
                : (Localizations.localeOf(context).languageCode == 'gu' ? 'વર્તમાન નિપુણતા ચકાસવા માટે "${topic.name}" પર પ્રેક્ટિસ ક્વિઝ લો.' : 'Take a practice quiz on "${topic.name}" to benchmark current mastery.'),
            style: TextStyle(
              fontSize: 13,
              color: isWeak ? Colors.red.shade900 : AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (ctx) {
              final userRole = ctx.watch<AuthProvider>().currentUser?.role;
              final isObserver = userRole == UserRole.principal || userRole == UserRole.brc;
              final isParent = userRole == UserRole.parent;
              final l10n = AppLocalizations.of(ctx);

              if (isObserver) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n?.remedialObservation ??
                              'Remedial quizzes are conducted by teachers in class or parents at home.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(
                    isParent
                        ? (l10n?.startHomeQuiz ?? (Localizations.localeOf(ctx).languageCode == 'gu' ? 'ઘરે પ્રેક્ટિસ શરૂ કરો: ${topic.name}' : 'Start Home Practice: ${topic.name}'))
                        : (l10n?.superviseQuiz ?? (Localizations.localeOf(ctx).languageCode == 'gu' ? 'ક્વિઝ લો: ${topic.name}' : 'Supervise Quiz: ${topic.name}')),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWeak
                        ? Colors.red.shade700
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.quiz,
                      arguments: {
                        'studentId': student.id,
                        'classId': student.classId,
                        'subjectId': subject.id,
                        'topicId': topic.id,
                        'topicName': topic.name,
                      },
                    ).then((_) => _loadData());
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsSection(
    SubjectModel subject,
    SubjectPerformance? subjectPerf,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizations.localeOf(context).languageCode == 'gu' ? 'વિષયો અને અધ્યયન ઉદ્દેશ્યો' : 'Topics & Learning Objectives',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          Localizations.localeOf(context).languageCode == 'gu' ? 'આ ધોરણ સ્તર માટે અપેક્ષિત વિગતવાર ક્ષમતાઓ' : 'Detailed competencies expected for this grade level',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...subject.topics.map((topic) {
          final TopicPerformance? tp = subjectPerf?.topicPerformances
              .where((p) => p.topicId == topic.id)
              .firstOrNull;

          final double? pct = tp?.percentage;
          final PerformanceLevel level =
              tp?.level ?? PerformanceLevel.notAssessed;
          final bool isWeak = level == PerformanceLevel.weak;

          return Card(
            elevation: 0.5,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isWeak ? Colors.red.shade300 : AppColors.dividerColor,
                width: isWeak ? 1.5 : 1,
              ),
            ),
            child: ExpansionTile(
              shape: const Border(),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.getPerformanceColor(level).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${topic.orderIndex}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.getPerformanceColor(level),
                  ),
                ),
              ),
              title: Text(
                topic.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: pct != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: PercentageBar(
                        label: Localizations.localeOf(context).languageCode == 'gu' ? 'નિપુણતા' : 'Mastery',
                        percentage: pct,
                        level: level,
                        height: 5,
                      ),
                    )
                  : const Text(
                      'Not assessed yet',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              children: [
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'gu' ? 'મુખ્ય અધ્યયન ઉદ્દેશ્યો:' : 'Key Learning Objectives:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ...topic.learningObjectives.map(
                  (obj) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.arrow_right_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            obj,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isWeak) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 18,
                          color: Colors.red.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Localizations.localeOf(context).languageCode == 'gu' ? 'વર્ગખંડમાં સૂચિત હસ્તક્ષેપ:' : 'Suggested Classroom Intervention:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getSuggestedActivity(topic.name),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade900,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubjectRemedialsSection(
    BuildContext context,
    StudentModel student,
    SubjectModel subject,
    List<RemedialAction> remedials,
  ) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                Localizations.localeOf(context).languageCode == 'gu' ? 'વિષય સંબંધિત ઉપચારાત્મક કાર્યો' : 'Subject Remedial Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user?.role == UserRole.teacher) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: Text(Localizations.localeOf(context).languageCode == 'gu' ? 'સોંપો' : 'Assign'),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.assignRemedial,
                    arguments: {'studentId': student.id, 'subjectId': subject.id},
                  ).then((_) => _loadData());
                },
              ),
            ],
          ],
        ),

        const SizedBox(height: 6),
        if (remedials.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'gu' ? 'આ વિષય માટે હાલમાં કોઈ ઉપચારાત્મક કાર્ય સુનિશ્ચિત થયેલ નથી.' : 'No remedial interventions currently scheduled for this subject.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...remedials.map((rem) {
            final isCompleted = rem.status == RemedialStatus.completed;
            final isNeedsFollowUp = rem.status == RemedialStatus.needsFollowUp;
            final Color badgeColor = isCompleted
                ? Colors.green.shade700
                : isNeedsFollowUp
                ? Colors.red.shade700
                : Colors.blue.shade700;

            final dateStr = DateFormat('dd MMM').format(rem.dueDate);

            return Card(
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.dividerColor),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: badgeColor.withOpacity(0.12),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : isNeedsFollowUp
                        ? Icons.error_outline_rounded
                        : Icons.hourglass_top_rounded,
                    color: badgeColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  rem.topicName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${rem.activityDescription}\n${Localizations.localeOf(context).languageCode == 'gu' ? "મુદત:" : "Due:"} $dateStr • ${rem.statusDisplayName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                isThreeLine: true,
                trailing: rem.hasQuiz
                    ? Builder(
                        builder: (ctx) {
                          final userRole = ctx.watch<AuthProvider>().currentUser?.role;
                          final isObserver = userRole == UserRole.principal || userRole == UserRole.brc;
                          if (isObserver) {
                            return const Icon(
                              Icons.assignment_turned_in_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            );
                          }
                          return IconButton(
                            icon: const Icon(
                              Icons.quiz_rounded,
                              color: AppColors.primary,
                            ),
                            tooltip: userRole == UserRole.parent ? 'Start Home Quiz' : 'Supervise Quiz',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.quiz,
                                arguments: {
                                  'studentId': student.id,
                                  'classId': student.classId,
                                  'subjectId': rem.subjectId,
                                  'topicId': rem.topicId,
                                  'topicName': rem.topicName,
                                  'remedialActionId': rem.id,
                                },
                              ).then((_) => _loadData());
                            },
                          );
                        },
                      )
                    : null,
              ),
            );
          }),
      ],
    );
  }
}
