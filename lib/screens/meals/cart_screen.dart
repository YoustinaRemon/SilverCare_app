import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_theme.dart';
import '../../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> items;
  final VoidCallback onClearCart;

  const CartScreen({
    super.key,
    required this.items,
    required this.onClearCart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _paymentMethod = 'Cash on Delivery';
  final double _deliveryFee = 20.0;

  double get _subtotal =>
      widget.items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get _total => _subtotal + _deliveryFee;

  void _confirmPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.primary, size: 60),
            const SizedBox(height: 16),
            Text('Payment Successful!'.tr(), textAlign: TextAlign.center),
          ],
        ),
        content: Text(
          'Your order has been placed successfully and will be delivered soon.'
              .tr(),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onClearCart();

                Navigator.pop(dialogContext);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text('Back to Menu'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'.tr()),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.items.length,
              itemBuilder: (context, i) {
                final item = widget.items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item.image,
                          width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    title: Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Qty: ${item.quantity}'),
                    trailing: Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 10,
                    offset: const Offset(0, -5))
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Method'.tr(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _PaymentOption(
                          title: 'Cash'.tr(),
                          icon: Icons.money_rounded,
                          isSelected: _paymentMethod == 'Cash on Delivery',
                          onTap: () => setState(
                              () => _paymentMethod = 'Cash on Delivery'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PaymentOption(
                          title: 'Credit Card'.tr(),
                          icon: Icons.credit_card_rounded,
                          isSelected: _paymentMethod == 'Credit Card',
                          onTap: () =>
                              setState(() => _paymentMethod = 'Credit Card'),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal'.tr(),
                          style: const TextStyle(color: AppTheme.mutedFg)),
                      Text('\$${_subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery Fee'.tr(),
                          style: const TextStyle(color: AppTheme.mutedFg)),
                      Text('\$${_deliveryFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total'.tr(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('\$${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmPayment,
                      child: Text('Confirm Order'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption(
      {required this.title,
      required this.icon,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: .1)
              : Colors.transparent,
          border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.mutedFg),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                    color: isSelected ? AppTheme.primary : AppTheme.mutedFg,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
