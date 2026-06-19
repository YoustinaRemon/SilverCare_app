import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_theme.dart';
import "../../../widgets/silver_care_app_bar.dart";

import '../widgets/admin_alert_card.dart';
import '../widgets/sos_filter_row.dart';
import '../widgets/patient_profile_modal.dart';

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
      _fetchAlerts();
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
          SosFilterRow(
            selectedStatus: _selectedStatusFilter,
            onFilterChanged: _filterAlerts,
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchAlerts,
                    child: _filteredAlerts.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3),
                              Center(
                                child: Text('No emergency alerts found.'.tr(),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 16)),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredAlerts.length,
                            itemBuilder: (context, index) {
                              final alert = _filteredAlerts[index];
                              return AdminAlertCard(
                                alert: alert,
                                onResolve: () =>
                                    _resolveAlert(alert['id'].toString()),
                                onOpenMap: () {
                                  if (alert['latitude'] != null &&
                                      alert['longitude'] != null) {
                                    _openMap(
                                        alert['latitude'], alert['longitude']);
                                  }
                                },
                                // 🌟 استدعاء الدالة السحرية من الملف المنفصل
                                onViewProfile: () {
                                  final userId = alert['user_id'];
                                  if (userId != null) {
                                    showPatientProfileModal(
                                        context, userId.toString());
                                  }
                                },
                                onCallPatient: () async {
                                  final userId = alert['user_id'];
                                  if (userId == null) return;

                                  final profile = await _supabase
                                      .from('health_profiles')
                                      .select('phone_number')
                                      .eq('id', userId)
                                      .maybeSingle();

                                  final phone = profile?['phone_number'];

                                  if (phone != null &&
                                      phone.toString().isNotEmpty) {
                                    final url = Uri.parse('tel:$phone');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'No phone number registered for this patient.'
                                                  .tr()),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  }
                                },
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
