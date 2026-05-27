import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/medication_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = Supabase.instance.client;

  bool _loading = true;
  Map<String, dynamic>? _healthProfile;
  int _alertsCount = 0;
  int _bookingsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);

    final user = context.read<AuthService>().currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      await context.read<MedicationProvider>().load(user.id);

      final results = await Future.wait<dynamic>([
        _db.from('Health Profile').select().eq('id', user.id).maybeSingle(),
        _db.from('emergency_alerts').select('id').eq('user_id', user.id),
        _db.from('companion_bookings').select('id').eq('user_id', user.id),
      ]);

      if (!mounted) return;
      setState(() {
        _healthProfile = results[0] as Map<String, dynamic>?;
        _alertsCount = (results[1] as List?)?.length ?? 0;
        _bookingsCount = (results[2] as List?)?.length ?? 0;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hp = _healthProfile;
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final medProvider = context.watch<MedicationProvider>();
    final medsTotal = medProvider.medications.length;
    final medsTaken = medProvider.takenIds.length;
    final medPct = medsTotal > 0 ? (medsTaken / medsTotal * 100).round() : 0;

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Text('Overview'.tr(), style: theme.textTheme.displayMedium),
            const SizedBox(height: 4),
            Text(
              'Your daily health summary'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedFg,
              ),
            ),
            const SizedBox(height: 24),

            /// STATS GRID
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Medications'.tr(),
                          value: '$medsTaken / $medsTotal',
                          sub: 'completed'.tr(args: ['$medPct']),
                          icon: Icons.medication_rounded,
                          iconColor: AppTheme.amber.withValues(alpha: .15),
                          iconFg: AppTheme.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Health Status'.tr(),
                          value: hp?['chronic_diseases'] != null
                              ? 'Managed'.tr()
                              : 'Good'.tr(),
                          sub: hp?['chronic_diseases']
                                  ?.toString()
                                  .split(',')
                                  .first ??
                              'No conditions on file'.tr(),
                          icon: Icons.monitor_heart_rounded,
                          iconColor: AppTheme.primary.withValues(alpha: .12),
                          iconFg: AppTheme.primary,
                          valueColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Alerts History'.tr(),
                          value: '$_alertsCount',
                          sub: 'Emergency events logged'.tr(),
                          icon: Icons.warning_rounded,
                          iconColor:
                              AppTheme.destructive.withValues(alpha: .12),
                          iconFg: AppTheme.destructive,
                          valueColor:
                              _alertsCount > 0 ? AppTheme.destructive : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Care Network'.tr(),
                          value: '$_bookingsCount',
                          sub: 'Active bookings'.tr(),
                          icon: Icons.group_rounded,
                          iconColor: AppTheme.secondary.withValues(alpha: .2),
                          iconFg: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 20),

            /// MEDICATION PROGRESS
            if (medsTotal > 0) ...[
              Card(
                clipBehavior: Clip.hardEdge,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite_rounded,
                              color: AppTheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Today\n’s Medication Progress'.tr(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value:
                                    medsTotal > 0 ? medsTaken / medsTotal : 0,
                                minHeight: 10,
                                backgroundColor: AppTheme.muted,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$medPct%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'taken'.tr(
                          args: ['$medsTaken', '${medsTotal - medsTaken}'],
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            /// HEALTH PROFILE
            Card(
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            color: AppTheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Health Profile Summary'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (hp != null) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            'age'.tr(),
                            '${hp['age'] ?? '—'} ${'yrs'.tr()}',
                          ),
                          _InfoChip(
                            'weight'.tr(),
                            '${hp['weight_kg'] ?? '—'} kg',
                          ),
                          _InfoChip(
                            'sugar'.tr(),
                            '${hp['blood_sugar'] ?? '—'} mg/dL',
                          ),
                          if (hp['blood_pressure_systolic'] != null)
                            _InfoChip(
                              'bp'.tr(),
                              '${hp['blood_pressure_systolic']}/${hp['blood_pressure_diastolic']}',
                            ),
                        ],
                      ),
                      if (hp['chronic_diseases'] != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (hp['chronic_diseases'] as String)
                              .split(',')
                              .map(
                                (d) => Chip(
                                  label: Text(
                                    d.trim(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor:
                                      AppTheme.primary.withValues(alpha: .1),
                                  side: BorderSide.none,
                                  padding: EdgeInsets.zero,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ] else
                      Column(
                        children: [
                          Text(
                            'No health profile data yet.'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mutedFg,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () => context.go('/health-profile'),
                            child: Text('Complete your profile →'.tr()),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// DATE CARD
            Card(
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            today,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Have a safe and healthy day. Remember to take your medications on time.'
                                .tr(),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _StatCard
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final IconData icon;
  final Color iconColor;
  final Color iconFg;
  final Color? valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
    required this.iconColor,
    required this.iconFg,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedFg,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconFg),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedFg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _InfoChip
// ---------------------------------------------------------------------------

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedFg,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
