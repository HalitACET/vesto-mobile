import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';

/// Boş liste / hata durumu için merkezi component.
/// Whitespace-first: fazla element değil, geniş nefes alanı.
class VestoEmptyState extends StatelessWidget {
  const VestoEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 48, color: AppColors.mist),
            SizedBox(height: spacing.lg),
          ],
          Text(
            title,
            style: AppTypography.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.sm),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: spacing.xl),
            VestoButton(
              label: actionLabel!,
              onPressed: onAction,
              size: VestoButtonSize.medium,
            ),
          ],
        ],
      ),
    );
  }
}
