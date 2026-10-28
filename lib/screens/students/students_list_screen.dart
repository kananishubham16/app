import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/screens/students/student_detail_screen.dart';
import 'package:learning_setu/widgets/add_student_dialog.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedClass = 'ALL';

  final List<String> _classFilters = const [
    'ALL',
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      final schoolId = user?.schoolId ?? 'school_1';
      context.read<StudentProvider>().loadStudentsBySchool(schoolId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final studentProv = context.watch<StudentProvider>();
    final allStudents = studentProv.students;

    // Apply class filter and search filter
    final query = _searchController.text.trim().toLowerCase();
    final filtered = allStudents.where((s) {
      final matchesClass = _selectedClass == 'ALL' ||
          s.className.toLowerCase() == _selectedClass.toLowerCase() ||
          s.classId.toLowerCase() == _selectedClass.toLowerCase().replaceAll(' ', '_');

      final matchesQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          s.studentId.toLowerCase().contains(query) ||
          (s.parentName?.toLowerCase().contains(query) ?? false) ||
          (s.parentPhone?.contains(query) ?? false);

      return matchesClass && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isGu ? 'વિદ્યાર્થીઓ' : 'Students Directory'),
        actions: [
          IconButton(
            tooltip: isGu ? 'નવો વિદ્યાર્થી ઉમેરો' : 'Add Student',
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _openAddStudentDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(isGu ? 'વિદ્યાર્થી ઉમેરો' : 'Add Student'),
        onPressed: () => _openAddStudentDialog(context),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: Column(
              children: [
                // Search box
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isGu
                        ? 'વિદ્યાર્થીનું નામ અથવા ID શોધો...'
                        : 'Search by student name or ID...',
                    prefixIcon: const Icon(Icons.search, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),

                // Class Filter Horizontal Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _classFilters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = _classFilters[index];
                      final isSelected = _selectedClass == item;
                      final label = item == 'ALL'
                          ? (isGu ? 'બધા વર્ગો' : 'All Classes')
                          : item;

                      return ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF0D9488),
                        backgroundColor: const Color(0xFFF1F5F9),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedClass = item);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Count Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            color: const Color(0xFFF8FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isGu
                      ? 'કુલ વિદ્યાર્થીઓ: ${filtered.length}'
                      : 'Showing ${filtered.length} Students',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (_selectedClass != 'ALL')
                  Text(
                    _selectedClass,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D9488),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Students List
          Expanded(
            child: studentProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 54,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isGu
                                  ? 'કોઈ વિદ્યાર્થી મળ્યા નથી'
                                  : 'No students found',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isGu
                                  ? 'કૃપા કરીને શોધ શબ્દ અથવા ફિલ્ટર બદલો'
                                  : 'Try adjusting your search or class filter',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final student = filtered[index];
                          return _buildStudentCard(context, student, isGu);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentModel student, bool isGu) {
    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF0D9488),
      const Color(0xFF7C3AED),
      const Color(0xFFD97706),
      const Color(0xFF059669),
    ];
    final color = colors[student.name.hashCode.abs() % colors.length];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.read<StudentProvider>().selectStudent(student);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailScreen(studentId: student.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.12),
                child: Text(
                  student.name.isNotEmpty ? student.name.substring(0, 1).toUpperCase() : 'S',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${student.className} - ${student.section}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${student.studentId} • ${student.schoolName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (student.parentName != null || student.parentPhone != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            student.parentName ?? 'Parent',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                          ),
                          if (student.parentPhone != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.phone_outlined, size: 13, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 3),
                            Text(
                              student.parentPhone!,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF0D9488), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddStudentDialog(BuildContext context) async {
    final user = context.read<AuthProvider>().currentUser;
    await AddStudentDialog.show(
      context,
      initialClassId: _selectedClass,
      schoolId: user?.schoolId,
    );
  }
}
