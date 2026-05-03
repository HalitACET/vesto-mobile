import 'package:flutter/material.dart';

abstract class AppColors {
  // --- Gri Palet (Lüks Moda Dergisi) ---
  static const Color onyx = Color(0xFF0A0A0A);      // Primary, en koyu
  static const Color charcoal = Color(0xFF1F1F1F);  // Surface dark, card bg
  static const Color graphite = Color(0xFF404040);  // Border, divider
  static const Color stone = Color(0xFF737373);     // Secondary text, placeholder
  static const Color mist = Color(0xFFD4D4D4);      // Disabled, subtle border
  static const Color pearl = Color(0xFFF5F5F5);     // Background light
  static const Color white = Color(0xFFFFFFFF);     // Pure white

  // --- Semantik Renkler ---
  static const Color error = Color(0xFF9B2226);     // Koyu kırmızı — minimal kullanım
  static const Color success = Color(0xFF386641);   // Koyu yeşil — minimal kullanım

  // --- Şeffaflıklar (overlay'ler için) ---
  static Color onyxWithOpacity(double opacity) => onyx.withValues(alpha: opacity);
  static Color whiteWithOpacity(double opacity) => white.withValues(alpha: opacity);
}
