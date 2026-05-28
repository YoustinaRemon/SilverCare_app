import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../theme/app_theme.dart';

class ManageCompanionsTab extends StatefulWidget {
  const ManageCompanionsTab({super.key});
  @override
  State<ManageCompanionsTab> createState() => _ManageCompanionsTabState();
}

class _ManageCompanionsTabState extends State<ManageCompanionsTab> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = _supabase
          .from('companion_bookings')
          .select('*')
          .order('booked_at', ascending: false)
          .then((data) => List<Map<String, dynamic>>.from(data));
    });
  }

  Future<void> _toggleStatus(dynamic id, String currentStatus) async {
    final nextStatus = currentStatus == 'pending' ? 'Approved' : 'pending';
    try {
      await _supabase
          .from('companion_bookings')
          .update({'status': nextStatus}).eq('id', id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _delete(dynamic id) async {
    try {
      await _supabase.from('companion_bookings').delete().eq('id', id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAddCompanionDialog() {
    final nameCtrl = TextEditingController();
    final skillsCtrl = TextEditingController();
    final langCtrl = TextEditingController();
    final personalityCtrl = TextEditingController();
    final avatarCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.person_add_rounded, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text('Add Companion'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                        labelText: 'Full Name'.tr(),
                        border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: skillsCtrl,
                    decoration: InputDecoration(
                        labelText: 'Skills (e.g. Nursing, Cooking)'.tr(),
                        border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: langCtrl,
                    decoration: InputDecoration(
                        labelText: 'Languages (e.g. English, Arabic)'.tr(),
                        border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: personalityCtrl,
                    decoration: InputDecoration(
                        labelText: 'Personality (e.g. Calm, Active)'.tr(),
                        border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: avatarCtrl,
                    decoration: InputDecoration(
                        labelText: 'Image URL (Optional)'.tr(),
                        border: const OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: Text('Cancel'.tr(),
                    style: const TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        if (nameCtrl.text.isEmpty) {
                          messenger.showSnackBar(const SnackBar(
                              content: Text('Name is required!')));
                          return;
                        }

                        setDialogState(() => isSaving = true);
                        try {
                          await _supabase.from('companions').insert({
                            'name': nameCtrl.text,
                            'skills': skillsCtrl.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList(),
                            'languages': langCtrl.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList(),
                            'personality': personalityCtrl.text,
                            'rating': 5.0,
                            'reviews': 0,
                            'avatar': avatarCtrl.text.isNotEmpty
                                ? avatarCtrl.text
                                : 'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                          });

                          if (!mounted) return;
                          navigator.pop();
                          messenger.showSnackBar(SnackBar(
                            content: Text('Companion added successfully!'.tr()),
                            backgroundColor: Colors.green,
                          ));
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          if (!mounted) return;
                          messenger.showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                        }
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Add'.tr()),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCompanionDialog,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('New Companion'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return Center(child: Text('No bookings found'.tr()));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 24, bottom: 80),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final item = list[i];
                final isPending = item['status'] == 'pending';

                final rawUserId = item['user_id']?.toString() ?? 'Unknown';
                final shortUserId = rawUserId.length > 8
                    ? rawUserId.substring(0, 8).toUpperCase()
                    : rawUserId;

                final compName = item['companion_name'] ?? 'Companion';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: AppTheme.border.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      AppTheme.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.person,
                                      color: AppTheme.primary),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  compName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    (isPending ? AppTheme.amber : Colors.green)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isPending ? 'Pending'.tr() : 'Approved'.tr(),
                                style: TextStyle(
                                  color:
                                      isPending ? AppTheme.amber : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.receipt_long_rounded,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('Booking Ref: #$shortUserId',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    _toggleStatus(item['id'], item['status']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPending
                                      ? AppTheme.primary
                                      : Colors.grey.shade200,
                                  foregroundColor:
                                      isPending ? Colors.white : Colors.black87,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(isPending
                                    ? 'Approve Booking'.tr()
                                    : 'Revoke Approval'.tr()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () => _delete(item['id']),
                              icon: const Icon(Icons.delete_outline,
                                  color: AppTheme.destructive),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    AppTheme.destructive.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
