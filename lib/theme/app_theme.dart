import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Light Mode - Matches Web Navy/Slate look)
  static const Color primary = Color(0xFF1E3A8A); // Navy Blue (Logo & Headings)
  static const Color secondary = Color(0xFF64748B); // Slate gray
  static const Color destructive = Color(0xFFEF4444); // SOS Red
  static const Color amber = Color(0xFFC2A052); // Muted Gold (Ambulance button)

  // Dark Mode Accent Colors
  static const Color darkPrimary =
      Color(0xFF60A5FA); // Light Blue for Dark Mode (بدون أي أخضر)

  // Neutral palette (Light Mode)
  static const Color background = Color(0xFFF8FAFC); // Off-white/Light Slate
  static const Color surface = Color(0xFFFFFFFF); // White Appbar/Sidebar
  static const Color cardBg = Color(0xFFFFFFFF); // White Cards
  static const Color muted =
      Color(0xFFF1F5F9); // Very light gray (Active tab/Hover)
  static const Color mutedFg = Color(0xFF64748B); // Slate text
  static const Color border = Color(0xFFE2E8F0); // Subtle borders
  static const Color foreground =
      Color(0xFF0F172A); // Dark Slate for normal text

  // Neutral palette (Dark Mode)
  static const Color darkBg = Color(0xFF0F172A); // Deep Slate Blue
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkFg = Color(0xFFF8FAFC);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      error: destructive,
      background: background,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: foreground,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary, // Navy for medium headings
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: foreground),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: foreground),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: mutedFg),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withValues(alpha: .08),
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      iconTheme: const IconThemeData(color: primary),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: muted,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: primary);
        }
        return GoogleFonts.inter(fontSize: 12, color: mutedFg);
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkPrimary,
      brightness: Brightness.dark,
      primary: darkPrimary,
      secondary: secondary,
      error: destructive,
      background: darkBg,
      surface: darkSurface,
    ),
    scaffoldBackgroundColor: darkBg,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: darkPrimary,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkPrimary,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkFg,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkFg,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: darkFg),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: darkFg),
      bodySmall:
          GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      elevation: 0,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: darkPrimary,
      ),
      iconTheme: const IconThemeData(color: darkPrimary),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkSurface,
      indicatorColor: darkPrimary.withValues(alpha: .12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: darkPrimary);
        }
        return GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8));
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F172A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
