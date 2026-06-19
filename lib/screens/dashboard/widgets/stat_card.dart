import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final IconData icon;
  final Color iconColor;
  final Color iconFg;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
    required this.iconColor,
    required this.iconFg,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedFg,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconFg),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedFg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
