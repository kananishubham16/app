import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/assessment_provider.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/performance_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/services/bilingual_notification_service.dart';

/// Form screen allowing educators to log new regular classroom assessments
/// with student selection, subject, dynamic per-topic scores, notes, and full validation.
class AddAssessmentScreen extends StatefulWidget {
  final String? studentId;
  final String? subjectId;

  const AddAssessmentScreen({super.key, this.studentId, this.subjectId});

  @override
  State<AddAssessmentScreen> createState() => _AddAssessmentScreenState();
}

class _AddAssessmentScreenState extends State<AddAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedStudentId;
  String? _selectedSubjectId;
  DateTime _assessmentDate = DateTime.now();
  final TextEditingController _totalMarksController = TextEditingController(
    text: '50',
  );
  final TextEditingController _notesController = TextEditingController();

  // Dynamic topic controllers: topicId -> {obtained: controller, total: controller}
  final Map<String, TextEditingController> _topicObtainedControllers = {};
  final Map<String, TextEditingController> _topicTotalControllers = {};

  bool _isSaving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.studentId;
    _selectedSubjectId = widget.subjectId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final studentProv = context.read<StudentProvider>();
      final schoolProv = context.read<SchoolProvider>();
      final authProv = context.read<AuthProvider>();

      final user = authProv.currentUser;
      final isTeacher = user?.role == UserRole.teacher;
      final teacherSubjectIds = (isTeacher && user?.subjectIds != null) ? user!.subjectIds! : <String>[];

      _selectedStudentId ??= studentProv.selectedStudent?.id;
      if (_selectedStudentId == null && studentProv.students.isNotEmpty) {
        _selectedStudentId = studentProv.students.first.id;
      }

      if (isTeacher) {
        if (widget.subjectId != null && teacherSubjectIds.contains(widget.subjectId)) {
          _selectedSubjectId = widget.subjectId;
        } else {
          _selectedSubjectId = teacherSubjectIds.isNotEmpty ? teacherSubjectIds.first : null;
        }
      } else {
        _selectedSubjectId ??= (schoolProv.subjects.isNotEmpty ? schoolProv.subjects.first.id : null);
      }

      _setupTopicControllers();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _totalMarksController.dispose();
    _notesController.dispose();
    for (final c in _topicObtainedControllers.values) {
      c.dispose();
    }
    for (final c in _topicTotalControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _setupTopicControllers() {
    final schoolProv = context.read<SchoolProvider>();
    final subject = schoolProv.subjects
        .where((s) => s.id == _selectedSubjectId)
        .firstOrNull;

    // Clear old controllers
    for (final c in _topicObtainedControllers.values) {
      c.dispose();
    }
    for (final c in _topicTotalControllers.values) {
      c.dispose();
    }
    _topicObtainedControllers.clear();
    _topicTotalControllers.clear();

    if (subject != null && subject.topics.isNotEmpty) {
      final totalMarks = double.tryParse(_totalMarksController.text) ?? 50.0;
      final perTopicTotal = (totalMarks / subject.topics.length)
          .roundToDouble();

      for (final topic in subject.topics) {
        _topicTotalControllers[topic.id] = TextEditingController(
          text: perTopicTotal.toStringAsFixed(0),
        );
        _topicObtainedControllers[topic.id] = TextEditingController(text: '');
      }
    }
  }

  void _onSubjectChanged(String? newSubjectId) {
    if (newSubjectId != null && newSubjectId != _selectedSubjectId) {
      setState(() {
        _selectedSubjectId = newSubjectId;
        _setupTopicControllers();
      });
    }
  }

  double _calculateTotalObtainedMarks() {
    double sum = 0.0;
    for (final c in _topicObtainedControllers.values) {
      final val = double.tryParse(c.text.trim()) ?? 0.0;
      sum += val;
    }
    return sum;
  }

  double _calculateTotalMaxMarks() {
    double sum = 0.0;
    for (final c in _topicTotalControllers.values) {
      final val = double.tryParse(c.text.trim()) ?? 0.0;
      sum += val;
    }
    return sum;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _assessmentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _assessmentDate = picked;
      });
    }
  }

  Future<void> _saveAssessment() async {
    if (!_formKey.currentState!.validate()) return;

    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    final authProv = context.read<AuthProvider>();
    final user = authProv.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final teacherSubjectIds = (isTeacher && user?.subjectIds != null) ? user!.subjectIds! : <String>[];

    if (isTeacher) {
      if (_selectedSubjectId == null || !teacherSubjectIds.contains(_selectedSubjectId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isGu
                  ? 'તમને ફક્ત તમારા સોંપાયેલા વિષયો માટે જ મૂલ્યાંકન ઉમેરવાની પરવાનગી છે.'
                  : 'You are only permitted to log assessments for your assigned subjects.',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }
    }

    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGu ? 'કૃપા કરીને વિદ્યાર્થી પસંદ કરો' : 'Please select a student',
          ),
        ),
      );
      return;
    }

    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGu ? 'કૃપા કરીને વિષય પસંદ કરો' : 'Please select a subject',
          ),
        ),
      );
      return;
    }

    final schoolProv = context.read<SchoolProvider>();
    final subject = schoolProv.subjects
        .where((s) => s.id == _selectedSubjectId)
        .firstOrNull;

    if (subject == null || subject.topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGu
                ? 'આ વિષય માટે કોઈ વિષયાંગ મળ્યા નથી'
                : 'No topics found for this subject',
          ),
        ),
      );
      return;
    }

    // Build topic scores
    final List<TopicScore> topicScores = [];
    for (final topic in subject.topics) {
      final obtainedStr =
          _topicObtainedControllers[topic.id]?.text.trim() ?? '0';
      final totalStr = _topicTotalControllers[topic.id]?.text.trim() ?? '10';

      final obtained = double.tryParse(obtainedStr) ?? 0.0;
      final total = double.tryParse(totalStr) ?? 10.0;

      if (obtained > total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isGu
                  ? '"${topic.name}" માટે મેળવેલ ગુણ કુલ ગુણથી વધુ ન હોઈ શકે'
                  : 'Obtained marks cannot exceed total for "${topic.name}"',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }

      topicScores.add(
        TopicScore(
          topicId: topic.id,
          topicName: topic.name,
          totalMarks: total,
          obtainedMarks: obtained,
        ),
      );
    }

    final totalMarks = _calculateTotalMaxMarks();
    final obtainedMarks = _calculateTotalObtainedMarks();

    if (totalMarks <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGu
                ? 'કુલ ગુણ ૦ કરતાં વધુ હોવા જોઈએ'
                : 'Total marks must be greater than 0',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newAssessment = AssessmentModel(
      id: const Uuid().v4(),
      studentId: _selectedStudentId!,
      subjectId: _selectedSubjectId!,
      type: AssessmentType.regular,
      date: _assessmentDate,
      totalMarks: totalMarks,
      obtainedMarks: obtainedMarks,
      topicScores: topicScores,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final assessProv = context.read<AssessmentProvider>();
    final perfProv = context.read<PerformanceProvider>();
    final studentProv = context.read<StudentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await assessProv.addAssessment(newAssessment);

    if (mounted) {
      if (success) {
        // Trigger performance summary refresh
        await perfProv.loadPerformance(_selectedStudentId!);
        if (!mounted) return;

        final student = studentProv.students
            .where((s) => s.id == _selectedStudentId)
            .firstOrNull;

        // Check if student has parent phone info
        if (student != null && student.parentPhone != null && mounted) {
          final bilingualMessage =
              BilingualNotificationService.buildBilingualAssessmentMessage(
            studentName: student.name,
            className: student.className,
            subjectName: subject.name,
            obtainedMarks: obtainedMarks,
            totalMarks: totalMarks,
            schoolName: student.schoolName,
            teacherNotes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

          await BilingualNotificationService.showMessageModal(
            context: context,
            title: isGu
                ? 'વાલીને પરિણામ મોકલો (Bilingual)'
                : 'Forward Result to Parent (Bilingual)',
            recipientName: student.parentName ?? student.name,
            recipientPhone: student.parentPhone!,
            message: bilingualMessage,
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Assessment logged successfully! Score: ${obtainedMarks.toStringAsFixed(0)}/${totalMarks.toStringAsFixed(0)}',
              ),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(assessProv.error ?? 'Failed to save assessment'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentProv = context.watch<StudentProvider>();
    final schoolProv = context.watch<SchoolProvider>();
    final authProv = context.watch<AuthProvider>();

    final user = authProv.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final teacherSubjectIds = (isTeacher && user?.subjectIds != null) ? user!.subjectIds! : <String>[];

    final subjects = isTeacher
        ? schoolProv.subjects.where((s) => teacherSubjectIds.contains(s.id)).toList()
        : schoolProv.subjects;
    final uniqueStudents = <String, StudentModel>{};
    for (final s in studentProv.students) {
      uniqueStudents[s.id] = s;
    }
    final studentsList = uniqueStudents.values.toList();
    final effectiveStudentId =
        studentsList.any((s) => s.id == _selectedStudentId)
            ? _selectedStudentId
            : null;

    final effectiveSubjectId =
        subjects.any((s) => s.id == _selectedSubjectId)
            ? _selectedSubjectId
            : (subjects.isNotEmpty ? subjects.first.id : null);

    if (_selectedSubjectId != effectiveSubjectId) {
      _selectedSubjectId = effectiveSubjectId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _setupTopicControllers();
          });
        }
      });
    }

    final currentSubject = subjects
        .where((s) => s.id == effectiveSubjectId)
        .firstOrNull;

    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final l10n = AppLocalizations.of(context);

    if (isTeacher && teacherSubjectIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n?.addAssessment ?? (isGu ? 'મૂલ્યાંકન ઉમેરો' : 'Add Assessment'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 56, color: Colors.amber.shade800),
                const SizedBox(height: 20),
                Text(
                  isGu ? 'કોઈ સોંપાયેલ વિષય નથી' : 'No Assigned Subjects',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isGu
                      ? 'તમારી પાસે મૂલ્યાંકન નોંધવા માટે કોઈ વિષય ફાળવેલ નથી.'
                      : 'You do not have any assigned subjects to log assessments for.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(isGu ? 'પાછા જાઓ' : 'Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (widget.subjectId != null &&
        isTeacher &&
        !teacherSubjectIds.contains(widget.subjectId)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n?.addAssessment ?? (isGu ? 'મૂલ્યાંકન ઉમેરો' : 'Add Assessment'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 56,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isGu ? 'પરવાનગી પ્રતિબંધિત (View-Only)' : 'Permission Restricted (View-Only)',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isGu
                      ? 'તમે અન્ય શિક્ષકના વિષય માટે નવું મૂલ્યાંકન અથવા ગુણ ઉમેરી શકતા નથી. તમારી પાસે ફક્ત તમારા સોંપાયેલા વિષયો માટે જ મૂલ્યાંકન ઉમેરવાની પરવાનગી છે.'
                      : 'You cannot log or enter new assessments for other subjects. You are only permitted to log assessments for your assigned subjects.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(isGu ? 'પાછા જાઓ' : 'Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.addAssessment ?? (isGu ? 'મૂલ્યાંકન ઉમેરો' : 'Add Assessment'),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveAssessment,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save Assessment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            // Student Selection
            Text(
              'Student *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: effectiveStudentId,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline_rounded),
                hintText: 'Select Student',
              ),
              items: studentsList.map((s) {
                return DropdownMenuItem<String>(
                  value: s.id,
                  child: Text(
                    '${s.name} (${s.studentId})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              validator: (val) =>
                  val == null ? 'Please select a student' : null,
              onChanged: (val) {
                setState(() {
                  _selectedStudentId = val;
                });
              },
            ),
            const SizedBox(height: 16),

            // Subject Selection & Assessment Type
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 340) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subject *',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: effectiveSubjectId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.book_outlined),
                        ),
                        items: subjects.map((sub) {
                          return DropdownMenuItem<String>(
                            value: sub.id,
                            child: Text(
                              sub.getLocalizedName(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        validator: (val) => val == null ? 'Required' : null,
                        onChanged: _onSubjectChanged,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Type',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.dividerColor),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.assignment_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Regular',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subject *',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: effectiveSubjectId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.book_outlined),
                            ),
                            items: subjects.map((sub) {
                              return DropdownMenuItem<String>(
                                value: sub.id,
                                child: Text(
                                  sub.getLocalizedName(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            validator: (val) => val == null ? 'Required' : null,
                            onChanged: _onSubjectChanged,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Type',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.dividerColor),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.assignment_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Regular',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Date Picker Field
            Text(
              'Assessment Date *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  DateFormat('dd MMMM yyyy').format(_assessmentDate),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dynamic Topic-Wise Marks Section
            Card(
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Topic Scores Allocation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Sum: ${_calculateTotalObtainedMarks().toStringAsFixed(0)} / ${_calculateTotalMaxMarks().toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Text(
                      'Enter obtained marks for each curriculum topic. Total marks will be dynamically computed.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Divider(height: 20),

                    if (currentSubject == null || currentSubject.topics.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Select a subject to display its curriculum topics.',
                        ),
                      )
                    else
                      ...currentSubject.topics.map((topic) {
                        final obtainedCtrl =
                            _topicObtainedControllers[topic.id];
                        final totalCtrl = _topicTotalControllers[topic.id];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 280) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topic.name,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Order #${topic.orderIndex}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: obtainedCtrl,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 6,
                                              ),
                                              hintText: 'Marks',
                                              labelText: 'Score',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            validator: (val) {
                                              if (val == null || val.trim().isEmpty) {
                                                return 'Req';
                                              }
                                              final numVal = double.tryParse(val.trim());
                                              if (numVal == null || numVal < 0) {
                                                return 'Inv';
                                              }
                                              final maxVal =
                                                  double.tryParse(
                                                    totalCtrl?.text.trim() ?? '10',
                                                  ) ??
                                                  10.0;
                                              if (numVal > maxVal) {
                                                return '>$maxVal';
                                              }
                                              return null;
                                            },
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6),
                                          child: Text(
                                            '/',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: totalCtrl,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 6,
                                              ),
                                              labelText: 'Total',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            validator: (val) {
                                              if (val == null || val.trim().isEmpty) {
                                                return 'Req';
                                              }
                                              final numVal = double.tryParse(val.trim());
                                              if (numVal == null || numVal <= 0) {
                                                return '>0';
                                              }
                                              return null;
                                            },
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          topic.name,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Order #${topic.orderIndex}',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Obtained Marks Field
                                  SizedBox(
                                    width: 65,
                                    child: TextFormField(
                                      controller: obtainedCtrl,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        hintText: 'Marks',
                                        labelText: 'Score',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Req';
                                        }
                                        final numVal = double.tryParse(val.trim());
                                        if (numVal == null || numVal < 0) {
                                          return 'Inv';
                                        }
                                        final maxVal =
                                            double.tryParse(
                                              totalCtrl?.text.trim() ?? '10',
                                            ) ??
                                            10.0;
                                        if (numVal > maxVal) {
                                          return '>$maxVal';
                                        }
                                        return null;
                                      },
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '/',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Max Marks Field
                                  SizedBox(
                                    width: 65,
                                    child: TextFormField(
                                      controller: totalCtrl,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        labelText: 'Total',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Req';
                                        }
                                        final numVal = double.tryParse(val.trim());
                                        if (numVal == null || numVal <= 0) {
                                          return '>0';
                                        }
                                        return null;
                                      },
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Teacher Notes Field
            Text(
              'Teacher Observations (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add qualitative notes on handwriting, problem solving speed, or specific learning gaps observed...',
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
