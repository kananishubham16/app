import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:learning_setu/screens/dashboards/dashboard_shell.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/remedial_provider.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/widgets/stat_card.dart';
import 'package:learning_setu/widgets/section_header.dart';
import 'package:learning_setu/widgets/loading_widget.dart';
import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/widgets/assigned_teacher_badge.dart';
import 'package:learning_setu/widgets/empty_state_widget.dart';
import 'package:learning_setu/widgets/percentage_bar.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/app/theme.dart';

class PrincipalDashboard extends StatefulWidget {
  const PrincipalDashboard({super.key});

  @override
  State<PrincipalDashboard> createState() => _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard> {
  bool _initialized = false;
  String _selectedClassFilter = 'ALL'; // 'ALL' or classId
  String _selectedDateFilter = 'term'; // '30days', 'term', 'year'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final schoolProvider = context.read<SchoolProvider>();
    final studentProvider = context.read<StudentProvider>();
    final remedialProvider = context.read<RemedialProvider>();
    final user = auth.currentUser;

    final schoolId = user?.schoolId ?? 'school_1';

    await schoolProvider.loadClassesBySchool(schoolId);
    await studentProvider.loadStudentsBySchool(schoolId);
    await schoolProvider.loadSubjects();
    await remedialProvider.loadRemedialsBySchool(schoolId);

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DashboardShell(
      title: l10n?.principalDashboard ?? 'Principal Dashboard',
      homeTab: _buildHomeTab(),
      subjectsTab: _buildSubjectsTab(),
      performanceTab: _buildPerformanceTab(),
    );
  }

  // ==========================================
  // TAB 1: HOME TAB (School Overview)
  // ==========================================
  Widget _buildHomeTab() {
    final schoolProvider = context.watch<SchoolProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final remedialProvider = context.watch<RemedialProvider>();

    if (!_initialized &&
        (schoolProvider.isLoading || studentProvider.isLoading)) {
      return const LoadingWidget(message: 'Loading school overview...');
    }

    final classes = schoolProvider.classes;
    var allStudents = studentProvider.students;
    final allRemedials = remedialProvider.remedials;

    // Filter by class if selected
    if (_selectedClassFilter != 'ALL') {
      allStudents = allStudents
          .where((s) => s.classId == _selectedClassFilter)
          .toList();
    }

    final totalStudents = allStudents.length;
    final totalClasses = classes.length;

    // Remedial stats
    final completedRemedials = allRemedials
        .where((r) => r.status == RemedialStatus.completed)
        .length;
    final totalRemedials = allRemedials.length;
    final completionRate = totalRemedials > 0
        ? ((completedRemedials / totalRemedials) * 100).toInt()
        : 82;

    // Coverage & Avg score
    const assessmentCoverage = 86; // Prototype benchmark
    const avgSchoolPerformance = 68.4; // Prototype benchmark

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Filter Row: Class and Date period
          _buildFilterBar(classes),
          const SizedBox(height: 16),

          // Overview Stats Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                childAspectRatio: constraints.maxWidth > 600
                    ? 1.4
                    : (constraints.maxWidth < 360
                        ? 0.92
                        : (constraints.maxWidth < 420 ? 0.98 : 1.1)),
                children: [
                  StatCard(
                    title: Localizations.localeOf(context).languageCode == 'gu' ? 'કુલ વિદ્યાર્થીઓ' : 'Total Students',
                    value: '$totalStudents',
                    icon: Icons.school_outlined,
                    color: AppColors.primary,
                  ),
                  StatCard(
                    title: Localizations.localeOf(context).languageCode == 'gu' ? 'કુલ વર્ગો' : 'Total Classes',
                    value: '$totalClasses',
                    icon: Icons.meeting_room_outlined,
                    color: AppColors.secondary,
                  ),
                  StatCard(
                    title: Localizations.localeOf(context).languageCode == 'gu' ? 'મૂલ્યાંકન કવરેજ' : 'Assessment Coverage',
                    value: '$assessmentCoverage%',
                    subtitle: Localizations.localeOf(context).languageCode == 'gu' ? 'લક્ષ્યાંક: ૯૫%' : 'Target: 95%',
                    icon: Icons.checklist_rounded,
                    color: Colors.indigo,
                  ),
                  StatCard(
                    title: Localizations.localeOf(context).languageCode == 'gu' ? 'સરેરાશ પ્રદર્શન' : 'Avg Performance',
                    value: '$avgSchoolPerformance%',
                    subtitle: Localizations.localeOf(context).languageCode == 'gu' ? '+૩.૨% ગયા સત્ર કરતા' : '+3.2% vs last term',
                    icon: Icons.insights_rounded,
                    color: AppColors.strongColor,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Remedial & Improvement Tracking Card
          _buildRemedialTrackingCard(
            totalRemedials: totalRemedials,
            completedRemedials: completedRemedials,
            completionRate: completionRate,
          ),
          const SizedBox(height: 20),

          // Class-wise Performance Cards
          SectionHeader(
            title: Localizations.localeOf(context).languageCode == 'gu' ? 'વર્ગવાર પ્રદર્શન' : 'Class-wise Performance',
            subtitle: Localizations.localeOf(context).languageCode == 'gu' ? 'વિભાગો અને સિદ્ધિઓનું તુલનાત્મક દૃશ્ય' : 'Comparative view of sections and learning milestones',
          ),
          const SizedBox(height: 8),
          _buildClassPerformanceList(classes),
          const SizedBox(height: 20),

          // Learning Gaps Requiring Attention
          SectionHeader(
            title: Localizations.localeOf(context).languageCode == 'gu' ? 'મુખ્ય અધ્યયન ક્ષતિઓ' : 'Critical Learning Gaps',
            subtitle: Localizations.localeOf(context).languageCode == 'gu' ? 'વહીવટી અને શિક્ષણ હસ્તક્ષેપની જરૂરિયાત વાળા વિષયો' : 'Focus topics needing administrative & teaching interventions',
          ),
          const SizedBox(height: 8),
          _buildCriticalGapsCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<ClassModel> classes) {
    final effectiveClassFilter = (_selectedClassFilter == 'ALL' ||
            classes.any((c) => c.id == _selectedClassFilter))
        ? _selectedClassFilter
        : 'ALL';
    const validDateFilters = ['30days', 'term', 'year'];
    final effectiveDateFilter = validDateFilters.contains(_selectedDateFilter)
        ? _selectedDateFilter
        : 'term';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: effectiveClassFilter,
                        isDense: true,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'ALL',
                            child: Text(
                              Localizations.localeOf(context).languageCode == 'gu' ? 'બધા વર્ગો' : 'All Classes',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ...classes.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                c.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedClassFilter = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 24,
              width: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: effectiveDateFilter,
                  isDense: true,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: '30days',
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'gu' ? 'છેલ્લા ૩૦ દિવસ' : 'Last 30 Days',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'term',
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'gu' ? 'સત્ર ૧ (ચાલુ)' : 'Term 1 (Current)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'year',
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'gu' ? 'આખું વર્ષ' : 'Full Year',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedDateFilter = val);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemedialTrackingCard({
    required int totalRemedials,
    required int completedRemedials,
    required int completionRate,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in,
                          color: AppColors.secondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'gu' ? 'ઉપચારાત્મક કાર્ય પ્રગતિ' : 'Remedial Action Progress',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$completionRate%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PercentageBar(
              label: Localizations.localeOf(context).languageCode == 'gu' ? 'એકંદર ઉપચારાત્મક પૂર્ણતા દર' : 'Overall Remedial Completion Rate',
              percentage: completionRate.toDouble(),
              color: AppColors.secondary,
              height: 10,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildMetricSnippet(
                  Localizations.localeOf(context).languageCode == 'gu' ? 'સોંપાયેલ' : 'Assigned',
                  '$totalRemedials ${Localizations.localeOf(context).languageCode == "gu" ? "કાર્યો" : "tasks"}',
                  Icons.pending_actions,
                ),
                _buildMetricSnippet(
                  Localizations.localeOf(context).languageCode == 'gu' ? 'પૂર્ણ થયેલ' : 'Completed',
                  '$completedRemedials ${Localizations.localeOf(context).languageCode == "gu" ? "કાર્યો" : "tasks"}',
                  Icons.check_circle_outline,
                ),
                _buildMetricSnippet(
                  Localizations.localeOf(context).languageCode == 'gu' ? 'સરેરાશ સુધારો' : 'Avg Improvement',
                  '+18.5%',
                  Icons.trending_up,
                  isHighlight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSnippet(
    String title,
    String val,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlight ? AppColors.strongColor : Colors.grey,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              val,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isHighlight ? AppColors.strongColor : null,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassPerformanceList(List<ClassModel> classes) {
    if (classes.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.class_outlined,
        title: 'No classes found',
      );
    }

    return Column(
      children: classes.map((cls) {
        // Mock realistic average score per class
        final avgScore = cls.name.contains('3') ? 66.8 : 72.4;
        final level = PerformanceClassification.classify(avgScore);
        final classTeacher = MockData.getClassTeacher(cls.id);

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
                    Expanded(
                      child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: Text(
                            cls.section,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cls.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${cls.studentIds.length} ${Localizations.localeOf(context).languageCode == "gu" ? "વિદ્યાર્થીઓ નોંધાયેલ" : "Students enrolled"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (classTeacher != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.badge_outlined,
                                        size: 12,
                                        color: Colors.indigo.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          Localizations.localeOf(context).languageCode == 'gu'
                                              ? 'વર્ગ શિક્ષક: ${classTeacher.name}'
                                              : 'Class Teacher: ${classTeacher.name}',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.indigo.shade800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getPerformanceColor(level)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${avgScore.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.getPerformanceColor(level),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                PercentageBar(
                  label: Localizations.localeOf(context).languageCode == 'gu' ? 'સરેરાશ પ્રદર્શન' : 'Average Performance',
                  percentage: avgScore,
                  level: level,
                  height: 6,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCriticalGapsCard() {
    return Card(
      elevation: 0,
      color: AppColors.weakColor.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.weakColor.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  color: AppColors.weakColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'gu' ? 'પ્રાથમિક ઉપચારાત્મક ચેતવણીઓ' : 'Priority Remediation Alerts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.weakColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              Localizations.localeOf(context).languageCode == 'gu'
                  ? '૧. ધોરણ ૩-અ ગણિત: ૨૮% વિદ્યાર્થીઓ વદીવાળા સરવાળામાં < ૪૦% ગુણ ધરાવે છે.\n૨. ધોરણ ૪-અ ગુજરાતી: વાંચન પ્રવાહ માટે જૂથ ઉપચારાત્મક સત્રોની જરૂર છે.\n૩. ૬ વિદ્યાર્થીઓની બાકી ઉપચારાત્મક ક્વિઝ પૂર્ણ કરવાની બાકી છે.'
                  : '1. Class 3-A Mathematics: 28% of students scoring < 40% in Basic Addition with Regrouping.\n2. Class 4-A Gujarati: Reading Fluency requires guided group remedial sessions.\n3. 6 students have overdue remedial quizzes pending completion.',
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: SUBJECTS TAB
  // ==========================================
  Widget _buildSubjectsTab() {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final schoolProvider = context.watch<SchoolProvider>();
    final subjects = schoolProvider.subjects;

    if (subjects.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.menu_book_outlined,
        title: 'No Subjects',
        message: 'No subjects recorded for this school.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SectionHeader(
          title: Localizations.localeOf(context).languageCode == 'gu' ? 'સમગ્ર શાળા વિષયવાર પ્રદર્શન' : 'School-wide Subject Performance',
          subtitle: Localizations.localeOf(context).languageCode == 'gu' ? 'બધા સક્રિય વર્ગોના એકંદર મૂલ્યાંકન મેટ્રિક્સ' : 'Aggregated assessment metrics across all active classes',
        ),
        const SizedBox(height: 12),
        ...subjects.map((subject) {
          final isMath = subject.name.toLowerCase().contains('math');
          final isScience = subject.name.toLowerCase().contains('science');
          final score = isMath ? 61.2 : (isScience ? 69.5 : 74.0);
          final level = PerformanceClassification.classify(score);
          final assignedTeacher = MockData.getTeacherForSubject(
            subjectId: subject.id,
            schoolId: user?.schoolId,
          );

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
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
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.getPerformanceColor(level)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.getPerformanceColor(level),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subject.getLocalizedName(context),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${subject.topics.length} ${Localizations.localeOf(context).languageCode == "gu" ? "અભ્યાસક્રમ વિષયો" : "Curriculum Topics"}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getPerformanceColor(level),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PercentageBar(
                    label: Localizations.localeOf(context).languageCode == 'gu' ? 'શાળા સરેરાશ' : 'School Average',
                    percentage: score,
                    level: level,
                    height: 8,
                  ),
                  if (assignedTeacher != null) ...[
                    const SizedBox(height: 10),
                    AssignedTeacherBadge(
                      teacher: assignedTeacher,
                      labelPrefix: Localizations.localeOf(context).languageCode == 'gu'
                          ? 'વિષય શિક્ષક'
                          : 'Subject Teacher',
                      showPhone: true,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: subject.topics.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          t.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      );
                    }).toList(),
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
  // TAB 3: PERFORMANCE TAB (Aggregate Analysis)
  // ==========================================
  Widget _buildPerformanceTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SectionHeader(
          title: Localizations.localeOf(context).languageCode == 'gu' ? 'સંસ્થાકીય પ્રદર્શન વિશ્લેષણ' : 'Institutional Performance Analysis',
          subtitle: Localizations.localeOf(context).languageCode == 'gu' ? 'વ્યૂહાત્મક વિશ્લેષણ અને FLN (પાયાની સાક્ષરતા અને સંખ્યાજ્ઞાન) સ્થિતિ' : 'Strategic analytics and FLN (Foundational Literacy & Numeracy) status',
        ),
        const SizedBox(height: 12),

        // FLN Mastery Distribution Card
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
                Text(
                  Localizations.localeOf(context).languageCode == 'gu' ? 'FLN ક્ષમતા વિતરણ' : 'FLN Competency Distribution',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                PercentageBar(
                  label: Localizations.localeOf(context).languageCode == 'gu' ? 'પાયાનું સંખ્યાજ્ઞાન (ધોરણ ૩-૫)' : 'Foundational Numeracy (Grade 3-5)',
                  percentage: 64.5,
                  level: PerformanceLevel.average,
                  height: 10,
                ),
                const SizedBox(height: 12),
                PercentageBar(
                  label: Localizations.localeOf(context).languageCode == 'gu' ? 'પાયાની સાક્ષરતા (ધોરણ ૩-૫)' : 'Foundational Literacy (Grade 3-5)',
                  percentage: 73.2,
                  level: PerformanceLevel.strong,
                  height: 10,
                ),
                const SizedBox(height: 12),
                PercentageBar(
                  label: Localizations.localeOf(context).languageCode == 'gu' ? 'પર્યાવરણ અભ્યાસ ક્ષમતા' : 'Environmental Studies Competency',
                  percentage: 68.0,
                  level: PerformanceLevel.average,
                  height: 10,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Administrative Recommendations Card
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
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Localizations.localeOf(context).languageCode == 'gu' ? 'આચાર્યના પગલાં અને આંતરદૃષ્ટિ' : 'Principal Action Items & Insights',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Localizations.localeOf(context).languageCode == 'gu'
                      ? '• સત્રાંત મૂલ્યાંકન પહેલાં ધોરણ ૩ ના શિક્ષકો માટે ગણિત ઉપચારાત્મક સુદ્રઢીકરણનું આયોજન કરો.\n• ઘરે ઉપચારાત્મક પ્રેક્ટિસ ક્વિઝ પર વાલીઓની ભાગીદારીની સમીક્ષા કરો.\n• ધોરણ ૪-બ માં બાકી રહેલા વિદ્યાર્થીઓ માટે ૧૦૦% મૂલ્યાંકન નોંધણી સુનિશ્ચિત કરો.'
                      : '• Schedule math remedial reinforcement for Class 3 teachers before mid-term evaluations.\n• Review pending parental engagement on home remedial practice quizzes.\n• Ensure 100% assessment logging for remaining unassessed students in Class 4-B.',
                  style: const TextStyle(height: 1.5, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
