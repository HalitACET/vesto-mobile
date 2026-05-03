import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/app/theme/app_colors.dart';

/// Tipografi hiyerarşisi — Vogue/Harper's Bazaar referans.
/// Başlıklar: Cormorant Serif (lokal, dramatik ve zarif)
/// Body/Label: Inter Sans-serif (okunaklı, modern, nötr)
abstract class AppTypography {
  // ── Serif Başlıklar (Cormorant) ──────────────────────────────────────────

  static TextStyle displayLarge = const TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 48,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.0,
    height: 1.1,
    color: AppColors.onyx,
  );

  static TextStyle displayMedium = const TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    height: 1.15,
    color: AppColors.onyx,
  );

  static TextStyle headlineLarge = const TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
    height: 1.2,
    color: AppColors.onyx,
  );

  static TextStyle headlineMedium = const TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    height: 1.25,
    color: AppColors.onyx,
  );

  static TextStyle headlineSmall = const TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.3,
    color: AppColors.onyx,
  );

  // ── Sans-serif Title / Body (Inter) ──────────────────────────────────────

  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.onyx,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.onyx,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.6,
    color: AppColors.onyx,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.onyx,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.stone,
  );

  // ── Label — Uppercase + Letter-spacing (moda dergisi imzası) ─────────────
  // Kullanımda metni .toUpperCase() ile büyüt — Flutter'da textTransform yok.

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.0,
    color: AppColors.onyx,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.0,
    color: AppColors.onyx,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    height: 1.0,
    color: AppColors.stone,
  );
}
