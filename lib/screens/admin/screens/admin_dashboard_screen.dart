import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../tabs/manage_companions_tab.dart';
import '../tabs/manage_meals_tab.dart';
import '../tabs/overview_tab.dart';
import "../../../widgets/silver_care_app_bar.dart";

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const OverviewTab(),
    const ManageCompanionsTab(),
    const ManageMealsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const SilverCareAppBar(
        healthProfileRoute: '/admin-profile',
        showCompanions: false,
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              NavigationRail(
                extended: true,
                backgroundColor: theme.cardColor,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) =>
                    setState(() => _selectedIndex = index),
                destinations: [
                  NavigationRailDestination(
                      icon: const Icon(Icons.dashboard_rounded),
                      label: Text('Overview'.tr())),
                  NavigationRailDestination(
                      icon: const Icon(Icons.group_rounded),
                      label: Text('Companions'.tr())),
                  NavigationRailDestination(
                      icon: const Icon(Icons.restaurant_rounded),
                      label: Text('Meals'.tr())),
                ],
              ),
            if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _tabs[_selectedIndex]),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) =>
                  setState(() => _selectedIndex = index),
              destinations: [
                NavigationDestination(
                    icon: const Icon(Icons.dashboard_rounded),
                    label: 'Overview'.tr()),
                NavigationDestination(
                    icon: const Icon(Icons.group_rounded),
                    label: 'Companions'.tr()),
                NavigationDestination(
                    icon: const Icon(Icons.restaurant_rounded),
                    label: 'Meals'.tr()),
              ],
            ),
    );
  }
}
