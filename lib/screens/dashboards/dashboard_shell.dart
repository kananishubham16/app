import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/locale_provider.dart';
import 'package:learning_setu/app/app_router.dart';

class DashboardShell extends StatefulWidget {
  final String title;
  final Widget homeTab;
  final Widget subjectsTab;
  final Widget performanceTab;
  final List<Widget>? appBarActions;
  final String? secondTabLabel;
  final IconData? secondTabIcon;
  final IconData? secondTabSelectedIcon;

  const DashboardShell({
    super.key,
    required this.title,
    required this.homeTab,
    required this.subjectsTab,
    required this.performanceTab,
    this.appBarActions,
    this.secondTabLabel,
    this.secondTabIcon,
    this.secondTabSelectedIcon,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ...?widget.appBarActions,
          // Language Switcher in App Bar
          Consumer<LocaleProvider>(
            builder: (context, localeProv, _) {
              final isGu = localeProv.locale.languageCode == 'gu';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => localeProv.toggleLanguage(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer
                          .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isGu ? 'ગુજરાતી' : 'English',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 6),
              child: Tooltip(
                message: l10n?.profile ?? 'Profile',
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.profile);
                  },
                  customBorder: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name.substring(0, 1).toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      drawer: _buildDrawer(context, user, l10n),
      body: IndexedStack(
        index: _currentIndex,
        children: [widget.homeTab, widget.subjectsTab, widget.performanceTab],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n?.home ?? 'Home',
          ),
          NavigationDestination(
            icon: Icon(widget.secondTabIcon ?? Icons.menu_book_outlined),
            selectedIcon: Icon(widget.secondTabSelectedIcon ?? Icons.menu_book),
            label: widget.secondTabLabel ?? (l10n?.subjects ?? 'Subjects'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: l10n?.performance ?? 'Performance',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    dynamic user,
    AppLocalizations? l10n,
  ) {
    final roleText = user != null ? user.getLocalizedRoleName(context) : '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: Text(user?.name ?? 'Guest'),
            accountEmail: Text(roleText),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user != null && user.name.isNotEmpty
                    ? user.name.substring(0, 1).toUpperCase()
                    : 'G',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n?.profile ?? 'Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.profile);
            },
          ),
          if (user?.role == UserRole.brc)
            ListTile(
              leading: const Icon(Icons.apartment_rounded),
              title: Text(
                Localizations.localeOf(context).languageCode == 'gu'
                    ? 'શાળાઓ અને સંસ્થાઓ'
                    : 'Schools & Institutions',
              ),
              subtitle: Text(
                Localizations.localeOf(context).languageCode == 'gu'
                    ? 'તમામ બ્લોક શાળાઓ'
                    : 'All Block Schools',
                style: const TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title:
                  Text(l10n?.subjectsAndCurriculum ?? 'Subjects & Curriculum'),
              subtitle: Text(
                l10n?.allSubjects ?? 'All Subjects',
                style: const TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.subjects);
              },
            ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: Text(l10n?.results ?? 'Results Details'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.results);
            },
          ),
          ListTile(
            leading: const Icon(Icons.insights),
            title: Text(l10n?.performanceAnalysis ?? 'Performance Analysis'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.performance);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_return_outlined),
            title: Text(
              l10n?.remedialActivities ?? 'Remedial Activities & Quizzes',
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.remedial);
            },
          ),
          const Divider(),
          // Language Switch in Drawer
          Consumer<LocaleProvider>(
            builder: (context, localeProv, _) {
              final isGu = localeProv.locale.languageCode == 'gu';
              return ListTile(
                leading: const Icon(Icons.translate_rounded),
                title: Text(l10n?.language ?? 'Language'),
                trailing: Text(
                  isGu ? 'ગુજરાતી' : 'English',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  localeProv.toggleLanguage();
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n?.settings ?? 'Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.settings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n?.logout ?? 'Logout'),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.welcome,
                  (r) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
