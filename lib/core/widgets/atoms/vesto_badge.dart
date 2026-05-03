import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';

/// Sayısal gösterge — bildirim sayısı, durum etiketi için.
/// Onyx zemin, Pearl metin: sert kontrastla göz dikkatini çeker.
class VestoBadge extends StatelessWidget {
  const VestoBadge({
    super.key,
    this.count,
    this.label,
    this.dot = false,
  }) : assert(
          dot || count != null || label != null,
          'dot=false ise count veya label gerekli',
        );

  /// Sayısal değer — 99 üzeri "99+" gösterir.
  final int? count;

  /// Metin etiketi (count yerine).
  final String? label;

  /// Sadece nokta göster, metin yok.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    if (dot) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.onyx,
          shape: BoxShape.circle,
        ),
      );
    }

    final text = count != null
        ? (count! > 99 ? '99+' : count.toString())
        : label ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.onyx,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.pearl,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
