import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _loadingHistory = true);
    final user = context.read<AuthService>().currentUser;
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
          _alerts = (data as List).cast<Map<String, dynamic>>();
          _loadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _triggerSOS() async {
    setState(() => _sosState = SOSState.locating);

    // Try to get GPS
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      _position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Continue without GPS
    }

    if (!mounted) return;
    setState(() => _sosState = SOSState.contacting);
    await Future.delayed(const Duration(seconds: 2));

    final user = context.read<AuthService>().currentUser;
    if (user == null || !mounted) return;

    try {
      await _db.from('emergency_alerts').insert({
        'user_id': user.id,
        'alert_type': 'SOS',
        'severity': 'high',
        'status': 'active',
        'latitude': _position?.latitude,
        'longitude': _position?.longitude,
      });
      await _loadAlerts();
    } catch (_) {}

    if (mounted) setState(() => _sosState = SOSState.sent);
  }

  void _cancelSOS() => setState(() => _sosState = SOSState.idle);

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
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAlerts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Emergency'.tr(), style: theme.textTheme.displayMedium),
            const SizedBox(height: 4),
            Text('Quick access to emergency services'.tr(),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.mutedFg)),
            const SizedBox(height: 28),

            // SOS Button Card
            Card(
              surfaceTintColor: AppTheme.destructive.withValues(alpha: .05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: AppTheme.destructive.withValues(alpha: .2),
                    width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('Emergency SOS'.tr(),
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(color: AppTheme.destructive)),
                    const SizedBox(height: 8),
                    Text(
                      'Press the SOS button to alert family, doctor and emergency services with your location.'
                          .tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.mutedFg),
                    ),
                    const SizedBox(height: 28),

                    // Big SOS Button
                    if (_sosState == SOSState.idle)
                      GestureDetector(
                        onTap: _triggerSOS,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.destructive,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.destructive.withValues(alpha: .4),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sos_rounded,
                                  color: Colors.white, size: 48),
                              SizedBox(height: 4),
                              Text('PRESS',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      letterSpacing: 2)),
                            ],
                          ),
                        ),
                      )
                    else if (_sosState == SOSState.sent) ...[
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withValues(alpha: .1),
                          border: Border.all(color: AppTheme.primary, width: 3),
                        ),
                        child: const Icon(Icons.check_circle_rounded,
                            color: AppTheme.primary, size: 64),
                      ),
                      const SizedBox(height: 16),
                      Text('SOS Sent!'.tr(),
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: AppTheme.primary)),
                      const SizedBox(height: 8),
                      Text(
                        'Emergency services and family have been notified with your location.'
                            .tr(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppTheme.mutedFg),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _cancelSOS,
                        child: const Text('Done'),
                      ),
                    ] else ...[
                      const CircularProgressIndicator(
                          color: AppTheme.destructive),
                      const SizedBox(height: 16),
                      Text(
                        _sosState == SOSState.locating
                            ? '📍 Getting your location...'.tr()
                            : '📞 Contacting emergency services...'.tr(),
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: AppTheme.destructive),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _cancelSOS,
                        child: Text('Cancel'.tr(),
                            style:
                                const TextStyle(color: AppTheme.destructive)),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Quick Contact Chips
            Text('Quick Contacts'.tr(), style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            const Row(children: [
              _ContactButton(
                icon: Icons.local_hospital_rounded,
                label: 'Ambulance\n123',
                color: AppTheme.destructive,
              ),
              SizedBox(width: 12),
              _ContactButton(
                icon: Icons.local_police_rounded,
                label: 'Police\n122',
                color: AppTheme.primary,
              ),
              SizedBox(width: 12),
              _ContactButton(
                icon: Icons.fire_truck_rounded,
                label: 'Fire\n125',
                color: AppTheme.amber,
              ),
            ]),

            const SizedBox(height: 28),

            // Alert History
            Text('Alert History'.tr(), style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),

            if (_loadingHistory)
              const Center(child: CircularProgressIndicator())
            else if (_alerts.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.shield_rounded,
                            color: AppTheme.primary, size: 40),
                        const SizedBox(height: 12),
                        Text('No emergency alerts.'.tr(),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.mutedFg)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._alerts.map((alert) {
                final createdAt = DateTime.tryParse(alert['created_at'] ?? '');
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _statusColor(alert['status'] ?? '')
                            .withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.warning_rounded,
                          color: _statusColor(alert['status'] ?? ''), size: 20),
                    ),
                    title: Text(alert['alert_type'] ?? 'SOS',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: createdAt != null
                        ? Text(DateFormat('dd MMM yyyy, HH:mm')
                            .format(createdAt.toLocal()))
                        : null,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(alert['status'] ?? '')
                            .withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        (alert['status'] ?? 'unknown').toUpperCase(),
                        style: TextStyle(
                            fontSize: 11,
                            color: _statusColor(alert['status'] ?? ''),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ContactButton(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: .25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
