import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';

class AlertHistorySection extends StatelessWidget {
  final bool loading;
  final List<Map<String, dynamic>> alerts;
  final Color Function(String) statusColorMapper;

  const AlertHistorySection({
    super.key,
    required this.loading,
    required this.alerts,
    required this.statusColorMapper,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alert History'.tr(), style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (alerts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.shield_rounded,
                        color: AppTheme.primary, size: 40),
                    const SizedBox(height: 12),
                    Text('No emergency alerts.'.tr(),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppTheme.mutedFg)),
                  ],
                ),
              ),
            ),
          )
        else
          ...alerts.map((alert) {
            final createdAt = DateTime.tryParse(alert['created_at'] ?? '');
            final status = alert['status'] ?? '';
            final color = statusColorMapper(status);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.warning_rounded, color: color, size: 20),
                ),
                title: Text(alert['alert_type'] ?? 'SOS',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: createdAt != null
                    ? Text(DateFormat('dd MMM yyyy, HH:mm')
                        .format(createdAt.toLocal()))
                    : null,
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    (status.isEmpty ? 'unknown' : status).toUpperCase(),
                    style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
