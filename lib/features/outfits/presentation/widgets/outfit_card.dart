import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/outfits/data/models/outfit.dart';
import 'package:mobile/features/outfits/data/models/outfit_items.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';

class OutfitCard extends ConsumerWidget {
  final Outfit outfit;
  final VoidCallback onTap;

  const OutfitCard({
    super.key,
    required this.outfit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(wardrobeItemsByIdsProvider(outfit.items.allItemIds.join(',')));

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini Collage Grid (2x2)
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.pearl,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mist),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  itemsAsync.when(
                    data: (items) {
                      if (items.isEmpty) return const Center(child: Icon(Icons.checkroom, color: AppColors.stone));
                      
                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          // Map slots: 0:Top, 1:Bottom, 2:Shoes, 3:Accessory
                          String? itemId;
                          if (index == 0) {
                            itemId = outfit.items.topId;
                          } else if (index == 1) {
                            itemId = outfit.items.bottomId;
                          } else if (index == 2) {
                            itemId = outfit.items.shoesId;
                          } else if (index == 3) {
                            itemId = outfit.items.accessoryId;
                          }

                          if (itemId == null) {
                            return Container(color: AppColors.pearl.withValues(alpha: 0.5));
                          }

                          final item = items.cast<WardrobeItem?>().firstWhere(
                            (i) => i?.id == itemId,
                            orElse: () => null,
                          );
                          if (item == null) {
                            return Container(color: AppColors.pearl);
                          }

                          return CachedNetworkImage(
                            imageUrl: item.imageUrl ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: AppColors.pearl),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, _) => const Center(child: Icon(Icons.error)),
                  ),
                  
                  // Favorite Heart
                  if (outfit.isFavorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Outfit Name
          Text(
            outfit.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.onyx,
            ),
          ),
          const SizedBox(height: 2),
          // Stats
          Text(
            '${outfit.wearCount} kez giyildi${outfit.lastWorn != null ? ' • ${DateFormat('d MMM').format(outfit.lastWorn!)}' : ''}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.stone,
            ),
          ),
        ],
      ),
    );
  }
}
