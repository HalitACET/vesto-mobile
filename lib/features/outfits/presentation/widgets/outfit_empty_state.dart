import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

class OutfitEmptyState extends StatelessWidget {
  const OutfitEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.pearl,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checkroom_outlined,
                size: 48,
                color: AppColors.stone,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz outfit oluşturmadın',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'İlk kombinini oluşturmak için + butonuna bas.\nGardırobunu canlandırmaya başla!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.stone,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
