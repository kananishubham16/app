import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/locale_provider.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

/// LoginScreen provides role-specific authentication for Learning Setu.
/// Includes standard credentials validation, quick demo login, and demo hint information.
class LoginScreen extends StatefulWidget {
  final UserRole role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedTeacherId = 'user_teacher';

  static const List<Map<String, String>> _teacherProfiles = [
    {
      'id': 'user_teacher',
      'name': 'Anita Sharma',
      'email': 'teacher@demo.com',
      'subjects_en': 'Mathematics & English',
      'subjects_gu': 'ગણિત અને અંગ્રેજી',
    },
    {
      'id': 'user_teacher_guj',
      'name': 'Bhavna Joshi',
      'email': 'teacher2@demo.com',
      'subjects_en': 'Gujarati Language',
      'subjects_gu': 'ગુજરાતી ભાષા',
    },
    {
      'id': 'user_teacher_evs',
      'name': 'Ramesh Solanki',
      'email': 'teacher3@demo.com',
      'subjects_en': 'Environmental Studies (EVS)',
      'subjects_gu': 'પર્યાવરણ અધ્યયન (EVS)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _identifierController.text = _getDefaultDemoEmail(widget.role);
    _passwordController.text = 'demo1234';
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getDefaultDemoEmail(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return 'teacher@demo.com';
      case UserRole.principal:
        return 'principal@demo.com';
      case UserRole.brc:
        return 'brc@demo.com';
      case UserRole.parent:
        return 'parent@demo.com';
    }
  }

  String _getRoleDisplayName(BuildContext context, UserRole role) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      switch (role) {
        case UserRole.teacher:
          return l10n.teacher;
        case UserRole.principal:
          return l10n.principal;
        case UserRole.brc:
          return l10n.brc;
        case UserRole.parent:
          return l10n.parent;
      }
    }
    switch (role) {
      case UserRole.teacher:
        return 'Primary School Teacher';
      case UserRole.principal:
        return 'School Principal';
      case UserRole.brc:
        return 'Block Resource Coordinator';
      case UserRole.parent:
        return 'Parent';
    }
  }

  String _getRoleSubtitle(BuildContext context, UserRole role) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    if (isGu) {
      switch (role) {
        case UserRole.teacher:
          return 'વર્ગખંડના નિદાન, વિદ્યાર્થી પ્રોફાઇલ અને ઉપચારાત્મક કાર્ય સોંપણી';
        case UserRole.principal:
          return 'શાળા-વ્યાપી બેન્ચમાર્ક્સ, ગ્રેડ વિશ્લેષણ અને હસ્તક્ષેપ પ્રગતિ';
        case UserRole.brc:
          return 'બ્લોક અને ક્લસ્ટર સ્તરની કામગીરીની સરખામણી અને વહીવટી દેખરેખ';
        case UserRole.parent:
          return 'વ્યક્તિગત વિદ્યાર્થી પ્રગતિ, અધ્યયન સીમાચિહ્નો અને માર્ગદર્શિત પ્રવૃત્તિઓ';
      }
    }
    switch (role) {
      case UserRole.teacher:
        return 'Classroom gap diagnostics, student profiles & remedial assignment';
      case UserRole.principal:
        return 'School-wide benchmarks, grade analytics & intervention progress';
      case UserRole.brc:
        return 'Block & cluster-level performance comparison and administrative oversight';
      case UserRole.parent:
        return 'Personalized student progress, learning milestones & guided home activities';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return Icons.school_rounded;
      case UserRole.principal:
        return Icons.admin_panel_settings_rounded;
      case UserRole.brc:
        return Icons.hub_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
    }
  }

  Color _getRoleThemeColor(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return const Color(0xFF1565C0);
      case UserRole.principal:
        return const Color(0xFF00796B);
      case UserRole.brc:
        return const Color(0xFF6A1B9A);
      case UserRole.parent:
        return const Color(0xFFD97706);
    }
  }

  String _getDashboardRoute(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return '/teacher-dashboard';
      case UserRole.principal:
        return '/principal-dashboard';
      case UserRole.brc:
        return '/brc-dashboard';
      case UserRole.parent:
        return '/parent-dashboard';
    }
  }

  String? _validateIdentifier(String? value) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    if (value == null || value.trim().isEmpty) {
      return isGu
          ? 'કૃપા કરીને તમારો ઈમેલ અથવા મોબાઈલ નંબર દાખલ કરો'
          : 'Please enter your email or mobile number';
    }
    final trimmed = value.trim();
    final isEmail = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(trimmed);
    final isPhone = RegExp(r'^[0-9]{10}$').hasMatch(trimmed);

    if (!isEmail && !isPhone) {
      return isGu
          ? 'માન્ય ઈમેલ અથવા ૧૦ અંકનો મોબાઈલ નંબર દાખલ કરો'
          : 'Enter a valid email or 10-digit mobile number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    if (value == null || value.isEmpty) {
      return isGu
          ? 'કૃપા કરીને તમારો પાસવર્ડ દાખલ કરો'
          : 'Please enter your password';
    }
    if (value.length < 6) {
      return isGu
          ? 'પાસવર્ડ ઓછામાં ઓછો ૬ અક્ષરનો હોવો જોઈએ'
          : 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleStandardLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    final success = await authProvider.login(identifier, password);
    if (!mounted) return;

    if (success) {
      _navigateToDashboard();
    } else {
      _showErrorSnackBar(authProvider.error ?? 'Authentication failed');
    }
  }

  Future<void> _handleDemoLogin() async {
    FocusScope.of(context).unfocus();
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.demoLogin(
      widget.role,
      userId: widget.role == UserRole.teacher ? _selectedTeacherId : null,
    );
    if (!mounted) return;

    if (success) {
      _navigateToDashboard();
    } else {
      _showErrorSnackBar(authProvider.error ?? 'Demo access failed');
    }
  }

  void _navigateToDashboard() {
    final route = _getDashboardRoute(widget.role);
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getRoleThemeColor(widget.role);
    final roleName = _getRoleDisplayName(context, widget.role);
    final roleIcon = _getRoleIcon(widget.role);
    final roleSubtitle = _getRoleSubtitle(context, widget.role);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
          tooltip: 'Return to Welcome Screen',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '$roleName ${l10n?.login ?? "Login"}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          Consumer<LocaleProvider>(
            builder: (context, localeProv, _) {
              final isGu = localeProv.locale.languageCode == 'gu';
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: TextButton.icon(
                  onPressed: () => localeProv.toggleLanguage(),
                  icon: const Icon(Icons.translate_rounded, size: 16),
                  label: Text(
                    isGu ? 'ગુજરાતી' : 'English',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Role Icon & Header Card
                  _buildHeaderCard(
                    themeColor,
                    roleIcon,
                    roleName,
                    roleSubtitle,
                    l10n,
                  ),

                  const SizedBox(height: 24),

                  // Authentication Form Card
                  _buildFormCard(themeColor, l10n),

                  const SizedBox(height: 20),

                  // Demo Credentials Info Box
                  _buildDemoCredentialsHint(themeColor, l10n),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header widget showing role badge, role icon, and descriptive text
  Widget _buildHeaderCard(
    Color themeColor,
    IconData roleIcon,
    String roleName,
    String roleSubtitle,
    AppLocalizations? l10n,
  ) {
    return Column(
      children: [
        // Role Icon in circular container
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: themeColor.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: themeColor.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(roleIcon, size: 36, color: themeColor),
        ),

        const SizedBox(height: 14),

        // Role Title
        Text(
          '$roleName ${l10n?.login ?? "Login"}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 6),

        // Role Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            roleSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Form card containing input fields, validation, and action buttons
  Widget _buildFormCard(Color themeColor, AppLocalizations? l10n) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoading = authProvider.isLoading;

        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Teacher Demo Profile Selector
                  if (widget.role == UserRole.teacher) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 16,
                          color: themeColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isGu
                              ? 'શિક્ષક પ્રોફાઇલ પસંદ કરો (વિષય અનુસાર):'
                              : 'Select Teacher Profile (By Subject):',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._teacherProfiles.map((tp) {
                      final isSelected = _selectedTeacherId == tp['id'];
                      final subjects =
                          isGu ? tp['subjects_gu']! : tp['subjects_en']!;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _selectedTeacherId = tp['id']!;
                                    _identifierController.text = tp['email']!;
                                    _passwordController.text = 'demo1234';
                                  });
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? themeColor.withOpacity(0.08)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? themeColor
                                    : const Color(0xFFCBD5E1),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: isSelected
                                      ? themeColor
                                      : const Color(0xFFE2E8F0),
                                  child: Text(
                                    tp['name']!.substring(0, 1),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF475569),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tp['name']!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isSelected
                                              ? themeColor
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        subjects,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: isSelected
                                              ? themeColor.withOpacity(0.9)
                                              : const Color(0xFF64748B),
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: themeColor,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  // Identifier field (Email or Mobile)
                  Text(
                    l10n?.email ?? (isGu ? 'ઈમેલ / મોબાઈલ નંબર' : 'Email or Mobile Number'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: isGu
                          ? 'દા.ત. teacher@demo.com અથવા 9876543210'
                          : 'e.g. teacher@demo.com or 9876543210',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.alternate_email_rounded,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: themeColor, width: 2),
                      ),
                    ),
                    validator: _validateIdentifier,
                  ),

                  const SizedBox(height: 18),

                  // Password field
                  Text(
                    l10n?.password ?? (isGu ? 'પાસવર્ડ' : 'Password'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleStandardLogin(),
                    decoration: InputDecoration(
                      hintText: isGu
                          ? 'તમારો પાસવર્ડ દાખલ કરો (ઓછામાં ઓછા ૬ અક્ષર)'
                          : 'Enter your password (min 6 chars)',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: const Color(0xFF64748B),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: themeColor, width: 2),
                      ),
                    ),
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 24),

                  // Standard Login Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleStandardLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.login_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  l10n?.login ?? (isGu ? 'લોગિન' : 'Login'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Divider OR
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          isGu ? 'અથવા' : 'OR',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 'Try Demo' Button (Outlined style)
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _handleDemoLogin,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: themeColor,
                        side: BorderSide(color: themeColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_rounded, size: 20, color: themeColor),
                          const SizedBox(width: 8),
                          Text(
                            isGu
                                ? 'ડેમો અજમાવો (૧-ક્લિક પ્રવેશ)'
                                : (l10n?.tryDemo ?? 'Try Demo (1-Click Access)'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: themeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Hint Card explaining demo credentials and quick reset
  Widget _buildDemoCredentialsHint(Color themeColor, AppLocalizations? l10n) {
    final demoEmail = _getDefaultDemoEmail(widget.role);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: themeColor,
              ),
              const SizedBox(width: 8),
              Text(
                isGu ? 'ડેમો ઓળખપત્રો' : 'Demo Credentials',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.role == UserRole.teacher) ...[
            Text(
              isGu
                  ? 'ઉપલબ્ધ શિક્ષક ડેમો એકાઉન્ટ્સ:'
                  : 'Available Teacher Demo Accounts:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            ..._teacherProfiles.map((tp) {
              final subjects =
                  isGu ? tp['subjects_gu']! : tp['subjects_en']!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(
                            color: themeColor, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF334155),
                          ),
                          children: [
                            TextSpan(
                              text: '${tp['name']}: ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '${tp['email']} ',
                              style: TextStyle(
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: '($subjects)',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  isGu ? 'પાસવર્ડ (તમામ ખાતાઓ): ' : 'Password (all accounts): ',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SelectableText(
                  'demo1234',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Text(
                  isGu ? 'ઈમેલ: ' : 'Email: ',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                SelectableText(
                  demoEmail,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  isGu ? 'પાસવર્ડ: ' : 'Password: ',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SelectableText(
                  'demo1234',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            l10n?.demoNote ??
                (isGu
                    ? 'ડેમો મોડ — પ્રમાણીકરણ સિમ્યુલેટેડ છે'
                    : 'Demo Mode — Authentication is simulated'),
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
