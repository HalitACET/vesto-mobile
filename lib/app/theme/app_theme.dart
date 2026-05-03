import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_durations.dart';
import 'package:mobile/app/theme/app_radius.dart';
import 'package:mobile/app/theme/app_spacing.dart';
import 'package:mobile/app/theme/app_typography.dart';

abstract class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.pearl,
      colorScheme: const ColorScheme.light(
        primary: AppColors.onyx,
        onPrimary: AppColors.white,
        secondary: AppColors.graphite,
        onSecondary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.onyx,
        error: AppColors.error,
        outline: AppColors.mist,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      cardTheme: _buildCardTheme(),
      dividerTheme: const DividerThemeData(
        color: AppColors.mist,
        thickness: 0.5,
        space: 0,
      ),
      extensions: const [
        VestoSpacing(),
        VestoRadius(),
        VestoDurations(),
      ],
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.onyx,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.white,
        onPrimary: AppColors.onyx,
        secondary: AppColors.mist,
        onSecondary: AppColors.onyx,
        surface: AppColors.charcoal,
        onSurface: AppColors.white,
        error: AppColors.error,
        outline: AppColors.graphite,
      ),
      textTheme: _buildTextTheme(dark: true),
      appBarTheme: _buildAppBarTheme(dark: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(dark: true),
      outlinedButtonTheme: _buildOutlinedButtonTheme(dark: true),
      inputDecorationTheme: _buildInputDecorationTheme(dark: true),
      cardTheme: _buildCardTheme(dark: true),
      dividerTheme: const DividerThemeData(
        color: AppColors.graphite,
        thickness: 0.5,
        space: 0,
      ),
      extensions: const [
        VestoSpacing(),
        VestoRadius(),
        VestoDurations(),
      ],
    );
  }

  static TextTheme _buildTextTheme({bool dark = false}) {
    final color = dark ? AppColors.white : AppColors.onyx;
    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: color),
      displayMedium: AppTypography.displayMedium.copyWith(color: color),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: color),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: color),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: color),
      titleLarge: AppTypography.titleLarge.copyWith(color: color),
      titleMedium: AppTypography.titleMedium.copyWith(color: color),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: color),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: color),
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge.copyWith(color: color),
      labelMedium: AppTypography.labelMedium.copyWith(color: color),
      labelSmall: AppTypography.labelSmall,
    );
  }

  static AppBarTheme _buildAppBarTheme({bool dark = false}) {
    return AppBarTheme(
      backgroundColor: dark ? AppColors.onyx : AppColors.white,
      foregroundColor: dark ? AppColors.white : AppColors.onyx,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headlineMedium.copyWith(
        color: dark ? AppColors.white : AppColors.onyx,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme({bool dark = false}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: dark ? AppColors.white : AppColors.onyx,
        foregroundColor: dark ? AppColors.onyx : AppColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 0,
        textStyle: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme({bool dark = false}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: dark ? AppColors.white : AppColors.onyx,
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(
          color: dark ? AppColors.graphite : AppColors.mist,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme({bool dark = false}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: dark ? AppColors.charcoal : AppColors.pearl,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: dark ? AppColors.graphite : AppColors.mist,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: dark ? AppColors.graphite : AppColors.mist,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: dark ? AppColors.white : AppColors.onyx,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
      labelStyle: AppTypography.bodySmall.copyWith(
        color: dark ? AppColors.mist : AppColors.stone,
      ),
    );
  }

  static CardThemeData _buildCardTheme({bool dark = false}) {
    return CardThemeData(
      color: dark ? AppColors.charcoal : AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: dark ? AppColors.graphite : AppColors.mist,
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.zero,
    );
  }
}
