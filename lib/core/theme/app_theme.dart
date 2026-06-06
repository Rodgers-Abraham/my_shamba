import 'package:flutter/material.dart';

class AppTheme {
  // Define strict Light Mode colors
  static const Color primary = Color(0xFFFF5722); // Streak Flame/Primary
  static const Color success = Color(0xFF2E7D32); // Success Green
  static const Color warning = Color(0xFFFFF8E1); // Warning Amber (Light)
  static const Color warningDark = Color(0xFFF57F17); // Warning Amber (Dark)
  
  static const Color background = Color(0xFFF8F9FA); // Light grey background
  static const Color surface = Color(0xFFFFFFFF); // White canvas
  static const Color textPrimary = Color(0xFF1A1D20); // Charcoal Slate
  static const Color textSecondary = Color(0xFF757575); // Lighter text

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primary,
        surface: surface,
        error: Colors.red.shade700,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: IconThemeData(color: primary),
        selectedLabelTextStyle: TextStyle(color: primary),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        unselectedLabelTextStyle: TextStyle(color: textSecondary),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
