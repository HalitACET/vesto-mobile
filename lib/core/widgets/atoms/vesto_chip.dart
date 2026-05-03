import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';

/// Filtre chip'i — kategori seçimi, etiket filtreleme için.
/// Selected: Onyx/Pearl (bold seçim); unselected: sade çerçeveli.
class VestoChip extends StatelessWidget {
  const VestoChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;

    final bg = selected ? AppColors.onyx : Colors.transparent;
    final border = selected ? AppColors.onyx : AppColors.graphite;
    final textColor = selected ? AppColors.pearl : AppColors.onyx;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius.fullBorderRadius,
          border: Border.all(color: border, width: 1),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(color: textColor),
        ),
      ),
    );
  }
}
