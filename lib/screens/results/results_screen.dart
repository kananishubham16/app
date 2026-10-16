import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/assessment_provider.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/widgets/assigned_teacher_badge.dart';
import 'package:learning_setu/widgets/empty_state_widget.dart';
import 'package:learning_setu/widgets/error_widget.dart';
import 'package:learning_setu/widgets/loading_widget.dart';
import 'package:learning_setu/widgets/percentage_bar.dart';
import 'package:learning_setu/widgets/performance_indicator.dart';

/// Assessment history and results screen with sorting, multi-criteria filtering,
/// topic-wise drill-downs, and assessment recording actions.
class ResultsScreen extends StatefulWidget {
  final String? studentId;

  const ResultsScreen({super.key, this.studentId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStudentId;
  String? _selectedSubjectId;
  String? _selectedClassId;
  DateTimeRange? _selectedDateRange;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedStudentId = widget.studentId;
    if (widget.studentId != null) {
      final st = MockData.students.where((s) => s.id == widget.studentId).firstOrNull;
      if (st != null) {
        _selectedClassId = st.classId;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final schoolProv = context.read<SchoolProvider>();
        final authProv = context.read<AuthProvider>();
        final studentProv = context.read<StudentProvider>();
        final user = authProv.currentUser;
        final isParent = user != null && user.role == UserRole.parent;

        if (isParent) {
          final parentChildrenIds = user.childrenIds ?? [];
          if (_selectedStudentId == null || !parentChildrenIds.contains(_selectedStudentId)) {
            _selectedStudentId = studentProv.selectedStudent?.id;
            if (_selectedStudentId == null || !parentChildrenIds.contains(_selectedStudentId)) {
              _selectedStudentId = parentChildrenIds.isNotEmpty ? parentChildrenIds.first : null;
            }
          }
          if (_selectedStudentId != null) {
            final st = MockData.students.where((s) => s.id == _selectedStudentId).firstOrNull;
            if (st != null) {
              _selectedClassId = st.classId;
            }
          }
        } else {
          if (_selectedClassId == null) {
            if (schoolProv.selectedClass != null) {
              _selectedClassId = schoolProv.selectedClass!.id;
            } else if (user != null && user.classIds != null && user.classIds!.isNotEmpty) {
              _selectedClassId = user.classIds!.first;
            }
          }
        }

        _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    final assessProv = context.read<AssessmentProvider>();
    final schoolProv = context.read<SchoolProvider>();
    final authProv = context.read<AuthProvider>();
    final user = authProv.currentUser;
    final isParent = user != null && user.role == UserRole.parent;

    await schoolProv.loadSubjects();

    if (isParent) {
      if (_selectedStudentId != null) {
        await assessProv.loadAssessmentsByStudent(_selectedStudentId!);
      }
      return;
    }

    final schoolId = user?.schoolId ?? 'school_1';
    if (schoolProv.classes.isEmpty) {
      await schoolProv.loadClassesBySchool(schoolId);
    }

    if (_selectedClassId != null) {
      await assessProv.loadAssessmentsByClass(_selectedClassId!);
    } else {
      final teacherClassIds = (user?.role == UserRole.teacher) ? user?.classIds : null;
      await assessProv.loadAllAssessments(classIds: teacherClassIds);
    }
  }

  String _formatClassLabel(ClassModel c) {
    final clean = c.name.replaceAll(RegExp(r'Class\s*', caseSensitive: false), '').trim();
    if (c.section.isNotEmpty) {
      return '$clean-${c.section}';
    }
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final assessProv = context.watch<AssessmentProvider>();
    final schoolProv = context.watch<SchoolProvider>();
    final authProv = context.watch<AuthProvider>();

    final user = authProv.currentUser;
    final isParent = user != null && user.role == UserRole.parent;
    final isTeacher = user != null && user.role == UserRole.teacher;
    final teacherSubjectIds = (isTeacher && user.subjectIds != null) ? user.subjectIds! : <String>[];

    final classesFromSchool = schoolProv.classes.isNotEmpty ? schoolProv.classes : MockData.classes;
    final List<ClassModel> availableClasses;
    if (isTeacher && user.classIds != null && user.classIds!.isNotEmpty) {
      availableClasses = classesFromSchool.where((c) => user.classIds!.contains(c.id)).toList();
    } else if (user?.schoolId != null) {
      availableClasses = classesFromSchool.where((c) => c.schoolId == user!.schoolId).toList();
    } else {
      availableClasses = classesFromSchool;
    }

    final allSubjects = (isTeacher && teacherSubjectIds.isNotEmpty)
        ? schoolProv.subjects.where((s) => teacherSubjectIds.contains(s.id)).toList()
        : schoolProv.subjects;

    final parentChildrenIds = user?.childrenIds ?? [];
    final List<StudentModel> parentChildren;
    if (isParent) {
      final fromProv = context.watch<StudentProvider>().students.where((s) => parentChildrenIds.contains(s.id)).toList();
      parentChildren = fromProv.isNotEmpty
          ? fromProv
          : MockData.students.where((s) => parentChildrenIds.contains(s.id)).toList();
    } else {
      parentChildren = [];
    }

    // Role-based assessment scoping: parents can ONLY see assessments for _selectedStudentId
    final assessments = isParent
        ? assessProv.assessments.where((a) => a.studentId == _selectedStudentId).toList()
        : ((isTeacher && teacherSubjectIds.isNotEmpty)
            ? assessProv.assessments.where((a) => teacherSubjectIds.contains(a.subjectId)).toList()
            : assessProv.assessments);

    // Filter assessments by class, subject and date range
    final filteredAssessments = assessments.where((a) {
      if (!isParent && _selectedClassId != null) {
        final student = MockData.students.where((s) => s.id == a.studentId).firstOrNull;
        if (student != null && student.classId != _selectedClassId) {
          return false;
        }
      }
      if (_selectedSubjectId != null && a.subjectId != _selectedSubjectId) {
        return false;
      }
      if (_selectedDateRange != null) {
        if (a.date.isBefore(_selectedDateRange!.start) ||
            a.date.isAfter(
              _selectedDateRange!.end.add(const Duration(days: 1)),
            )) {
          return false;
        }
      }
      return true;
    }).toList();

    final regularList = filteredAssessments
        .where((a) => a.type == AssessmentType.regular)
        .toList();
    final quizList = filteredAssessments
        .where((a) => a.type == AssessmentType.remedialQuiz)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.results ?? 'Assessment Results'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: '${l10n?.allSubjects ?? "All"} (${filteredAssessments.length})'),
            Tab(text: '${Localizations.localeOf(context).languageCode == "gu" ? "નિયમિત" : "Regular"} (${regularList.length})'),
            Tab(text: '${Localizations.localeOf(context).languageCode == "gu" ? "ક્વિઝ" : "Quizzes"} (${quizList.length})'),
          ],
        ),
      ),
      floatingActionButton: isTeacher
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.addAssessment,
                ).then((value) {
                  if (value == true) _loadData();
                });
              },
              icon: const Icon(Icons.add_task_rounded),
              label: Text(l10n?.addAssessment ?? 'Add Assessment'),
            )
          : null,
      body: assessProv.isLoading && assessments.isEmpty
          ? const LoadingWidget(message: 'Loading assessment history...')
          : assessProv.error != null && assessments.isEmpty
          ? AppErrorWidget(message: assessProv.error!, onRetry: _loadData)
          : Column(
              children: [
                _buildFiltersHeader(
                  availableClasses,
                  allSubjects,
                  isParent: isParent,
                  parentChildren: parentChildren,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAssessmentList(filteredAssessments, allSubjects),
                      _buildAssessmentList(regularList, allSubjects),
                      _buildAssessmentList(quizList, allSubjects),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFiltersHeader(
    List<ClassModel> classes,
    List<SubjectModel> subjects, {
    required bool isParent,
    required List<StudentModel> parentChildren,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    final effectiveClassId = classes.any((c) => c.id == _selectedClassId) ? _selectedClassId : null;

    final uniqueSubjects = <String, SubjectModel>{for (var s in subjects) s.id: s}.values.toList();
    final effectiveSubjectId = uniqueSubjects.any((s) => s.id == _selectedSubjectId) ? _selectedSubjectId : null;

    final effectiveChildId = parentChildren.any((c) => c.id == _selectedStudentId)
        ? _selectedStudentId
        : (parentChildren.isNotEmpty ? parentChildren.first.id : null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              // If Parent: show Child Selector or Single Child Badge (Never show Class Selector to parents)
              if (isParent)
                Expanded(
                  flex: 5,
                  child: parentChildren.length > 1
                      ? Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.dividerColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: effectiveChildId,
                              isExpanded: true,
                              items: parentChildren.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c.id,
                                  child: Text(
                                    '${c.name} (${c.className}-${c.section})',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (newChildId) {
                                if (newChildId != null && newChildId != _selectedStudentId) {
                                  setState(() {
                                    _selectedStudentId = newChildId;
                                    final st = MockData.students.where((s) => s.id == newChildId).firstOrNull;
                                    if (st != null) _selectedClassId = st.classId;
                                  });
                                  final selectedChild = parentChildren.where((c) => c.id == newChildId).firstOrNull;
                                  if (selectedChild != null) {
                                    context.read<StudentProvider>().selectStudent(selectedChild);
                                  }
                                  _loadData();
                                }
                              },
                            ),
                          ),
                        )
                      : Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  parentChildren.isNotEmpty
                                      ? '${parentChildren.first.name} (${parentChildren.first.className}-${parentChildren.first.section})'
                                      : (_selectedStudentId ?? 'Child Profile'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                )
              else
                // Class Selector (e.g. "All Classes", "3-A", "4-A")
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.dividerColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: effectiveClassId,
                        isExpanded: true,
                        hint: Text(
                          l10n?.selectClass ?? (isGu ? 'વર્ગ પસંદ કરો' : 'Select Class'),
                          style: const TextStyle(fontSize: 13),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              l10n?.allClasses ?? (isGu ? 'બધા વર્ગો' : 'All Classes'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ...classes.map((c) {
                            return DropdownMenuItem<String?>(
                              value: c.id,
                              child: Text(
                                _formatClassLabel(c),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (newClassId) {
                          setState(() {
                            _selectedClassId = newClassId;
                          });
                          if (newClassId != null) {
                            context
                                .read<AssessmentProvider>()
                                .loadAssessmentsByClass(newClassId);
                          } else {
                            final user = context.read<AuthProvider>().currentUser;
                            final teacherClassIds = (user?.role == UserRole.teacher) ? user?.classIds : null;
                            context
                                .read<AssessmentProvider>()
                                .loadAllAssessments(classIds: teacherClassIds);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),

              // Subject Filter
              Expanded(
                flex: 4,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: effectiveSubjectId,
                      isExpanded: true,
                      hint: Text(
                        l10n?.allSubjects ?? 'All Subjects',
                        style: const TextStyle(fontSize: 13),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            l10n?.allSubjects ?? 'All Subjects',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        ...uniqueSubjects.map((s) {
                          return DropdownMenuItem<String?>(
                            value: s.id,
                            child: Text(
                              s.getLocalizedName(context),
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (newSubjectId) {
                        setState(() {
                          _selectedSubjectId = newSubjectId;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Date Filter Button
              IconButton.filledTonal(
                icon: Icon(
                  _selectedDateRange != null
                      ? Icons.filter_alt_rounded
                      : Icons.date_range_rounded,
                  size: 20,
                  color: _selectedDateRange != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                tooltip: Localizations.localeOf(context).languageCode == 'gu' ? 'તારીખ શ્રેણી દ્વારા ફિલ્ટર કરો' : 'Filter by date range',
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _pickDateRange,
              ),
            ],
          ),
          if (_selectedDateRange != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Chip(
                  label: Text(
                    '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () {
                    setState(() {
                      _selectedDateRange = null;
                    });
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange:
          _selectedDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 60)),
            end: now,
          ),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Widget _buildAssessmentList(
    List<AssessmentModel> list,
    List<SubjectModel> subjects,
  ) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.assignment_outlined,
        title: Localizations.localeOf(context).languageCode == 'gu' ? 'કોઈ મૂલ્યાંકન રેકોર્ડ નથી' : 'No Assessment Records',
        message: Localizations.localeOf(context).languageCode == 'gu' ? 'સક્રિય ફિલ્ટર્સ સાથે મેળ ખાતા કોઈ પરીક્ષણો નથી.' : 'No recorded tests or remedial quizzes match the active filters.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final assessment = list[index];
          final subject = subjects
              .where((s) => s.id == assessment.subjectId)
              .firstOrNull;
          final subjectName = subject?.name ?? assessment.subjectId;
          final isQuiz = assessment.type == AssessmentType.remedialQuiz;
          final level = PerformanceClassification.classify(
            assessment.percentage,
          );
          final dateStr = DateFormat('dd MMM yyyy').format(assessment.date);
          final student = MockData.students
              .where((s) => s.id == assessment.studentId)
              .firstOrNull;
          final studentClass = student != null
              ? '${student.className.replaceAll(RegExp(r"Class\s*", caseSensitive: false), "").trim()}-${student.section}'
              : '';
          final user = context.watch<AuthProvider>().currentUser;
          final assignedTeacher = MockData.getTeacherForSubject(
            subjectId: assessment.subjectId,
            classId: student?.classId,
            schoolId: student?.schoolId,
          );

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.dividerColor),
            ),
            child: InkWell(
              onTap: () => _showAssessmentDetailBottomSheet(
                context,
                assessment,
                subjectName,
              ),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subjectName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    user?.role == UserRole.brc
                                        ? Icons.apartment_rounded
                                        : Icons.person_outline_rounded,
                                    size: 13,
                                    color: user?.role == UserRole.brc
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      user?.role == UserRole.brc
                                          ? '${student?.schoolName ?? "Primary School"} • Class $studentClass Batch'
                                          : (student != null
                                              ? '${student.name} • $studentClass'
                                              : 'Student ${assessment.studentId}'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: user?.role == UserRole.brc
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (user?.role == UserRole.principal && assignedTeacher != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.badge_outlined,
                                        size: 13,
                                        color: Colors.indigo.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          Localizations.localeOf(context).languageCode == 'gu'
                                              ? 'શિક્ષક: ${assignedTeacher.name}'
                                              : 'Teacher: ${assignedTeacher.name}',
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
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${assessment.obtainedMarks.toStringAsFixed(0)} / ${assessment.totalMarks.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: PerformanceIndicator(
                                level: level,
                                percentage: assessment.percentage,
                                size: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
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
                            isQuiz
                                ? (Localizations.localeOf(context).languageCode == 'gu' ? 'ઉપચારાત્મક ક્વિઝ' : 'Remedial Quiz')
                                : (Localizations.localeOf(context).languageCode == 'gu' ? 'નિયમિત મૂલ્યાંકન' : 'Regular Assessment'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isQuiz
                                  ? Colors.purple.shade700
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${assessment.topicScores.length} ${Localizations.localeOf(context).languageCode == "gu" ? "વિષયો" : "Topics"}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PercentageBar(
                      label: Localizations.localeOf(context).languageCode == 'gu' ? 'એકંદર સ્કોર' : 'Overall Score',
                      percentage: assessment.percentage,
                      level: level,
                      height: 6,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
    final student = MockData.students
        .where((s) => s.id == assessment.studentId)
        .firstOrNull;
    final studentClass = student != null
        ? '${student.className.replaceAll(RegExp(r"Class\s*", caseSensitive: false), "").trim()}-${student.section}'
        : '';
    final assignedTeacher = MockData.getTeacherForSubject(
      subjectId: assessment.subjectId,
      classId: student?.classId,
      schoolId: student?.schoolId,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
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
                          '$subjectName ${Localizations.localeOf(context).languageCode == "gu" ? "વિગતો" : "Details"}',
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
                  if (student != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            context.read<AuthProvider>().currentUser?.role == UserRole.brc
                                ? Icons.apartment_rounded
                                : Icons.person_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              context.read<AuthProvider>().currentUser?.role == UserRole.brc
                                  ? '${student.schoolName} • ${isGu ? "વર્ગ" : "Class"} $studentClass Batch'
                                  : '${student.name} (${student.studentId}) • ${isGu ? "વર્ગ" : "Class"} $studentClass',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (context.read<AuthProvider>().currentUser?.role == UserRole.principal &&
                      assignedTeacher != null) ...[
                    const SizedBox(height: 8),
                    AssignedTeacherBadge(
                      teacher: assignedTeacher,
                      labelPrefix: isGu ? 'સોંપાયેલ વિષય શિક્ષક' : 'Assigned Subject Teacher',
                      showPhone: true,
                    ),
                  ],

                  const Divider(height: 24),
                  Text(
                    Localizations.localeOf(context).languageCode == 'gu' ? 'વિષય મુજબ પરિણામો' : 'Topic-Wise Results',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (assessment.topicScores.isEmpty)
                    Text(Localizations.localeOf(context).languageCode == 'gu' ? 'કોઈ વિષય મુજબ સ્કોર સંગ્રહિત નથી.' : 'No individual topic scores stored.')
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${ts.obtainedMarks.toStringAsFixed(0)} / ${ts.totalMarks.toStringAsFixed(0)} (${ts.percentage.toStringAsFixed(0)}%)',
                                  style: TextStyle(
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
                      Localizations.localeOf(context).languageCode == 'gu' ? 'શિક્ષકની નોંધ' : 'Teacher Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        assessment.notes!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
