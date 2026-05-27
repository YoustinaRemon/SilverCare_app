import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const MealCard({
    super.key,
    required this.meal,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image & Badge
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
          // Info (Name, Calories, Price, Add/Remove)
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
