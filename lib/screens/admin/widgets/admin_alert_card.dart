import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';

class AdminAlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onResolve;
  final VoidCallback onOpenMap;
  // 🌟 ضفنا الدوال الجديدة هنا
  final VoidCallback onCallPatient;
  final VoidCallback onViewProfile;

  const AdminAlertCard({
    super.key,
    required this.alert,
    required this.onResolve,
    required this.onOpenMap,
    required this.onCallPatient, // 🌟
    required this.onViewProfile, // 🌟
  });

  @override
  Widget build(BuildContext context) {
    final String status = (alert['status'] ?? 'unknown').toString();
    final isActive = status == 'active';
    final lat = alert['latitude'];
    final lng = alert['longitude'];
    final createdAt = DateTime.tryParse(alert['created_at'] ?? '');
    final patientName = alert['patient_name'] ?? 'Unknown Patient';
    final patientEmail = alert['patient_email'] ?? 'No Email';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: isActive ? AppTheme.destructive : AppTheme.border,
            width: isActive ? 2 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isActive ? Icons.warning_rounded : Icons.check_circle,
                        color:
                            isActive ? AppTheme.destructive : AppTheme.primary,
                        size: 28),
                    const SizedBox(width: 8),
                    Text('SOS Alert'.tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.destructive.withValues(alpha: 0.1)
                        : AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase().tr(),
                    style: TextStyle(
                        color:
                            isActive ? AppTheme.destructive : AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // ─── Info ───
            if (createdAt != null)
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 18, color: AppTheme.mutedFg),
                  const SizedBox(width: 8),
                  Text(
                      DateFormat('dd MMM yyyy, hh:mm a')
                          .format(createdAt.toLocal()),
                      style: const TextStyle(color: AppTheme.mutedFg)),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(patientName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.email_outlined,
                    size: 18, color: AppTheme.mutedFg),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(patientEmail,
                      style: const TextStyle(
                          color: AppTheme.mutedFg, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🌟 ─── الصف الأول من الأزرار (الملف الطبي والاتصال) ─── 🌟
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewProfile,
                    icon: const Icon(Icons.medical_information_outlined),
                    label: Text('Profile'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade50,
                      foregroundColor: Colors.purple.shade700,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCallPatient,
                    icon: const Icon(Icons.call),
                    label: Text('Call'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green.shade700,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── الصف الثاني من الأزرار (الخريطة وحل المشكلة) ───
            Row(
              children: [
                if (lat != null && lng != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onOpenMap,
                      icon: const Icon(Icons.location_on),
                      label: Text('Open Map'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade700,
                        elevation: 0,
                      ),
                    ),
                  ),
                if (lat != null && lng != null) const SizedBox(width: 12),
                if (isActive)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onResolve,
                      icon: const Icon(Icons.check),
                      label: Text('Resolve'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
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
