import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';

/// User profile and demographic details screen with editable demo profile fields,
/// role badges, linked student profile card, and quick navigation to system settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Color _getRoleColor(UserRole? role) {
    switch (role) {
      case UserRole.teacher:
        return const Color(0xFF1565C0);
      case UserRole.principal:
        return const Color(0xFF6A1B9A);
      case UserRole.brc:
        return const Color(0xFF00897B);
      case UserRole.parent:
        return const Color(0xFFE65100);
      case null:
        return AppColors.primary;
    }
  }

  void _saveDemoProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isEditing = false;
      });
      final isGu = Localizations.localeOf(context).languageCode == 'gu';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGu
                ? 'ડેમો પ્રોફાઇલ સફળતાપૂર્વક અપડેટ થઈ! (સ્થાનિક સત્ર)'
                : 'Demo profile updated successfully! (Local session only)',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProv = context.watch<AuthProvider>();
    final studentProv = context.watch<StudentProvider>();
    final l10n = AppLocalizations.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    final user = authProv.currentUser;
    final selectedStudent = studentProv.selectedStudent;

    final roleColor = _getRoleColor(user?.role);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.profile ?? (isGu ? 'મારી પ્રોફાઇલ' : 'My Profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n?.settings ?? (isGu ? 'સેટિંગ્સ' : 'Settings'),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.settings);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Demo notice banner
            _buildDemoNotice(),
            const SizedBox(height: 16),

            // User Profile Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar & Role Badge
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: roleColor.withOpacity(0.15),
                        child: Text(
                          user?.avatarInitials ?? 'LS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: roleColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          user?.roleDisplayName ?? 'Primary School Teacher',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // User Editable/Display Fields
                      if (!_isEditing) ...[
                        Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                              : (user?.name ?? 'Demo User'),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _emailController.text.isNotEmpty
                              ? _emailController.text
                              : (user?.email ?? 'user@demo.com'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.phone ?? '+91 98765 43210',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Divider(height: 24),

                        // Institutional details
                        _buildDetailRow(
                          Icons.account_balance_outlined,
                          'Institution / Block',
                          user?.schoolId != null
                              ? 'GPS Sector 7 Primary School'
                              : (user?.blockId != null
                                    ? 'Gandhinagar Block'
                                    : 'State Education Department'),
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          Icons.location_on_outlined,
                          'District',
                          'Gandhinagar, Gujarat',
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: Text(
                              isGu
                                  ? 'ડેમો વિગતો સંપાદિત કરો'
                                  : 'Edit Demo Details',
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 44),
                            ),
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                          ),
                        ),
                      ] else ...[
                        // Edit Mode
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: isGu ? 'પૂરું નામ' : 'Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? (isGu ? 'જરૂરી છે' : 'Required')
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: isGu ? 'ઈમેલ સરનામું' : 'Email Address',
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? (isGu ? 'જરૂરી છે' : 'Required')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    if (user != null) {
                                      _nameController.text = user.name;
                                      _emailController.text = user.email;
                                    }
                                  });
                                },
                                child: Text(l10n?.cancel ?? (isGu ? 'રદ કરો' : 'Cancel')),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveDemoProfile,
                                child: Text(isGu ? 'ફેરફારો સાચવો' : 'Save Changes'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Linked Student Profile Card (if student selected or parent role)
            if (selectedStudent != null) ...[
              _buildStudentProfileCard(selectedStudent),
              const SizedBox(height: 20),
            ],

            // Quick App Actions
            Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.settings_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'Application Settings',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Language preferences, app version, demo reset',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.settings);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.logout_rounded,
                      color: Colors.red.shade700,
                    ),
                    title: Text(
                      'Logout / Switch Role',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    subtitle: const Text(
                      'Return to role selection welcome screen',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _confirmLogout(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.amber.shade900,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Profile editing is for demo purposes only. Real deployments bind to Gujarat State Education Department directory.',
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentProfileCard(StudentModel student) {
    final theme = Theme.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

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
                  Icons.badge_outlined,
                  color: AppColors.secondary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isGu ? 'પસંદ કરેલ વિદ્યાર્થી પ્રોફાઇલ' : 'Selected Student Profile',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow(Icons.person_rounded, 'Student Name', student.name),
            const SizedBox(height: 10),
            _buildDetailRow(
              Icons.pin_rounded,
              'Enrollment Number',
              student.studentId,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              Icons.school_rounded,
              'Class & Section',
              '${student.className} (Section ${student.section})',
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              Icons.account_balance_rounded,
              'School',
              student.schoolName,
            ),
            if (student.parentName != null) ...[
              const SizedBox(height: 10),
              _buildDetailRow(
                Icons.family_restroom_rounded,
                'Parent Name',
                student.parentName!,
              ),
            ],
            if (student.parentPhone != null) ...[
              const SizedBox(height: 10),
              _buildDetailRow(
                Icons.phone_rounded,
                'Parent Contact',
                student.parentPhone!,
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(
                  isGu ? 'વિદ્યાર્થી એનાલિટિક્સ ખોલો' : 'Open Student Analytics',
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 42),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.studentDetail,
                    arguments: student.id,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final l10n = AppLocalizations.of(context);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isGu ? 'લોગઆઉટ / ડેમો ભૂમિકા બદલવી છે?' : 'Logout / Switch Demo Role?',
        ),
        content: Text(
          isGu
              ? 'આ વર્તમાન સત્ર સાફ કરશે અને તમને ભૂમિકા પસંદગી સ્ક્રીન પર પાછા લઈ જશે.'
              : 'This will clear the current session and take you back to the role selection screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? (isGu ? 'રદ કરો' : 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.logout ?? (isGu ? 'લોગઆઉટ' : 'Logout')),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.welcome,
        (route) => false,
      );
    }
  }
}
