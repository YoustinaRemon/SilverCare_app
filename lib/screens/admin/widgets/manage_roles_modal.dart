import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../theme/app_theme.dart';

class ManageRolesModal extends StatefulWidget {
  const ManageRolesModal({super.key});

  @override
  State<ManageRolesModal> createState() => _ManageRolesModalState();
}

class _ManageRolesModalState extends State<ManageRolesModal> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _emailCtrl = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _searchedUser;
  String? _selectedRole;
  bool _isVerified = false;

  // 1. البحث عن المستخدم بالإيميل
  Future<void> _searchUser() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchedUser = null;
    });

    try {
      final data = await _supabase
          .from('health_profiles')
          .select('id, full_name, email, role, is_verified, avatar_url')
          .ilike('email', email)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _searchedUser = data;
          if (data != null) {
            _selectedRole = data['role'] ?? 'patient';
            _isVerified = data['is_verified'] ?? false;
          }
          _isLoading = false;
        });

        if (data == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('No user found with this email.'.tr()),
                backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.destructive),
        );
      }
    }
  }

  // 2. تحديث صلاحيات المستخدم
  Future<void> _updateUserRole() async {
    if (_searchedUser == null) return;

    setState(() => _isLoading = true);
    try {
      await _supabase.from('health_profiles').update({
        'role': _selectedRole,
        'is_verified': _isVerified,
      }).eq('id', _searchedUser!['id']);

      if (mounted) {
        setState(() {
          _searchedUser!['role'] = _selectedRole;
          _searchedUser!['is_verified'] = _isVerified;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('User role updated successfully!'.tr()),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context); // قفل النافذة بعد التحديث بنجاح
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Update failed: $e'),
              backgroundColor: AppTheme.destructive),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // تجنب تغطية الكيبورد للنافذة
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security_rounded,
                    color: AppTheme.primary, size: 28),
                const SizedBox(width: 12),
                Text('Manage Roles'.tr(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                'Search for a user by email to update their role or verification status.'
                    .tr(),
                style: const TextStyle(color: AppTheme.mutedFg)),
            const SizedBox(height: 24),

            // شريط البحث
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'user@example.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading && _searchedUser == null
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // عرض نتيجة البحث والتعديل
            if (_searchedUser != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              AppTheme.primary.withValues(alpha: 0.1),
                          backgroundImage: _searchedUser!['avatar_url'] != null
                              ? NetworkImage(_searchedUser!['avatar_url'])
                              : null,
                          child: _searchedUser!['avatar_url'] == null
                              ? Text(_searchedUser!['full_name'][0])
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_searchedUser!['full_name'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(_searchedUser!['email'],
                                  style: const TextStyle(
                                      color: AppTheme.mutedFg, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // اختيار الصلاحية (Role)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('User Role:'.tr(),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<String>(
                          value: _selectedRole,
                          items: ['patient', 'companion', 'admin'].map((role) {
                            return DropdownMenuItem(
                                value: role, child: Text(role.toUpperCase()));
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedRole = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Account Verified:'.tr(),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Switch(
                          value: _isVerified,
                          activeThumbColor: Colors.green,
                          onChanged: (val) => setState(() => _isVerified = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateUserRole,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading && _searchedUser != null
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Save Changes'.tr(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void showManageRolesModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ManageRolesModal(),
  );
}
