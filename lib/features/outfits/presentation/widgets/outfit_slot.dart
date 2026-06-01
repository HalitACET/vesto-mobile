import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';

class OutfitSlot extends ConsumerWidget {
  final ItemCategory category;
  final String? itemId;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final double? height;
  final double? width;

  final void Function(String)? onSelected;
  final bool readOnly;

  const OutfitSlot({
    super.key,
    required this.category,
    this.itemId,
    required this.onTap,
    required this.onRemove,
    this.onSelected,
    this.height,
    this.width,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = itemId != null ? ref.watch(wardrobeItemStreamProvider(itemId!)) : null;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !readOnly,
      onAcceptWithDetails: (details) {
        if (!readOnly) onSelected?.call(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = !readOnly && candidateData.isNotEmpty;

        return GestureDetector(
          onTap: readOnly ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: isHovering ? AppColors.mist.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHovering ? AppColors.onyx : (itemId != null ? AppColors.mist : AppColors.stone.withValues(alpha: 0.3)),
                width: isHovering ? 2 : 1,
                style: BorderStyle.solid,
              ),
            ),
            child: itemId == null
                ? _buildPlaceholder()
                : _buildContent(itemAsync as AsyncValue<WardrobeItem?>),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add, color: AppColors.stone),
        const SizedBox(height: 4),
        Text(
          _getLabel(),
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.stone,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(AsyncValue<WardrobeItem?> itemAsync) {
    return Stack(
      children: [
        itemAsync.when(
          data: (item) => item != null 
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: CachedNetworkImage(
                  // bgRemovedUrl varsa onu kullan (transparent PNG) — yoksa orijinal
                  imageUrl: item.bgRemovedUrl ?? item.imageUrl ?? '',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,   // contain: transparent bg ile daha iyi görünür
                  placeholder: (context, url) => Container(color: AppColors.pearl),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            : const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, _) => const Center(child: Icon(Icons.error)),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: readOnly
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: () {
                    onRemove();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
        ),
      ],
    );
  }

  String _getLabel() {
    switch (category) {
      case ItemCategory.top:
        return 'ÜST';
      case ItemCategory.bottom:
        return 'ALT';
      case ItemCategory.footwear:
        return 'AYAKKABI';
      case ItemCategory.accessory:
        return 'AKSESUAR';
      default:
        return '';
    }
  }
}
