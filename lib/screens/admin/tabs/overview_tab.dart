import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../theme/app_theme.dart';
import "../../../widgets/silver_care_app_bar.dart";

// استيراد الشاشات الفرعية
import '../screens/admin_sos_screen.dart';
import '../screens/admin_users_screen.dart';
import 'manage_companions_tab.dart';
import '../../../screens/admin/screens/admin_orders_screen.dart';

// 🌟 استيراد الـ Widgets المنفصلة
import '../widgets/manage_roles_modal.dart';
import '../widgets/stat_card_admin.dart';
import '../widgets/percentage_row.dart';
import '../widgets/broadcast_dialog.dart';

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
  int _totalOrders = 0;

  double _completedProfilesPercent = 0.0;
  double _chronicPatientsPercent = 0.0;
  String _avgAge = "-";

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
      final ordersData = await _supabase.from('meal_orders').select('id');

      final profilesData = await _supabase
          .from('health_profiles')
          .select('id, age, chronic_diseases, phone_number');

      int total = profilesData.length;
      int completedCount = 0;
      int chronicCount = 0;
      int validAgesCount = 0;
      int sumAges = 0;

      for (var p in profilesData) {
        if (p['phone_number'] != null &&
            p['phone_number'].toString().trim().isNotEmpty) {
          completedCount++;
        }

        final chronic =
            p['chronic_diseases']?.toString().trim().toLowerCase() ?? '';
        if (chronic.isNotEmpty &&
            chronic != 'none' &&
            chronic != 'Doesn\n’t have') {
          chronicCount++;
        }

        final ageStr = p['age']?.toString() ?? '';
        final ageInt = int.tryParse(ageStr);
        if (ageInt != null && ageInt > 0 && ageInt < 120) {
          sumAges += ageInt;
          validAgesCount++;
        }
      }

      if (mounted) {
        setState(() {
          _totalBookings = bookingsData.length;
          _activeSOS = sosData.length;
          _totalUsers = total;
          _totalOrders = ordersData.length;

          _completedProfilesPercent =
              total > 0 ? (completedCount / total) : 0.0;
          _chronicPatientsPercent = total > 0 ? (chronicCount / total) : 0.0;
          _avgAge = validAgesCount > 0
              ? (sumAges / validAgesCount).round().toString()
              : '-';

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
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        // 🌟 استخدام كارت الإحصائيات المنفصل
                        StatCardAdmin(
                          title: 'Total Users'.tr(),
                          value: '$_totalUsers',
                          icon: Icons.people_alt,
                          color: Colors.blue,
                          isClickable: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminUsersScreen()),
                            );
                          },
                        ),
                        StatCardAdmin(
                          title: 'Active SOS'.tr(),
                          value: '$_activeSOS',
                          icon: Icons.sos_rounded,
                          color: AppTheme.destructive,
                          isClickable: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AdminSosScreen()),
                            );
                          },
                        ),
                        StatCardAdmin(
                          title: 'Total Bookings'.tr(),
                          value: '$_totalBookings',
                          icon: Icons.calendar_month,
                          color: AppTheme.amber,
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
                        StatCardAdmin(
                          title: 'Meals Ordered'.tr(),
                          value: '$_totalOrders',
                          icon: Icons.shopping_bag_rounded,
                          color: Colors.green,
                          isClickable: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminOrdersScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text('Demographics & Insights'.tr(),
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppTheme.border.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 🌟 استخدام ودجت النسب المئوية المنفصلة
                          PercentageRow(
                            title: 'Completed Profiles',
                            percentage: _completedProfilesPercent,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 20),
                          PercentageRow(
                            title: 'High-Risk (Chronic)',
                            percentage: _chronicPatientsPercent,
                            color: AppTheme.destructive,
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.purple.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.cake_rounded,
                                        color: Colors.purple, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('Average Patient Age'.tr(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                ],
                              ),
                              Text('$_avgAge ${'yrs'.tr()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.purple)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Quick Actions'.tr(),
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            // 🌟 استدعاء دالة الإرسال الجماعي
                            onPressed: () =>
                                showBroadcastDialog(context, _supabase),
                            style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16))),
                            icon: const Icon(Icons.campaign_rounded),
                            label: const Text('Broadcast Alert'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            // 🌟 استدعاء دالة إدارة الصلاحيات
                            onPressed: () => showManageRolesModal(context),
                            style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16))),
                            icon: const Icon(Icons.security_rounded),
                            label: const Text('Manage Roles'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
