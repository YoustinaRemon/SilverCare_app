import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../theme/app_theme.dart';

class SosFilterRow extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onFilterChanged;

  const SosFilterRow({
    super.key,
    required this.selectedStatus,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['active', 'resolved', 'all'].map((status) {
          final isSelected = selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status.toUpperCase().tr()),
              selected: isSelected,
              selectedColor:
                  status == 'active' ? AppTheme.destructive : AppTheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              onSelected: (_) => onFilterChanged(status),
            ),
          );
        }).toList(),
      ),
    );
  }
}
