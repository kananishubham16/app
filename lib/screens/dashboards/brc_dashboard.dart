import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

import 'package:learning_setu/screens/dashboards/dashboard_shell.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/widgets/stat_card.dart';
import 'package:learning_setu/widgets/section_header.dart';
import 'package:learning_setu/widgets/loading_widget.dart';
import 'package:learning_setu/widgets/empty_state_widget.dart';
import 'package:learning_setu/widgets/percentage_bar.dart';
import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/providers/performance_provider.dart';

/// Model representing a scheduled BRC pedagogical inspection visit with calendar reminder
class BrcSchoolVisit {
  final String id;
  final String schoolId;
  final String schoolName;
  final String schoolAddress;
  final DateTime dateTime;
  final String purpose;
  final String reminderTiming;
  final String? notes;

  const BrcSchoolVisit({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.schoolAddress,
    required this.dateTime,
    required this.purpose,
    required this.reminderTiming,
    this.notes,
  });
}

class BrcDashboard extends StatefulWidget {
  const BrcDashboard({super.key});

  @override
  State<BrcDashboard> createState() => _BrcDashboardState();
}

class _BrcDashboardState extends State<BrcDashboard> {
  bool _initialized = false;
  late List<BrcSchoolVisit> _scheduledVisits;
  final String _performanceFilterSchoolId = 'all';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _scheduledVisits = [
      BrcSchoolVisit(
        id: 'visit_demo_1',
        schoolId: 'school_2',
        schoolName: 'GPS Sector 21 Primary School',
        schoolAddress: 'Sector 21, Gandhinagar',
        dateTime: DateTime(now.year, now.month, now.day + 1, 10, 30),
        purpose: 'Remedial Teaching & FLN Review',
        reminderTiming: '1 day before (09:00 AM)',
        notes: 'Review remedial worksheets in Class 3 Math and assess subtraction gaps.',
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final schoolProvider = context.read<SchoolProvider>();
    final perfProvider = context.read<PerformanceProvider>();
    final user = auth.currentUser;

    final blockId = user?.blockId ?? 'block_1';
    final lang = Localizations.localeOf(context).languageCode;
    await Future.wait([
      schoolProvider.loadSchoolsByBlock(blockId),
      schoolProvider.loadSubjects(),
      perfProvider.loadSchoolPerformance(_performanceFilterSchoolId, languageCode: lang),
    ]);

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return DashboardShell(
      title: l10n?.brcDashboard ?? 'BRC Dashboard',
      secondTabLabel: isGu ? 'શાળાઓ' : 'Schools',
      secondTabIcon: Icons.apartment_outlined,
      secondTabSelectedIcon: Icons.apartment_rounded,
      homeTab: _buildHomeTab(),
      subjectsTab: _buildSchoolsComparisonTab(),
      performanceTab: _buildPerformanceTab(),
    );
  }

  // ==========================================
  // TAB 1: HOME TAB (Block Overview)
  // ==========================================
  Widget _buildHomeTab() {
    final schoolProvider = context.watch<SchoolProvider>();
    final l10n = AppLocalizations.of(context);

    if (!_initialized && schoolProvider.isLoading) {
      return LoadingWidget(
        message: l10n?.loading ?? 'Loading block administrative data...',
      );
    }

    final schools = schoolProvider.schools;
    final totalSchools = schools.length;
    const assessmentCoverage = 84; // 84% assessed
    const avgBlockPerformance = 67.2; // Block average

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Block Header Banner
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer
                .withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gandhinagar Block Cluster',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Primary Education Cluster • Gujarat',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Overview Stats Grid - Focused on SCHOOLS
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
                    : (constraints.maxWidth < 360 ? 0.95 : 1.1),
                children: [
                  StatCard(
                    title: l10n?.totalSchools ?? 'Total Schools',
                    value: '$totalSchools',
                    subtitle: 'Active in Block',
                    icon: Icons.account_balance_outlined,
                    color: AppColors.primary,
                  ),
                  StatCard(
                    title: l10n?.schoolsInBlock ?? 'Schools in Block',
                    value: '$totalSchools',
                    subtitle: '100% Institutional Coverage',
                    icon: Icons.domain_verification_rounded,
                    color: AppColors.secondary,
                  ),
                  StatCard(
                    title: l10n?.assessmentCoverage ?? 'Assessment Coverage',
                    value: '$assessmentCoverage%',
                    subtitle: 'Cluster Target: 90%',
                    icon: Icons.fact_check_outlined,
                    color: Colors.indigo,
                  ),
                  StatCard(
                    title: l10n?.avgBlockScore ?? 'Avg Block Score',
                    value: '$avgBlockPerformance%',
                    subtitle: 'State standard: 65%',
                    icon: Icons.auto_graph_rounded,
                    color: AppColors.strongColor,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Remedial Progress Across Schools
          SectionHeader(
            title: 'Remedial Progress Across Schools',
            subtitle: 'Implementation tracking across cluster schools',
          ),
          const SizedBox(height: 8),
          _buildRemedialProgressList(schools),
          const SizedBox(height: 20),

          // Schools Needing Support
          SectionHeader(
            title: l10n?.prioritySupportSchools ?? 'Priority Support Schools',
            subtitle:
                'Institutions requiring cluster-level pedagogical assistance',
          ),
          const SizedBox(height: 8),
          _buildSupportSchoolsCard(schools),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRemedialProgressList(List<SchoolModel> schools) {
    if (schools.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.school_outlined,
        title: 'No schools found',
      );
    }

    final mockProgress = [88.0, 62.0, 75.0];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(schools.length, (index) {
            final school = schools[index];
            final pct = index < mockProgress.length
                ? mockProgress[index]
                : 70.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: PercentageBar(
                label: school.name,
                percentage: pct,
                color: pct < 70 ? AppColors.weakColor : AppColors.secondary,
                height: 8,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSupportSchoolsCard(List<SchoolModel> schools) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final l10n = AppLocalizations.of(context);
    final school2 = schools.where((s) => s.id == 'school_2').firstOrNull;

    return Card(
      elevation: 0,
      color: AppColors.weakColor.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.weakColor.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.weakColor),
                const SizedBox(width: 8),
                Text(
                  school2?.name ?? 'GPS Sector 21 Primary School',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.weakColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isGu
                  ? '• શાળા સ્તરની ઉપચારાત્મક કાર્ય યોજના પૂર્ણતા ૬૨% છે (ક્લસ્ટર બેંચમાર્ક: ૭૮%).\n'
                      '• પ્રાથમિક વર્ગોમાં મૂળભૂત ગણન ક્ષતિઓનું ઊંચું પ્રમાણ જોવા મળે છે.\n'
                      '• ભલામણ કરેલ ક્રિયા: BRC શિક્ષણશાસ્ત્રીય નિરીક્ષણ મુલાકાત ગોઠવો અને મુખ્ય શિક્ષકને લક્ષિત ઉપચારાત્મક કિટ્સ મોકલો.'
                  : '• School-level remedial action plan completion is at 62% (cluster benchmark: 78%).\n'
                      '• Primary grades show high concentration of foundational numeracy gaps.\n'
                      '• Recommended action: Schedule BRC pedagogical inspection visit and dispatch targeted remedial kits to school headmaster.',
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: school2 == null
                    ? null
                    : () {
                        _showSchoolAnalyticsModal(
                          context,
                          school2,
                          59.8,
                          78.0,
                          PerformanceLevel.weak,
                        );
                      },
                icon: const Icon(Icons.analytics_outlined, size: 16),
                label: Text(
                  l10n?.viewAnalytics ?? (isGu ? 'વિશ્લેષણ જુઓ' : 'View Analytics'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: SCHOOL COMPARISONS TAB
  // ==========================================
  Widget _buildSchoolsComparisonTab() {
    final schoolProvider = context.watch<SchoolProvider>();
    final schools = schoolProvider.schools;
    final l10n = AppLocalizations.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    if (schools.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.school_outlined,
        title: 'No schools in block',
        message: 'No institutional records available for this cluster.',
      );
    }

    final mockAverages = [74.5, 59.8, 68.2];
    final mockCoverage = [92.0, 78.0, 84.0];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (_scheduledVisits.isNotEmpty) ...[
          _buildScheduledVisitsSection(),
          const SizedBox(height: 16),
        ],
        SectionHeader(
          title:
              '${l10n?.schoolPerformanceComparisons ?? "School Performance Comparisons"} (${schools.length})',
          subtitle: isGu ? 'ગાંધીનગર બ્લોકની શાળાઓનું વિગતવાર સંસ્થાકીય વિશ્લેષણ' : 'Detailed institutional breakdown for Gandhinagar Block',
        ),
        const SizedBox(height: 12),
        ...List.generate(schools.length, (index) {
          final school = schools[index];
          final avgScore = index < mockAverages.length
              ? mockAverages[index]
              : 65.0;
          final coverage = index < mockCoverage.length
              ? mockCoverage[index]
              : 80.0;
          final level = PerformanceClassification.classify(avgScore);

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _showSchoolAnalyticsModal(
                  context,
                  school,
                  avgScore,
                  coverage,
                  level,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.getPerformanceColor(level)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.apartment_rounded,
                            color: AppColors.getPerformanceColor(level),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                school.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                school.address,
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
                    const SizedBox(height: 16),
                    PercentageBar(
                      label: isGu ? 'શૈક્ષણિક પ્રદર્શન સરેરાશ' : 'Academic Performance Average',
                      percentage: avgScore,
                      level: level,
                      height: 8,
                    ),
                    const SizedBox(height: 10),
                    PercentageBar(
                      label: isGu ? 'મૂલ્યાંકન કવરેજ દર' : 'Assessment Coverage Rate',
                      percentage: coverage,
                      color: AppColors.secondary,
                      height: 8,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.getPerformanceColor(level).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${l10n?.statusLabel ?? (isGu ? "સ્થિતિ" : "Status")}: ${PerformanceClassification.getLocalizedLabel(context, level)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                              color: AppColors.getPerformanceColor(level),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  _showScheduleVisitDialog(context, school);
                                },
                                icon: const Icon(Icons.calendar_month_outlined, size: 14),
                                label: Text(
                                  isGu ? 'મુલાકાત શેડ્યૂલ' : 'Schedule Visit',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showSchoolAnalyticsModal(
                                    context,
                                    school,
                                    avgScore,
                                    coverage,
                                    level,
                                  );
                                },
                                icon: const Icon(Icons.analytics_outlined, size: 14),
                                label: Text(
                                  l10n?.viewAnalytics ?? (isGu ? 'વિશ્લેષણ જુઓ' : 'View Analytics'),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // SCHOOL ANALYTICS MODAL
  // ==========================================
  void _showSchoolAnalyticsModal(
    BuildContext context,
    SchoolModel school,
    double avgScore,
    double coverage,
    PerformanceLevel level,
  ) {
    final theme = Theme.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    // Dynamic school calculations
    final schoolClasses = MockData.classes
        .where((c) => c.schoolId == school.id)
        .toList();
    final schoolStudents = MockData.students
        .where((s) => s.schoolId == school.id)
        .toList();
    final studentIds = schoolStudents.map((s) => s.id).toSet();
    final schoolAssessments = MockData.assessments
        .where(
          (a) =>
              studentIds.contains(a.studentId) &&
              a.type == AssessmentType.regular,
        )
        .toList();
    final schoolRemedials = MockData.remedialActions
        .where((r) => studentIds.contains(r.studentId))
        .toList();

    final completedRemedials = schoolRemedials
        .where((r) => r.status == RemedialStatus.completed)
        .length;
    final remedialRate = schoolRemedials.isNotEmpty
        ? ((completedRemedials / schoolRemedials.length) * 100).toInt()
        : 75;

    // Identify weak topics in this school
    final Map<String, int> weakTopicCounts = {};
    for (final a in schoolAssessments) {
      for (final ts in a.topicScores) {
        if (ts.percentage < 40.0) {
          weakTopicCounts[ts.topicName] =
              (weakTopicCounts[ts.topicName] ?? 0) + 1;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (scrollContext, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),

                  // Header with School Details & Close Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.getPerformanceColor(level).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.apartment_rounded,
                            color: AppColors.getPerformanceColor(level),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                school.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${school.address} • ${school.blockName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.getPerformanceColor(level).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${PerformanceClassification.getLocalizedLabel(context, level)} (${avgScore.toStringAsFixed(1)}%)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.getPerformanceColor(level),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${isGu ? "કવરેજ" : "Coverage"}: ${coverage.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 16),

                  // Scrollable Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        // KPI Stat Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                title: isGu ? 'વિદ્યાર્થીઓ' : 'Students',
                                value: '${schoolStudents.length}',
                                icon: Icons.people_outline_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMetricTile(
                                title: isGu ? 'વર્ગો' : 'Classes',
                                value: '${schoolClasses.length}',
                                icon: Icons.meeting_room_outlined,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMetricTile(
                                title: isGu ? 'ઉપચારાત્મક દર' : 'Remedial Rate',
                                value: '$remedialRate%',
                                icon: Icons.task_alt_rounded,
                                color: remedialRate >= 70 ? Colors.green.shade700 : Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Class-wise Breakdown
                        Text(
                          isGu ? 'વર્ગવાર શૈક્ષણિક વિશ્લેષણ' : 'Class-wise Performance Breakdown',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...schoolClasses.map((cls) {
                          final clsStudents = schoolStudents.where((s) => s.classId == cls.id).toList();
                          final clsAssessments = schoolAssessments
                              .where((a) => cls.studentIds.contains(a.studentId))
                              .toList();
                          final double clsAvg = clsAssessments.isNotEmpty
                              ? clsAssessments.map((a) => a.percentage).reduce((a, b) => a + b) /
                                  clsAssessments.length
                              : avgScore;
                          final clsLevel = PerformanceClassification.classify(clsAvg);

                          return Card(
                            elevation: 0.5,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.dividerColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${cls.name} - Section ${cls.section}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${clsStudents.length} ${isGu ? "વિદ્યાર્થીઓ" : "Students"}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  PercentageBar(
                                    label: isGu ? 'સરેરાશ સ્કોર' : 'Class Average',
                                    percentage: clsAvg,
                                    level: clsLevel,
                                    height: 7,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Subject-wise Competency Overview
                        Text(
                          isGu ? 'વિષયવાર નિપુણતા વિશ્લેષણ' : 'Subject-wise Mastery Analysis',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.dividerColor),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              children: [
                                _buildSubjectRow(
                                  subjectName: isGu ? 'ગણિત (Mathematics)' : 'Mathematics',
                                  score: (avgScore - 4.5).clamp(0.0, 100.0),
                                ),
                                const Divider(height: 18),
                                _buildSubjectRow(
                                  subjectName: isGu ? 'ગુજરાતી (Gujarati)' : 'Gujarati',
                                  score: (avgScore + 5.2).clamp(0.0, 100.0),
                                ),
                                const Divider(height: 18),
                                _buildSubjectRow(
                                  subjectName: isGu ? 'અંગ્રેજી (English)' : 'English',
                                  score: (avgScore - 1.8).clamp(0.0, 100.0),
                                ),
                                const Divider(height: 18),
                                _buildSubjectRow(
                                  subjectName: isGu ? 'પર્યાવરણ (EVS)' : 'Environmental Studies',
                                  score: (avgScore + 1.1).clamp(0.0, 100.0),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Critical Learning Gaps in this School
                        Text(
                          isGu ? 'ઓળખાયેલી મુખ્ય અધ્યયન ક્ષતિઓ' : 'Identified Learning Gaps in School',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (weakTopicCounts.isEmpty)
                          Card(
                            elevation: 0,
                            color: Colors.green.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.green.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.green.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isGu
                                          ? 'ઉત્તમ પ્રદર્શન! આ શાળામાં કોઈ ગંભીર ક્ષતિ ઓળખાયેલ નથી.'
                                          : 'Satisfactory performance. No critical school-level learning gaps identified.',
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: weakTopicCounts.entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.shade700),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${entry.key} (${entry.value} ${isGu ? "વિદ્યાર્થીઓ" : "students"})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 20),

                        // AI Institutional Advisory for BRC Member
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFC7D7FE)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    isGu
                                        ? 'BRC ક્લસ્ટર AI સંસ્થાકીય ભલામણો'
                                        : 'BRC Cluster AI Institutional Advisory',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _generateSchoolAiAdvisory(school.id, avgScore, isGu),
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Action Buttons: Schedule Visit & Done
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.event_available_rounded, size: 16),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    isGu ? 'મુલાકાત શેડ્યૂલ કરો' : 'Schedule Visit',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: AppColors.primary),
                                ),
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  _showScheduleVisitDialog(context, school);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_rounded, size: 16),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    isGu ? 'પૂર્ણ' : 'Done',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () => Navigator.pop(sheetContext),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectRow({
    required String subjectName,
    required double score,
  }) {
    final level = PerformanceClassification.classify(score);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: PercentageBar(
        label: subjectName,
        percentage: score,
        level: level,
        height: 7,
      ),
    );
  }

  String _generateSchoolAiAdvisory(String schoolId, double avgScore, bool isGu) {
    if (avgScore < 60.0) {
      return isGu
          ? '• FLN સંકલ્પનાઓમાં વિલંબ: ગણિત અને અંગ્રેજીમાં ૪૦% થી નીચેના વિદ્યાર્થીઓનું પ્રમાણ વધુ છે.\n'
              '• ભલામણ કરેલ BRC પગલાં: શાળા મુલાકાત દરમિયાન શિક્ષકોને મૂર્ત ગણિત કિટ્સ પ્રદાન કરો અને મુખ્ય શિક્ષક સાથે દૈનિક ઉપચારાત્મક સમીક્ષા સુનિશ્ચિત કરો.'
          : '• Critical FLN Gap: High density of students below 40% threshold in foundational arithmetic and language skills.\n'
              '• Recommended BRC Action: Dispatch experiential learning kits, verify daily remedial activity adherence, and schedule joint inspection with Headmaster.';
    } else if (avgScore >= 70.0) {
      return isGu
          ? '• ઉત્કૃષ્ટ પ્રગતિ: આ શાળા FLN લક્ષ્યો અને ભાષા પ્રાવીણ્યમાં ક્લસ્ટર સરેરાશ કરતાં આગળ છે.\n'
              '• ભલામણ કરેલ BRC પગલાં: સાથી શાળાઓના માર્ગદર્શન માટે શ્રેષ્ઠ પદ્ધતિઓનું દસ્તાવેજીકરણ કરો અને ઉચ્ચ સ્તરીય જ્ઞાનવર્ધક પ્રવૃત્તિઓ દાખલ કરો.'
          : '• Exemplary Performance: School leads the block in reading comprehension and foundational numeracy.\n'
              '• Recommended BRC Action: Leverage top teachers for peer mentoring across cluster schools and introduce advanced HOTS learning challenges.';
    } else {
      return isGu
          ? '• સંતુલિત વૃદ્ધિ: ગુજરાતી અને વિજ્ઞાનમાં મજબૂત પ્રદર્શન, પરંતુ ગણિતના જટિલ વિષયોમાં પુનરાવર્તન જરૂરી છે.\n'
              '• ભલામણ કરેલ BRC પગલાં: સાપ્તાહિક માઇક્રો-ક્વિઝ દ્વારા વિદ્યાર્થીઓની પ્રગતિ ટ્રેક કરો અને વાલી સહભાગિતા વધારો.'
          : '• Balanced Trajectory: Strong retention in Regional Language & EVS. Scaffolding required in multi-step problem solving.\n'
              '• Recommended BRC Action: Monitor weekly quiz attempt velocity and support parent-led home learning reinforcement.';
    }
  }

  // ==========================================
  // TAB 3: PERFORMANCE TAB (Aggregate Analysis)
  // ==========================================
  Widget _buildPerformanceTab() {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SectionHeader(
          title: isGu
              ? 'બ્લોક ક્લસ્ટર સામૂહિક વિશ્લેષણ'
              : 'Block Cluster Aggregate Analysis',
          subtitle: isGu
              ? 'તમામ શાળાઓમાં અભ્યાસક્રમ-વ્યાપી તુલનાત્મક વિશ્લેષણ'
              : 'Curriculum-wide comparative analytics across all schools',
        ),
        const SizedBox(height: 12),

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
                  isGu ? 'બ્લોક વિષય ક્ષમતાઓ' : 'Block Subject Competencies',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                PercentageBar(
                  label: isGu
                      ? 'ગણિત (સરેરાશ: 62.4%)'
                      : 'Mathematics (Mean: 62.4%)',
                  percentage: 62.4,
                  level: PerformanceLevel.average,
                  height: 10,
                ),
                const SizedBox(height: 14),
                PercentageBar(
                  label: isGu
                      ? 'ગુજરાતી ભાષા (સરેરાશ: 73.8%)'
                      : 'Gujarati Language (Mean: 73.8%)',
                  percentage: 73.8,
                  level: PerformanceLevel.strong,
                  height: 10,
                ),
                const SizedBox(height: 14),
                PercentageBar(
                  label: isGu
                      ? 'પર્યાવરણ અધ્યયન (સરેરાશ: 68.1%)'
                      : 'General Science & EVS (Mean: 68.1%)',
                  percentage: 68.1,
                  level: PerformanceLevel.average,
                  height: 10,
                ),
                const SizedBox(height: 14),
                PercentageBar(
                  label: isGu
                      ? 'અંગ્રેજી વાંચન અને શબ્દભંડોળ (સરેરાશ: 64.9%)'
                      : 'English Vocabulary & Reading (Mean: 64.9%)',
                  percentage: 64.9,
                  level: PerformanceLevel.average,
                  height: 10,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

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
                      Icons.policy_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isGu ? 'BRC ક્લસ્ટર નિર્દેશો' : 'BRC Cluster Directives',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isGu
                      ? '૧. સેક્ટર ૨૧ અને સેક્ટર ૭ ના મુખ્ય શિક્ષકો સાથે માસિક FLN સમીક્ષા બેઠક યોજવી.\n'
                          '૨. તમામ નિદાન કરેલ અધ્યયન ક્ષતિઓ માટે સક્રિય ઉપચારાત્મક ક્વિઝ ફાળવવામાં આવી છે તેની ચકાસણી કરવી.\n'
                          '૩. વાલીઓની સહભાગિતા વધારવા આવતા શનિવારે વાલી વર્કશોપનું આયોજન કરવું.'
                      : '1. Conduct monthly FLN review meeting with Sector 21 and Sector 7 headmasters.\n'
                          '2. Verify that all diagnosed learning gaps have corresponding active remedial quizzes assigned.\n'
                          '3. Parent outreach workshop scheduled for next Saturday to boost home activity engagement.',
                  style: const TextStyle(height: 1.5, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BRC SCHOOL VISIT & CALENDAR REMINDER METHODS
  // ==========================================

  Widget _buildScheduledVisitsSection() {
    final theme = Theme.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50.withOpacity(0.7),
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGu
                            ? 'આગામી શાળા મુલાકાતો અને રીમાઇન્ડર'
                            : 'Upcoming School Visits & Reminders',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        isGu
                            ? '${_scheduledVisits.length} મુલાકાત કેલેન્ડર સાથે સમન્વયિત'
                            : '${_scheduledVisits.length} visit(s) synced with calendar',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._scheduledVisits.map((visit) {
              final formattedDate =
                  DateFormat('EEE, d MMM yyyy • hh:mm a').format(visit.dateTime);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                visit.schoolName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                visit.schoolAddress,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 20, color: Colors.redAccent),
                          tooltip: isGu ? 'મુલાકાત રદ કરો' : 'Cancel Visit',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _confirmDeleteVisit(visit);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 15, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 80,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flag_outlined,
                                  size: 13, color: Colors.amber.shade900),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  visit.purpose,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber.shade900,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 80,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notifications_active_outlined,
                                  size: 13, color: Colors.purple.shade700),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  visit.reminderTiming,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple.shade700,
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
                    if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '📝 ${visit.notes}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            _openCalendarEvent(
                              schoolName: visit.schoolName,
                              schoolAddress: visit.schoolAddress,
                              dateTime: visit.dateTime,
                              purpose: visit.purpose,
                              reminderTiming: visit.reminderTiming,
                              notes: visit.notes,
                            );
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 14),
                          label: Text(
                            isGu ? 'કેલેન્ડરમાં ખોલો' : 'Open in Calendar',
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteVisit(BrcSchoolVisit visit) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(isGu ? 'મુલાકાત રદ કરવી છે?' : 'Cancel Visit?'),
          content: Text(
            isGu
                ? 'શું તમે ખરેખર ${visit.schoolName} માટેની આ મુલાકાત રદ કરવા માંગો છો?'
                : 'Are you sure you want to cancel the scheduled visit for ${visit.schoolName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(isGu ? 'ના' : 'No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                setState(() {
                  _scheduledVisits.removeWhere((v) => v.id == visit.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isGu
                          ? 'મુલાકાત રદ કરવામાં આવી છે.'
                          : 'Visit removed from schedule.',
                    ),
                  ),
                );
              },
              child: Text(isGu ? 'હા, રદ કરો' : 'Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCalendarEvent({
    required String schoolName,
    required String schoolAddress,
    required DateTime dateTime,
    required String purpose,
    required String reminderTiming,
    String? notes,
  }) async {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    // Calendar event window: 1.5 hours
    final startUtc = dateTime.toUtc();
    final endUtc = dateTime.add(const Duration(minutes: 90)).toUtc();

    final startStr = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(startUtc);
    final endStr = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(endUtc);

    final title = 'BRC Inspection Visit: $schoolName';
    final location = '$schoolName, $schoolAddress';
    final detailsBuffer = StringBuffer()
      ..writeln('BRC School Visit & Inspection')
      ..writeln('School: $schoolName')
      ..writeln('Address: $schoolAddress')
      ..writeln('Purpose: $purpose')
      ..writeln('Scheduled Reminder: $reminderTiming');
    if (notes != null && notes.isNotEmpty) {
      detailsBuffer.writeln('Agenda / Notes: $notes');
    }
    detailsBuffer.writeln('\nOrganized via EduTrack BRC Management System');

    final uri = Uri.parse('https://calendar.google.com/calendar/render').replace(
      queryParameters: {
        'action': 'TEMPLATE',
        'text': title,
        'dates': '$startStr/$endStr',
        'details': detailsBuffer.toString(),
        'location': location,
      },
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isGu
                  ? 'કેલેન્ડર ખોલવામાં અસમર્થ. કૃપા કરીને બ્રાઉઝર અથવા કેલેન્ડર એપ તપાસો.'
                  : 'Could not launch calendar. Please check your browser or calendar app.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isGu
                  ? 'કેલેન્ડર રીમાઇન્ડર ખોલતી વખતે ભૂલ આવી.'
                  : 'Error opening calendar reminder.',
            ),
          ),
        );
      }
    }
  }

  void _showScheduleVisitDialog(BuildContext context, SchoolModel school) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 30);

    final purposesEn = [
      'Remedial Teaching & FLN Review',
      'Assessment Verification & Learning Gaps',
      'Curriculum Implementation Check',
      'Teacher Support & Mentoring',
      'Parent Engagement & SMC Review',
    ];

    final purposesGu = [
      'ઉપચારાત્મક શિક્ષણ અને FLN સમીક્ષા',
      'મૂલ્યાંકન ચકાસણી અને અધ્યયન ક્ષતિઓ',
      'અભ્યાસક્રમ અમલીકરણ ચકાસણી',
      'શિક્ષક સહાય અને માર્ગદર્શન',
      'વાલી સહભાગિતા અને SMC સમીક્ષા',
    ];

    final remindersEn = [
      '1 day before (09:00 AM)',
      '2 hours before',
      '1 hour before',
      '30 minutes before',
      'At time of visit',
    ];

    final remindersGu = [
      '૧ દિવસ પહેલા (સવારે ૦૯:૦૦)',
      '૨ કલાક પહેલા',
      '૧ કલાક પહેલા',
      '૩૦ મિનિટ પહેલા',
      'મુલાકાતના સમયે',
    ];

    String selectedPurpose = isGu ? purposesGu[0] : purposesEn[0];
    String selectedReminder = isGu ? remindersGu[0] : remindersEn[0];
    bool addToDeviceCalendar = true;
    final notesController = TextEditingController(
      text: isGu
          ? 'FLN સિદ્ધિઓની ચકાસણી અને નબળા વિષયોના ઉપચારાત્મક મૂલ્યાંકનનું નિરીક્ષણ.'
          : 'Inspect FLN competencies, review remedial worksheets and teacher records.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            final combinedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20,
                top: 16,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isGu
                                    ? 'શાળા મુલાકાત શેડ્યૂલ કરો'
                                    : 'Schedule School Visit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                school.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Date & Time Selectors
                    Text(
                      isGu ? 'તારીખ અને સમય પસંદ કરો' : 'Select Date & Time',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: dialogCtx,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (pickedDate != null) {
                                setModalState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd MMM yyyy').format(selectedDate),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: dialogCtx,
                                initialTime: selectedTime,
                              );
                              if (pickedTime != null) {
                                setModalState(() {
                                  selectedTime = pickedTime;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded,
                                      size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedTime.format(dialogCtx),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Inspection Purpose
                    Text(
                      isGu ? 'મુલાકાતનો હેતુ (Agenda / Purpose)' : 'Inspection Purpose / Agenda',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade50,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPurpose,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_rounded),
                          items: (isGu ? purposesGu : purposesEn).map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(p, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedPurpose = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Reminder Alert Timing
                    Text(
                      isGu ? 'કેલેન્ડર રીમાઇન્ડર સૂચના (Reminder Alert)' : 'Calendar Reminder Alert Notification',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade50,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedReminder,
                          isExpanded: true,
                          icon: const Icon(Icons.notifications_active_outlined,
                              size: 18, color: AppColors.primary),
                          items: (isGu ? remindersGu : remindersEn).map((r) {
                            return DropdownMenuItem(
                              value: r,
                              child: Text(r, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedReminder = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notes / Instructions
                    Text(
                      isGu ? 'વિશેષ નોંધ અને સૂચનાઓ' : 'Inspection Notes & Directives',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: isGu
                            ? 'શાળા મુલાકાત માટેની તૈયારી કે મુદ્દા દાખલ કરો...'
                            : 'Enter specific checklist or review notes for this visit...',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Calendar integration checkbox
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: addToDeviceCalendar,
                        activeColor: AppColors.primary,
                        title: Text(
                          isGu
                              ? 'ડિવાઇસ / ગૂગલ કેલેન્ડરમાં રીમાઇન્ડર ઇવેન્ટ ઉમેરો'
                              : 'Add reminder event to Device / Google Calendar',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          isGu
                              ? 'મુલાકાત સાચવતાની સાથે કેલેન્ડર એપ્લિકેશન ખુલશે'
                              : 'Automatically pre-fills event title, time, location & alarm',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            addToDeviceCalendar = val ?? true;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Submit & Cancel Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetCtx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(isGu ? 'રદ કરો' : 'Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_alarm_rounded, size: 18),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isGu ? 'શેડ્યૂલ અને રીમાઇન્ડર સાચવો' : 'Schedule & Set Reminder',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final newVisit = BrcSchoolVisit(
                                id: 'visit_${DateTime.now().millisecondsSinceEpoch}',
                                schoolId: school.id,
                                schoolName: school.name,
                                schoolAddress: school.address,
                                dateTime: combinedDateTime,
                                purpose: selectedPurpose,
                                reminderTiming: selectedReminder,
                                notes: notesController.text.trim(),
                              );

                              setState(() {
                                _scheduledVisits.insert(0, newVisit);
                              });

                              Navigator.pop(sheetCtx);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          isGu
                                              ? '${school.name} માટેની મુલાકાત શેડ્યૂલ થઈ ગઈ!'
                                              : 'Visit scheduled for ${school.name}!',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              if (addToDeviceCalendar) {
                                await _openCalendarEvent(
                                  schoolName: school.name,
                                  schoolAddress: school.address,
                                  dateTime: combinedDateTime,
                                  purpose: selectedPurpose,
                                  reminderTiming: selectedReminder,
                                  notes: notesController.text.trim(),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
