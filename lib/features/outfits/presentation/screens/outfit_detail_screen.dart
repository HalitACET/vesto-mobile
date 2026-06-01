import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/outfits/data/models/outfit.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:go_router/go_router.dart';

class OutfitDetailScreen extends ConsumerStatefulWidget {
  final Outfit outfit;

  const OutfitDetailScreen({super.key, required this.outfit});

  @override
  ConsumerState<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends ConsumerState<OutfitDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.outfit.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    final previousState = _isFavorite;
    setState(() {
      _isFavorite = !_isFavorite;
    });
    try {
      await ref.read(outfitRepositoryProvider).toggleFavorite(widget.outfit.id, previousState);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorite = previousState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favori güncellenemedi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get full items details
    final itemIds = [
      widget.outfit.items.topId,
      widget.outfit.items.bottomId,
      widget.outfit.items.shoesId,
      widget.outfit.items.accessoryId
    ].whereType<String>().toList();

    final itemsAsync = ref.watch(wardrobeItemsByIdsProvider(itemIds.join(',')));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
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
                    widget.outfit.name,
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
                          '${widget.outfit.wearCount} kez giyildi',
                          style: const TextStyle(fontSize: 12, color: AppColors.stone),
                        ),
                      ),
                      if (widget.outfit.lastWorn != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          'Son: ${DateFormat('dd MMM yyyy').format(widget.outfit.lastWorn!)}',
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
              data: (items) => Hero(
                tag: 'outfit-${widget.outfit.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: _buildCanvas(items),
                ),
              ),
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
                      await ref.read(outfitRepositoryProvider).markAsWorn(widget.outfit);
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
                    onPressed: () => context.push('/forum/share/${widget.outfit.id}'),
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
    final top = items.where((i) => i.id == widget.outfit.items.topId).firstOrNull;
    final bottom = items.where((i) => i.id == widget.outfit.items.bottomId).firstOrNull;
    final shoes = items.where((i) => i.id == widget.outfit.items.shoesId).firstOrNull;
    final accessory = items.where((i) => i.id == widget.outfit.items.accessoryId).firstOrNull;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (top != null) _buildItemRow('Üst Giyim', top),
            if (bottom != null) _buildItemRow('Alt Giyim', bottom),
            if (shoes != null) _buildItemRow('Ayakkabı', shoes),
            if (accessory != null) _buildItemRow('Aksesuar', accessory),
          ],
        ),
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
              fadeInDuration: const Duration(milliseconds: 300),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: const TextStyle(fontSize: 12, color: AppColors.stone, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.subcategory.isNotEmpty ? item.subcategory : item.category.displayLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.brand != null)
                  Text(
                    item.brand!, 
                    style: const TextStyle(fontSize: 14, color: AppColors.stone),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
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
              ref.read(outfitRepositoryProvider).deleteOutfit(widget.outfit.id);
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
