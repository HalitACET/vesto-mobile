import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

class ForumEmptyState extends StatelessWidget {
  const ForumEmptyState({super.key});

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
              decoration: const BoxDecoration(
                color: AppColors.pearl,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 48,
                color: AppColors.stone,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz Paylaşım Yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Cormorant',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Forumda henüz kombin paylaşılmamış.\nİlk paylaşımı sen yap ve stiline ilham ver!',
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
