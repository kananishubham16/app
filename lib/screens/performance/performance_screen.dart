import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/assessment_provider.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/performance_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/widgets/empty_state_widget.dart';
import 'package:learning_setu/widgets/error_widget.dart';
import 'package:learning_setu/widgets/loading_widget.dart';
import 'package:learning_setu/widgets/percentage_bar.dart';
import 'package:learning_setu/widgets/performance_indicator.dart';

/// Screen providing comprehensive diagnostic analysis of student performance,
/// or institutional school analytics for BRC administrators with zero student PII.
class PerformanceScreen extends StatefulWidget {
  final String? studentId;
  final String? schoolId;

  const PerformanceScreen({super.key, this.studentId, this.schoolId});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  String? _selectedStudentId;
  String _selectedSchoolId = 'all';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.studentId;
    if (widget.schoolId != null) {
      _selectedSchoolId = widget.schoolId!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final authProv = context.read<AuthProvider>();
        final user = authProv.currentUser;
        final isBrc = user?.role == UserRole.brc;
        final isParent = user?.role == UserRole.parent;
        final parentChildrenIds = user?.childrenIds ?? [];

        if (isBrc) {
          _loadSchoolData();
        } else {
          final studentProv = context.read<StudentProvider>();
          final List<StudentModel> baseStudents;
          if (isParent) {
            final fromProv = studentProv.students.where((s) => parentChildrenIds.contains(s.id)).toList();
            baseStudents = fromProv.isNotEmpty
                ? fromProv
                : MockData.students.where((s) => parentChildrenIds.contains(s.id)).toList();
          } else {
            baseStudents = studentProv.students;
          }

          final uniqueStudents = <String, StudentModel>{
            for (var s in baseStudents) s.id: s,
          }.values.toList();

          if (isParent) {
            if (_selectedStudentId == null || !parentChildrenIds.contains(_selectedStudentId)) {
              _selectedStudentId = studentProv.selectedStudent?.id;
              if (_selectedStudentId == null || !parentChildrenIds.contains(_selectedStudentId)) {
                _selectedStudentId = uniqueStudents.isNotEmpty ? uniqueStudents.first.id : null;
              }
            }
          } else {
            _selectedStudentId ??= studentProv.selectedStudent?.id;
            if (_selectedStudentId == null ||
                !uniqueStudents.any((s) => s.id == _selectedStudentId)) {
              _selectedStudentId =
                  uniqueStudents.isNotEmpty ? uniqueStudents.first.id : null;
            }
          }
          _loadData();
        }
      });
    }
  }

  Future<void> _loadSchoolData() async {
    final perfProv = context.read<PerformanceProvider>();
    final schoolProv = context.read<SchoolProvider>();
    final lang = Localizations.localeOf(context).languageCode;

    await Future.wait([
      perfProv.loadSchoolPerformance(_selectedSchoolId, languageCode: lang),
      schoolProv.loadSchoolsByBlock('block_1'),
      schoolProv.loadSubjects(),
    ]);
  }

  Future<void> _loadData() async {
    if (_selectedStudentId != null) {
      final perfProv = context.read<PerformanceProvider>();
      final assessProv = context.read<AssessmentProvider>();
      final schoolProv = context.read<SchoolProvider>();
      final lang = Localizations.localeOf(context).languageCode;

      await Future.wait([
        perfProv.loadPerformance(_selectedStudentId!, languageCode: lang),
        assessProv.loadAssessmentsByStudent(_selectedStudentId!),
        schoolProv.loadSubjects(),
      ]);
    }
  }

  StudentModel? _findStudent(List<StudentModel> students) {
    if (_selectedStudentId == null) return null;
    return students.where((s) => s.id == _selectedStudentId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProv = context.watch<AuthProvider>();
    final perfProv = context.watch<PerformanceProvider>();
    final user = authProv.currentUser;
    final isBrc = user?.role == UserRole.brc;
    final isParent = user?.role == UserRole.parent;
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    if (isBrc) {
      return _buildBrcScaffold(context, l10n, perfProv, isGu);
    }

    final studentProv = context.watch<StudentProvider>();
    final assessProv = context.watch<AssessmentProvider>();

    final parentChildrenIds = user?.childrenIds ?? [];
    final List<StudentModel> students;
    if (isParent) {
      final fromProv = studentProv.students.where((s) => parentChildrenIds.contains(s.id)).toList();
      students = fromProv.isNotEmpty
          ? fromProv
          : MockData.students.where((s) => parentChildrenIds.contains(s.id)).toList();
    } else {
      students = studentProv.students;
    }

    final currentStudent = _findStudent(students);
    final summary = perfProv.summary;

    return Scaffold(

      appBar: AppBar(
        title: Text(l10n?.performanceDiagnostic ?? 'Performance Diagnostic'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n?.retry ?? 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // AI-Powered Diagnostic Notice Banner
            _buildAiPoweredNotice(l10n, summary),
            const SizedBox(height: 12),

            // Student Selector
            _buildStudentSelector(students, currentStudent, studentProv, l10n),
            const SizedBox(height: 16),

            if (perfProv.isLoading && summary == null)
              LoadingWidget(message: l10n?.generatingAnalysis ?? 'Generating AI-powered analysis...')
            else if (perfProv.error != null && summary == null)
              AppErrorWidget(message: perfProv.error!, onRetry: _loadData)
            else if (summary == null)
              EmptyStateWidget(
                icon: Icons.analytics_outlined,
                title: l10n?.noPerformanceData ?? 'No Performance Data',
                message:
                    l10n?.noData ?? 'No assessments have been recorded for this student yet.',
              )
            else ...[
              // Overall Performance Summary Card
              _buildOverallCard(summary),
              const SizedBox(height: 16),

              // Plain-Language Rule-Based Summary
              _buildPlainLanguageCard(summary),
              const SizedBox(height: 16),

              // Subject percentage bars sorted by performance
              _buildSortedSubjectBars(summary, currentStudent),
              const SizedBox(height: 16),

              // Categorized Subject Groups (Weak / Average / Strong)
              _buildCategorizedGroups(summary),
              const SizedBox(height: 16),

              // Topic-level learning gaps section
              _buildTopicLearningGaps(summary, currentStudent),
              const SizedBox(height: 16),

              // Progress History & Improvement Tracking
              _buildProgressHistory(assessProv.assessments),
              const SizedBox(height: 16),

              // Recommended Next Actions
              _buildRecommendedActions(context, summary, currentStudent),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAiPoweredNotice(AppLocalizations? l10n, StudentPerformanceSummary? summary) {
    final theme = Theme.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final modelName = summary?.aiModel ?? 'Gemini 1.5 Flash';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7D7FE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      l10n?.aiPoweredDiagnostic ?? (isGu ? 'AI શૈક્ષણિક નિદાન' : 'AI Pedagogical Diagnostics'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        modelName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.aiPoweredNotice ??
                      (isGu
                          ? 'AI નિદાન (Gemini 1.5 Flash અને શૈક્ષણિક એન્જિન) દ્વારા વિશ્લેષણ અને લક્ષિત ઉપચારાત્મક હસ્તક્ષેપ તૈયાર કરાયા છે.'
                          : 'Analysis and targeted micro-interventions generated using AI diagnostics (Gemini 1.5 Flash & Cognitive Pedagogical Engine).'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSelector(
    List<StudentModel> students,
    StudentModel? currentStudent,
    StudentProvider studentProv,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final authProv = context.watch<AuthProvider>();
    final isParent = authProv.currentUser?.role == UserRole.parent;
    final uniqueStudents = <String, StudentModel>{for (var s in students) s.id: s}.values.toList();
    final effectiveStudentId = uniqueStudents.any((s) => s.id == _selectedStudentId)
        ? _selectedStudentId
        : (uniqueStudents.isNotEmpty ? uniqueStudents.first.id : null);

    if (isParent && uniqueStudents.length <= 1 && currentStudent != null) {
      return Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            children: [
              const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${currentStudent.name} (${currentStudent.className}-${currentStudent.section})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        child: Row(
          children: [
            const Icon(
              Icons.person_outline_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: effectiveStudentId,
                  isExpanded: true,
                  hint: Text(l10n?.selectStudentToAnalyze ?? 'Select Student to Analyze'),
                  items: uniqueStudents.map((s) {
                    return DropdownMenuItem<String>(
                      value: s.id,
                      child: Text(
                        '${s.name} (${s.className}-${s.section})',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (newId) {
                    if (newId != null && newId != _selectedStudentId) {
                      setState(() {
                        _selectedStudentId = newId;
                      });
                      final chosen = uniqueStudents.firstWhere((s) => s.id == newId);
                      studentProv.selectStudent(chosen);
                      _loadData();
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

  Widget _buildOverallCard(StudentPerformanceSummary summary) {
    final theme = Theme.of(context);
    final overallPct = summary.overallPercentage;
    final level = summary.overallLevel;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'gu' ? 'એકંદર શૈક્ષણિક નિપુણતા' : 'Overall Academic Mastery',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${summary.subjectsAssessed} of ${summary.totalSubjects} subjects assessed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PerformanceIndicator(level: level, size: 12),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  overallPct != null ? overallPct.toStringAsFixed(1) : '--',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppColors.getPerformanceColor(level),
                  ),
                ),
                Text(
                  '%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getPerformanceColor(level),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: overallPct != null
                    ? (overallPct / 100.0).clamp(0.0, 1.0)
                    : 0,
                minHeight: 8,
                backgroundColor: AppColors.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.getPerformanceColor(level),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Localizations.localeOf(context).languageCode == 'gu' ? 'નબળું (<૪૦%)' : 'Weak (<40%)', Colors.red.shade700),
                _buildLegendItem(Localizations.localeOf(context).languageCode == 'gu' ? 'સામાન્ય (૪૦-૬૯%)' : 'Average (40-69%)', Colors.amber.shade700),
                _buildLegendItem(Localizations.localeOf(context).languageCode == 'gu' ? 'મજબૂત (≥૭૦%)' : 'Strong (≥70%)', Colors.green.shade700),
              ],
            ),
            const SizedBox(height: 14),
            _buildMasteryComplimentBox(summary),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryComplimentBox(StudentPerformanceSummary summary) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final level = summary.overallLevel;

    Color bgColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    IconData icon;
    String badgeTitle;
    String message;

    switch (level) {
      case PerformanceLevel.strong:
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFF86EFAC);
        iconColor = const Color(0xFF15803D);
        textColor = const Color(0xFF14532D);
        icon = Icons.emoji_events_rounded;
        badgeTitle = isGu ? 'ઉત્કૃષ્ટ શૈક્ષણિક પ્રાવીણ્ય 🌟' : 'Exemplary Mastery 🌟';
        message = isGu
            ? 'શાબાશ! અદ્ભુત સિદ્ધિ. તમે સંકલ્પનાત્મક સ્પષ્ટતા અને ઉત્તમ શૈક્ષણિક પ્રાવીણ્ય દર્શાવ્યું છે. વધુ ઉચ્ચ-સ્તરીય વિચારસરણી અને નવા પડકારો સાથે તમારી પ્રતિભાને વિસ્તારો!'
            : 'Outstanding achievement! You have demonstrated exceptional conceptual clarity and diligence. Continue stretching your curiosity with advanced enrichment tasks and creative problem solving!';
        break;

      case PerformanceLevel.average:
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFF93C5FD);
        iconColor = const Color(0xFF1D4ED8);
        textColor = const Color(0xFF1E3A8A);
        icon = Icons.trending_up_rounded;
        badgeTitle = isGu ? 'સતત પ્રગતિ અને ક્ષમતા 📈' : 'Steady Progress & Potential 📈';
        message = isGu
            ? 'સરસ અને સ્થિર પ્રગતિ! તમે એક સારો પાયો કેળવ્યો છે. મુખ્ય નબળા મુદ્દાઓમાં દૈનિક પુનરાવર્તન અને થોડા વધુ મહાવરા સાથે તમે સરળતાથી સર્વોચ્ચ નિપુણતા મેળવી શકો છો.'
            : 'Good steady progress! You have built a solid foundation. With focused revision on your key growth topics and consistent practice, you can confidently advance into top mastery.';
        break;

      case PerformanceLevel.weak:
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFCD34D);
        iconColor = const Color(0xFFD97706);
        textColor = const Color(0xFF78350F);
        icon = Icons.fitness_center_rounded;
        badgeTitle = isGu ? 'પ્રોત્સાહન અને વધુ પરિશ્રમ 🌱' : 'Encouragement to Practice 🌱';
        message = isGu
            ? 'દરેક નવી બાબત શીખવામાં સમય અને સતત પ્રયત્નની જરૂર છે. હિંમત હાર્યા વગર પાયાના ખ્યાલો પર વધુ ધ્યાન આપો અને નિયમિત ક્વિઝ પ્રેક્ટિસ કરો. દૈનિક વધુ મહેનત અને મહાવરાથી તમે ચોક્કસ આગળ વધશો!'
            : 'Every concept takes time and persistent effort to master. Do not be discouraged—focus on foundational practice and short daily quizzes. Consistent extra work and regular practice will build your strength step by step!';
        break;

      case PerformanceLevel.notAssessed:
        bgColor = const Color(0xFFF8FAFC);
        borderColor = const Color(0xFFCBD5E1);
        iconColor = const Color(0xFF64748B);
        textColor = const Color(0xFF334155);
        icon = Icons.assignment_outlined;
        badgeTitle = isGu ? 'મૂલ્યાંકન પ્રક્રિયા બાકી 📋' : 'Assessment Pending 📋';
        message = isGu
            ? 'તમારી શક્તિઓ અને શીખવાના ક્ષેત્રો જાણવા માટે નિયમિત વિષયવાર મૂલ્યાંકન પૂર્ણ કરો.'
            : 'Complete regular subject assessments to uncover strengths and unlock your personalized learning journey.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badgeTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: textColor.withOpacity(0.95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPlainLanguageCard(StudentPerformanceSummary summary) {
    final theme = Theme.of(context);
    final perfProv = context.watch<PerformanceProvider>();
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFD6E4FF)),
      ),
      color: const Color(0xFFF8FAFF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.aiDiagnosticSummary ??
                        (isGu ? 'AI નિદાન મૂલ્યાંકન સારાંશ' : 'AI Diagnostic Assessment Summary'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 11, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        l10n?.aiPoweredDiagnostic ?? (isGu ? 'AI વિશ્લેષણ' : 'AI Diagnostic'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              summary.plainLanguageSummary,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                icon: perfProv.isAiAnalyzing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 15),
                label: Text(
                  perfProv.isAiAnalyzing
                      ? (isGu ? 'AI વિશ્લેષણ ચાલુ છે...' : 'Analyzing with AI...')
                      : (l10n?.aiReanalyze ?? (isGu ? 'AI વિશ્લેષણ અપડેટ કરો' : 'AI Re-analyze')),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFC7D7FE)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                onPressed: (perfProv.isAiAnalyzing || _selectedStudentId == null)
                    ? null
                    : () {
                        perfProv.regenerateAiAnalysis(
                          _selectedStudentId!,
                          languageCode: Localizations.localeOf(context).languageCode,
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortedSubjectBars(
    StudentPerformanceSummary summary,
    StudentModel? student,
  ) {
    final theme = Theme.of(context);

    // Sort subjects by performance ascending so weakest appear at top
    final sortedSubjects =
        List<SubjectPerformance>.from(summary.subjectPerformances)
          ..sort((a, b) {
            final aVal = a.latestPercentage ?? -1;
            final bVal = b.latestPercentage ?? -1;
            return aVal.compareTo(bVal);
          });

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
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'gu' ? 'નિપુણતા મુજબ ક્રમાંકિત વિષયો' : 'Subjects Ranked by Mastery',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Localizations.localeOf(context).languageCode == 'gu' ? 'ઓછાથી વધુ' : 'Lowest to Highest',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sortedSubjects.map((sp) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.subjectDetail,
                    arguments: {
                      'subjectId': sp.subjectId,
                      'studentId': student?.id,
                    },
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PercentageBar(
                    label: sp.subjectName,
                    percentage: sp.latestPercentage ?? 0,
                    level: sp.level,
                    height: 8,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorizedGroups(StudentPerformanceSummary summary) {
    final theme = Theme.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    final weakSubjects = summary.subjectPerformances
        .where((s) => s.level == PerformanceLevel.weak)
        .toList();
    final avgSubjects = summary.subjectPerformances
        .where((s) => s.level == PerformanceLevel.average)
        .toList();
    final strongSubjects = summary.subjectPerformances
        .where((s) => s.level == PerformanceLevel.strong)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isGu ? 'વિષય વર્ગીકરણ' : 'Subject Categorization',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            // When screen is very narrow (< 380dp), render 1 column or responsive 3-column with small padding
            final itemWidth = (constraints.maxWidth - 16) / 3;
            if (itemWidth < 98) {
              // Stack vertically or 2+1 on compact mobile viewports to prevent 4.7px right overflow
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildCategoryBox(
                          title: isGu ? 'સહાયની જરૂર' : 'Needs Support',
                          count: weakSubjects.length,
                          color: Colors.red.shade700,
                          bgColor: Colors.red.shade50,
                          names: weakSubjects.map((s) => s.subjectName).toList(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCategoryBox(
                          title: isGu ? 'વિકાસશીલ' : 'Developing',
                          count: avgSubjects.length,
                          color: Colors.amber.shade800,
                          bgColor: Colors.amber.shade50,
                          names: avgSubjects.map((s) => s.subjectName).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryBox(
                    title: isGu ? 'નિપુણ' : 'Proficient',
                    count: strongSubjects.length,
                    color: Colors.green.shade700,
                    bgColor: Colors.green.shade50,
                    names: strongSubjects.map((s) => s.subjectName).toList(),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCategoryBox(
                    title: isGu ? 'સહાયની જરૂર' : 'Needs Support',
                    count: weakSubjects.length,
                    color: Colors.red.shade700,
                    bgColor: Colors.red.shade50,
                    names: weakSubjects.map((s) => s.subjectName).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCategoryBox(
                    title: isGu ? 'વિકાસશીલ' : 'Developing',
                    count: avgSubjects.length,
                    color: Colors.amber.shade800,
                    bgColor: Colors.amber.shade50,
                    names: avgSubjects.map((s) => s.subjectName).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCategoryBox(
                    title: isGu ? 'નિપુણ' : 'Proficient',
                    count: strongSubjects.length,
                    color: Colors.green.shade700,
                    bgColor: Colors.green.shade50,
                    names: strongSubjects.map((s) => s.subjectName).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }


  Widget _buildCategoryBox({
    required String title,
    required int count,
    required Color color,
    required Color bgColor,
    required List<String> names,
  }) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
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
          ),
          const SizedBox(height: 8),
          if (names.isEmpty)
            Text(
              isGu ? 'કંઈ નહીં' : 'None',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            )
          else
            ...names.map(
              (n) => Text(
                '• $n',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildTopicLearningGaps(
    StudentPerformanceSummary summary,
    StudentModel? student,
  ) {
    final theme = Theme.of(context);

    // Extract all weak topics
    final List<Map<String, dynamic>> weakList = [];
    for (final s in summary.subjectPerformances) {
      for (final t in s.topicPerformances) {
        if (t.level == PerformanceLevel.weak) {
          weakList.add({
            'subjectId': s.subjectId,
            'subjectName': s.subjectName,
            'topicId': t.topicId,
            'topicName': t.topicName,
            'percentage': t.percentage,
          });
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
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${Localizations.localeOf(context).languageCode == "gu" ? "મુખ્ય અધ્યયન ક્ષતિઓ" : "Critical Learning Gaps"} (${weakList.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              Localizations.localeOf(context).languageCode == 'gu' ? 'વિશિષ્ટ વિષયો જ્યાં નિપુણતા ૪૦% થી ઓછી છે' : 'Specific curriculum topics where mastery is below 40%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Divider(height: 20),
            if (weakList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  Localizations.localeOf(context).languageCode == 'gu' ? 'ઉત્તમ સમાચાર! કોઈ ગંભીર ક્ષતિ ઓળખાયેલ નથી.' : 'Great news! No critical topic-level learning gaps identified.',
                ),
              )
            else
              ...weakList.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['topicName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${item['subjectName']} • Score: ${item['percentage']?.toStringAsFixed(0) ?? 0}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Builder(
                        builder: (ctx) {
                          final userRole = ctx.watch<AuthProvider>().currentUser?.role;
                          final isTeacher = userRole == UserRole.teacher;
                          final l10n = AppLocalizations.of(ctx);

                          // Only teachers can supervise or assign quizzes
                          // Parents, Principals, and BRC view diagnostic gap badge
                          if (!isTeacher) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.assignment_outlined, size: 12, color: Colors.red.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n?.needSupport ?? 'Support Needed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return OutlinedButton.icon(
                            icon: const Icon(Icons.quiz_rounded, size: 14),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n?.superviseQuiz ?? 'Supervise Quiz',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              foregroundColor: Colors.red.shade800,
                              side: BorderSide(color: Colors.red.shade300),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.quiz,
                                arguments: {
                                  'studentId': student?.id,
                                  'classId': student?.classId,
                                  'subjectId': item['subjectId'],
                                  'topicId': item['topicId'],
                                  'topicName': item['topicName'],
                                },
                              ).then((_) => _loadData());
                            },
                          );
                        },
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

  Widget _buildProgressHistory(List<AssessmentModel> assessments) {
    final theme = Theme.of(context);
    final regularAssessments = assessments
        .where((a) => a.type == AssessmentType.regular)
        .toList();

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
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'gu' ? 'પ્રગતિ અને ટ્રેન્ડ ટ્રેકિંગ' : 'Progress & Trend Tracking',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.show_chart_rounded, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 12),
            if (regularAssessments.length < 2)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'gu' ? 'પ્રગતિ ટ્રેકિંગ માટે અપૂરતો ડેટા. ટ્રેન્ડની ગણતરી માટે ઓછામાં ઓછા બે નિયમિત મૂલ્યાંકનની જરૂર છે.' : 'Insufficient data for progress tracking. At least two regular assessments are required to calculate trend delta.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Calculate delta between latest two regular assessments
              Builder(
                builder: (context) {
                  final latest = regularAssessments[0];
                  final previous = regularAssessments[1];
                  final delta = latest.percentage - previous.percentage;
                  final isPositive = delta >= 0;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPositive
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: isPositive
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${isPositive ? "+" : ""}${delta.toStringAsFixed(1)}% percentage points',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isPositive
                                      ? Colors.green.shade900
                                      : Colors.red.shade900,
                                ),
                              ),
                              Text(
                                'Compared to previous test on ${previous.date.day}/${previous.date.month}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isPositive
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedActions(
    BuildContext context,
    StudentPerformanceSummary summary,
    StudentModel? student,
  ) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;

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
              Localizations.localeOf(context).languageCode == 'gu' ? 'ભલામણ કરેલ આગામી હસ્તક્ષેપો' : 'Recommended Next Interventions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...summary.recommendedActions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (user?.role == UserRole.teacher && (user?.subjectIds?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.handyman_rounded, size: 18),
                  label: Text(Localizations.localeOf(context).languageCode == 'gu' ? 'ઉપચારાત્મક પ્રેક્ટિસ સોંપો' : 'Assign Remedial Practice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                  ),
                  onPressed: () {
                    final teacherSubjectIds = user?.subjectIds ?? [];
                    final targetSubjectId = teacherSubjectIds.isNotEmpty ? teacherSubjectIds.first : null;
                    Navigator.pushNamed(
                      context,
                      AppRouter.assignRemedial,
                      arguments: targetSubjectId != null
                          ? {'studentId': student?.id, 'subjectId': targetSubjectId}
                          : {'studentId': student?.id},
                    ).then((_) => _loadData());
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  // ==========================================
  // BRC INSTITUTIONAL SCHOOL PERFORMANCE VIEW
  // ==========================================
  Widget _buildBrcScaffold(
    BuildContext context,
    AppLocalizations? l10n,
    PerformanceProvider perfProv,
    bool isGu,
  ) {
    final schoolSummary = perfProv.schoolSummary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGu
              ? 'શાળા શૈક્ષણિક વિશ્લેષણ (BRC)'
              : 'School Performance Diagnostic (BRC)',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n?.retry ?? (isGu ? 'તાજું કરો' : 'Refresh'),
            onPressed: _loadSchoolData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSchoolData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // AI-Powered Notice
            _buildBrcAiPoweredNotice(schoolSummary, isGu),
            const SizedBox(height: 12),

            // School Selector Dropdown (All Schools / School 1 / School 2 / School 3)
            _buildBrcSchoolSelector(isGu),
            const SizedBox(height: 16),

            if (perfProv.isLoading && schoolSummary == null)
              LoadingWidget(
                message: isGu
                    ? 'શાળાનું AI વિશ્લેષણ તૈયાર થઈ રહ્યું છે...'
                    : 'Synthesizing institutional AI diagnostics...',
              )
            else if (perfProv.error != null && schoolSummary == null)
              AppErrorWidget(
                message: perfProv.error!,
                onRetry: _loadSchoolData,
              )
            else if (schoolSummary == null)
              EmptyStateWidget(
                icon: Icons.apartment_rounded,
                title: isGu ? 'કોઈ સંસ્થાકીય ડેટા નથી' : 'No Institutional Data',
                message: isGu
                    ? 'પસંદ કરેલ શાળા માટે કોઈ મૂલ્યાંકન રેકોર્ડ મળ્યો નથી.'
                    : 'No assessment data available for the selected institution.',
              )
            else ...[
              // 1. Overall Institutional KPI Card
              _buildBrcOverallCard(schoolSummary, isGu),
              const SizedBox(height: 16),

              // 2. AI Institutional Diagnostic & Bottlenecks
              _buildBrcAiDiagnosticCard(schoolSummary, isGu),
              const SizedBox(height: 16),

              // 3. Subject-wise Mastery Breakdown
              _buildBrcSubjectMastery(schoolSummary, isGu),
              const SizedBox(height: 16),

              // 4. Critical FLN Gaps across the School/Block
              _buildBrcInstitutionalGaps(schoolSummary, isGu),
              const SizedBox(height: 16),

              // 5. School Comparison or Class Breakdown
              _buildBrcBreakdownSection(schoolSummary, isGu),
              const SizedBox(height: 16),

              // 6. Supervisory Action Plan & Calendar Reminders
              _buildBrcSupervisoryActions(schoolSummary, isGu),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBrcAiPoweredNotice(
    SchoolPerformanceSummary? summary,
    bool isGu,
  ) {
    final theme = Theme.of(context);
    final modelName = summary?.aiModel ?? 'Gemini 1.5 Flash';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7D7FE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      isGu ? 'AI સંસ્થાકીય નિદાન' : 'AI Institutional Diagnostics',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        modelName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isGu
                      ? 'આ વિશ્લેષણ શાળાઓની સામૂહિક અધ્યયન ક્ષતિઓ, FLN સિદ્ધિ અને ઉપચારાત્મક પ્રગતિનું AI સંશ્લેષણ કરે છે.'
                      : 'Synthesizes institutional FLN mastery trends, cluster remedial completion rates, and supervisory recommendations across schools.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrcSchoolSelector(bool isGu) {
    final theme = Theme.of(context);
    final schools = MockData.schools;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        child: Row(
          children: [
            const Icon(
              Icons.apartment_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSchoolId,
                  isExpanded: true,
                  hint: Text(isGu ? 'શાળા પસંદ કરો' : 'Select School to Analyze'),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'all',
                      child: Text(
                        isGu
                            ? '🏢 ગાંધીનગર ક્લસ્ટર (તમામ ૩ શાળાઓ)'
                            : '🏢 Gandhinagar Cluster (All 3 Schools)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...schools.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(
                          '🏫 ${s.name}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (newId) {
                    if (newId != null && newId != _selectedSchoolId) {
                      setState(() {
                        _selectedSchoolId = newId;
                      });
                      _loadSchoolData();
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

  Widget _buildBrcOverallCard(SchoolPerformanceSummary summary, bool isGu) {
    final theme = Theme.of(context);
    final overallPct = summary.overallPercentage;
    final level = summary.overallLevel;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.schoolName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${summary.blockName} • ${summary.totalClasses} ${isGu ? "વર્ગો મોનિટર થયેલ" : "Monitored Classes"}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PerformanceIndicator(level: level, size: 12),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  overallPct.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppColors.getPerformanceColor(level),
                  ),
                ),
                Text(
                  '%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getPerformanceColor(level),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (overallPct / 100.0).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.getPerformanceColor(level),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  isGu ? 'નબળું (<૪૦%)' : 'Weak (<40%)',
                  Colors.red.shade700,
                ),
                _buildLegendItem(
                  isGu ? 'સામાન્ય (૪૦-૬૯%)' : 'Average (40-69%)',
                  Colors.amber.shade700,
                ),
                _buildLegendItem(
                  isGu ? 'મજબૂત (≥૭૦%)' : 'Strong (≥70%)',
                  Colors.green.shade700,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildBrcMetricTile(
                    title: isGu ? 'મૂલ્યાંકન કવરેજ' : 'Coverage Rate',
                    value: '${summary.coveragePercentage.toStringAsFixed(0)}%',
                    icon: Icons.pie_chart_outline_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBrcMetricTile(
                    title: isGu ? 'ઉપચારાત્મક દર' : 'Remedial Rate',
                    value: '${summary.remedialCompletionRate.toStringAsFixed(0)}%',
                    icon: Icons.task_alt_rounded,
                    color: summary.remedialCompletionRate >= 70
                        ? Colors.green.shade700
                        : Colors.amber.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildBrcMetricTile(
                    title: isGu ? 'વર્ગો સંખ્યા' : 'Classes Tracked',
                    value: '${summary.totalClasses}',
                    icon: Icons.meeting_room_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBrcMetricTile(
                    title: isGu ? 'કુલ મૂલ્યાંકન' : 'Learners Assessed',
                    value: '${summary.totalLearnersAssessed}',
                    icon: Icons.groups_outlined,
                    color: Colors.indigo.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrcMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrcAiDiagnosticCard(SchoolPerformanceSummary summary, bool isGu) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isGu
                        ? 'AI સંસ્થાકીય નિદાન અને ક્લસ્ટર વિશ્લેષણ'
                        : 'AI Institutional Diagnostic & Cluster Analysis',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    summary.aiModel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              summary.plainLanguageSummary,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrcSubjectMastery(SchoolPerformanceSummary summary, bool isGu) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isGu ? 'વિષયવાર સંસ્થાકીય નિપુણતા' : 'Subject-wise Mastery Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ...summary.subjectPerformances.map((subj) {
              final pct = subj.latestPercentage ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: PercentageBar(
                  label: subj.subjectName,
                  percentage: pct,
                  level: subj.level,
                  height: 8,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBrcInstitutionalGaps(SchoolPerformanceSummary summary, bool isGu) {
    final theme = Theme.of(context);
    final gaps = summary.criticalGaps;

    if (gaps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.report_problem_outlined,
                  color: Colors.deepOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isGu
                        ? 'મુખ્ય FLN અધ્યયન ક્ષતિઓ (ક્લસ્ટર સ્તર)'
                        : 'Critical FLN Competency Gaps (Cluster Level)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isGu
                  ? 'શાળાના મૂલ્યાંકન પરથી તારવેલી પ્રાથમિકતા ક્ષતિઓ (કોઈ વિદ્યાર્થી ડેટા નહીં)'
                  : 'Institutional learning deficiencies identified from regular assessments',
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            ...gaps.take(4).map((gap) {
              final isHigh =
                  gap.severity.contains('High') || gap.severity.contains('ઉચ્ચ');
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHigh
                      ? Colors.red.shade50.withOpacity(0.6)
                      : Colors.amber.shade50.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isHigh ? Colors.red.shade200 : Colors.amber.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${gap.topicName} (${gap.subjectName})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isHigh ? Colors.red.shade100 : Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${gap.deficiencyRate.toStringAsFixed(0)}% ${isGu ? "ક્ષતિ દર" : "deficiency"}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  isHigh ? Colors.red.shade900 : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '💡 ${gap.recommendedIntervention}',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Color(0xFF334155),
                      ),
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

  Widget _buildBrcBreakdownSection(SchoolPerformanceSummary summary, bool isGu) {
    final theme = Theme.of(context);

    if (_selectedSchoolId == 'all') {
      final schools = MockData.schools;
      return Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGu ? 'શાળાવાર તુલનાત્મક વિશ્લેષણ' : 'School Performance Comparisons',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...schools.map((school) {
                final avgScore = school.id == 'school_1'
                    ? 74.5
                    : (school.id == 'school_2' ? 59.8 : 68.2);
                final coverage = school.id == 'school_1'
                    ? 92.0
                    : (school.id == 'school_2' ? 78.0 : 84.0);
                final level = PerformanceClassification.classify(avgScore);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
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
                                  school.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  school.address,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          PerformanceIndicator(level: level, size: 10),
                        ],
                      ),
                      const SizedBox(height: 10),
                      PercentageBar(
                        label: isGu ? 'શૈક્ષણિક સરેરાશ' : 'Academic Score',
                        percentage: avgScore,
                        level: level,
                        height: 7,
                      ),
                      const SizedBox(height: 6),
                      PercentageBar(
                        label: isGu ? 'મૂલ્યાંકન કવરેજ' : 'Coverage Rate',
                        percentage: coverage,
                        color: AppColors.secondary,
                        height: 7,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _showScheduleVisitDialog(context, school);
                            },
                            icon: const Icon(Icons.calendar_month_outlined, size: 15),
                            label: Text(
                              isGu ? 'મુલાકાત શેડ્યૂલ' : 'Schedule Visit',
                              style: const TextStyle(fontSize: 11.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedSchoolId = school.id;
                              });
                              _loadSchoolData();
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                            label: Text(
                              isGu ? 'વિગતવાર નિદાન' : 'Inspect School',
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
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
    } else {
      return Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGu ? 'વર્ગવાર શૈક્ષણિક પ્રદર્શન' : 'Class-wise Performance Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...summary.classPerformances.map((cls) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cls.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${cls.learnersCount} ${isGu ? "વિદ્યાર્થીઓ મોનિટર" : "Learners Monitored"}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      PercentageBar(
                        label: isGu ? 'વર્ગ સરેરાશ' : 'Class Average',
                        percentage: cls.averagePercentage,
                        level: cls.level,
                        height: 7,
                      ),
                      const SizedBox(height: 6),
                      PercentageBar(
                        label: isGu ? 'મૂલ્યાંકન કવરેજ' : 'Assessment Coverage',
                        percentage: cls.coveragePercentage,
                        color: AppColors.secondary,
                        height: 7,
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
  }

  Widget _buildBrcSupervisoryActions(SchoolPerformanceSummary summary, bool isGu) {
    final theme = Theme.of(context);
    final schools = MockData.schools;
    final currentSchool = _selectedSchoolId == 'all'
        ? schools.first
        : (schools.where((s) => s.id == _selectedSchoolId).firstOrNull ??
            schools.first);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.checklist_rtl_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  isGu ? 'BRC સંસ્થાકીય કાર્ય યોજના' : 'BRC Supervisory Action Plan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...summary.recommendedActions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.event_note_rounded, size: 18),
                label: Text(
                  isGu
                      ? 'શાળા મુલાકાત અને કેલેન્ડર રીમાઇન્ડર સેટ કરો'
                      : 'Schedule Inspection Visit & Calendar Reminder',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 46),
                ),
                onPressed: () {
                  _showScheduleVisitDialog(context, currentSchool);
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.inventory_2_outlined, size: 16),
                    label: Text(
                      isGu ? 'FLN કિટ્સ ફાળવો' : 'Dispatch Kits',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            isGu
                                ? '${currentSchool.name} માટે FLN ઉપચારાત્મક કિટ્સ ફાળવણી મંજૂર કરાઈ છે.'
                                : 'FLN remedial kit allocation approved for ${currentSchool.name}.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: Text(
                      isGu ? 'રિપોર્ટ એક્સપોર્ટ' : 'Export Report',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.secondary,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            isGu
                                ? 'સંસ્થાકીય શૈક્ષણિક રિપોર્ટ PDF ડાઉનલોડ થઈ ગયો છે.'
                                : 'Institutional diagnostic report exported successfully.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_month_rounded,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isGu
                                    ? 'શાળા મુલાકાત શેડ્યૂલ કરો'
                                    : 'Schedule School Visit',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                school.name,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      isGu ? 'મુલાકાત તારીખ અને સમય' : 'Visit Date & Time',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
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
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 90)),
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
                                  const Icon(Icons.event_rounded,
                                      size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(selectedDate),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
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
                                          fontWeight: FontWeight.w600),
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
                    Text(
                      isGu
                          ? 'મુલાકાતનો હેતુ (Agenda / Purpose)'
                          : 'Inspection Purpose / Agenda',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
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
                          items: (isGu ? purposesGu : purposesEn).map((p) {
                            return DropdownMenuItem<String>(
                              value: p,
                              child:
                                  Text(p, style: const TextStyle(fontSize: 13)),
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
                    Text(
                      isGu
                          ? 'કેલેન્ડર રીમાઇન્ડર એલાર્મ'
                          : 'Calendar Reminder Alert',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
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
                          items: (isGu ? remindersGu : remindersEn).map((r) {
                            return DropdownMenuItem<String>(
                              value: r,
                              child: Row(
                                children: [
                                  const Icon(
                                      Icons.notifications_active_outlined,
                                      size: 16,
                                      color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(r,
                                          style:
                                              const TextStyle(fontSize: 13))),
                                ],
                              ),
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
                    Text(
                      isGu
                          ? 'વિશેષ નોંધ / સૂચનાઓ'
                          : 'Inspection Notes & Directives',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        hintText: isGu
                            ? 'મુલાકાત માટેની વિગતો દાખલ કરો...'
                            : 'Enter directives for this visit...',
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Container(
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
                              ? 'ડિવાઇસ / ગૂગલ કેલેન્ડરમાં રીમાઇન્ડર ઉમેરો'
                              : 'Add reminder event to Device / Google Calendar',
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            addToDeviceCalendar = val ?? true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetCtx),
                            style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13)),
                            child: Text(isGu ? 'રદ કરો' : 'Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_alarm_rounded, size: 18),
                            label: Text(
                              isGu
                                  ? 'શેડ્યૂલ અને રીમાઇન્ડર સાચવો'
                                  : 'Schedule & Set Reminder',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            onPressed: () async {
                              Navigator.pop(sheetCtx);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    isGu
                                        ? '${school.name} માટે મુલાકાત શેડ્યૂલ કરાઈ!'
                                        : 'Inspection visit scheduled for ${school.name}!',
                                    style: const TextStyle(color: Colors.white),
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

  Future<void> _openCalendarEvent({
    required String schoolName,
    required String schoolAddress,
    required DateTime dateTime,
    required String purpose,
    required String reminderTiming,
    String? notes,
  }) async {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

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

    final uri =
        Uri.parse('https://calendar.google.com/calendar/render').replace(
      queryParameters: {
        'action': 'TEMPLATE',
        'text': title,
        'dates': '$startStr/$endStr',
        'details': detailsBuffer.toString(),
        'location': location,
      },
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isGu
                  ? 'કેલેન્ડર રીમાઇન્ડર ખોલવામાં અસમર્થ.'
                  : 'Could not open calendar reminder.',
            ),
          ),
        );
      }
    }
  }
}

