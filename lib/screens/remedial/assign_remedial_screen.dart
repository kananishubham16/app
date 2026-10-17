import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/remedial_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';

/// Form screen enabling educators to assign targeted remedial interventions,
/// select preset pedagogical activities or create custom tasks, set due dates,
/// attach home guidance for parents, and optionally mandate an automatic quiz verification.
class AssignRemedialScreen extends StatefulWidget {
  final String? studentId;
  final String? subjectId;
  final String? topicId;

  const AssignRemedialScreen({
    super.key,
    this.studentId,
    this.subjectId,
    this.topicId,
  });

  @override
  State<AssignRemedialScreen> createState() => _AssignRemedialScreenState();
}

class _AssignRemedialScreenState extends State<AssignRemedialScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedStudentId;
  String? _selectedSubjectId;
  String? _selectedTopicId;
  String? _selectedPresetActivity;
  bool _isCustomActivity = false;

  final TextEditingController _customActivityController =
      TextEditingController();
  final TextEditingController _teacherNoteController = TextEditingController();
  final TextEditingController _parentInstructionController =
      TextEditingController();

  bool _includeQuiz = true;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;
  bool _initialized = false;

  static const List<String> _exampleActivities = [
    'Practise subtraction using objects',
    'Read a short paragraph aloud',
    'Match words with pictures',
    'Complete multiplication flashcards',
    'Custom activity...',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.studentId;
    _selectedSubjectId = widget.subjectId;
    _selectedTopicId = widget.topicId;
    _selectedPresetActivity = _exampleActivities.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final studentProv = context.read<StudentProvider>();
      final schoolProv = context.read<SchoolProvider>();

      _selectedStudentId ??= studentProv.selectedStudent?.id;
      if (_selectedStudentId == null && studentProv.students.isNotEmpty) {
        _selectedStudentId = studentProv.students.first.id;
      }

      if (_selectedSubjectId == null && schoolProv.subjects.isNotEmpty) {
        _selectedSubjectId = schoolProv.subjects.first.id;
      }

      _syncTopicSelection();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _customActivityController.dispose();
    _teacherNoteController.dispose();
    _parentInstructionController.dispose();
    super.dispose();
  }

  void _syncTopicSelection() {
    final schoolProv = context.read<SchoolProvider>();
    final subject = schoolProv.subjects
        .where((s) => s.id == _selectedSubjectId)
        .firstOrNull;

    if (subject != null && subject.topics.isNotEmpty) {
      if (_selectedTopicId == null ||
          !subject.topics.any((t) => t.id == _selectedTopicId)) {
        _selectedTopicId = subject.topics.first.id;
      }
    } else {
      _selectedTopicId = null;
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    if (!_formKey.currentState!.validate()) return;

    final authProv = context.read<AuthProvider>();
    final user = authProv.currentUser;
    if (user?.role == UserRole.teacher &&
        user?.subjectIds != null &&
        user!.subjectIds!.isNotEmpty &&
        !user.subjectIds!.contains(_selectedSubjectId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGu
                ? 'તમને ફક્ત તમારા સોંપાયેલા વિષયો માટે જ ઉપચારાત્મક કાર્ય સોંપવાની પરવાનગી છે.'
                : 'You are only permitted to assign remedial actions for your assigned subjects.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
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

    if (_selectedSubjectId == null || _selectedTopicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGu
                ? 'કૃપા કરીને વિષય અને વિષયાંગ પસંદ કરો'
                : 'Please select a subject and topic',
          ),
        ),
      );
      return;
    }

    final schoolProv = context.read<SchoolProvider>();
    final subject = schoolProv.subjects
        .where((s) => s.id == _selectedSubjectId)
        .firstOrNull;
    final topic = subject?.topics
        .where((t) => t.id == _selectedTopicId)
        .firstOrNull;

    final String activityText = _isCustomActivity
        ? _customActivityController.text.trim()
        : (_selectedPresetActivity ?? 'Practice fundamental exercises');

    if (activityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGu
                ? 'કૃપા કરીને પ્રવૃત્તિનું વર્ણન સ્પષ્ટ કરો'
                : 'Please specify the activity description',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final action = RemedialAction(
      id: const Uuid().v4(),
      studentId: _selectedStudentId!,
      subjectId: _selectedSubjectId!,
      topicId: _selectedTopicId!,
      topicName: topic?.name ?? 'Topic Review',
      activityDescription: activityText,
      hasQuiz: _includeQuiz,
      assignedDate: DateTime.now(),
      dueDate: _dueDate,
      status: RemedialStatus.assigned,
      teacherNote: _teacherNoteController.text.trim().isEmpty
          ? null
          : _teacherNoteController.text.trim(),
      parentInstruction: _parentInstructionController.text.trim().isEmpty
          ? null
          : _parentInstructionController.text.trim(),
    );

    final remedialProv = context.read<RemedialProvider>();
    final success = await remedialProv.addRemedial(action);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Remedial action assigned for ${topic?.name ?? "student"}!',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              remedialProv.error ?? 'Failed to assign remedial action',
            ),
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

    final subjects = (isTeacher && teacherSubjectIds.isNotEmpty)
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

    final currentSubject = subjects
        .where((s) => s.id == effectiveSubjectId)
        .firstOrNull;
    final topics = currentSubject?.topics ?? <TopicModel>[];

    final effectiveTopicId =
        topics.any((t) => t.id == _selectedTopicId)
            ? _selectedTopicId
            : (topics.isNotEmpty ? topics.first.id : null);

    final effectivePresetActivity =
        _exampleActivities.contains(_selectedPresetActivity)
            ? _selectedPresetActivity
            : _exampleActivities.first;

    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final l10n = AppLocalizations.of(context);

    if (!isTeacher) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n?.assignRemedial ?? (isGu ? 'ઉપચારાત્મક કાર્ય સોંપો' : 'Assign Remedial Action'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gpp_bad_rounded, size: 64, color: Colors.orange.shade700),
                const SizedBox(height: 16),
                Text(
                  isGu ? 'અનધિકૃત ઍક્સેસ' : 'Unauthorized Access',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isGu
                      ? 'માત્ર શિક્ષકો જ વિદ્યાર્થીઓ માટે ઉપચારાત્મક કાર્યો સોંપી શકે છે.'
                      : 'Only teachers have permission to assign remedial actions to students.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isGu ? 'પાછા જાઓ' : 'Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (widget.subjectId != null &&
        isTeacher &&
        teacherSubjectIds.isNotEmpty &&
        !teacherSubjectIds.contains(widget.subjectId)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n?.assignRemedial ?? (isGu ? 'ઉપચારાત્મક કાર્ય સોંપો' : 'Assign Remedial Action'),
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
                      ? 'તમે અન્ય શિક્ષકના વિષય માટે ઉપચારાત્મક કાર્ય સોંપી શકતા નથી. તમારી પાસે ફક્ત જોવાની પરવાનગી છે.'
                      : 'You cannot assign remedial actions for other subjects. You have view-only access.',
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
          l10n?.assignRemedial ??
              (isGu ? 'ઉપચારાત્મક કાર્ય સોંપો' : 'Assign Remedial Action'),
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
              blurRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Assign Action',
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
            // Student Selector
            Text(
              'Select Student *',
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
              validator: (val) => val == null ? 'Required' : null,
              onChanged: (val) {
                setState(() {
                  _selectedStudentId = val;
                });
              },
            ),
            const SizedBox(height: 16),

            // Subject Cascading Dropdown
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
              onChanged: (newSubjectId) {
                setState(() {
                  _selectedSubjectId = newSubjectId;
                  _syncTopicSelection();
                });
              },
            ),
            const SizedBox(height: 16),

            // Topic Cascading Dropdown
            Text(
              'Topic *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: effectiveTopicId,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.topic_outlined),
                hintText: 'Select Topic',
              ),
              items: topics.map((top) {
                return DropdownMenuItem<String>(
                  value: top.id,
                  child: Text(top.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              validator: (val) => val == null ? 'Required' : null,
              onChanged: (newTopicId) {
                setState(() {
                  _selectedTopicId = newTopicId;
                });
              },
            ),
            const SizedBox(height: 16),

            // Activity Description Dropdown & Custom Field
            Text(
              'Remedial Activity Description *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: effectivePresetActivity,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.psychology_outlined),
              ),
              items: _exampleActivities.map((act) {
                return DropdownMenuItem<String>(
                  value: act,
                  child: Text(act, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedPresetActivity = val;
                  _isCustomActivity = val == 'Custom activity...';
                });
              },
            ),

            if (_isCustomActivity) ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _customActivityController,
                decoration: const InputDecoration(
                  hintText:
                      'Enter specific classroom or home activity details...',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (val) {
                  if (_isCustomActivity &&
                      (val == null || val.trim().isEmpty)) {
                    return 'Please describe the custom activity';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),

            // Include Quiz Toggle Card
            Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.dividerColor),
              ),
              child: SwitchListTile(
                value: _includeQuiz,
                activeColor: Colors.purple.shade700,
                title: const Text(
                  'Link Verification Quiz',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text(
                  'Student or parent will take an auto-scored quiz to verify understanding.',
                  style: TextStyle(fontSize: 12),
                ),
                onChanged: (val) {
                  setState(() {
                    _includeQuiz = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Due Date Picker Field
            Text(
              'Due Date *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.event_available_rounded),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  DateFormat('dd MMMM yyyy').format(_dueDate),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Parent Instruction Field
            Text(
              'Parent Instruction (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Guidelines visible to parents on their portal to assist child at home.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _parentInstructionController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g. Please spend 10 minutes reading aloud before bedtime...',
              ),
            ),
            const SizedBox(height: 16),

            // Teacher Internal Note Field
            Text(
              'Teacher Private Note (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _teacherNoteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Internal note for progress tracking and peer discussions...',
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
