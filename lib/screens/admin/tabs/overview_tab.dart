import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../theme/app_theme.dart';
import '../screens/admin_users_screen.dart';
import 'manage_companions_tab.dart';
import "../../../widgets/silver_care_app_bar.dart";

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});
  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final _supabase = Supabase.instance.client;
  bool _loading = true;
  int _totalBookings = 0;
  int _activeSOS = 0;
  int _totalUsers = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      setState(() => _loading = true);
      final bookingsData =
          await _supabase.from('companion_bookings').select('id');
      final sosData = await _supabase
          .from('emergency_alerts')
          .select('id')
          .neq('status', 'resolved');

      final usersData = await _supabase.from('health_profiles').select('id');

      if (mounted) {
        setState(() {
          _totalBookings = bookingsData.length;
          _activeSOS = sosData.length;
          _totalUsers = usersData.length;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchStats,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          Text(
            'Admin Dashboard'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back! Here is what is happening today.'.tr(),
            style: const TextStyle(fontSize: 16, color: AppTheme.mutedFg),
          ),
          const SizedBox(height: 32),
          _loading
              ? const Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Center(child: CircularProgressIndicator()))
              : Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildStatCard(
                      'Total Users'.tr(),
                      '$_totalUsers',
                      Icons.people_alt,
                      Colors.blue,
                      context,
                      isClickable: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AdminUsersScreen()),
                        );
                      },
                    ),
                    _buildStatCard('Active SOS'.tr(), '$_activeSOS',
                        Icons.sos_rounded, AppTheme.destructive, context),
                    _buildStatCard(
                      'Total Bookings'.tr(),
                      '$_totalBookings',
                      Icons.calendar_month,
                      AppTheme.amber,
                      context,
                      isClickable: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Scaffold(
                              appBar: SilverCareAppBar(
                                healthProfileRoute: '/admin-profile',
                                showCompanions: false,
                              ),
                              body: ManageCompanionsTab(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildStatCard('Meals Ordered'.tr(), '156',
                        Icons.shopping_bag_rounded, Colors.green, context),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      BuildContext context,
      {VoidCallback? onTap, bool isClickable = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth =
            (MediaQuery.of(context).size.width - (24 * 2) - 16) / 2;
        if (MediaQuery.of(context).size.width > 600) {
          cardWidth =
              (MediaQuery.of(context).size.width - (24 * 2) - (16 * 3) - 100) /
                  4;
        }

        return Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: isClickable
                    ? color.withValues(alpha: 0.3)
                    : color.withValues(alpha: 0.1),
                width: isClickable ? 2.0 : 1.5),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        if (isClickable)
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: color.withValues(alpha: 0.5), size: 16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(title,
                        style: TextStyle(
                            color: isClickable ? color : AppTheme.mutedFg,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
