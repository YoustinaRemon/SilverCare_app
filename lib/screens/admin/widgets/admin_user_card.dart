import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class AdminUserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = user['avatar_url'];
    final rawId = user['id']?.toString() ?? 'Unknown';
    final shortId =
        rawId.length > 8 ? rawId.substring(0, 8).toUpperCase() : rawId;
    final name = user['full_name'] ?? 'User $shortId';
    final email = user['email'] ?? 'No email provided';
    final age = user['age'] ?? '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? Text(
                      name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 14, color: AppTheme.mutedFg),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(email,
                            style: const TextStyle(
                                color: AppTheme.mutedFg, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('ID: #$shortId',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('Age: $age',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
