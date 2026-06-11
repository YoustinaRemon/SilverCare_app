import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "../../../theme/app_theme.dart";

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _supabase = Supabase.instance.client;
  bool _loading = true;
  List<Map<String, dynamic>> _allOrders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  String _selectedStatusFilter = 'All';

  final List<String> _statuses = ['Pending', 'Preparing', 'Delivered'];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // جلب الطلبات من الداتا بيز
  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await _supabase
          .from('meal_orders')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _allOrders = List<Map<String, dynamic>>.from(data);
          _filterOrders(_selectedStatusFilter);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // فلترة الطلبات حسب الحالة في الـ UI
  void _filterOrders(String status) {
    setState(() {
      _selectedStatusFilter = status;
      if (status == 'All') {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders =
            _allOrders.where((order) => order['status'] == status).toList();
      }
    });
  }

  // تحديث حالة الطلب في Supabase
  Future<void> _updateOrderStatus(dynamic orderId, String newStatus) async {
    try {
      await _supabase
          .from('meal_orders')
          .update({'status': newStatus}).eq('id', orderId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Order status updated to $newStatus'.tr()),
            backgroundColor: Colors.green),
      );
      _fetchOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error updating status: $e'),
              backgroundColor: AppTheme.destructive),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppTheme.amber;
      case 'Preparing':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Orders Management'.tr()),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children:
                  ['All', 'Pending', 'Preparing', 'Delivered'].map((status) {
                final isSelected = _selectedStatusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status.tr()),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => _filterOrders(status),
                  ),
                );
              }).toList(),
            ),
          ),

          // قائمة الطلبات 📋
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchOrders,
                    child: _filteredOrders.isEmpty
                        ? Center(
                            child: Text('No orders found'.tr(),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              final rawId = order['id'].toString();
                              final shortId = rawId.length > 8
                                  ? rawId.substring(0, 8).toUpperCase()
                                  : rawId;
                              final customerName =
                                  order['full_name'] ?? 'Unknown Patient';
                              final customerEmail =
                                  order['email'] ?? 'No Email';
                              final total = order['total'] ?? 0.0;
                              final paymentMethod =
                                  order['payment_method'] ?? 'Cash';
                              final String currentStatus =
                                  (order['status'] ?? 'Pending').toString();
                              // قراءة الوجبات المشتراة من الـ JSONB
                              final List<dynamic> itemsList =
                                  order['items'] ?? [];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                      color: AppTheme.border
                                          .withValues(alpha: 0.5)),
                                ),
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // الهيدر: كود الطلب وحالته الحالية
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Order #$shortId',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  _getStatusColor(currentStatus)
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              currentStatus.tr(),
                                              style: TextStyle(
                                                  color: _getStatusColor(
                                                      currentStatus),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),

                                      // بيانات المريض صاحب الطلب
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline,
                                              size: 18,
                                              color: AppTheme.primary),
                                          const SizedBox(width: 8),
                                          Text(customerName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.email_outlined,
                                              size: 18,
                                              color: AppTheme.mutedFg),
                                          const SizedBox(width: 8),
                                          Text(customerEmail,
                                              style: const TextStyle(
                                                  color: AppTheme.mutedFg,
                                                  fontSize: 13)),
                                        ],
                                      ),
                                      const Divider(height: 24),

                                      // تفاصيل الوجبات المطلوبة 🍲
                                      Text('Items:'.tr(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 13)),
                                      const SizedBox(height: 6),
                                      ...itemsList.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${item['quantity']}x  ${item['name']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              Text(
                                                  '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87)),
                                            ],
                                          ),
                                        );
                                      }),
                                      const Divider(height: 24),

                                      // الإجمالي وطريقة الدفع
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Payment: $paymentMethod'.tr(),
                                              style: const TextStyle(
                                                  color: AppTheme.mutedFg,
                                                  fontSize: 13)),
                                          Text(
                                            '\$${total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                color: AppTheme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // التحكم في تغيير حالة الطلب من الأدمن ⚙️
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Change Status:'.tr(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Container(
                                              height: 36,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: AppTheme.border),
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: currentStatus,
                                                  items: _statuses
                                                      .map((String status) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: status,
                                                      child: Text(status.tr(),
                                                          style: TextStyle(
                                                              color:
                                                                  _getStatusColor(
                                                                      status),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? val) {
                                                    if (val != null &&
                                                        val != currentStatus) {
                                                      _updateOrderStatus(
                                                          order['id'], val);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
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
