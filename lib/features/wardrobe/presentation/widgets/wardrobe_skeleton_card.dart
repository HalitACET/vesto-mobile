import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/theme_extensions.dart';

/// Yükleme sırasında gösterilen shimmer placeholder — grid ve list moddaki
/// WardrobeItemCard ile aynı boyut oranını korur.
class WardrobeSkeletonCard extends StatelessWidget {
  const WardrobeSkeletonCard({super.key, this.isListMode = false});

  final bool isListMode;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.mist,
      highlightColor: AppColors.pearl,
      child:
          isListMode ? _ListSkeleton(context: context) : _GridSkeleton(context: context),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    final radius = context.radius;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: radius.smBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail alanı
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.only(
                  topLeft: radius.smBorderRadius.topLeft,
                  topRight: radius.smBorderRadius.topRight,
                ),
              ),
            ),
          ),
          // Bilgi alanı
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 10, width: 80, color: AppColors.mist),
                  const SizedBox(height: 6),
                  Container(height: 8, width: 56, color: AppColors.mist),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    final radius = context.radius;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: radius.smBorderRadius,
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.only(
                topLeft: radius.smBorderRadius.topLeft,
                bottomLeft: radius.smBorderRadius.bottomLeft,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Bilgi
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 10, width: 100, color: AppColors.mist),
              const SizedBox(height: 6),
              Container(height: 8, width: 70, color: AppColors.mist),
            ],
          ),
        ],
      ),
    );
  }
}
