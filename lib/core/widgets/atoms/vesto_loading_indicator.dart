import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';

/// Özel yükleme göstergesi — Material'ın kalın halkası yerine ince, zarif çizgi.
/// Stroke genişliği 1.5px ile "lightweight" bir his verir.
class VestoLoadingIndicator extends StatelessWidget {
  const VestoLoadingIndicator({
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 1.5,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.pearl
            : AppColors.onyx);

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );
  }
}
