import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Spacing scale — moda dergisi geniş whitespace felsefesi.
/// Tüm layout padding/margin değerleri buradan çekilir, hard-code yasak.
class VestoSpacing extends ThemeExtension<VestoSpacing> {
  const VestoSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.xxl = 48,
    this.pagePadding = 24,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  /// Ekran kenar padding — tüm sayfalarda tutarlı yan boşluk.
  final double pagePadding;

  @override
  VestoSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? pagePadding,
  }) {
    return VestoSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      pagePadding: pagePadding ?? this.pagePadding,
    );
  }

  @override
  VestoSpacing lerp(ThemeExtension<VestoSpacing>? other, double t) {
    if (other is! VestoSpacing) return this;
    return VestoSpacing(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      pagePadding: lerpDouble(pagePadding, other.pagePadding, t)!,
    );
  }
}
