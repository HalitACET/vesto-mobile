import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';

enum VestoSnackBarType { info, success, error }

/// ScaffoldMessenger wrapper — Charcoal zemin, Pearl metin, floating davranış.
/// Static helper: widget tree'den bağımsız çağrılır.
abstract class VestoSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    VestoSnackBarType type = VestoSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final icon = switch (type) {
      VestoSnackBarType.info => Icons.info_outline,
      VestoSnackBarType.success => Icons.check_circle_outline,
      VestoSnackBarType.error => Icons.error_outline,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.charcoal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          content: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.mist),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.pearl,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel.toUpperCase(),
                  textColor: AppColors.pearl,
                  onPressed: onAction ?? () {},
                )
              : null,
        ),
      );
  }
}
