import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';
import '../emergency_screen.dart'; // استيراد الـ enum من الشاشة الرئيسية

class SosActionCard extends StatelessWidget {
  final SOSState sosState;
  final VoidCallback onTrigger;
  final VoidCallback onCancel;

  const SosActionCard({
    super.key,
    required this.sosState,
    required this.onTrigger,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      surfaceTintColor: AppTheme.destructive.withValues(alpha: .05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: AppTheme.destructive.withValues(alpha: .2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Emergency SOS'.tr(),
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: AppTheme.destructive)),
            const SizedBox(height: 8),
            Text(
              'Press the SOS button to alert family, doctor and emergency services with your location.'
                  .tr(),
              textAlign: TextAlign.center,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedFg),
            ),
            const SizedBox(height: 28),
            if (sosState == SOSState.idle)
              GestureDetector(
                onTap: onTrigger,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.destructive,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.destructive.withValues(alpha: .4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sos_rounded, color: Colors.white, size: 48),
                      SizedBox(height: 4),
                      Text('PRESS',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 2)),
                    ],
                  ),
                ),
              )
            else if (sosState == SOSState.sent) ...[
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: .1),
                  border: Border.all(color: AppTheme.primary, width: 3),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.primary, size: 64),
              ),
              const SizedBox(height: 16),
              Text('SOS Sent!'.tr(),
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: AppTheme.primary)),
              const SizedBox(height: 8),
              Text(
                'Emergency services and family have been notified with your location.'
                    .tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.mutedFg),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onCancel,
                child: Text('Mark as Safe'.tr()),
              ),
            ] else ...[
              const CircularProgressIndicator(color: AppTheme.destructive),
              const SizedBox(height: 16),
              Text(
                sosState == SOSState.locating
                    ? '📍 Getting your location...'.tr()
                    : '📞 Contacting emergency services...'.tr(),
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: AppTheme.destructive),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onCancel,
                child: Text('Cancel'.tr(),
                    style: const TextStyle(color: AppTheme.destructive)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
