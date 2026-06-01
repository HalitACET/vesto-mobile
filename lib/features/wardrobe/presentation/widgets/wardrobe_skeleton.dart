import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobile/app/theme/app_colors.dart';

class WardrobeSkeleton extends StatelessWidget {
  const WardrobeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const _WardrobeCardSkeleton(),
    );
  }
}

class _WardrobeCardSkeleton extends StatelessWidget {
  const _WardrobeCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.mist,
      highlightColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 80,
            color: AppColors.mist,
          ),
          const SizedBox(height: 4),
          Container(
            height: 10,
            width: 50,
            color: AppColors.mist,
          ),
        ],
      ),
    );
  }
}
