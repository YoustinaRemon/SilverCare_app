import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_theme.dart';
import '../../models/cart_item.dart';
import 'cart_screen.dart';

import 'meals_data.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/category_filter.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});
  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  String _filter = 'All';
  final Map<String, int> _cart = {};

  List<Map<String, dynamic>> get _filtered => _filter == 'All'
      ? mockMeals.toList()
      : mockMeals.where((m) => m['category'] == _filter).toList();

  int get _totalItems => _cart.values.fold(0, (a, b) => a + b);

  double get _totalPrice => _cart.entries.fold(0.0, (sum, e) {
        final meal = mockMeals.firstWhere((m) => m['id'] == e.key);
        return sum + (meal['price'] as double) * e.value;
      });

  void _add(String id) => setState(() => _cart[id] = (_cart[id] ?? 0) + 1);

  void _remove(String id) => setState(() {
        if ((_cart[id] ?? 0) > 1) {
          _cart[id] = _cart[id]! - 1;
        } else {
          _cart.remove(id);
        }
      });

  void _goToCart() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your cart is empty!'.tr()),
          backgroundColor: AppTheme.mutedFg,
        ),
      );
      return;
    }

    final items = _cart.entries.map((entry) {
      final meal = mockMeals.firstWhere((m) => m['id'] == entry.key);
      return CartItem(
        id: entry.key,
        name: meal['name'] as String,
        price: meal['price'] as double,
        image: meal['image'] as String,
        quantity: entry.value,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          items: items,
          onClearCart: () => setState(() => _cart.clear()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Healthy Meal Marketplace'.tr(),
                          style: theme.textTheme.displayMedium,
                        ),
                      ),
                      Badge(
                        isLabelVisible: _totalItems > 0,
                        label: Text('$_totalItems'),
                        backgroundColor: AppTheme.destructive,
                        child: IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined,
                              size: 28),
                          color: AppTheme.primary,
                          onPressed: _goToCart,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nutritious, medical-grade meals for your health condition.'
                        .tr(),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.mutedFg),
                  ),
                  const SizedBox(height: 16),
                  CategoryFilter(
                    categories: mealCategories,
                    selectedCategory: _filter,
                    onSelected: (cat) => setState(() => _filter = cat),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final meal = _filtered[i];
                  return MealCard(
                    meal: meal,
                    qty: _cart[meal['id']] ?? 0,
                    onAdd: () => _add(meal['id'] as String),
                    onRemove: () => _remove(meal['id'] as String),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: _goToCart,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: Text(
                'Checkout · \$${_totalPrice.toStringAsFixed(2)} ($_totalItems)',
              ),
            )
          : null,
    );
  }
}
