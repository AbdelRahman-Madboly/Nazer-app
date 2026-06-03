// lib/theme/app_colors.dart
// Barrel re-export so screens can import '../theme/app_colors.dart'
// while the full theme (fonts, ThemeData) stays in app_theme.dart.
//
// If AppColors is defined in app_theme.dart, this file re-exports it.
// If it's inlined here, app_theme.dart should import this file instead.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bgDark    = Color(0xFF0A0E1A);
  static const Color bgCard    = Color(0xFF111827);
  static const Color bgSurface = Color(0xFF1F2937);

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary   = Color(0xFF00D4FF);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success   = Color(0xFF22C55E);
  static const Color warning   = Color(0xFFF59E0B);
  static const Color danger    = Color(0xFFEF4444);
  static const Color info      = Color(0xFF3B82F6);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted     = Color(0xFF6B7280);

  // ── Border ────────────────────────────────────────────────────────────────
  static const Color border    = Color(0xFF374151);
}