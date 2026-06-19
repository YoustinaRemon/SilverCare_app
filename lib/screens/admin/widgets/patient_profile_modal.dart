import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../theme/app_theme.dart';

void showPatientProfileModal(BuildContext context, String userId) {
  final db = Supabase.instance.client;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: db
                    .from('health_profiles')
                    .select()
                    .eq('id', userId)
                    .maybeSingle(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                        child: Text('Could not load medical profile.'.tr()));
                  }

                  final profile = snapshot.data!;
                  final avatarUrl = profile['avatar_url'];
                  final name = profile['full_name'] ?? 'Unknown Patient';
                  final email = profile['email'] ?? 'No Email';
                  final phone = profile['phone_number'] ?? 'No Phone Number';

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor:
                                  AppTheme.primary.withValues(alpha: 0.1),
                              backgroundImage:
                                  avatarUrl != null && avatarUrl.isNotEmpty
                                      ? NetworkImage(avatarUrl)
                                      : null,
                              child: avatarUrl == null
                                  ? Text(name[0].toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary))
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(email,
                                style: const TextStyle(
                                    color: AppTheme.mutedFg, fontSize: 14)),
                            Text(phone,
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                      const Divider(height: 40),
                      _buildModalSectionTitle(
                          context, 'Basic Information', Icons.person_outline),
                      _buildMedicalInfoTile(
                          'Age', '${profile['age'] ?? '--'} ${'yrs'.tr()}'),
                      _buildMedicalInfoTile('Weight',
                          '${profile['weight_kg'] ?? '--'} ${'kg'.tr()}'),
                      _buildMedicalInfoTile('Height',
                          '${profile['height_cm'] ?? '--'} ${'cm'.tr()}'),
                      const SizedBox(height: 20),
                      _buildModalSectionTitle(
                          context, 'Vital Signs', Icons.monitor_heart_outlined),
                      _buildMedicalInfoTile('Blood Sugar',
                          '${profile['blood_sugar'] ?? '--'} mg/dL'),
                      _buildMedicalInfoTile('Blood Pressure',
                          '${profile['blood_pressure_systolic'] ?? '--'}/${profile['blood_pressure_diastolic'] ?? '--'} mmHg'),
                      const SizedBox(height: 20),
                      _buildModalSectionTitle(
                          context, 'Medical History', Icons.history_rounded),
                      _buildMedicalInfoTile('Chronic Diseases',
                          profile['chronic_diseases'] ?? 'None'.tr()),
                      _buildMedicalInfoTile(
                          'Allergies', profile['allergies'] ?? 'None'.tr()),
                      _buildMedicalInfoTile('Medical Notes',
                          profile['medical_notes'] ?? 'None'.tr()),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildModalSectionTitle(
    BuildContext context, String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title.tr(),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                fontSize: 16)),
      ],
    ),
  );
}

Widget _buildMedicalInfoTile(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: Text(label.tr(),
                style: const TextStyle(
                    color: AppTheme.mutedFg, fontWeight: FontWeight.w500))),
        Expanded(
            flex: 3,
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    ),
  );
}
