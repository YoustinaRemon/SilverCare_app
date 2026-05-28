import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../widgets/silver_care_app_bar.dart';

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
        icon: Icons.sos_rounded, label: 'Emergency', path: '/emergency'),
    const _NavItem(
        icon: Icons.restaurant_rounded, label: 'Meals', path: '/meals'),
    const _NavItem(
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
    final selectedIdx = _selectedIndex(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: const SilverCareAppBar(
        healthProfileRoute: '/health-profile',
        showCompanions: true,
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
                        label: Text(item.label.tr()),
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
