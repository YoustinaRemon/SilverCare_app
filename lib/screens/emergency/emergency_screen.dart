import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

import 'widgets/emergency_header.dart';
import 'widgets/sos_action_card.dart';
import 'widgets/quick_contacts_section.dart';
import 'widgets/alert_history_section.dart';

enum SOSState { idle, locating, contacting, sent, cancelled }

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _db = Supabase.instance.client;
  SOSState _sosState = SOSState.idle;
  Position? _position;
  List<Map<String, dynamic>> _alerts = [];
  bool _loadingHistory = true;
  String? _currentAlertId;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _loadingHistory = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null) {
      setState(() => _loadingHistory = false);
      return;
    }
    try {
      final data = await _db
          .from('emergency_alerts')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(10);
      if (mounted) {
        setState(() {
          _alerts = List<Map<String, dynamic>>.from(data);
          _loadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _triggerSOS() async {
    setState(() => _sosState = SOSState.locating);

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      _position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 10));
    } catch (_) {}

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    setState(() => _sosState = SOSState.contacting);
    await Future.delayed(const Duration(seconds: 2));

    if (user == null || !mounted) return;

    try {
      final fullName = user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          'Unknown Patient';
      final email = user.email ?? 'No Email';

      final response = await _db
          .from('emergency_alerts')
          .insert({
            'user_id': user.id,
            'patient_name': fullName,
            'patient_email': email,
            'alert_type': 'SOS',
            'severity': 'high',
            'status': 'active',
            'latitude': _position?.latitude,
            'longitude': _position?.longitude,
          })
          .select()
          .single();

      _currentAlertId = response['id'].toString();
      await _loadAlerts();

      if (mounted) setState(() => _sosState = SOSState.sent);
    } catch (e) {
      debugPrint('Error sending SOS: $e');
      if (mounted) {
        setState(() => _sosState = SOSState.idle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database Error: $e'),
            backgroundColor: AppTheme.destructive,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _cancelSOS() async {
    if (_currentAlertId != null) {
      try {
        await _db
            .from('emergency_alerts')
            .update({'status': 'resolved'}).eq('id', _currentAlertId!);
        _currentAlertId = null;
        _loadAlerts();
      } catch (e) {
        debugPrint('Error resolving SOS: $e');
      }
    }
    setState(() => _sosState = SOSState.idle);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.destructive;
      case 'resolved':
        return AppTheme.primary;
      default:
        return AppTheme.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAlerts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const EmergencyHeader(), // 🌟
            const SizedBox(height: 28),
            SosActionCard(
              // 🌟
              sosState: _sosState,
              onTrigger: _triggerSOS,
              onCancel: _cancelSOS,
            ),
            const SizedBox(height: 28),
            const QuickContactsSection(), // 🌟
            const SizedBox(height: 28),
            AlertHistorySection(
              // 🌟
              loading: _loadingHistory,
              alerts: _alerts,
              statusColorMapper: _statusColor,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
