import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';

/// 1px ince çizgi — moda dergisi geometrik bölümlendirme.
/// Padding sıfır: parent widget boşluğu yönetir.
class VestoDivider extends StatelessWidget {
  const VestoDivider({super.key, this.vertical = false});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.graphite : AppColors.mist;

    if (vertical) {
      return Container(width: 1, color: color);
    }
    return Container(height: 1, color: color);
  }
}
