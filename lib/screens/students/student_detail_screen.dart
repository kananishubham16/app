import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/assessment_provider.dart';
import 'package:learning_setu/providers/performance_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/widgets/empty_state_widget.dart';
import 'package:learning_setu/widgets/error_widget.dart';
import 'package:learning_setu/widgets/loading_widget.dart';
import 'package:learning_setu/widgets/percentage_bar.dart';
import 'package:learning_setu/widgets/performance_indicator.dart';

/// Screen displaying in-depth details of a specific student,
/// including demographics, subject performance overview, learning gap groups,
/// recent assessments history, and quick academic interventions.
class StudentDetailScreen extends StatefulWidget {
  final String? studentId;
  final StudentModel? student;

  const StudentDetailScreen({super.key, this.studentId, this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadData();
        }
      });
      _initialized = true;
    }
  }

  Future<void> _loadData() async {
    final studentProv = context.read<StudentProvider>();
    final assessmentProv = context.read<AssessmentProvider>();
    final performanceProv = context.read<PerformanceProvider>();
    final schoolProv = context.read<SchoolProvider>();

    if (widget.studentId != null && _resolveStudent(listen: false)?.id != widget.studentId) {
      await studentProv.loadStudent(widget.studentId!);
    }
    if (!mounted) return;
    final student = _resolveStudent(listen: false);
    if (student != null) {
      await Future.wait([
        assessmentProv.loadAssessmentsByStudent(student.id),
        performanceProv.loadPerformance(student.id),
        schoolProv.loadSubjects(classId: student.classId),
      ]);
    }
  }

  StudentModel? _resolveStudent({bool listen = false}) {
    if (widget.student != null) return widget.student;

    final studentProv = listen
        ? context.watch<StudentProvider>()
        : context.read<StudentProvider>();
    if (widget.studentId != null) {
      final match = studentProv.students
          .where((s) => s.id == widget.studentId)
          .firstOrNull;
      if (match != null) return match;
      if (studentProv.selectedStudent?.id == widget.studentId) {
        return studentProv.selectedStudent;
      }
    }
    return studentProv.selectedStudent;
  }

  @override
  Widget build(BuildContext context) {
    final student = _resolveStudent(listen: true);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: Text(isGu ? 'વિદ્યાર્થીની વિગતો' : 'Student Details')),
        body: EmptyStateWidget(
          icon: Icons.person_off_rounded,
          title: isGu ? 'કોઈ વિદ્યાર્થી પસંદ થયેલ નથી' : 'No Student Selected',
          message: isGu
              ? 'કૃપા કરીને તમારી વર્ગ યાદીમાંથી વિદ્યાર્થી પસંદ કરો.'
              : 'Please select a student from your class roster.',
        ),
      );
    }

    final perfProv = context.watch<PerformanceProvider>();
    final assessProv = context.watch<AssessmentProvider>();
    final schoolProv = context.watch<SchoolProvider>();

    final isLoading =
        perfProv.isLoading || assessProv.isLoading || schoolProv.isLoading;
    final error = perfProv.error ?? assessProv.error ?? schoolProv.error;

    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: isGu ? 'ડેટા તાજું કરો' : 'Refresh Data',
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading && perfProv.summary == null
          ? LoadingWidget(
              message: isGu
                  ? 'વિદ્યાર્થીની પ્રગતિ લોડ થઈ રહી છે...'
                  : 'Loading student progress...',
            )
          : error != null && perfProv.summary == null
          ? AppErrorWidget(message: error, onRetry: _loadData)
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStudentInfoCard(student),
                    const SizedBox(height: 16),
                    _buildQuickActions(
                      context,
                      student,
                      perfProv.summary,
                      schoolProv.subjects,
                    ),
                    const SizedBox(height: 20),
                    _buildPerformanceOverview(
                      context,
                      student,
                      perfProv.summary,
                    ),
                    const SizedBox(height: 20),
                    _buildTopicGroups(perfProv.summary),
                    const SizedBox(height: 20),
                    _buildRecentAssessments(
                      context,
                      student,
                      assessProv.assessments,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStudentInfoCard(StudentModel student) {
    final theme = Theme.of(context);

    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    student.name.isNotEmpty
                        ? student.name
                              .split(' ')
                              .map((n) => n.isNotEmpty ? n[0] : '')
                              .take(2)
                              .join()
                        : 'S',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${student.studentId} • ${student.className} (${student.section})',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              student.schoolName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (student.parentName != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.family_restroom_rounded,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isGu ? 'વાલી: ' : 'Parent: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(student.parentName!, style: theme.textTheme.bodySmall),
                  const Spacer(),
                  if (student.parentPhone != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            student.parentPhone!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    StudentModel student,
    StudentPerformanceSummary? summary,
    List<SubjectModel> subjects,
  ) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isParent = user?.role == UserRole.parent;
    final isObserver =
        user?.role == UserRole.principal || user?.role == UserRole.brc;
    final isTeacher = user?.role == UserRole.teacher;
    final teacherSubjectIds = (isTeacher && user?.subjectIds != null) ? user!.subjectIds! : <String>[];

    // Find first weak topic, scoped strictly to teacher's assigned subjects for teacher role
    TopicPerformance? firstWeakTopic;
    String? weakSubjectId;
    if (summary != null) {
      for (final s in summary.subjectPerformances) {
        if (isTeacher && teacherSubjectIds.isNotEmpty && !teacherSubjectIds.contains(s.subjectId)) {
          continue;
        }
        final weak = s.topicPerformances
            .where((t) => t.level == PerformanceLevel.weak)
            .firstOrNull;
        if (weak != null) {
          firstWeakTopic = weak;
          weakSubjectId = s.subjectId;
          break;
        }
      }
    }

    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    if (isObserver) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 20,
                  color: Colors.blue.shade800,
                ),
                const SizedBox(width: 8),
                Text(
                  isGu ? 'વહીવટી નિરીક્ષક દૃશ્ય' : 'Administrative Observer View',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n?.remedialObservation ??
                  (isGu
                      ? 'ઉપચારાત્મક ક્વિઝ શિક્ષકો દ્વારા વર્ગમાં અથવા વાલીઓ દ્વારા ઘરે લેવામાં આવે છે.'
                      : 'Remedial quizzes are conducted by teachers in class or parents at home.'),
              style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.assignment_return_outlined, size: 16),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l10n?.remedialActivities ?? (isGu ? 'ઉપચારાત્મક કાર્યો' : 'Remedial Actions')),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.remedial);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.insights, size: 16),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l10n?.performanceDiagnostic ?? (isGu ? 'નિદાન' : 'Diagnostics')),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.performance,
                        arguments: student.id,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (isParent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.quickActions ?? (isGu ? 'ઝડપી પગલાં' : 'Quick Actions'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.quiz_rounded, size: 18),
              label: Text(
                firstWeakTopic != null
                    ? '${l10n?.startHomeQuiz ?? (isGu ? "ઘરે ક્વિઝ શરૂ કરો" : "Start Home Quiz")}: ${firstWeakTopic.topicName}'
                    : (l10n?.startHomeQuiz ?? (isGu ? 'ઘરે ક્વિઝ શરૂ કરો' : 'Start Home Quiz')),
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: firstWeakTopic != null
                    ? Colors.red.shade50
                    : AppColors.surfaceVariant,
                foregroundColor: firstWeakTopic != null
                    ? Colors.red.shade800
                    : AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: firstWeakTopic != null
                        ? Colors.red.shade200
                        : AppColors.dividerColor,
                  ),
                ),
              ),
              onPressed: () {
                final defaultSubject =
                    subjects.isNotEmpty ? subjects.first : null;
                final defaultTopic =
                    defaultSubject != null && defaultSubject.topics.isNotEmpty
                        ? defaultSubject.topics.first
                        : null;

                Navigator.pushNamed(
                  context,
                  AppRouter.quiz,
                  arguments: {
                    'studentId': student.id,
                    'classId': student.classId,
                    'subjectId':
                        weakSubjectId ?? defaultSubject?.id ?? 'subject_math',
                    'topicId': firstWeakTopic?.topicId ??
                        defaultTopic?.id ??
                        'topic_math_add',
                    'topicName': firstWeakTopic?.topicName ??
                        defaultTopic?.name ??
                        'Addition',
                  },
                ).then((_) => _loadData());
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.assignment_return_outlined, size: 18),
              label: Text(
                  l10n?.remedialActivities ?? (isGu ? 'સોંપાયેલ ગૃહ પ્રવૃત્તિઓ' : 'Assigned Home Activities')),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(0, 48),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.remedial);
              },
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.quickActions ?? (isGu ? 'ઝડપી પગલાં' : 'Quick Actions'),
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.post_add_rounded, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(l10n?.addAssessment ?? (isGu ? 'મૂલ્યાંકન ઉમેરો' : 'Add Assessment')),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(0, 48),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.addAssessment,
                    arguments: {'studentId': student.id},
                  ).then((_) => _loadData());
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.handyman_rounded, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(l10n?.assignPractice ?? (isGu ? 'પ્રેક્ટિસ સોંપો' : 'Assign Practice')),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(0, 48),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.assignRemedial,
                    arguments: {'studentId': student.id},
                  ).then((_) => _loadData());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            icon: const Icon(Icons.quiz_rounded, size: 18),
            label: Text(
              firstWeakTopic != null
                  ? '${l10n?.superviseQuiz ?? (isGu ? "ક્વિઝ લો" : "Supervise Quiz")}: ${firstWeakTopic.topicName}'
                  : (l10n?.superviseQuiz ?? (isGu ? 'ક્વિઝ લો' : 'Supervise Quiz')),
              overflow: TextOverflow.ellipsis,
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: firstWeakTopic != null
                  ? Colors.red.shade50
                  : AppColors.surfaceVariant,
              foregroundColor: firstWeakTopic != null
                  ? Colors.red.shade800
                  : AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: firstWeakTopic != null
                      ? Colors.red.shade200
                      : AppColors.dividerColor,
                ),
              ),
            ),
            onPressed: () {
              final defaultSubject = (isTeacher && teacherSubjectIds.isNotEmpty)
                  ? subjects.where((s) => teacherSubjectIds.contains(s.id)).firstOrNull ?? (subjects.isNotEmpty ? subjects.first : null)
                  : (subjects.isNotEmpty ? subjects.first : null);
              final defaultTopic =
                  defaultSubject != null && defaultSubject.topics.isNotEmpty
                  ? defaultSubject.topics.first
                  : null;

              Navigator.pushNamed(
                context,
                AppRouter.quiz,
                arguments: {
                  'studentId': student.id,
                  'classId': student.classId,
                  'subjectId':
                      weakSubjectId ?? defaultSubject?.id ?? 'subject_math',
                  'topicId':
                      firstWeakTopic?.topicId ??
                      defaultTopic?.id ??
                      'topic_math_add',
                  'topicName':
                      firstWeakTopic?.topicName ??
                      defaultTopic?.name ??
                      'Addition',
                },
              ).then((_) => _loadData());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceOverview(
    BuildContext context,
    StudentModel student,
    StudentPerformanceSummary? summary,
  ) {
    final theme = Theme.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    if (summary == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGu ? 'વિષયવાર પ્રદર્શન વિહંગાવલોકન' : 'Subject Performance Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(isGu ? 'હજુ સુધી કોઈ પ્રદર્શન ડેટા ઉપલબ્ધ નથી.' : 'No performance data available yet.'),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGu ? 'વિષયવાર પ્રદર્શન' : 'Subject Performance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isGu
                            ? '${summary.totalSubjects} માંથી ${summary.subjectsAssessed} વિષયોનું મૂલ્યાંકન થયું'
                            : '${summary.subjectsAssessed} of ${summary.totalSubjects} subjects assessed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PerformanceIndicator(
                  level: summary.overallLevel,
                  percentage: summary.overallPercentage,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildEncouragementCallout(summary),
            const Divider(height: 24),
            ...summary.subjectPerformances.map((subj) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.subjectDetail,
                    arguments: {
                      'subjectId': subj.subjectId,
                      'studentId': student.id,
                    },
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              subj.subjectName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          PerformanceIndicator(
                            level: subj.level,
                            percentage: subj.latestPercentage,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      PercentageBar(
                        label: isGu ? 'તાજેતરનો સ્કોર' : 'Latest Score',
                        percentage: subj.latestPercentage ?? 0,
                        level: subj.level,
                        height: 6,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEncouragementCallout(StudentPerformanceSummary summary) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final level = summary.overallLevel;

    Color bgColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    IconData icon;
    String text;

    switch (level) {
      case PerformanceLevel.strong:
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFF86EFAC);
        iconColor = const Color(0xFF15803D);
        textColor = const Color(0xFF14532D);
        icon = Icons.emoji_events_rounded;
        text = isGu
            ? 'ઉત્કૃષ્ટ શૈક્ષણિક પ્રાવીણ્ય! 🌟 ઉચ્ચ સ્તરીય વિચારસરણી અને નવા પડકારો સાથે પ્રતિભા વિસ્તારો.'
            : 'Outstanding mastery! 🌟 Keep challenging yourself with enrichment and creative tasks.';
        break;

      case PerformanceLevel.average:
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFF93C5FD);
        iconColor = const Color(0xFF1D4ED8);
        textColor = const Color(0xFF1E3A8A);
        icon = Icons.trending_up_rounded;
        text = isGu
            ? 'સતત પ્રગતિ! 📈 મુખ્ય વિષયોમાં નિયમિત મહાવરા સાથે તમે સરળતાથી સર્વોચ્ચ નિપુણતા મેળવી શકશો.'
            : 'Steady progress! 📈 With focused daily revision on key topics, top mastery is within reach.';
        break;

      case PerformanceLevel.weak:
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFCD34D);
        iconColor = const Color(0xFFD97706);
        textColor = const Color(0xFF78350F);
        icon = Icons.fitness_center_rounded;
        text = isGu
            ? 'દરેક પગલું મહત્વપૂર્ણ છે! 🌱 હિંમત હાર્યા વગર પાયાના ખ્યાલોના દૈનિક અભ્યાસ અને મહાવરાથી આગળ વધો.'
            : 'Every step counts! 🌱 Focus on consistent daily practice with fundamental exercises to step up.';
        break;

      case PerformanceLevel.notAssessed:
        bgColor = const Color(0xFFF8FAFC);
        borderColor = const Color(0xFFCBD5E1);
        iconColor = const Color(0xFF64748B);
        textColor = const Color(0xFF334155);
        icon = Icons.assignment_outlined;
        text = isGu
            ? 'શૈક્ષણિક વિહંગાવલોકન મેળવવા માટે નિયમિત વિષયવાર મૂલ્યાંકન પૂર્ણ કરો.'
            : 'Complete regular assessments to unlock personalized learning guidance.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicGroups(StudentPerformanceSummary? summary) {
    final theme = Theme.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    if (summary == null) return const SizedBox.shrink();

    final List<TopicPerformance> weakTopics = [];
    final List<TopicPerformance> averageTopics = [];
    final List<TopicPerformance> strongTopics = [];

    for (final s in summary.subjectPerformances) {
      for (final t in s.topicPerformances) {
        if (t.level == PerformanceLevel.weak) {
          weakTopics.add(t);
        } else if (t.level == PerformanceLevel.average) {
          averageTopics.add(t);
        } else if (t.level == PerformanceLevel.strong) {
          strongTopics.add(t);
        }
      }
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isGu ? 'વિષય મુજબ અધ્યયન ક્ષતિ જૂથો' : 'Topic Learning Gap Groups',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isGu ? 'તાજેતરના મૂલ્યાંકન સ્કોર દ્વારા વર્ગીકૃત' : 'Categorized by latest assessment scores',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Weak Topics Group
            _buildGroupHeader(
              isGu ? 'ધ્યાનની જરૂર (<૪૦%)' : 'Needs Attention (<40%)',
              Colors.red.shade700,
              weakTopics.length,
            ),
            const SizedBox(height: 8),
            weakTopics.isEmpty
                ? Text(
                    isGu ? 'કોઈ ગંભીર ક્ષતિ નોંધાયેલ નથી.' : 'No critical learning gaps recorded.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: weakTopics.map((t) {
                      return Chip(
                        avatar: Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.red.shade700,
                        ),
                        label: Text(
                          '${t.topicName} (${t.percentage?.round() ?? 0}%)',
                        ),
                        backgroundColor: Colors.red.shade50,
                        side: BorderSide(color: Colors.red.shade200),
                        labelStyle: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 16),

            // Average Topics Group
            _buildGroupHeader(
              isGu ? 'વિકાસશીલ (૪૦% - ૬૯%)' : 'Developing (40% - 69%)',
              Colors.amber.shade800,
              averageTopics.length,
            ),
            const SizedBox(height: 8),
            averageTopics.isEmpty
                ? Text(
                    isGu ? 'આ શ્રેણીમાં કોઈ વિષય નથી.' : 'No developing topics in this band.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: averageTopics.map((t) {
                      return Chip(
                        avatar: Icon(
                          Icons.trending_flat_rounded,
                          size: 16,
                          color: Colors.amber.shade800,
                        ),
                        label: Text(
                          '${t.topicName} (${t.percentage?.round() ?? 0}%)',
                        ),
                        backgroundColor: Colors.amber.shade50,
                        side: BorderSide(color: Colors.amber.shade200),
                        labelStyle: TextStyle(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 16),

            // Strong Topics Group
            _buildGroupHeader(
              isGu ? 'નિપુણ (≥૭૦%)' : 'Proficient (≥70%)',
              Colors.green.shade700,
              strongTopics.length,
            ),
            const SizedBox(height: 8),
            strongTopics.isEmpty
                ? Text(
                    isGu ? 'હજુ સુધી કોઈ નિપુણ વિષય નોંધાયેલ નથી.' : 'No proficient topics recorded yet.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: strongTopics.map((t) {
                      return Chip(
                        avatar: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                        label: Text(
                          '${t.topicName} (${t.percentage?.round() ?? 0}%)',
                        ),
                        backgroundColor: Colors.green.shade50,
                        side: BorderSide(color: Colors.green.shade200),
                        labelStyle: TextStyle(
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAssessments(
    BuildContext context,
    StudentModel student,
    List<AssessmentModel> assessments,
  ) {
    final theme = Theme.of(context);
    final schoolProv = context.watch<SchoolProvider>();
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final l10n = AppLocalizations.of(context);
    final authProv = context.watch<AuthProvider>();
    final user = authProv.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final teacherSubjectIds = (isTeacher && user?.subjectIds != null) ? user!.subjectIds! : <String>[];

    final effectiveAssessments = (isTeacher && teacherSubjectIds.isNotEmpty)
        ? assessments.where((a) => teacherSubjectIds.contains(a.subjectId)).toList()
        : assessments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.recentAssessments ?? 'Recent Assessments',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.results,
                  arguments: {'studentId': student.id},
                );
              },
              child: Text(l10n?.viewAll ?? 'View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (effectiveAssessments.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  l10n?.noData ?? 'No assessments recorded yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: effectiveAssessments.take(4).length,
            itemBuilder: (context, index) {
              final a = effectiveAssessments[index];
              final subject = schoolProv.subjects
                  .where((s) => s.id == a.subjectId)
                  .firstOrNull;
              final subjectName = subject?.name ?? a.subjectId;
              final isQuiz = a.type == AssessmentType.remedialQuiz;
              final level = PerformanceClassification.classify(a.percentage);
              final dateStr = DateFormat('dd MMM yyyy').format(a.date);

              return Card(
                elevation: 0.5,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.dividerColor),
                ),
                child: InkWell(
                  onTap: () =>
                      _showAssessmentDetailBottomSheet(context, a, subjectName),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isQuiz
                                ? Colors.purple.shade50
                                : AppColors.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isQuiz
                                ? Icons.quiz_rounded
                                : Icons.assignment_turned_in_rounded,
                            color: isQuiz
                                ? Colors.purple.shade700
                                : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      subjectName,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isQuiz
                                          ? Colors.purple.shade50
                                          : AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isQuiz ? (isGu ? 'ઉપચારાત્મક ક્વિઝ' : 'Remedial Quiz') : (isGu ? 'નિયમિત' : 'Regular'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isQuiz
                                            ? Colors.purple.shade700
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateStr,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${a.obtainedMarks.toStringAsFixed(0)}/${a.totalMarks.toStringAsFixed(0)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            PerformanceIndicator(
                              level: level,
                              percentage: a.percentage,
                              size: 11,
                              showIcon: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAssessmentDetailBottomSheet(
    BuildContext context,
    AssessmentModel assessment,
    String subjectName,
  ) {
    final theme = Theme.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(assessment.date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          maxChildSize: 0.85,
          minChildSize: 0.35,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isGu ? '$subjectName મૂલ્યાંકન' : '$subjectName Assessment',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PerformanceIndicator(
                        level: PerformanceClassification.classify(
                          assessment.percentage,
                        ),
                        percentage: assessment.percentage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    isGu ? 'વિષય મુજબ ગુણ વિભાજન' : 'Topic-Wise Score Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (assessment.topicScores.isEmpty)
                    Text(
                      isGu ? 'આ મૂલ્યાંકન માટે કોઈ વિષય વિભાજન ઉપલબ્ધ નથી.' : 'No topic breakdown recorded for this assessment.',
                    )
                  else
                    ...assessment.topicScores.map((ts) {
                      final topicLevel = PerformanceClassification.classify(
                        ts.percentage,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    ts.topicName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${ts.obtainedMarks.toStringAsFixed(0)} / ${ts.totalMarks.toStringAsFixed(0)} (${ts.percentage.toStringAsFixed(0)}%)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.getPerformanceColor(
                                      topicLevel,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            PercentageBar(
                              label: '',
                              percentage: ts.percentage,
                              level: topicLevel,
                              height: 6,
                            ),
                          ],
                        ),
                      );
                    }),
                  if (assessment.notes != null &&
                      assessment.notes!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      isGu ? 'શિક્ષકની નોંધ' : 'Teacher Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        assessment.notes!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
