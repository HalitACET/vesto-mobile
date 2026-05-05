import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';

/// 4 seviyeli şifre gücü göstergesi.
/// Renk geçişi: Mist → Stone → Graphite → Onyx (kırmızı yok, lüks estetik).
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.password});

  final String password;

  PasswordStrength get _strength {
    final len = password.length;
    if (len == 0) return PasswordStrength.none;
    if (len < 4) return PasswordStrength.weak;
    if (len < 6) return PasswordStrength.fair;
    if (len < 8) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength;
    if (strength == PasswordStrength.none) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < strength.level;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled ? strength.color : AppColors.mist,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          strength.label,
          style: AppTypography.labelSmall.copyWith(
            color: strength.color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

enum PasswordStrength {
  none(0, '', AppColors.mist),
  weak(1, 'Zayıf', AppColors.stone),
  fair(2, 'Orta', AppColors.graphite),
  good(3, 'İyi', AppColors.charcoal),
  strong(4, 'Güçlü', AppColors.onyx);

  const PasswordStrength(this.level, this.label, this.color);

  final int level;
  final String label;
  final Color color;
}
