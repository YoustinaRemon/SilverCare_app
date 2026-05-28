import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../theme/app_theme.dart';

class ManageMealsTab extends StatefulWidget {
  const ManageMealsTab({super.key});
  @override
  State<ManageMealsTab> createState() => _ManageMealsTabState();
}

class _ManageMealsTabState extends State<ManageMealsTab> {
  final _supabase = Supabase.instance.client;
  bool _loading = true;
  List<Map<String, dynamic>> _meals = [];

  // قايمة التصنيفات المتاحة
  final List<String> _categories = [
    'General',
    'Diabetic',
    'Low Sodium',
    'Elderly Soft',
    'Cholesterol-Friendly'
  ];

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    setState(() => _loading = true);
    try {
      final data = await _supabase
          .from('meals')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _meals = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching meals: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus(dynamic id, bool isAvailable) async {
    try {
      setState(() {
        final index = _meals.indexWhere((m) => m['id'] == id);
        if (index != -1) _meals[index]['is_available'] = isAvailable;
      });

      await _supabase
          .from('meals')
          .update({'is_available': isAvailable}).eq('id', id);
    } catch (e) {
      _fetchMeals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error updating status: $e'),
              backgroundColor: AppTheme.destructive),
        );
      }
    }
  }

  Future<void> _deleteMeal(dynamic id) async {
    try {
      await _supabase.from('meals').delete().eq('id', id);
      _fetchMeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error deleting meal: $e'),
              backgroundColor: AppTheme.destructive),
        );
      }
    }
  }

  // ⬅️ تم تحديث نافذة الإضافة بالخانات الجديدة
  void _addMealDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final caloriesCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    String selectedCategory = 'General';
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.restaurant_menu, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text('Add New Meal'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            // استخدمنا ScrollView عشان الشاشة متضربش لو الكيبورد فتح
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Meal Name'.tr(),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          decoration: InputDecoration(
                            labelText: 'Price (\$)'.tr(),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: caloriesCtrl,
                          decoration: InputDecoration(
                            labelText: 'Calories (kcal)'.tr(),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category'.tr(),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedCategory = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageCtrl,
                    decoration: InputDecoration(
                      labelText: 'Image URL'.tr(),
                      hintText: 'https://...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.image_outlined),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: Text('Cancel'.tr(),
                    style: const TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final name = nameCtrl.text.trim();
                        final price = double.tryParse(priceCtrl.text.trim());
                        final calories =
                            int.tryParse(caloriesCtrl.text.trim()) ?? 0;
                        final image = imageCtrl.text.trim();

                        if (name.isEmpty || price == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please enter name and valid price')),
                          );
                          return;
                        }

                        setDialogState(() => isSaving = true);

                        try {
                          await _supabase.from('meals').insert({
                            'name': name,
                            'price': price,
                            'calories': calories,
                            'category': selectedCategory,
                            'image': image,
                            'is_available': true,
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            _fetchMeals();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Meal added successfully!'),
                                  backgroundColor: Colors.green),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppTheme.destructive),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Add'.tr()),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMealDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Meal'.tr(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchMeals,
              child: _meals.isEmpty
                  ? Center(
                      child: Text('No meals found. Add some!'.tr(),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 16)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 24, bottom: 80),
                      itemCount: _meals.length,
                      itemBuilder: (context, i) {
                        final meal = _meals[i];
                        final isAvail = meal['is_available'] == true;
                        final category = meal['category'] ?? 'General';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: AppTheme.border.withValues(alpha: 0.5)),
                          ),
                          elevation: 0,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (isAvail ? AppTheme.primary : Colors.grey)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.restaurant,
                                  color:
                                      isAvail ? AppTheme.primary : Colors.grey),
                            ),
                            title: Text(
                              meal['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                decoration: isAvail
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                                color: isAvail ? Colors.black87 : Colors.grey,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '\$${meal['price']} • $category', // ⬅️ عرضنا التصنيف للأدمن
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: isAvail,
                                  activeThumbColor: Colors.green,
                                  onChanged: (val) =>
                                      _toggleStatus(meal['id'], val),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppTheme.destructive),
                                  onPressed: () => _deleteMeal(meal['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
