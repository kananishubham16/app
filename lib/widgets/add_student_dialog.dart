import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/providers/student_provider.dart';

class AddStudentDialog extends StatefulWidget {
  final String? initialClassId;
  final String? schoolId;
  final String? schoolName;

  const AddStudentDialog({
    super.key,
    this.initialClassId,
    this.schoolId,
    this.schoolName,
  });

  static Future<StudentModel?> show(
    BuildContext context, {
    String? initialClassId,
    String? schoolId,
    String? schoolName,
  }) {
    return showDialog<StudentModel>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddStudentDialog(
        initialClassId: initialClassId,
        schoolId: schoolId,
        schoolName: schoolName,
      ),
    );
  }

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;

  late String _selectedClass;
  late String _selectedSection;
  bool _isSubmitting = false;

  final List<String> _classes = const [
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
  ];

  final List<String> _sections = const ['A', 'B', 'C'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _studentIdController = TextEditingController(
      text: 'GPS-2026-${(DateTime.now().millisecondsSinceEpoch % 900) + 100}',
    );
    _parentNameController = TextEditingController();
    _parentPhoneController = TextEditingController();

    // Determine initial class selection
    String defaultClass = 'Class 4';
    if (widget.initialClassId != null && widget.initialClassId != 'ALL') {
      final matched = _classes.firstWhere(
        (c) =>
            c.toLowerCase().replaceAll(' ', '_') ==
            widget.initialClassId!.toLowerCase().replaceAll(' ', '_'),
        orElse: () => 'Class 4',
      );
      defaultClass = matched;
    }
    _selectedClass = defaultClass;
    _selectedSection = 'A';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final studentId = _studentIdController.text.trim();
      final parentName = _parentNameController.text.trim();
      final parentPhone = _parentPhoneController.text.trim();
      final classId = _selectedClass.toLowerCase().replaceAll(' ', '_');
      final schoolId = widget.schoolId ?? 'school_1';
      final schoolName = widget.schoolName ?? 'GPS Primary School';

      final newStudent = StudentModel(
        id: 'student_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        studentId: studentId,
        classId: classId,
        className: _selectedClass,
        section: _selectedSection,
        schoolId: schoolId,
        schoolName: schoolName,
        parentName: parentName.isNotEmpty ? parentName : null,
        parentPhone: parentPhone.isNotEmpty ? parentPhone : null,
      );

      final created = await context.read<StudentProvider>().addStudent(newStudent);

      if (mounted) {
        Navigator.of(context).pop(created);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'gu'
                  ? 'વિદ્યાર્થી $name સફળતાપૂર્વક ઉમેરાયા!'
                  : 'Student $name added successfully!',
            ),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add student: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Color(0xFF0D9488),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGu ? 'નવો વિદ્યાર્થી ઉમેરો' : 'Add New Student',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isGu
                                ? 'પ્રાથમિક શાળા રજિસ્ટરમાં નવો પ્રવેશ'
                                : 'Enroll into Primary School Register',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 18),

                // Student Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: isGu ? 'વિદ્યાર્થીનું નામ' : 'Student Full Name *',
                    hintText: isGu ? 'દા.ત. પ્રિયા શર્મા' : 'e.g. Priya Sharma',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return isGu ? 'નામ દાખલ કરવું જરૂરી છે' : 'Please enter student name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Student Enrollment ID
                TextFormField(
                  controller: _studentIdController,
                  decoration: InputDecoration(
                    labelText: isGu ? 'નોંધણી નંબર / આઈડી' : 'Enrollment / Student ID *',
                    hintText: 'e.g. GPS-2026-105',
                    prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return isGu ? 'આઈડી દાખલ કરવું જરૂરી છે' : 'Please enter student ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Class & Section Row
                Row(
                  children: [
                    // Class Dropdown
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _selectedClass,
                        decoration: InputDecoration(
                          labelText: isGu ? 'ધોરણ' : 'Class *',
                          prefixIcon: const Icon(Icons.school_outlined, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                        items: _classes.map((cls) {
                          return DropdownMenuItem(
                            value: cls,
                            child: Text(cls, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedClass = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Section Dropdown
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedSection,
                        decoration: InputDecoration(
                          labelText: isGu ? 'વિભાગ' : 'Section',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                        items: _sections.map((sec) {
                          return DropdownMenuItem(
                            value: sec,
                            child: Text('Sec $sec', style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSection = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Parent / Guardian Name
                TextFormField(
                  controller: _parentNameController,
                  decoration: InputDecoration(
                    labelText: isGu ? 'વાલીનું નામ' : 'Parent / Guardian Name',
                    hintText: isGu ? 'દા.ત. રમેશ શર્મા' : 'e.g. Ramesh Sharma',
                    prefixIcon: const Icon(Icons.family_restroom_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Parent Phone Number
                TextFormField(
                  controller: _parentPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: isGu ? 'વાલી મોબાઈલ નંબર' : 'Parent Mobile Number',
                    hintText: 'e.g. 9876543210',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 22),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        isGu ? 'રદ કરો' : 'Cancel',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: Text(
                        isGu ? 'ઉમેરો' : 'Add Student',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
