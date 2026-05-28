import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../widgets/language_picker.dart';

class SilverCareAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showCompanions;
  final String healthProfileRoute;

  const SilverCareAppBar({
    super.key,
    this.showCompanions = true,
    required this.healthProfileRoute,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('SilverCare'),
      actions: [
        const LanguagePicker(),
        IconButton(
          icon: const Icon(Icons.person_rounded),
          onPressed: () =>
              context.go(healthProfileRoute), // استخدام المتغير هنا
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            // الـ if دي هتخلي الـ Companions يظهر بس لو showCompanions قيمتها true
            if (showCompanions)
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
                  Navigator.pop(context);
                  context.read<ThemeProvider>().toggleTheme(context);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: Text("Sign Out".tr()),
                onTap: () async {
                  await AuthService().signOut();
                  if (context.mounted) context.go('/');
                },
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // الجزء ده مهم جداً عشان الـ Scaffold يعرف ارتفاع الـ AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
