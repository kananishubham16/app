import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/remedial_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/widgets/empty_state_widget.dart';
import 'package:learning_setu/widgets/error_widget.dart';
import 'package:learning_setu/widgets/loading_widget.dart';
import 'package:learning_setu/widgets/stat_card.dart';

/// Remedial activities and targeted interventions management screen.
/// Tailored for teachers (status updates, assigning tasks), parents (home instructions),
/// and administrators (aggregate completion tracking).
class RemedialScreen extends StatefulWidget {
  final String? studentId;

  const RemedialScreen({super.key, this.studentId});

  @override
  State<RemedialScreen> createState() => _RemedialScreenState();
}

class _RemedialScreenState extends State<RemedialScreen> {
  RemedialStatus? _selectedStatusFilter;
  String? _selectedStudentId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.studentId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final studentProv = context.read<StudentProvider>();
      final uniqueStudents = <String, StudentModel>{for (var s in studentProv.students) s.id: s}.values.toList();
      _selectedStudentId ??= studentProv.selectedStudent?.id;
      if (_selectedStudentId != null && !uniqueStudents.any((s) => s.id == _selectedStudentId)) {
        _selectedStudentId = uniqueStudents.isNotEmpty ? uniqueStudents.first.id : null;
      }
      _loadData();
      _initialized = true;
    }
  }

  Future<void> _loadData() async {
    final remedialProv = context.read<RemedialProvider>();
    final schoolProv = context.read<SchoolProvider>();
    final authProv = context.read<AuthProvider>();

    final user = authProv.currentUser;
    await schoolProv.loadSubjects();

    if (user != null &&
        (user.role == UserRole.principal || user.role == UserRole.brc)) {
      if (user.schoolId != null) {
        await remedialProv.loadRemedialsBySchool(user.schoolId!);
      } else {
        await remedialProv.loadRemedialsBySchool('school_1');
      }
    } else if (_selectedStudentId != null) {
      await remedialProv.loadRemedialsByStudent(_selectedStudentId!);
    }
  }

  Color _getStatusColor(RemedialStatus status) {
    switch (status) {
      case RemedialStatus.assigned:
        return const Color(0xFF1E88E5); // Blue
      case RemedialStatus.inProgress:
        return const Color(0xFFF57C00); // Orange
      case RemedialStatus.completed:
        return const Color(0xFF2E7D32); // Green
      case RemedialStatus.needsFollowUp:
        return const Color(0xFFD32F2F); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remedialProv = context.watch<RemedialProvider>();
    final studentProv = context.watch<StudentProvider>();
    final authProv = context.watch<AuthProvider>();

    final user = authProv.currentUser;
    final isParent = user?.role == UserRole.parent;
    final isAdmin =
        user?.role == UserRole.principal || user?.role == UserRole.brc;
    final isTeacher = !isParent && !isAdmin;
    final teacherSubjectIds = (isTeacher && user?.subjectIds != null) ? user!.subjectIds! : <String>[];

    // Restrict teacher to ONLY see tasks/remedials of their assigned subject(s)
    final allRemedials = (isTeacher && teacherSubjectIds.isNotEmpty)
        ? remedialProv.remedials
            .where((r) => teacherSubjectIds.contains(r.subjectId))
            .toList()
        : remedialProv.remedials;
    final students = studentProv.students;

    // Filter list
    final filteredList = allRemedials.where((r) {
      if (!isAdmin &&
          _selectedStudentId != null &&
          r.studentId != _selectedStudentId) {
        return false;
      }
      if (_selectedStatusFilter != null && r.status != _selectedStatusFilter) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.remedialInterventions ?? 'Remedial Interventions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n?.retry ?? 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: isTeacher
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.assignRemedial,
                  arguments: {'studentId': _selectedStudentId},
                ).then((res) {
                  if (res == true) _loadData();
                });
              },
              icon: const Icon(Icons.add_task_rounded),
              label: Text(l10n?.assignRemedial ?? 'Assign Remedial'),
            )
          : null,
      body: remedialProv.isLoading && allRemedials.isEmpty
          ? LoadingWidget(message: l10n?.loading ?? 'Loading remedial actions...')
          : remedialProv.error != null && allRemedials.isEmpty
          ? AppErrorWidget(message: remedialProv.error!, onRetry: _loadData)
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                children: [
                  // Role-specific Header
                  if (isAdmin)
                    _buildAdminAggregateSummary(allRemedials)
                  else if (isParent)
                    _buildParentGuidanceBanner()
                  else
                    _buildStudentSelector(students, studentProv, l10n),

                  if (isTeacher && teacherSubjectIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.assignment_turned_in_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              Localizations.localeOf(context).languageCode == 'gu'
                                  ? 'ફક્ત તમારા સોંપાયેલા વિષયનાં ઉપચારાત્મક કાર્યો દર્શાવેલ છે'
                                  : 'Showing remedial tasks exclusively for your assigned subject(s)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Filter Chips by Status
                  _buildStatusFilterBar(allRemedials),
                  const SizedBox(height: 12),

                  if (filteredList.isEmpty)
                    EmptyStateWidget(
                      icon: Icons.checklist_rtl_rounded,
                      title: l10n?.noActionsFound ?? 'No Actions Found',
                      message: 'No remedial interventions match the selected criteria.',
                    )
                  else
                    ...filteredList.map((rem) {
                      return _buildRemedialCard(
                        context: context,
                        action: rem,
                        isParent: isParent,
                        isTeacher: isTeacher,
                        students: students,
                      );
                    }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildAdminAggregateSummary(List<RemedialAction> list) {
    final assignedCount = list
        .where((r) => r.status == RemedialStatus.assigned)
        .length;
    final inProgressCount = list
        .where((r) => r.status == RemedialStatus.inProgress)
        .length;
    final completedCount = list
        .where((r) => r.status == RemedialStatus.completed)
        .length;
    final followUpCount = list
        .where((r) => r.status == RemedialStatus.needsFollowUp)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizations.localeOf(context).languageCode == 'gu' ? 'શાળા ઉપચારાત્મક ટ્રેકિંગ સારાંશ' : 'School Remedial Tracking Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Assigned',
                value: '$assignedCount',
                icon: Icons.assignment_outlined,
                color: const Color(0xFF1E88E5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                title: 'In Progress',
                value: '$inProgressCount',
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFF57C00),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Completed',
                value: '$completedCount',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                title: 'Needs Follow-up',
                value: '$followUpCount',
                icon: Icons.error_outline_rounded,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParentGuidanceBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.home_outlined, color: Color(0xFF2E7D32), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localizations.localeOf(context).languageCode == 'gu' ? 'વાલીઓ માટે ગૃહ પ્રેક્ટિસ માર્ગદર્શિકા' : 'Home Practice Guide for Parents',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  Localizations.localeOf(context).languageCode == 'gu' ? 'આ લક્ષિત પ્રવૃત્તિઓ તમારા બાળકના શિક્ષક દ્વારા દરરોજ ૧૦-૧૫ મિનિટમાં મૂળભૂત બાબતોને સુદ્રઢ કરવા સૂચવવામાં આવી છે.' : 'These targeted activities are suggested by your child\'s teacher to reinforce core basics at home in 10-15 minutes a day.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
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
    StudentProvider studentProv,
    AppLocalizations? l10n,
  ) {
    final uniqueStudents = <String, StudentModel>{for (var s in students) s.id: s}.values.toList();
    final effectiveStudentId = uniqueStudents.any((s) => s.id == _selectedStudentId) ? _selectedStudentId : null;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
        child: Row(
          children: [
            const Icon(
              Icons.person_pin_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: effectiveStudentId,
                  isExpanded: true,
                  hint: Text(l10n?.allClasses ?? 'All Class Students'),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n?.allClasses ?? 'All Class Students'),
                    ),
                    ...uniqueStudents.map((s) {
                      return DropdownMenuItem<String?>(
                        value: s.id,
                        child: Text('${s.name} (${s.className}-${s.section})'),
                      );
                    }),
                  ],
                  onChanged: (newId) {
                    setState(() {
                      _selectedStudentId = newId;
                    });
                    if (newId != null) {
                      final student = uniqueStudents.firstWhere((s) => s.id == newId);
                      studentProv.selectStudent(student);
                      context.read<RemedialProvider>().loadRemedialsByStudent(
                        newId,
                      );
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

  Widget _buildStatusFilterBar(List<RemedialAction> list) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(null, 'All (${list.length})', null),
          const SizedBox(width: 8),
          _buildFilterChip(
            RemedialStatus.assigned,
            'Assigned (${list.where((r) => r.status == RemedialStatus.assigned).length})',
            _getStatusColor(RemedialStatus.assigned),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            RemedialStatus.inProgress,
            'In Progress (${list.where((r) => r.status == RemedialStatus.inProgress).length})',
            _getStatusColor(RemedialStatus.inProgress),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            RemedialStatus.completed,
            'Completed (${list.where((r) => r.status == RemedialStatus.completed).length})',
            _getStatusColor(RemedialStatus.completed),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            RemedialStatus.needsFollowUp,
            'Needs Follow-up (${list.where((r) => r.status == RemedialStatus.needsFollowUp).length})',
            _getStatusColor(RemedialStatus.needsFollowUp),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(RemedialStatus? status, String label, Color? color) {
    final isSelected = _selectedStatusFilter == status;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? (color ?? AppColors.primary)
            : AppColors.textPrimary,
      ),
      backgroundColor: Colors.transparent,
      selectedColor: (color ?? AppColors.primary).withOpacity(0.12),
      side: BorderSide(
        color: isSelected
            ? (color ?? AppColors.primary)
            : AppColors.dividerColor,
        width: isSelected ? 1.5 : 1,
      ),
      onSelected: (_) {
        setState(() {
          _selectedStatusFilter = status;
        });
      },
    );
  }

  Widget _buildRemedialCard({
    required BuildContext context,
    required RemedialAction action,
    required bool isParent,
    required bool isTeacher,
    required List<StudentModel> students,
  }) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(action.status);
    final student = students.where((s) => s.id == action.studentId).firstOrNull;
    final dueDateStr = DateFormat('dd MMM yyyy').format(action.dueDate);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: statusColor.withOpacity(0.4), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Topic Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.topicName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (student != null)
                        Text(
                          context.read<AuthProvider>().currentUser?.role == UserRole.brc
                              ? '${student.schoolName} • ${student.className}-${student.section} Remedial'
                              : '${Localizations.localeOf(context).languageCode == "gu" ? "વિદ્યાર્થી:" : "Student:"} ${student.name} (${student.className})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.read<AuthProvider>().currentUser?.role == UserRole.brc
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: context.read<AuthProvider>().currentUser?.role == UserRole.brc
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),

                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        action.statusDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Activity Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    action.activityDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Due Date
            Row(
              children: [
                const Icon(
                  Icons.event_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${Localizations.localeOf(context).languageCode == "gu" ? "મુદત તારીખ:" : "Due Date:"} $dueDateStr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (action.hasQuiz) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.quiz_rounded,
                          size: 14,
                          color: Colors.purple.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Localizations.localeOf(context).languageCode == 'gu' ? 'ક્વિઝ જોડાયેલ' : 'Quiz Linked',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            // Parent Instructions (if parent role or present)
            if (isParent && action.parentInstruction != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: Color(0xFF388E3C),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Localizations.localeOf(context).languageCode == 'gu' ? 'વાલી સૂચના:' : 'Parent Instruction:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            action.parentInstruction!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1B5E20),
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

            // Teacher Note (if present)
            if (!isParent &&
                action.teacherNote != null &&
                action.teacherNote!.isNotEmpty) ...[
              const SizedBox(height: 10),
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
                      Icons.note_alt_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${Localizations.localeOf(context).languageCode == "gu" ? "નોંધ:" : "Note:"} ${action.teacherNote!}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Action Buttons
            Row(
              children: [
                if (action.hasQuiz) ...[
                  if (!isTeacher && !isParent) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 16, color: Colors.purple.shade700),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)?.quizAssignedObserver ??
                                'Quiz Assigned (Supervised by Teacher / Parent)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                      label: Text(
                        isParent
                            ? (AppLocalizations.of(context)?.startHomeQuiz ?? 'Start Home Quiz')
                            : (AppLocalizations.of(context)?.superviseQuiz ?? 'Supervise Quiz'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 42),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.quiz,
                          arguments: {
                            'studentId': action.studentId,
                            'classId': student?.classId,
                            'subjectId': action.subjectId,
                            'topicId': action.topicId,
                            'topicName': action.topicName,
                            'remedialActionId': action.id,
                          },
                        ).then((_) => _loadData());
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],

                if (isTeacher) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.update_rounded, size: 16),
                    label: Text(AppLocalizations.of(context)?.updateStatus ?? 'Update Status'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 42),
                    ),
                    onPressed: () => _showUpdateStatusDialog(action),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(RemedialAction action) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('${action.topicName} ${Localizations.localeOf(context).languageCode == "gu" ? "માટે સ્થિતિ અપડેટ કરો" : "Update Status for"}'),
          children: RemedialStatus.values.map((status) {
            final color = _getStatusColor(status);
            return SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                final remProv = context.read<RemedialProvider>();
                await remProv.updateStatus(action.id, status);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated to ${status.name}')),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      status == RemedialStatus.assigned
                          ? 'Assigned'
                          : status == RemedialStatus.inProgress
                          ? 'In Progress'
                          : status == RemedialStatus.completed
                          ? 'Completed'
                          : 'Needs Follow-up',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
