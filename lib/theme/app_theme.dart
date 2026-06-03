// lib/theme/app_theme.dart
// Phase 6H: Added proper light theme. Dark theme unchanged from Phase 6E.
//
// RULE: always import this file — never a separate app_colors.dart.
// AppColors contains both dark-mode constants (used by all screens) and
// light-mode constants (used by the light ThemeData only).

import 'package:flutter/material.dart';

// ── Color tokens ──────────────────────────────────────────────────────────────

/// Static color constants.
/// Dark-mode values are used directly by screen widgets (which are dark-only).
/// Light-mode values are exposed via AppColorsLight for use inside AppTheme.light().
class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF00D4FF);  // Electric cyan
  static const Color primaryDark  = Color(0xFF0099CC);  // Darker cyan (light theme)

  // ── Dark backgrounds ───────────────────────────────────────────────────────
  static const Color bgDark       = Color(0xFF0A0E1A);  // Deep navy
  static const Color bgCard       = Color(0xFF111827);
  static const Color bgSurface    = Color(0xFF1F2937);

  // ── Light backgrounds ──────────────────────────────────────────────────────
  static const Color bgLight      = Color(0xFFF8FAFC);
  static const Color bgCardLight  = Color(0xFFFFFFFF);
  static const Color bgSurfaceLight = Color(0xFFF1F5F9);

  // ── Status (shared) ────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF16A34A);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color danger       = Color(0xFFEF4444);
  static const Color dangerLight  = Color(0xFFDC2626);
  static const Color info         = Color(0xFF3B82F6);

  // ── Dark text ──────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted     = Color(0xFF6B7280);

  // ── Light text ─────────────────────────────────────────────────────────────
  static const Color textPrimaryLight   = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight     = Color(0xFF94A3B8);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const Color border       = Color(0xFF374151);
  static const Color borderLight  = Color(0xFFE2E8F0);
}

// ── Theme builder ─────────────────────────────────────────────────────────────

class AppTheme {
  // ── Dark ──────────────────────────────────────────────────────────────────
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary:     AppColors.primary,
        secondary:   AppColors.primaryDark,
        surface:     AppColors.bgCard,
        error:       AppColors.danger,
        onPrimary:   AppColors.bgDark,
        onSecondary: AppColors.textPrimary,
        onSurface:   AppColors.textPrimary,
        onError:     AppColors.textPrimary,
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
        centerTitle: false,
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
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.bgSurface,
        ),
      ),
      dividerColor: AppColors.border,
      useMaterial3: true,
    );
  }

  // ── Light ─────────────────────────────────────────────────────────────────
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      primaryColor: AppColors.primaryDark,
      colorScheme: const ColorScheme.light(
        primary:     AppColors.primaryDark,
        secondary:   AppColors.primary,
        surface:     AppColors.bgCardLight,
        error:       AppColors.dangerLight,
        onPrimary:   Colors.white,
        onSecondary: AppColors.textPrimaryLight,
        onSurface:   AppColors.textPrimaryLight,
        onError:     Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
        displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimaryLight),
        bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondaryLight),
        bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMutedLight),
        labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgCardLight,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.borderLight),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgCardLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCardLight,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primaryDark : AppColors.textMutedLight,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primaryDark.withValues(alpha: 0.35)
              : AppColors.bgSurfaceLight,
        ),
      ),
      dividerColor: AppColors.borderLight,
      useMaterial3: true,
    );
  }
}
