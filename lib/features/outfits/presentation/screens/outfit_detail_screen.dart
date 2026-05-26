import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/outfits/data/models/outfit.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:go_router/go_router.dart';

class OutfitDetailScreen extends ConsumerWidget {
  final Outfit outfit;

  const OutfitDetailScreen({super.key, required this.outfit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get full items details
    final itemIds = [
      outfit.items.topId,
      outfit.items.bottomId,
      outfit.items.shoesId,
      outfit.items.accessoryId
    ].whereType<String>().toList();

    final itemsAsync = ref.watch(wardrobeItemsByIdsProvider(itemIds.join(',')));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              outfit.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: outfit.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(outfitRepositoryProvider).toggleFavorite(outfit.id, outfit.isFavorite);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit.name,
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.pearl,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${outfit.wearCount} kez giyildi',
                          style: const TextStyle(fontSize: 12, color: AppColors.stone),
                        ),
                      ),
                      if (outfit.lastWorn != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          'Son: ${DateFormat('dd MMM yyyy').format(outfit.lastWorn!)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.stone),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Visual Canvas (Simplified for Detail)
            itemsAsync.when(
              data: (items) => _buildCanvas(items),
              loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Center(child: Text('Hata: $e')),
            ),

            const SizedBox(height: 32),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(outfitRepositoryProvider).markAsWorn(outfit);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Harika görünüyorsun! Giyim kaydedildi.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onyx,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('BUGÜN BUNU GİYDİM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/forum/share/${outfit.id}'),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('FORUM\'DA PAYLAŞ', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onyx,
                      side: const BorderSide(color: AppColors.onyx),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas(List<WardrobeItem> items) {
    // Map items back to slots
    final top = items.where((i) => i.id == outfit.items.topId).firstOrNull;
    final bottom = items.where((i) => i.id == outfit.items.bottomId).firstOrNull;
    final shoes = items.where((i) => i.id == outfit.items.shoesId).firstOrNull;
    final accessory = items.where((i) => i.id == outfit.items.accessoryId).firstOrNull;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (top != null) _buildItemRow('Üst Giyim', top),
          if (bottom != null) _buildItemRow('Alt Giyim', bottom),
          if (shoes != null) _buildItemRow('Ayakkabı', shoes),
          if (accessory != null) _buildItemRow('Aksesuar', accessory),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, WardrobeItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mist),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: item.imageUrl ?? '',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.stone, fontWeight: FontWeight.bold)),
              Text(
                item.subcategory.isNotEmpty ? item.subcategory : item.category.displayLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              if (item.brand != null)
                Text(item.brand!, style: const TextStyle(fontSize: 14, color: AppColors.stone)),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kombini Sil?'),
        content: const Text('Bu kombini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('VAZGEÇ')),
          TextButton(
            onPressed: () {
              ref.read(outfitRepositoryProvider).deleteOutfit(outfit.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from detail
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('SİL'),
          ),
        ],
      ),
    );
  }
}
