import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';

class EmergencyHeader extends StatelessWidget {
  const EmergencyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Emergency'.tr(), style: theme.textTheme.displayMedium),
        const SizedBox(height: 4),
        Text(
          'Quick access to emergency services'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedFg),
        ),
      ],
    );
  }
}
