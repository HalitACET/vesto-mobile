import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_durations.dart';
import 'package:mobile/app/theme/app_radius.dart';
import 'package:mobile/app/theme/app_spacing.dart';

/// BuildContext üzerinden tema değerlerine kısa yoldan erişim.
/// Kullanım: context.spacing.lg, context.radius.sm, context.durations.fast
extension VestoTheme on BuildContext {
  VestoSpacing get spacing => Theme.of(this).extension<VestoSpacing>()!;
  VestoRadius get radius => Theme.of(this).extension<VestoRadius>()!;
  VestoDurations get durations => Theme.of(this).extension<VestoDurations>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
