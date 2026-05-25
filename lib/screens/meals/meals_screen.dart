import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

const _mockMeals = [
  {
    'id': '1',
    'name': 'Diabetes-Friendly Salmon Bowl',
    'price': 25.50,
    'category': 'Diabetic',
    'calories': 450,
    'image':
        'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&q=80',
  },
  {
    'id': '2',
    'name': 'Low-Sodium Chicken Soup',
    'price': 18.00,
    'category': 'Low Sodium',
    'calories': 320,
    'image':
        'https://images.unsplash.com/photo-1547592180-85f173990554?w=400&q=80',
  },
  {
    'id': '3',
    'name': 'Soft Mashed Root Vegetables',
    'price': 15.00,
    'category': 'Elderly Soft',
    'calories': 250,
    'image':
        'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&q=80',
  },
  {
    'id': '4',
    'name': 'Heart-Healthy Quinoa Salad',
    'price': 22.00,
    'category': 'Cholesterol-Friendly',
    'calories': 380,
    'image':
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80',
  },
  {
    'id': '5',
    'name': 'Low-Sugar Oat Porridge',
    'price': 12.00,
    'category': 'Diabetic',
    'calories': 280,
    'image':
        'https://images.unsplash.com/photo-1495214783159-3503fd1b572d?w=400&q=80',
  },
  {
    'id': '6',
    'name': 'Steamed White Fish & Greens',
    'price': 20.00,
    'category': 'Low Sodium',
    'calories': 310,
    'image':
        'https://images.unsplash.com/photo-1551248429-40975aa4de74?w=400&q=80',
  },
];

const _categories = [
  'All',
  'Diabetic',
  'Low Sodium',
  'Elderly Soft',
  'Cholesterol-Friendly'
];

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});
  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  String _filter = 'All';
  final Map<String, int> _cart = {};

  List<Map<String, dynamic>> get _filtered => _filter == 'All'
      ? _mockMeals.toList()
      : _mockMeals.where((m) => m['category'] == _filter).toList();

  int get _totalItems => _cart.values.fold(0, (a, b) => a + b);
  double get _totalPrice => _cart.entries.fold(0.0, (sum, e) {
        final meal = _mockMeals.firstWhere((m) => m['id'] == e.key);
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

  void _checkout() {
    setState(() => _cart.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('✅ Order placed! Your meals will be delivered shortly.'.tr()),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Healthy Meal Marketplace'.tr(),
                    style: theme.textTheme.displayMedium),
                const SizedBox(height: 4),
                Text(
                    'Nutritious, medical-grade meals for your health condition.'
                        .tr(),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.mutedFg)),
                const SizedBox(height: 16),
                // Category filter chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final selected = _filter == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) => setState(() => _filter = cat),
                        selectedColor: AppTheme.primary,
                        labelStyle: TextStyle(
                            color: selected ? Colors.white : null,
                            fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Meal Grid
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
                final qty = _cart[meal['id']] ?? 0;
                return _MealCard(
                  meal: meal,
                  qty: qty,
                  onAdd: () => _add(meal['id'] as String),
                  onRemove: () => _remove(meal['id'] as String),
                );
              },
            ),
          ),
        ],
      ),

      // Cart FAB
      floatingActionButton: _totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: _checkout,
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

class _MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final int qty;
  final VoidCallback onAdd, onRemove;
  const _MealCard(
      {required this.meal,
      required this.qty,
      required this.onAdd,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  meal['image'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.muted,
                    child: const Icon(Icons.restaurant_rounded,
                        color: AppTheme.primary, size: 40),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      meal['category'] as String,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal['name'] as String,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${meal['calories']} kcal',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.mutedFg)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${(meal['price'] as double).toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800)),
                    if (qty == 0)
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 16),
                        ),
                      )
                    else
                      Row(children: [
                        GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppTheme.muted,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(Icons.remove, size: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('$qty',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                        GestureDetector(
                          onTap: onAdd,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
