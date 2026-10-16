import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/performance_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/widgets/assigned_teacher_badge.dart';
import 'package:learning_setu/widgets/empty_state_widget.dart';
import 'package:learning_setu/widgets/error_widget.dart';
import 'package:learning_setu/widgets/loading_widget.dart';
import 'package:learning_setu/widgets/percentage_bar.dart';
import 'package:learning_setu/widgets/performance_indicator.dart';

/// Screen displaying the primary school subject curriculum grid.
/// Supports both general curriculum listing and student-specific performance overlay.
class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  bool _initialized = false;
  String? _selectedSchoolId;
  String? _selectedClassId;
  bool _teacherFilterAssigned = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final studentProv = context.read<StudentProvider>();
        final uniqueStudents = <String, StudentModel>{for (var s in studentProv.students) s.id: s}.values.toList();
        if (studentProv.selectedStudent != null && !uniqueStudents.any((s) => s.id == studentProv.selectedStudent!.id)) {
          studentProv.selectStudent(null);
        }
        _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final schoolProv = context.read<SchoolProvider>();
    final studentProv = context.read<StudentProvider>();
    final perfProv = context.read<PerformanceProvider>();

    final user = auth.currentUser;
    if (user?.role == UserRole.brc) {
      final blockId = user?.blockId ?? 'block_1';
      await schoolProv.loadSchoolsByBlock(blockId);
    } else if (user?.role == UserRole.principal) {
      if (user?.schoolId != null) {
        await schoolProv.loadClassesBySchool(user!.schoolId!);
      }
    }

    await schoolProv.loadSubjects();

    if (studentProv.selectedStudent != null) {
      await perfProv.loadPerformance(studentProv.selectedStudent!.id);
    }
  }

  IconData _getSubjectIcon(String iconName) {
    switch (iconName.toLowerCase()) {
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

  Color _getSubjectColor(String subjectId) {
    switch (subjectId) {
      case 'subject_math':
        return const Color(0xFF1565C0); // Blue
      case 'subject_guj':
        return const Color(0xFFD84315); // Deep Orange
      case 'subject_eng':
        return const Color(0xFF6A1B9A); // Deep Purple
      case 'subject_evs':
        return const Color(0xFF2E7D32); // Forest Green
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final schoolProv = context.watch<SchoolProvider>();
    final studentProv = context.watch<StudentProvider>();
    final perfProv = context.watch<PerformanceProvider>();
    final authProv = context.watch<AuthProvider>();

    final user = authProv.currentUser;
    final selectedStudent = studentProv.selectedStudent;
    final allSubjects = schoolProv.subjects;
    final summary = perfProv.summary;

    final assignedSubjectIds = user?.subjectIds;
    final subjects = (user?.role == UserRole.teacher &&
            _teacherFilterAssigned &&
            assignedSubjectIds != null &&
            assignedSubjectIds.isNotEmpty)
        ? allSubjects.where((s) => assignedSubjectIds.contains(s.id)).toList()
        : allSubjects;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.subjectsAndCurriculum ?? 'Subjects & Curriculum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n?.retry ?? 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: schoolProv.isLoading && allSubjects.isEmpty
          ? LoadingWidget(message: l10n?.loading ?? 'Loading subjects...')
          : schoolProv.error != null && allSubjects.isEmpty
          ? AppErrorWidget(message: schoolProv.error!, onRetry: _loadData)
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                children: [
                  // Prominent Curriculum Disclaimer Note
                  _buildCurriculumNotice(),
                  const SizedBox(height: 12),

                  // Student Context Filter Selector
                  _buildStudentContextBar(studentProv, schoolProv, user, l10n),
                  const SizedBox(height: 16),

                  // Mistake 1 Fix: Teacher Assigned Subjects Filter Bar
                  if (user?.role == UserRole.teacher &&
                      assignedSubjectIds != null &&
                      assignedSubjectIds.isNotEmpty) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            avatar: const Icon(Icons.assignment_ind_outlined, size: 16),
                            label: Text(
                              '${l10n?.myAssignedSubjects ?? "My Assigned Subjects"} (${assignedSubjectIds.length})',
                            ),
                            selected: _teacherFilterAssigned,
                            onSelected: (val) {
                              setState(() => _teacherFilterAssigned = true);
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            avatar: const Icon(Icons.menu_book, size: 16),
                            label: Text(
                              '${l10n?.allCurriculumSubjects ?? "All Grade Subjects"} (${allSubjects.length})',
                            ),
                            selected: !_teacherFilterAssigned,
                            onSelected: (val) {
                              setState(() => _teacherFilterAssigned = false);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  if (subjects.isEmpty)
                    EmptyStateWidget(
                      icon: Icons.menu_book_outlined,
                      title: l10n?.noData ?? 'No Subjects Found',
                      message: 'No subjects currently registered for this filter.',
                    )
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            selectedStudent != null
                                ? (l10n?.classPerformanceOverview ?? 'Performance by Subject')
                                : (l10n?.curriculumSubjects ?? 'Curriculum Subjects'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${subjects.length} ${l10n?.subjects ?? "Subjects"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Responsive Grid of Subject Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        if (!isWide) {
                          return Column(
                            children: subjects.map((subject) {
                              final SubjectPerformance? subjectPerf = summary
                                  ?.subjectPerformances
                                  .where((sp) => sp.subjectId == subject.id)
                                  .firstOrNull;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildSubjectCard(
                                  context: context,
                                  subject: subject,
                                  performance: subjectPerf,
                                  selectedStudent: selectedStudent,
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subjects.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.55,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final subject = subjects[index];
                            final SubjectPerformance? subjectPerf = summary
                                ?.subjectPerformances
                                .where((sp) => sp.subjectId == subject.id)
                                .firstOrNull;

                            return _buildSubjectCard(
                              context: context,
                              subject: subject,
                              performance: subjectPerf,
                              selectedStudent: selectedStudent,
                            );
                          },
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildCurriculumNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.amber.shade900,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              Localizations.localeOf(context).languageCode == 'gu' ? 'નમૂનારૂપ અધ્યયન સામગ્રી માત્ર દર્શનાર્થે છે, સત્તાવાર રીતે ચકાસાયેલ અભ્યાસક્રમ નથી.' : 'Sample learning content shown is illustrative, not officially verified curriculum.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentContextBar(
    StudentProvider studentProv,
    SchoolProvider schoolProv,
    UserModel? user,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final selected = studentProv.selectedStudent;
    final allStudents = studentProv.students;
    final uniqueStudents = <String, StudentModel>{for (var s in allStudents) s.id: s}.values.toList();
    final hasSelected = uniqueStudents.any((s) => s.id == selected?.id);

    // BRC Hierarchical Selector: School -> Class -> Student (Mistake 2 & Video 3 Fix)
    if (user?.role == UserRole.brc) {
      final schools = schoolProv.schools;
      final classes = schoolProv.classes;

      return Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. School Selector
              Row(
                children: [
                  const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n?.selectSchool ?? "School"}:',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: schools.any((s) => s.id == _selectedSchoolId) ? _selectedSchoolId : null,
                        isExpanded: true,
                        hint: Text(l10n?.allSchools ?? 'All Schools in Block', style: const TextStyle(fontSize: 13)),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              l10n?.allSchools ?? 'All Schools in Block',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...schools.map(
                            (s) => DropdownMenuItem<String?>(
                              value: s.id,
                              child: Text(s.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: (newSchoolId) {
                          setState(() {
                            _selectedSchoolId = newSchoolId;
                            _selectedClassId = null;
                          });
                          studentProv.selectStudent(null);
                          context.read<PerformanceProvider>().clear();
                          if (newSchoolId != null) {
                            schoolProv.loadClassesBySchool(newSchoolId);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Class Selector (when a school is selected)
              if (_selectedSchoolId != null && classes.isNotEmpty) ...[
                const Divider(height: 12),
                Row(
                  children: [
                    const Icon(Icons.class_outlined, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n?.selectClass ?? "Class"}:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: classes.any((c) => c.id == _selectedClassId) ? _selectedClassId : null,
                          isExpanded: true,
                          hint: Text(l10n?.allClasses ?? 'All Classes in School', style: const TextStyle(fontSize: 12)),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(l10n?.allClasses ?? 'All Classes in School', style: const TextStyle(fontSize: 12)),
                            ),
                            ...classes.map(
                              (c) => DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.displayName, style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                          onChanged: (newClassId) {
                            setState(() {
                              _selectedClassId = newClassId;
                            });
                            studentProv.selectStudent(null);
                            context.read<PerformanceProvider>().clear();
                            if (newClassId != null) {
                              studentProv.loadStudentsByClass(newClassId);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // 3. Student drilldown (when class is selected)
              if (_selectedClassId != null && uniqueStudents.isNotEmpty) ...[
                const Divider(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n?.selectStudent ?? "Student"}:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: hasSelected ? selected?.id : null,
                          isExpanded: true,
                          hint: Text(l10n?.curriculumOverview ?? 'Curriculum Overview', style: const TextStyle(fontSize: 12)),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                l10n?.curriculumOverview ?? 'Curriculum Overview',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...uniqueStudents.map(
                              (s) => DropdownMenuItem<String?>(
                                value: s.id,
                                child: Text(s.name, style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                          onChanged: (newId) {
                            if (newId == null) {
                              studentProv.selectStudent(null);
                              context.read<PerformanceProvider>().clear();
                            } else {
                              final chosen = uniqueStudents.firstWhere((s) => s.id == newId);
                              studentProv.selectStudent(chosen);
                              context.read<PerformanceProvider>().loadPerformance(chosen.id);
                            }
                          },
                        ),
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

    // Standard context bar for Teacher, Principal, Parent
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Row(
          children: [
            const Icon(
              Icons.person_pin_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.viewingStudent ?? 'Viewing Student',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    selected != null
                        ? '${selected.name} (${selected.className}-${selected.section})'
                        : (l10n?.generalView ?? 'General View (No student selected)'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (uniqueStudents.isNotEmpty)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(0, 36),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                label: Text(
                  Localizations.localeOf(context).languageCode == 'gu' ? 'બદલો' : 'Change',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                onPressed: () {
                  _showStudentSelectionBottomSheet(
                    context,
                    uniqueStudents,
                    selected,
                    studentProv,
                    l10n,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }


  void _showStudentSelectionBottomSheet(
    BuildContext context,
    List<StudentModel> students,
    StudentModel? currentSelected,
    StudentProvider studentProv,
    AppLocalizations? l10n,
  ) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isGu ? 'વિદ્યાર્થી પસંદ કરો' : 'Select Student',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
                  ),
                  title: Text(
                    l10n?.curriculumOverview ?? (isGu ? 'અભ્યાસક્રમ સામાન્ય દૃશ્ય' : 'General Curriculum Overview'),
                    style: TextStyle(
                      fontWeight: currentSelected == null ? FontWeight.bold : FontWeight.w500,
                      color: currentSelected == null ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    isGu ? 'કોઈ ચોક્કસ વિદ્યાર્થી પસંદ કરેલ નથી' : 'No specific student filtered',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: currentSelected == null
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    studentProv.selectStudent(null);
                    context.read<PerformanceProvider>().clear();
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: students.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {

                      final s = students[index];
                      final isSelected = currentSelected?.id == s.id;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.grey.shade100,
                          child: Text(
                            s.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        title: Text(
                          s.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${s.className} • ID: ${s.studentId}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            : null,
                        onTap: () {
                          studentProv.selectStudent(s);
                          context.read<PerformanceProvider>().loadPerformance(s.id);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectCard({

    required BuildContext context,
    required SubjectModel subject,
    required SubjectPerformance? performance,
    required StudentModel? selectedStudent,
  }) {
    final theme = Theme.of(context);
    final subjectColor = _getSubjectColor(subject.id);
    final iconData = _getSubjectIcon(subject.iconName);

    final bool hasStudent = selectedStudent != null;
    final double? score = performance?.latestPercentage;
    final PerformanceLevel level =
        performance?.level ?? PerformanceLevel.notAssessed;
    final user = context.watch<AuthProvider>().currentUser;
    final assignedTeacher = MockData.getTeacherForSubject(
      subjectId: subject.id,
      classId: selectedStudent?.classId,
      schoolId: user?.schoolId,
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: hasStudent && level == PerformanceLevel.weak
              ? Colors.red.shade300
              : AppColors.dividerColor,
          width: hasStudent && level == PerformanceLevel.weak ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.subjectDetail,
            arguments: {
              'subjectId': subject.id,
              'studentId': selectedStudent?.id,
              'subject': subject,
            },
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: subjectColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(iconData, color: subjectColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.getLocalizedName(context),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${subject.topics.length} ${Localizations.localeOf(context).languageCode == "gu" ? "મુખ્ય વિષયો" : "Key Topics"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hasStudent)
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: PerformanceIndicator(
                          level: level,
                          percentage: score,
                          size: 11,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subject.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (user?.role == UserRole.principal && assignedTeacher != null) ...[
                const SizedBox(height: 8),
                AssignedTeacherBadge(
                  teacher: assignedTeacher,
                  labelPrefix: Localizations.localeOf(context).languageCode == 'gu'
                      ? 'સોંપાયેલ શિક્ષક'
                      : 'Assigned Teacher',
                  showPhone: true,
                ),
              ],
              const SizedBox(height: 10),
              if (hasStudent && score != null) ...[
                PercentageBar(
                  label: Localizations.localeOf(context).languageCode == 'gu' ? 'તાજેતરનું મૂલ્યાંકન' : 'Latest Assessment',
                  percentage: score,
                  level: level,
                  height: 6,
                ),
              ] else if (hasStudent) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'gu' ? 'આ વિદ્યાર્થી માટે હજુ મૂલ્યાંકન થયું નથી' : 'Not assessed yet for this student',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'gu' ? 'અભ્યાસક્રમ અને ઉદ્દેશ્યો જોવા ટેપ કરો' : 'Tap to view curriculum & objectives',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
