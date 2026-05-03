import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';

/// Splash ekranı — go_router redirect'i auth durumunu beklerken burada kalır.
/// Herhangi bir business logic içermez; routing tamamen router.dart'ta yönetilir.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.onyx,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VESTO',
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.white,
                letterSpacing: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI WARDROBE',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.stone,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: AppColors.whiteWithOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
