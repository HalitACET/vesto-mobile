import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobile/app/theme/app_colors.dart';

class PublicProfileSkeleton extends StatelessWidget {
  const PublicProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.mist,
      highlightColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            color: AppColors.mist,
          ),
          const SizedBox(height: 16),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (_) => Container(
                width: 60,
                height: 40,
                color: AppColors.mist,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
