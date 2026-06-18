import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_theme.dart';
import "../../../widgets/silver_care_app_bar.dart";

class AdminSosScreen extends StatefulWidget {
  const AdminSosScreen({super.key});

  @override
  State<AdminSosScreen> createState() => _AdminSosScreenState();
}

class _AdminSosScreenState extends State<AdminSosScreen> {
  final _supabase = Supabase.instance.client;
  bool _loading = true;
  List<Map<String, dynamic>> _allAlerts = [];
  List<Map<String, dynamic>> _filteredAlerts = [];
  String _selectedStatusFilter = 'active';

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  // جلب الاستغاثات من الداتا بيز
  Future<void> _fetchAlerts() async {
    setState(() => _loading = true);
    try {
      final data = await _supabase
          .from('emergency_alerts')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _allAlerts = List<Map<String, dynamic>>.from(data);
          _filterAlerts(_selectedStatusFilter);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching SOS alerts: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // فلترة الحالات
  void _filterAlerts(String status) {
    setState(() {
      _selectedStatusFilter = status;
      if (status == 'all') {
        _filteredAlerts = _allAlerts;
      } else {
        _filteredAlerts =
            _allAlerts.where((alert) => alert['status'] == status).toList();
      }
    });
  }

  // إنهاء حالة الطوارئ (تم الحل)
  Future<void> _resolveAlert(String alertId) async {
    try {
      await _supabase
          .from('emergency_alerts')
          .update({'status': 'resolved'}).eq('id', alertId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Alert marked as resolved!'.tr()),
              backgroundColor: Colors.green),
        );
      }
      _fetchAlerts(); // تحديث الشاشة
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.destructive),
        );
      }
    }
  }

  // فتح موقع المريض على خريطة جوجل
  Future<void> _openMap(double lat, double lng) async {
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Google Maps'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SilverCareAppBar(
        healthProfileRoute: '/admin/overview',
        showCompanions: false,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['active', 'resolved', 'all'].map((status) {
                final isSelected = _selectedStatusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status.toUpperCase().tr()),
                    selected: isSelected,
                    selectedColor: status == 'active'
                        ? AppTheme.destructive
                        : AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    onSelected: (_) => _filterAlerts(status),
                  ),
                );
              }).toList(),
            ),
          ),

          // قائمة الاستغاثات
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchAlerts,
                    child: _filteredAlerts.isEmpty
                        ? Center(
                            child: Text('No emergency alerts found.'.tr(),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredAlerts.length,
                            itemBuilder: (context, index) {
                              final alert = _filteredAlerts[index];
                              final alertId = alert['id'].toString();
                              final String status =
                                  (alert['status'] ?? 'unknown').toString();
                              final isActive = status == 'active';
                              final lat = alert['latitude'];
                              final lng = alert['longitude'];
                              final createdAt =
                                  DateTime.tryParse(alert['created_at'] ?? '');

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                      color: isActive
                                          ? AppTheme.destructive
                                          : AppTheme.border,
                                      width: isActive ? 2 : 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                  isActive
                                                      ? Icons.warning_rounded
                                                      : Icons.check_circle,
                                                  color: isActive
                                                      ? AppTheme.destructive
                                                      : AppTheme.primary,
                                                  size: 28),
                                              const SizedBox(width: 8),
                                              Text('SOS Alert'.tr(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18)),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? AppTheme.destructive
                                                      .withValues(alpha: 0.1)
                                                  : AppTheme.primary
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              status.toUpperCase().tr(),
                                              style: TextStyle(
                                                  color: isActive
                                                      ? AppTheme.destructive
                                                      : AppTheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),

                                      // وقت الاستغاثة
                                      if (createdAt != null)
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.access_time_rounded,
                                                size: 18,
                                                color: AppTheme.mutedFg),
                                            const SizedBox(width: 8),
                                            Text(
                                                DateFormat(
                                                        'dd MMM yyyy, hh:mm a')
                                                    .format(
                                                        createdAt.toLocal()),
                                                style: const TextStyle(
                                                    color: AppTheme.mutedFg)),
                                          ],
                                        ),
                                      const SizedBox(height: 8),

                                      // عرض الـ User ID
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline,
                                              size: 18,
                                              color: AppTheme.mutedFg),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                                'Patient ID: ${alert['user_id']}',
                                                style: const TextStyle(
                                                    color: AppTheme.mutedFg,
                                                    fontSize: 13)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // أزرار التحكم (الخريطة - تم الحل)
                                      Row(
                                        children: [
                                          if (lat != null && lng != null)
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _openMap(lat, lng),
                                                icon: const Icon(
                                                    Icons.location_on),
                                                label: Text('Open Map'.tr()),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue.shade50,
                                                  foregroundColor:
                                                      Colors.blue.shade700,
                                                  elevation: 0,
                                                ),
                                              ),
                                            ),
                                          if (lat != null && lng != null)
                                            const SizedBox(width: 12),
                                          if (isActive)
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _resolveAlert(alertId),
                                                icon: const Icon(Icons.check),
                                                label: Text('Resolve'.tr()),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppTheme.primary,
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
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
