import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';
import 'contact_button.dart';

class QuickContactsSection extends StatelessWidget {
  const QuickContactsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Contacts'.tr(), style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        Row(children: [
          const ContactButton(
            icon: Icons.local_hospital_rounded,
            label: 'Ambulance\n123',
            color: AppTheme.destructive,
            phone: '123',
          ),
          const SizedBox(width: 12),
          const ContactButton(
            icon: Icons.local_police_rounded,
            label: 'Police\n122',
            color: AppTheme.primary,
            phone: '122',
          ),
          const SizedBox(width: 12),
          ContactButton(
            icon: Icons.favorite_rounded,
            label: 'Family\n01286354482'.tr(),
            color: Colors.purple,
            phone: '01286354482',
          ),
        ]),
      ],
    );
  }
}
