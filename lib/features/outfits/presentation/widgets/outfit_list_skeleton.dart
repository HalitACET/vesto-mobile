import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobile/app/theme/app_colors.dart';

class OutfitListSkeleton extends StatelessWidget {
  const OutfitListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero skeleton
          Shimmer.fromColors(
            baseColor: AppColors.mist,
            highlightColor: Colors.white,
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Grid skeleton
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 4,
            itemBuilder: (_, _) => Shimmer.fromColors(
              baseColor: AppColors.mist,
              highlightColor: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
