import 'package:flutter/material.dart';

/// NAZER Design System
/// Colors sourced from globals.css / Guidelines.md
class AppColors {
  // Primary brand
  static const Color primary      = Color(0xFF00D4FF);  // Electric cyan
  static const Color primaryDark  = Color(0xFF0099CC);

  // Backgrounds
  static const Color bgDark       = Color(0xFF0A0E1A);  // Deep navy
  static const Color bgCard       = Color(0xFF111827);
  static const Color bgSurface    = Color(0xFF1F2937);

  // Status
  static const Color success      = Color(0xFF22C55E);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color danger       = Color(0xFFEF4444);
  static const Color info         = Color(0xFF3B82F6);

  // Text
  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textSecondary= Color(0xFF9CA3AF);
  static const Color textMuted    = Color(0xFF6B7280);

  // Borders
  static const Color border       = Color(0xFF374151);
  static const Color borderLight  = Color(0xFF4B5563);
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary:    AppColors.primary,
        secondary:  AppColors.primaryDark,
        surface:    AppColors.bgCard,
        error:      AppColors.danger,
        onPrimary:  AppColors.bgDark,
        onSecondary:AppColors.textPrimary,
        onSurface:  AppColors.textPrimary,
        onError:    AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted),
        labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.bgDark,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      dividerColor: AppColors.border,
      useMaterial3: true,
    );
  }

  static ThemeData light() => dark(); // Dark-only for now; Phase 6H may add light
}
