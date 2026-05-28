import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../models/cart_item.dart';
import 'cart_screen.dart';

import '../../widgets/meal_card.dart';
import '../../widgets/category_filter.dart';
import '../../providers/cart_provider.dart';

const mockMeals = [
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

const mealCategories = [
  'All',
  'Diabetic',
  'Low Sodium',
  'Elderly Soft',
  'Cholesterol-Friendly',
  'General'
];

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});
  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final _supabase = Supabase.instance.client;

  String _filter = 'All';
  bool _loading = true;
  List<Map<String, dynamic>> _combinedMeals = [];

  @override
  void initState() {
    super.initState();
    _fetchDynamicMeals();
  }

  Future<void> _fetchDynamicMeals() async {
    try {
      final data =
          await _supabase.from('meals').select().eq('is_available', true);

      final dynamicMeals = data.map((m) {
        final imageUrl = m['image']?.toString() ?? '';

        return {
          'id': m['id'].toString(),
          'name': m['name'] ?? 'Unknown Meal',
          'price': (m['price'] as num).toDouble(),

          // ⬅️ سحبنا التصنيف والسعرات الحقيقية
          'category': m['category'] ?? 'General',
          'calories': m['calories'] ?? 0,

          // ⬅️ لو الأدمن حط رابط صورة هيتعرض، لو محطش هيعرض صورة افتراضية شيك
          'image': imageUrl.isNotEmpty
              ? imageUrl
              : 'https://images.unsplash.com/photo-1490818387583-1b5ba2607823?w=400&q=80',
        };
      }).toList();

      if (mounted) {
        setState(() {
          _combinedMeals = [...mockMeals, ...dynamicMeals];
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching meals: $e');
      if (mounted) {
        setState(() {
          _combinedMeals = List.from(mockMeals);
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filtered => _filter == 'All'
      ? _combinedMeals
      : _combinedMeals.where((m) => m['category'] == _filter).toList();

  void _add(String id) => context.read<CartProvider>().add(id);

  void _remove(String id) => context.read<CartProvider>().remove(id);

  double _calculateTotalPrice(Map<String, int> cart) {
    return cart.entries.fold(0.0, (sum, e) {
      try {
        final meal = _combinedMeals.firstWhere((m) => m['id'] == e.key);
        return sum + (meal['price'] as double) * e.value;
      } catch (_) {
        return sum;
      }
    });
  }

  void _goToCart() {
    final cartProvider = context.read<CartProvider>();
    final cart = cartProvider.cart;

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty'.tr())),
      );
      return;
    }

    final items = <CartItem>[];
    for (var entry in cart.entries) {
      try {
        final meal = _combinedMeals.firstWhere((m) => m['id'] == entry.key);
        items.add(CartItem(
          id: entry.key,
          name: meal['name'] as String,
          price: meal['price'] as double,
          image: meal['image'] as String,
          quantity: entry.value,
        ));
      } catch (_) {}
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          items: items,
          onClearCart: () => context.read<CartProvider>().clear(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;
    final totalItems = cartProvider.totalItems;
    final totalPrice = _calculateTotalPrice(cart);

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
                        isLabelVisible: totalItems > 0,
                        label: Text('$totalItems'),
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                          qty: cart[meal['id']] ?? 0,
                          onAdd: () => _add(meal['id'] as String),
                          onRemove: () => _remove(meal['id'] as String),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: _goToCart,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: Text(
                'Checkout · \$${totalPrice.toStringAsFixed(2)} ($totalItems)',
              ),
            )
          : null,
    );
  }
}
