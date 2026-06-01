import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/data/repositories/wardrobe_repository.dart';

part 'public_wardrobe_picker_sheet.g.dart';

@riverpod
Stream<List<WardrobeItem>> targetPublicWardrobe(Ref ref, String userId) {
  return ref.read(wardrobeRepositoryProvider).watchPublicItems(userId);
}

class PublicWardrobePickerSheet extends ConsumerWidget {
  final String targetUserId;
  final ItemCategory category;
  final Function(String?) onSelected;

  const PublicWardrobePickerSheet({
    super.key,
    required this.targetUserId,
    required this.category,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobeAsync = ref.watch(targetPublicWardrobeProvider(targetUserId));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getCategoryLabel(category),
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: wardrobeAsync.when(
                  data: (items) {
                    final filteredItems =
                        items.where((i) => i.category == category).toList();

                    if (filteredItems.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 48, color: AppColors.stone),
                            SizedBox(height: 16),
                            Text(
                              'Bu kategoride herkese açık kıyafet yok.',
                              style: TextStyle(color: AppColors.stone),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return GestureDetector(
                          onTap: () {
                            onSelected(item.id);
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.mist),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: item.bgRemovedUrl ?? item.imageUrl ?? '',
                              fit: BoxFit.contain,
                              errorWidget: (_, _, _) => CachedNetworkImage(
                                imageUrl: item.imageUrl ?? '',
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Hata: $e')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCategoryLabel(ItemCategory category) {
    switch (category) {
      case ItemCategory.top:
        return 'Üst Giyim Seç';
      case ItemCategory.bottom:
        return 'Alt Giyim Seç';
      case ItemCategory.footwear:
        return 'Ayakkabı Seç';
      case ItemCategory.accessory:
        return 'Aksesuar Seç';
      default:
        return 'Kıyafet Seç';
    }
  }
}
