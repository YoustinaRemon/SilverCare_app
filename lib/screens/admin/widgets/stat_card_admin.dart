import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class StatCardAdmin extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isClickable;

  const StatCardAdmin({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
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
