import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PercentageRow extends StatelessWidget {
  final String title;
  final double percentage;
  final Color color;

  const PercentageRow({
    super.key,
    required this.title,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title.tr(),
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Text('${(percentage * 100).toInt()}%',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
