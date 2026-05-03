import 'package:flutter/material.dart';

/// Animasyon süresi sabitleri — micro-interactions için merkezi kaynak.
/// Moda dergisi: hızlı ve öz. Uzun animasyonlar ucuz hissettirir.
class VestoDurations extends ThemeExtension<VestoDurations> {
  const VestoDurations({
    this.fast = const Duration(milliseconds: 150),
    this.medium = const Duration(milliseconds: 250),
    this.slow = const Duration(milliseconds: 400),
  });

  final Duration fast;
  final Duration medium;
  final Duration slow;

  @override
  VestoDurations copyWith({
    Duration? fast,
    Duration? medium,
    Duration? slow,
  }) {
    return VestoDurations(
      fast: fast ?? this.fast,
      medium: medium ?? this.medium,
      slow: slow ?? this.slow,
    );
  }

  @override
  VestoDurations lerp(ThemeExtension<VestoDurations>? other, double t) {
    if (other is! VestoDurations) return this;
    return VestoDurations(
      fast: _lerpDuration(fast, other.fast, t),
      medium: _lerpDuration(medium, other.medium, t),
      slow: _lerpDuration(slow, other.slow, t),
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) {
    return Duration(
      microseconds:
          (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t)
              .round(),
    );
  }
}
