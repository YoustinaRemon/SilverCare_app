import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../theme/app_theme.dart';

class AdminUserSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const AdminUserSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search by name or email...'.tr(),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}
