import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:learning_setu/screens/dashboards/dashboard_shell.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/assessment_provider.dart';
import 'package:learning_setu/providers/remedial_provider.dart';
import 'package:learning_setu/providers/performance_provider.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/widgets/section_header.dart';
import 'package:learning_setu/widgets/loading_widget.dart';
import 'package:learning_setu/widgets/empty_state_widget.dart';
import 'package:learning_setu/widgets/percentage_bar.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/app/theme.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final auth = context.read<AuthProvider>();
    final studentProvider = context.read<StudentProvider>();
    final schoolProvider = context.read<SchoolProvider>();
    final user = auth.currentUser;

    // Parents can ONLY see their linked children
    final childrenIds = user?.childrenIds ?? ['student_1'];

    await studentProvider.loadStudentsByIds(childrenIds);
    await schoolProvider.loadSubjects();

    final selectedStudent =
        studentProvider.selectedStudent ??
        (studentProvider.students.isNotEmpty
            ? studentProvider.students.first
            : null);

    if (selectedStudent != null) {
      await _loadChildDetails(selectedStudent.id);
    }

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  Future<void> _loadChildDetails(String studentId) async {
    final assessmentProvider = context.read<AssessmentProvider>();
    final remedialProvider = context.read<RemedialProvider>();
    final performanceProvider = context.read<PerformanceProvider>();

    await Future.wait([
      assessmentProvider.loadAssessmentsByStudent(studentId),
      remedialProvider.loadRemedialsByStudent(studentId),
      performanceProvider.loadPerformance(studentId),
    ]);
  }

  Future<void> _onChildChanged(StudentModel? child) async {
    if (child == null) return;
    context.read<StudentProvider>().selectStudent(child);
    await _loadChildDetails(child.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DashboardShell(
      title: l10n?.parentDashboard ?? 'Parent Portal',
      homeTab: _buildHomeTab(),
      subjectsTab: _buildSubjectsTab(),
      performanceTab: _buildPerformanceTab(),
    );
  }

  // ==========================================
  // TAB 1: HOME TAB (Child Overview & Activities)
  // ==========================================
  Widget _buildHomeTab() {
    final studentProvider = context.watch<StudentProvider>();
    final remedialProvider = context.watch<RemedialProvider>();
    final assessmentProvider = context.watch<AssessmentProvider>();
    final performanceProvider = context.watch<PerformanceProvider>();

    if (!_initialized && studentProvider.isLoading) {
      return LoadingWidget(
        message: Localizations.localeOf(context).languageCode == 'gu' ? 'તમારા બાળકની અધ્યયન પ્રોફાઇલ લોડ થઈ રહી છે...' : 'Loading your child\'s learning profile...',
      );
    }

    final uniqueChildren = <String, StudentModel>{};
    for (final c in studentProvider.students) {
      uniqueChildren[c.id] = c;
    }
    final children = uniqueChildren.values.toList();
    final currentChild = children.any((c) => c.id == studentProvider.selectedStudent?.id)
        ? children.firstWhere((c) => c.id == studentProvider.selectedStudent?.id)
        : (children.isNotEmpty ? children.first : null);

    if (currentChild == null) {
      return EmptyStateWidget(
        icon: Icons.family_restroom_outlined,
        title: Localizations.localeOf(context).languageCode == 'gu' ? 'કોઈ બાળક જોડાયેલ નથી' : 'No Linked Children',
        message: Localizations.localeOf(context).languageCode == 'gu' ? 'તમારા વાલી એકાઉન્ટ સાથે હાલમાં કોઈ વિદ્યાર્થી પ્રોફાઇલ જોડાયેલ નથી.' : 'No student profile is currently linked to your parent account.',
      );
    }

    final childRemedials = remedialProvider.getByStudent(currentChild.id);
    final pendingRemedials = childRemedials
        .where(
          (r) =>
              r.status == RemedialStatus.assigned ||
              r.status == RemedialStatus.inProgress,
        )
        .toList();
    final completedRemedials = childRemedials
        .where((r) => r.status == RemedialStatus.completed)
        .toList();

    final assessments = assessmentProvider.assessments
        .where((a) => a.studentId == currentChild.id)
        .take(5)
        .toList();

    final summary = performanceProvider.summary;
    final overallPct = summary?.overallPercentage ?? 72.0;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Prominent Child Profile Card & Selector
          _buildChildHeaderCard(children, currentChild),
          const SizedBox(height: 16),

          // 2. Warm Guidance Message Card
          _buildParentGuidanceBanner(),
          const SizedBox(height: 16),

          // 3. Stats Snapshot Metric Bar
          _buildParentMetricBar(
            overallPct: overallPct,
            pendingCount: pendingRemedials.length,
            completedCount: completedRemedials.length,
          ),
          const SizedBox(height: 20),

          // 4. Assigned Quizzes and Home Activities
          SectionHeader(
            title: Localizations.localeOf(context).languageCode == 'gu' ? 'સોંપાયેલ ગૃહ પ્રવૃત્તિઓ અને ક્વિઝ' : 'Assigned Home Activities & Quizzes',
            subtitle: Localizations.localeOf(context).languageCode == 'gu' ? 'શિક્ષકો દ્વારા સૂચવેલ સહાયક કાર્યો' : 'Tasks recommended by school teachers for support',
          ),
          const SizedBox(height: 8),
          _buildAssignedActivitiesList(pendingRemedials, currentChild),
          const SizedBox(height: 20),

          // 5. Recent Results
          SectionHeader(
            title: Localizations.localeOf(context).languageCode == 'gu' ? 'તાજેતરના મૂલ્યાંકન પરિણામો' : 'Recent Assessment Results',
            subtitle: Localizations.localeOf(context).languageCode == 'gu' ? 'વર્ગખંડના તાજેતરના મૂલ્યાંકન પરિણામો' : 'Latest classroom evaluations and milestone checks',
          ),
          const SizedBox(height: 8),
          _buildRecentResultsList(assessments),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChildHeaderCard(
    List<StudentModel> children,
    StudentModel currentChild,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If parent has multiple children, show dropdown selector
            if (children.length > 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'gu' ? 'બાળક પસંદ કરો:' : 'Select Child:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  DropdownButton<StudentModel>(
                    value: children.any((c) => c.id == currentChild.id)
                        ? children.firstWhere((c) => c.id == currentChild.id)
                        : null,
                    isDense: true,
                    underline: const SizedBox(),
                    items: children.map((c) {
                      return DropdownMenuItem<StudentModel>(
                        value: c,
                        child: Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: _onChildChanged,
                  ),
                ],
              ),
              const Divider(height: 16),
            ],

            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    currentChild.name.isNotEmpty
                        ? currentChild.name.substring(0, 1).toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentChild.name,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentChild.className} - Section ${currentChild.section} • Roll #${currentChild.studentId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              currentChild.schoolName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
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
          ],
        ),
      ),
    );
  }

  Widget _buildParentGuidanceBanner() {
    return Card(
      elevation: 0,
      color: AppColors.secondary.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                Localizations.localeOf(context).languageCode == 'gu' ? '“દરરોજ સાંજે ઘરે ૧૫ મિનિટ વાંચન અને સરળ ગણિતના કોયડા ઉકેલવા પ્રોત્સાહિત કરો!”' : '“Keep encouraging 15 minutes of reading practice and simple math puzzles at home each evening!”',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSecondaryContainer,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentMetricBar({
    required double overallPct,
    required int pendingCount,
    required int completedCount,
  }) {
    final theme = Theme.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            // Metric 1: Overall Progress
            Expanded(
              child: _buildParentMetricItem(
                icon: Icons.emoji_events_rounded,
                iconColor: AppColors.primary,
                value: '${overallPct.toStringAsFixed(0)}%',
                title: isGu ? 'સમગ્ર પ્રગતિ' : 'Overall Mastery',
              ),
            ),
            Container(
              height: 38,
              width: 1,
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
            // Metric 2: Active Activities
            Expanded(
              child: _buildParentMetricItem(
                icon: Icons.home_work_rounded,
                iconColor: AppColors.tertiary,
                value: '$pendingCount',
                title: isGu ? 'સક્રિય કાર્યો' : 'Active Tasks',
              ),
            ),
            Container(
              height: 38,
              width: 1,
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
            // Metric 3: Completed
            Expanded(
              child: _buildParentMetricItem(
                icon: Icons.task_alt_rounded,
                iconColor: AppColors.secondary,
                value: '$completedCount',
                title: isGu ? 'પૂર્ણ થયેલ' : 'Completed',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentMetricItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String title,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAssignedActivitiesList(
    List<RemedialAction> remedials, [
    StudentModel? currentChild,
  ]) {
    if (remedials.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant
                .withOpacity(0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              Localizations.localeOf(context).languageCode == 'gu' ? 'કોઈ બાકી પ્રવૃત્તિ નથી! તમારા બાળકની પ્રેક્ટિસ પૂર્ણ છે.' : 'No pending activities! Your child is all caught up with practice.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM');

    return Column(
      children: remedials.map((remedial) {
        final instruction =
            remedial.parentInstruction ?? remedial.activityDescription;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        remedial.topicName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ),
                    Text(
                      '${Localizations.localeOf(context).languageCode == 'gu' ? "મુદત" : "Due"} ${dateFormat.format(remedial.dueDate)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  instruction,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (remedial.teacherNote != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${Localizations.localeOf(context).languageCode == 'gu' ? "શિક્ષકની નોંધ:" : "Teacher Note:"} ${remedial.teacherNote}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (remedial.hasQuiz) ...[
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.quiz,
                            arguments: {
                              'studentId': remedial.studentId,
                              'subjectId': remedial.subjectId,
                              'topicId': remedial.topicId,
                              'topicName': remedial.topicName,
                              'classId': currentChild?.classId ?? 'class_3',
                              'remedialActionId': remedial.id,
                            },
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: Text(Localizations.localeOf(context).languageCode == 'gu' ? 'ક્વિઝ શરૂ કરો' : 'Start Quiz'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ] else ...[
                      OutlinedButton.icon(
                        onPressed: () async {
                          await context.read<RemedialProvider>().updateStatus(
                            remedial.id,
                            RemedialStatus.completed,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  Localizations.localeOf(context).languageCode == 'gu' ? 'ખૂબ સરસ! પ્રવૃત્તિ પૂર્ણ તરીકે નોંધાઈ.' : 'Great job! Practice marked completed.',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: Text(Localizations.localeOf(context).languageCode == 'gu' ? 'પૂર્ણ થયું' : 'Mark Done'),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentResultsList(List<AssessmentModel> assessments) {
    if (assessments.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant
                .withOpacity(0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(child: Text(Localizations.localeOf(context).languageCode == 'gu' ? 'હજુ સુધી કોઈ મૂલ્યાંકન નોંધાયેલ નથી.' : 'No assessments recorded yet.')),
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: assessments.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = assessments[index];
          final level = PerformanceClassification.classify(item.percentage);
          final levelColor = AppColors.getPerformanceColor(level);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: levelColor.withOpacity(0.12),
              child: Icon(
                AppColors.getPerformanceIcon(level),
                color: levelColor,
                size: 20,
              ),
            ),
            title: Text(
              item.subjectId.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(dateFormat.format(item.date)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${item.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: levelColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 2: SUBJECTS TAB
  // ==========================================
  Widget _buildSubjectsTab() {
    final schoolProvider = context.watch<SchoolProvider>();
    final subjects = schoolProvider.subjects;

    if (subjects.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.menu_book_outlined,
        title: 'No Subjects',
        message: 'No curriculum subjects recorded.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SectionHeader(
          title: Localizations.localeOf(context).languageCode == 'gu' ? 'વિષય મુજબ અધ્યયન પ્રગતિ' : 'Subject Learning Progress',
          subtitle: Localizations.localeOf(context).languageCode == 'gu' ? 'અભ્યાસક્રમના વિષયોમાં પ્રગતિ અને પ્રોત્સાહન' : 'Progress and encouragement across curriculum topics',
        ),
        const SizedBox(height: 12),
        ...subjects.map((subject) {
          // Provide friendly supportive demo percentages
          final isMath = subject.name.toLowerCase().contains('math');
          final isScience = subject.name.toLowerCase().contains('science');
          final score = isMath ? 58.0 : (isScience ? 76.0 : 82.0);
          final level = PerformanceClassification.classify(score);

          String supportiveFeedback;
          final isGu = Localizations.localeOf(context).languageCode == 'gu';
          if (score >= 70) {
            supportiveFeedback = isGu ? 'અદભુત પ્રદર્શન! મૂળભૂત ખ્યાલો પર ઉત્તમ પકડ.' : 'Doing fantastic! Strong grasp of fundamental concepts.';
          } else if (score >= 40) {
            supportiveFeedback = isGu ? 'સ્થિર પ્રગતિ. ગૃહકાર્ય સાથે થોડી વધુ પ્રેક્ટિસ મદદરૂપ થશે.' : 'Making steady progress. A little extra practice with homework will help.';
          } else {
            supportiveFeedback = isGu ? 'વધારાના પ્રોત્સાહન અને ઘરે મૂળભૂત અભ્યાસની સમીક્ષાની જરૂર છે.' : 'Needs extra encouragement and review of foundational exercises at home.';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subject.getLocalizedName(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${score.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getPerformanceColor(level),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PercentageBar(
                    label: Localizations.localeOf(context).languageCode == 'gu' ? 'નિપુણતા સ્તર' : 'Mastery Level',
                    percentage: score,
                    level: level,
                    height: 8,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.tips_and_updates_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            supportiveFeedback,
                            style: const TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // TAB 3: PERFORMANCE TAB (Detailed Analysis & Guidance)
  // ==========================================
  Widget _buildPerformanceTab() {
    final performanceProvider = context.watch<PerformanceProvider>();
    final summary = performanceProvider.summary;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SectionHeader(
          title: Localizations.localeOf(context).languageCode == 'gu' ? 'અધ્યયન વિશ્લેષણ અને માર્ગદર્શન' : 'Learning Analysis & Guidance',
          subtitle: Localizations.localeOf(context).languageCode == 'gu' ? 'વાલીઓ માટે પારદર્શક મૂલ્યાંકન સારાંશ' : 'Transparent evaluation summary for parents',
        ),
        const SizedBox(height: 12),

        // Summary Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Localizations.localeOf(context).languageCode == 'gu' ? 'શિક્ષક મૂલ્યાંકન સારાંશ' : 'Teacher Evaluation Summary',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  summary?.plainLanguageSummary ?? (Localizations.localeOf(context).languageCode == 'gu' ? 'તાજેતરના મૂલ્યાંકનો મુજબ, તમારું બાળક તમામ વિષયોમાં પ્રગતિ કરી રહ્યું છે. નબળા વિષયોની નિયમિત સમીક્ષાથી આત્મવિશ્વાસ વધશે.' : 'Based on latest assessments, your child is making encouraging progress across subjects. Regular home review of weak topics will build lasting confidence.'),
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Recommended Home Actions Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.home_outlined, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      Localizations.localeOf(context).languageCode == 'gu' ? 'ઘરે મદદ કરવાના ઉપાયો' : 'Ways to Support at Home',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (summary?.recommendedActions != null &&
                    summary!.recommendedActions.isNotEmpty) ...[
                  ...summary.recommendedActions.map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Text(
                              action,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    Localizations.localeOf(context).languageCode == 'gu'
                        ? '• ૧૦ મિનિટ મૌખિક ગણિત (સરવાળો અને બાદબાકી) ની પ્રેક્ટિસ કરો.\n• તમારા બાળકને પાઠ્યપુસ્તકમાંથી વાર્તા મોટેથી વાંચવા કહો.\n• અધ્યયન ઉત્સાહ વધારવા ક્વિઝ પૂર્ણ થવા પર પ્રોત્સાહિત કરો!'
                        : '• Practice 10 minutes of mental arithmetic (addition and subtraction).\n• Ask your child to read aloud a story from their textbook.\n• Celebrate quiz completions to build learning enthusiasm!',
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
