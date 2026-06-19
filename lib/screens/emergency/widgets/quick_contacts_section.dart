import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../theme/app_theme.dart';
import 'contact_button.dart';

class QuickContactsSection extends StatelessWidget {
  const QuickContactsSection({super.key});

  void _showFamilyContacts(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_rounded,
                      color: Colors.purple, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Family Emergency Contacts'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>?>(
                future: Supabase.instance.client
                    .from('health_profiles')
                    .select('emergency_contact_1, emergency_contact_2')
                    .eq('id', userId)
                    .maybeSingle(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final data = snapshot.data;
                  final String? phone1 = data?['emergency_contact_1'];
                  final String? phone2 = data?['emergency_contact_2'];

                  final bool hasPhone1 =
                      phone1 != null && phone1.toString().trim().isNotEmpty;
                  final bool hasPhone2 =
                      phone2 != null && phone2.toString().trim().isNotEmpty;

                  if (!hasPhone1 && !hasPhone2) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No emergency contacts registered. Please update your profile.'
                            .tr(),
                        style: const TextStyle(
                            color: AppTheme.mutedFg, fontSize: 16),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (hasPhone1)
                        _buildContactTile(
                            context, 'Primary Contact'.tr(), phone1.toString()),
                      if (hasPhone1 && hasPhone2) const Divider(),
                      if (hasPhone2)
                        _buildContactTile(context, 'Secondary Contact'.tr(),
                            phone2.toString()),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactTile(BuildContext context, String title, String phone) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.purple.withValues(alpha: 0.1),
        child: const Icon(Icons.phone, color: Colors.purple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(phone, style: const TextStyle(fontSize: 16)),
      trailing: ElevatedButton.icon(
        onPressed: () async {
          Navigator.pop(context);
          final url = Uri.parse('tel:$phone');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        },
        icon: const Icon(Icons.call, size: 18),
        label: Text('Call'.tr()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Contacts'.tr(), style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        Row(
          children: [
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
              label: 'Family\nContacts'.tr(),
              color: Colors.purple,
              phone: '',
              onTap: () => _showFamilyContacts(context),
            ),
          ],
        ),
      ],
    );
  }
}
