import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/features/wardrobe/data/models/ai_analysis.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';

/// Tek bir kıyafet kartı — grid ve list modu destekler.
///
/// UploadStatus davranışı:
///   uploading → thumbnail üstünde shimmer overlay + "Yükleniyor" badge
///   failed    → thumbnail üstünde kırmızı overlay + "Hata" badge
///   ready     → normal thumbnail gösterimi
class WardrobeItemCard extends StatelessWidget {
  const WardrobeItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
    this.isListMode = false,
    this.isSuitableForToday = false,
  });

  final WardrobeItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isListMode;
  final bool isSuitableForToday;

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: radius.smBorderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.onyxWithOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isListMode 
            ? _ListLayout(item: item, isSuitable: isSuitableForToday) 
            : _GridLayout(item: item, isSuitable: isSuitableForToday),
      ),
    );
  }
}

// ── Grid Layout ───────────────────────────────────────────────────────────────

class _GridLayout extends StatelessWidget {
  const _GridLayout({required this.item, required this.isSuitable});
  final WardrobeItem item;
  final bool isSuitable;

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail — 1:1 oranı AspectRatio ile sağlanır
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: radius.smBorderRadius.topLeft,
              topRight: radius.smBorderRadius.topRight,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ThumbnailImage(item: item),
                _UploadOverlay(status: item.uploadStatus),
                Positioned(
                  top: 6,
                  left: 6,
                  child: _VisibilityBadge(isPublic: item.isPublic),
                ),
                if (item.aiAnalysis != null)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: _ColorDots(colors: item.aiAnalysis!.dominantColors),
                  ),
                if (isSuitable)
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: _SuitableBadge(),
                  ),
              ],
            ),
          ),
        ),
        // Bilgi alanı
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.brand != null)
                Text(
                  item.brand!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onyx,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  item.subcategory,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onyx,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              Text(
                '${item.category.displayLabel} · ${item.subcategory}',
                style: AppTypography.bodySmall.copyWith(fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── List Layout ───────────────────────────────────────────────────────────────

class _ListLayout extends StatelessWidget {
  const _ListLayout({required this.item, required this.isSuitable});
  final WardrobeItem item;
  final bool isSuitable;

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;

    return SizedBox(
      height: 80,
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: radius.smBorderRadius.topLeft,
              bottomLeft: radius.smBorderRadius.bottomLeft,
            ),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ThumbnailImage(item: item),
                  _UploadOverlay(status: item.uploadStatus),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _VisibilityBadge(isPublic: item.isPublic),
                  ),
                  if (item.aiAnalysis != null)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: _ColorDots(
                        colors: item.aiAnalysis!.dominantColors,
                        dotSize: 6,
                        spacing: 2,
                      ),
                    ),
                  if (isSuitable)
                    const Positioned(
                      top: 4,
                      left: 4,
                      child: _SuitableBadge(isSmall: true),
                    ),
                ],
              ),
            ),
          ),
          // Bilgi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.brand != null)
                    Text(
                      item.brand!,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    '${item.category.displayLabel} · ${item.subcategory}',
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.size != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.size!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.stone,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Arrow hint
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.mist,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thumbnail Image ───────────────────────────────────────────────────────────

class _ThumbnailImage extends StatelessWidget {
  const _ThumbnailImage({required this.item});
  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    final url = item.thumbnailUrl ?? item.imageUrl;

    if (url == null) {
      // Henüz URL yok (uploading veya failed)
      return Container(
        color: AppColors.pearl,
        child: const Center(
          child: Icon(Icons.checkroom_outlined, color: AppColors.mist, size: 32),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => Shimmer.fromColors(
        baseColor: AppColors.mist,
        highlightColor: AppColors.pearl,
        child: Container(color: AppColors.mist),
      ),
      errorWidget: (_, _, _) => Container(
        color: AppColors.pearl,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: AppColors.stone, size: 24),
        ),
      ),
    );
  }
}

// ── Upload Status Overlay ─────────────────────────────────────────────────────

class _UploadOverlay extends StatelessWidget {
  const _UploadOverlay({required this.status});
  final UploadStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == UploadStatus.ready) return const SizedBox.shrink();

    final isUploading = status == UploadStatus.uploading;

    return Positioned(
      bottom: 6,
      left: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isUploading
              ? AppColors.onyxWithOpacity(0.75)
              : AppColors.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUploading)
              const SizedBox(
                width: 8,
                height: 8,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.pearl,
                ),
              )
            else
              const Icon(Icons.error_outline, size: 8, color: AppColors.pearl),
            const SizedBox(width: 4),
            Text(
              isUploading ? 'Yükleniyor' : 'Hata',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.pearl,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI Color Dots ─────────────────────────────────────────────────────────────

class _ColorDots extends StatelessWidget {
  const _ColorDots({
    required this.colors,
    this.dotSize = 8,
    this.spacing = 3,
  });

  final List<DominantColor> colors;
  final double dotSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    // En yüksek yüzdeli 3 renk
    final displayColors = colors.take(3).toList();
    if (displayColors.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: displayColors.map<Widget>((c) {
        final color = _parseHex(c.hex);
        return Container(
          margin: EdgeInsets.only(left: spacing),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.onyxWithOpacity(0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _parseHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return Colors.transparent;
    }
  }
}

class _SuitableBadge extends StatelessWidget {
  final bool isSmall;

  const _SuitableBadge({this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 4 : 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50), // Nature Green
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny, size: isSmall ? 8 : 10, color: AppColors.white),
          if (!isSmall) ...[
            const SizedBox(width: 4),
            const Text(
              'BUGÜN',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.isPublic});
  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.onyxWithOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isPublic ? Icons.public : Icons.lock_outline,
        size: 10,
        color: isPublic ? const Color(0xFFFFD700) : AppColors.white,
      ),
    );
  }
}
