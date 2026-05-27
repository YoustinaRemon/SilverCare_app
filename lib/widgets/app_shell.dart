import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../widgets/language_picker.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static final _navItems = [
    const _NavItem(
        icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/dashboard'),
    const _NavItem(
        icon: Icons.medical_services_rounded,
        label: 'Medications',
        path: '/medications'),
    const _NavItem(
        // ✅ تم التصليح هنا
        icon: Icons.sos_rounded,
        label: 'Emergency',
        path: '/emergency'),
    const _NavItem(
        icon: Icons.restaurant_rounded, label: 'Meals', path: '/meals'),
    const _NavItem(
        // ✅ وتم التصليح هنا
        icon: Icons.smart_toy_rounded,
        label: 'AI Assistant',
        path: '/ai-assistant'),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final selectedIdx = _selectedIndex(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SilverCare'),
        actions: [
          const LanguagePicker(),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () => context.go('/health-profile'),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.group_rounded),
                  title: Text("Companions".tr()),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/companions');
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(
                    Provider.of<ThemeProvider>(context, listen: false)
                                .themeMode ==
                            ThemeMode.dark
                        ? Icons.wb_sunny
                        : Icons.nights_stay,
                  ),
                  title: Text("Toggle Theme".tr()),
                  onTap: () {
                    Navigator.pop(
                        context); // يفضل نقفل المنيو بعد ما نغير الثيم
                    context.read<ThemeProvider>().toggleTheme(context);
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text("Sign Out".tr()),
                  onTap: () async {
                    await auth.signOut();
                    if (context.mounted) context.go('/');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              extended: true,
              selectedIndex: selectedIdx,
              onDestinationSelected: (i) => context.go(_navItems[i].path),
              destinations: _navItems
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(
                            item.label.tr()), // ✅ ضفتلك .tr() هنا عشان تترجم
                      ))
                  .toList(),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: selectedIdx,
              onDestinationSelected: (i) => context.go(_navItems[i].path),
              destinations: _navItems
                  .map((item) => NavigationDestination(
                        icon: Icon(item.icon),
                        label: item.label.tr(),
                      ))
                  .toList(),
            ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({required this.icon, required this.label, required this.path});
}
