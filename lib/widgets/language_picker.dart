import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale =
        EasyLocalization.of(context)?.locale.languageCode ?? 'en';

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language_rounded, color: AppTheme.primary),
      tooltip: 'Change Language',
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 40),
      onSelected: (String langCode) async {
        await context.setLocale(Locale(langCode));
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildMenuItem('en', '🇺🇸', 'English', currentLocale),
        _buildMenuItem('ar', '🇪🇬', 'العربية', currentLocale),
        _buildMenuItem('fr', '🇫🇷', 'Français', currentLocale),
        _buildMenuItem('de', '🇩🇪', 'Deutsch', currentLocale),
        _buildMenuItem('it', '🇮🇹', 'Italiano', currentLocale),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      String code, String flag, String name, String currentLocale) {
    final isSelected = code == currentLocale;
    return PopupMenuItem<String>(
      value: code,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: .1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.foreground,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.primary, size: 18),
            ]
          ],
        ),
      ),
    );
  }
}
