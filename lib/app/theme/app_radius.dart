import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Border radius scale — keskin ve minimal. Moda dergisi yuvarlak değil, geometrik.
/// xs/sm: butonlar ve input'lar, md: kartlar, full: pill/chip.
class VestoRadius extends ThemeExtension<VestoRadius> {
  const VestoRadius({
    this.xs = 2,
    this.sm = 4,
    this.md = 8,
    this.lg = 16,
    this.full = 999,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double full;

  BorderRadius get xsBorderRadius => BorderRadius.circular(xs);
  BorderRadius get smBorderRadius => BorderRadius.circular(sm);
  BorderRadius get mdBorderRadius => BorderRadius.circular(md);
  BorderRadius get lgBorderRadius => BorderRadius.circular(lg);
  BorderRadius get fullBorderRadius => BorderRadius.circular(full);

  @override
  VestoRadius copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? full,
  }) {
    return VestoRadius(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      full: full ?? this.full,
    );
  }

  @override
  VestoRadius lerp(ThemeExtension<VestoRadius>? other, double t) {
    if (other is! VestoRadius) return this;
    return VestoRadius(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      full: lerpDouble(full, other.full, t)!,
    );
  }
}
