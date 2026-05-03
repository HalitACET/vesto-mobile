import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/theme_extensions.dart';

/// Flat kart — kesinlikle gölge yok, sadece 1px border.
/// Moda dergisi estetiği: içerik öne çıkar, konteyner geri çekilir.
class VestoCard extends StatelessWidget {
  const VestoCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.noPadding = false,
  });

  final Widget child;

  /// Varsayılan: spacing.lg (24px). Sıfırlamak için noPadding: true.
  final EdgeInsetsGeometry? padding;
  final bool noPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final spacing = context.spacing;
    final radius = context.radius;

    final effectivePadding =
        noPadding ? EdgeInsets.zero : padding ?? EdgeInsets.all(spacing.lg);

    return Material(
      color: isDark ? AppColors.charcoal : AppColors.white,
      borderRadius: radius.mdBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius.mdBorderRadius,
        splashColor: Colors.transparent,
        highlightColor: AppColors.onyxWithOpacity(0.04),
        child: Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            borderRadius: radius.mdBorderRadius,
            border: Border.all(
              color: isDark ? AppColors.graphite : AppColors.mist,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
