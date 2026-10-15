import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/locale_provider.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/screens/auth/login_screen.dart';

/// WelcomeScreen provides the entry point for Learning Setu.
/// Features role selection cards, language toggle, and responsive layout.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEBF3FD), Color(0xFFF7FAFD), Color(0xFFFFFFFF)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with branding & language toggle
              _buildTopBar(context),

              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width > 600 ? 32.0 : 20.0,
                    vertical: 12.0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          // Hero branding section
                          _buildHeroSection(context, theme, colorScheme),

                          const SizedBox(height: 28),

                          // Section Title
                          _buildSectionHeader(context, theme),

                          const SizedBox(height: 18),

                          // Responsive Role Selection Grid
                          _buildRoleGrid(context),

                          const SizedBox(height: 32),

                          // Demo Mode banner
                          _buildDemoBanner(context, theme, colorScheme),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// App top bar with Hackathon badge and language toggle
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          // Initiative Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF1565C0).withOpacity(0.2),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00897B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SFIC 2026 • PS000060',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Language Toggle Button (EN / ગુજરાતી)
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, _) {
              final isGujarati = localeProvider.locale.languageCode == 'gu';
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => localeProvider.toggleLanguage(),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF1565C0).withOpacity(0.4),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.translate_rounded,
                          size: 17,
                          color: Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isGujarati ? 'ગુજરાતી' : 'English',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isGujarati ? 'EN' : 'ગુ',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Logo, Title, Tagline and App Overview
  Widget _buildHeroSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return Column(
      children: [
        // App Logo Icon with multi-layer shadow and gradient
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.32),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Icon(
                Icons.auto_stories_rounded,
                size: 44,
                color: Colors.white,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // App Name
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isGu ? 'લર્નિંગ ' : 'Learning ',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isGu ? 'સેતુ' : 'Setu',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Tagline
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            l10n?.tagline ?? 'Smart Tracking & Remedial Action System for Student Learning Gaps',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F766E),
              height: 1.35,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Brief Description
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Text(
            l10n?.appSubtitle ?? 'An educational bridge connecting classroom diagnostics with targeted micro-interventions, adaptive quizzes, and analytics across primary schools.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Section Header
  Widget _buildSectionHeader(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Container(width: 20, height: 1.5, color: const Color(0xFFCBD5E1)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n?.selectRole ?? 'Select your role to explore the portal',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 20, height: 1.5, color: const Color(0xFFCBD5E1)),
      ],
    );
  }

  /// Responsive Grid of 4 Role Selection Cards
  Widget _buildRoleGrid(BuildContext context) {
    final roles = [
      const _RoleCardData(
        role: UserRole.teacher,
        title: 'Primary School Teacher',
        gujaratiTitle: 'પ્રાથમિક શાળા શિક્ષક',
        subtitle: 'Record assessments, detect student learning gaps & assign personalized remedial practice.',
        gujaratiSubtitle: 'મૂલ્યાંકનો રેકોર્ડ કરો, અધ્યયન ગાબડાં ઓળખો અને વ્યક્તિગત પ્રેક્ટિસ સોંપો.',
        icon: Icons.school_rounded,
        primaryColor: Color(0xFF1565C0), // Royal Blue
        lightBgColor: Color(0xFFE8F1FC),
        badgeText: 'Classroom & Diagnostics',
        gujaratiBadgeText: 'વર્ગખંડ અને નિદાન',
      ),
      const _RoleCardData(
        role: UserRole.principal,
        title: 'School Principal',
        gujaratiTitle: 'શાળાના આચાર્ય',
        subtitle: 'Monitor school-level KPIs, grade benchmarks & track teacher remediation action status.',
        gujaratiSubtitle: 'શાળા સ્તરના સૂચકાંકો, ગ્રેડ બેન્ચમાર્ક અને ઉપચારાત્મક પ્રગતિ ટ્રેક કરો.',
        icon: Icons.admin_panel_settings_rounded,
        primaryColor: Color(0xFF00796B), // Deep Teal
        lightBgColor: Color(0xFFE0F2F1),
        badgeText: 'School Oversight',
        gujaratiBadgeText: 'શાળા દેખરેખ',
      ),
      const _RoleCardData(
        role: UserRole.brc,
        title: 'Block Resource Coordinator',
        gujaratiTitle: 'બ્લોક રિસોર્સ કોઓર્ડિનેટર',
        subtitle: 'Analyze block & cluster metrics, comparative school reports & allocate pedagogical support.',
        gujaratiSubtitle: 'બ્લોક મેટ્રિક્સ, તુલનાત્મક શાળા અહેવાલોનું વિશ્લેષણ અને સહાય ફાળવો.',
        icon: Icons.hub_rounded,
        primaryColor: Color(0xFF6A1B9A), // Rich Purple
        lightBgColor: Color(0xFFF3E5F5),
        badgeText: 'Cluster Analytics',
        gujaratiBadgeText: 'ક્લસ્ટર વિશ્લેષણ',
      ),
      const _RoleCardData(
        role: UserRole.parent,
        title: 'Parent',
        gujaratiTitle: 'વાલી',
        subtitle: 'View your child\'s learning mastery, quiz achievements & engage in guided home activities.',
        gujaratiSubtitle: 'બાળકના શિક્ષણની પ્રગતિ, ક્વિઝ સિદ્ધિઓ જુઓ અને ઘરની પ્રવૃત્તિઓ કરો.',
        icon: Icons.family_restroom_rounded,
        primaryColor: Color(0xFFD97706), // Warm Amber / Orange
        lightBgColor: Color(0xFFFEF3C7),
        badgeText: 'Child Progress',
        gujaratiBadgeText: 'બાળકની પ્રગતિ',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 560) {
          return Column(
            children: roles.map((role) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildRoleCard(context, role),
              );
            }).toList(),
          );
        }

        final int crossAxisCount = width >= 860 ? 4 : 2;
        final double childAspectRatio = width >= 860 ? 0.82 : 1.25;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: roles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            return _buildRoleCard(context, roles[index]);
          },
        );
      },
    );
  }

  /// Individual Role Selection Card
  Widget _buildRoleCard(BuildContext context, _RoleCardData data) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final isGujarati = localeProvider.locale.languageCode == 'gu';
        final displayTitle = isGujarati ? data.gujaratiTitle : data.title;
        final displaySubtitle = isGujarati
            ? data.gujaratiSubtitle
            : data.subtitle;
        final displayBadge = isGujarati
            ? data.gujaratiBadgeText
            : data.badgeText;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: data.primaryColor.withOpacity(0.18),
              width: 1.5,
            ),
          ),
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen(role: data.role)),
              );
            },
            splashColor: data.primaryColor.withOpacity(0.12),
            highlightColor: data.primaryColor.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top section: Icon + Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: data.lightBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          data.icon,
                          color: data.primaryColor,
                          size: 22,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: data.lightBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            displayBadge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: data.primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Middle Section: Role Title & Subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displaySubtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Bottom Action Link
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isGujarati
                              ? '$displayTitle તરીકે ચાલુ રાખો'
                              : 'Continue as ${data.role.name.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: data.primaryColor,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: data.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Banner at the bottom explaining demo authentication
  Widget _buildDemoBanner(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade900.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 20,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.demoNote ?? 'Demo Mode — Authentication is simulated',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isGu
                      ? 'બિલ્ટ-ઇન ડેમો ઓળખપત્રો અથવા ઝડપી ઍક્સેસ વડે કોઈપણ ભૂમિકામાં લોગિન કરો.'
                      : 'Tap any role above to log in instantly using built-in demo credentials or quick access.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper model for role cards configuration
class _RoleCardData {
  final UserRole role;
  final String title;
  final String gujaratiTitle;
  final String subtitle;
  final String gujaratiSubtitle;
  final IconData icon;
  final Color primaryColor;
  final Color lightBgColor;
  final String badgeText;
  final String gujaratiBadgeText;

  const _RoleCardData({
    required this.role,
    required this.title,
    required this.gujaratiTitle,
    required this.subtitle,
    required this.gujaratiSubtitle,
    required this.icon,
    required this.primaryColor,
    required this.lightBgColor,
    required this.badgeText,
    required this.gujaratiBadgeText,
  });
}
