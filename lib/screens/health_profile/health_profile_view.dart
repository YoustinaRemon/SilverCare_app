import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_theme.dart';

class HealthProfileView extends StatelessWidget {
  final String userEmail;
  final TextEditingController fullNameCtrl;
  final TextEditingController phoneCtrl;

  final String? avatarUrl;

  // 🌟 استقبال أرقام الطوارئ
  final TextEditingController emergencyContact1Ctrl;
  final TextEditingController emergencyContact2Ctrl;

  final TextEditingController ageCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController heightCtrl;
  final TextEditingController bloodSugarCtrl;
  final TextEditingController bpSystolicCtrl;
  final TextEditingController bpDiastolicCtrl;
  final TextEditingController chronicCtrl;
  final TextEditingController allergiesCtrl;
  final TextEditingController notesCtrl;

  const HealthProfileView({
    super.key,
    required this.userEmail,
    required this.fullNameCtrl,
    required this.phoneCtrl,
    required this.avatarUrl,
    required this.emergencyContact1Ctrl, // 🌟
    required this.emergencyContact2Ctrl, // 🌟
    required this.ageCtrl,
    required this.weightCtrl,
    required this.heightCtrl,
    required this.bloodSugarCtrl,
    required this.bpSystolicCtrl,
    required this.bpDiastolicCtrl,
    required this.chronicCtrl,
    required this.allergiesCtrl,
    required this.notesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String actualName = fullNameCtrl.text.isNotEmpty
        ? fullNameCtrl.text
        : 'Unknown Patient'.tr();
    final String actualPhone =
        phoneCtrl.text.isNotEmpty ? phoneCtrl.text : 'No phone number'.tr();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ── User Header ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: .05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primary.withValues(alpha: .2),
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? Text(
                          actualName.isNotEmpty
                              ? actualName[0].toUpperCase()
                              : 'U',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(actualName, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(userEmail,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.mutedFg)),
                const SizedBox(height: 4),
                Text(actualPhone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Health Data Cards ──
          _InfoCard(
            title: 'Basic Information'.tr(),
            icon: Icons.person_outline,
            data: {
              'Full Name'.tr(): actualName,
              'Phone'.tr(): actualPhone,
              'Age'.tr(): '${ageCtrl.text} ${'yrs'.tr()}',
              'Weight'.tr(): '${weightCtrl.text} ${'kg'.tr()}',
              'Height'.tr(): '${heightCtrl.text} ${'cm'.tr()}',
            },
          ),
          const SizedBox(height: 16),

          // 🌟 كارت أرقام الطوارئ في العرض 🌟
          _InfoCard(
            title: 'Emergency Contacts (Family)'.tr(),
            icon: Icons.favorite_border_rounded,
            data: {
              'Primary'.tr(): emergencyContact1Ctrl.text.isEmpty
                  ? 'None'.tr()
                  : emergencyContact1Ctrl.text,
              'Secondary'.tr(): emergencyContact2Ctrl.text.isEmpty
                  ? 'None'.tr()
                  : emergencyContact2Ctrl.text,
            },
          ),
          const SizedBox(height: 16),

          _InfoCard(
            title: 'Vital Signs'.tr(),
            icon: Icons.monitor_heart_outlined,
            data: {
              'Blood Sugar'.tr(): '${bloodSugarCtrl.text} ${'mg_dl'.tr()}',
              'BP Systolic'.tr(): '${bpSystolicCtrl.text} ${'mmhg'.tr()}',
              'BP Diastolic'.tr(): '${bpDiastolicCtrl.text} ${'mmhg'.tr()}',
            },
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Medical History'.tr(),
            icon: Icons.history_rounded,
            data: {
              'Chronic Diseases'.tr():
                  chronicCtrl.text.isEmpty ? 'None' : chronicCtrl.text,
              'Allergies'.tr():
                  allergiesCtrl.text.isEmpty ? 'None' : allergiesCtrl.text,
              'Notes'.tr(): notesCtrl.text.isEmpty ? 'None' : notesCtrl.text,
            },
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, String> data;

  const _InfoCard(
      {required this.title, required this.icon, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.muted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...data.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        e.key,
                        style: const TextStyle(
                            color: AppTheme.mutedFg,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        e.value.trim().isEmpty ||
                                e.value.trim() == 'yrs' ||
                                e.value.trim() == 'kg' ||
                                e.value.trim() == 'cm' ||
                                e.value.trim() == 'mg_dl' ||
                                e.value.trim() == 'mmhg'
                            ? '--'
                            : e.value,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
