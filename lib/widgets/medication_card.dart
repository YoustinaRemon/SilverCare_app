import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';

class MedicationCard extends StatelessWidget {
  final Map<String, dynamic> med;
  final bool isTaken;
  final bool isSkipped;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  final VoidCallback onReset;

  const MedicationCard({
    super.key,
    required this.med,
    required this.isTaken,
    required this.isSkipped,
    required this.onTake,
    required this.onSkip,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor = AppTheme.amber;
    if (isTaken) statusColor = AppTheme.primary;
    if (isSkipped) statusColor = AppTheme.destructive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.medication_rounded,
                      color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med['name'] ?? '',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text('${med['dosage'] ?? ''} · ${med['frequency'] ?? ''}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppTheme.mutedFg)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(med['schedule_time'] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),

            // ── Notes ──
            if (med['notes'] != null && med['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(med['notes'],
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppTheme.mutedFg)),
            ],

            const SizedBox(height: 12),

            // ── Actions ──
            if (!isTaken && !isSkipped)
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSkip,
                    icon: const Icon(Icons.close, size: 16),
                    label: Text('Skipped'.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.destructive,
                      side: const BorderSide(color: AppTheme.destructive),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTake,
                    icon: const Icon(Icons.check, size: 16),
                    label: Text('Taken'.tr()),
                  ),
                ),
              ])
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(
                      isTaken
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: isTaken ? AppTheme.primary : AppTheme.destructive,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isTaken ? 'Marked as taken'.tr() : 'Skipped'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            isTaken ? AppTheme.primary : AppTheme.destructive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                  TextButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.undo_rounded, size: 14),
                    label: Text('Undo'.tr()),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.mutedFg,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
