import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF38A256);
  static const Color primaryDark = Color(0xFF2A7A40);
  static const Color primaryLight = Color(0xFF5BBD74);
  static const Color primarySurface = Color(0xFFE8F5EC); // خلفية فاتحة خضرا

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF38A256);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2196F3);

  // Border
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocus = Color(0xFF38A256);
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    scaffoldBackgroundColor: AppColors.background,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 54),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // TextField
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Cairo',
        color: AppColors.textLight,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Cairo',
        color: AppColors.textLight,
        fontSize: 14,
      ),
    ),

    // Text
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textMedium,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMedium,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      ),
    ),
  );
}
