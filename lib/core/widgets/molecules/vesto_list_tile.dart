import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';

/// Tek tip liste satırı — leading, title, subtitle, trailing kombinasyonları.
/// Material ListTile'dan bağımsız: padding ve font tamamen Vesto sisteminden.
class VestoListTile extends StatelessWidget {
  const VestoListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  /// Icon, badge, chevron vb.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isDark = context.isDark;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: AppColors.onyxWithOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.pagePadding,
          vertical: spacing.md,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: spacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.pearl : AppColors.onyx,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: spacing.md),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
