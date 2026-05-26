import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/widgets/molecules/vesto_app_bar.dart';
import 'package:mobile/features/forum/presentation/providers/forum_providers.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';

class ForumShareScreen extends ConsumerStatefulWidget {
  final String outfitId;
  const ForumShareScreen({required this.outfitId, super.key});

  @override
  ConsumerState<ForumShareScreen> createState() => _ForumShareScreenState();
}

class _ForumShareScreenState extends ConsumerState<ForumShareScreen> {
  final _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final caption = _captionController.text.trim();
    
    // Character limit check (from rules)
    if (caption.length > 280) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Açıklama 280 karakterden uzun olamaz.')),
      );
      return;
    }

    await ref.read(forumShareProvider.notifier).shareOutfit(
          outfitId: widget.outfitId,
          caption: caption,
        );

    if (mounted && !ref.read(forumShareProvider).hasError) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Forum\'da paylaşıldı!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shareState = ref.watch(forumShareProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: VestoAppBar(
        title: 'Forum\'a Paylaş',
        actions: [
          shareState.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onyx),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _share,
                  child: const Text(
                    'PAYLAŞ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: AppColors.onyx,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outfit preview
            _OutfitPreview(outfitId: widget.outfitId),
            const SizedBox(height: 24),

            // Caption input
            const Text(
              'AÇIKLAMA',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.stone,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.pearl,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _captionController,
                maxLength: 280,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Bu kombin hakkında bir şeyler yaz...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  counterStyle: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.stone,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: AppColors.onyx,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutfitPreview extends ConsumerWidget {
  final String outfitId;
  const _OutfitPreview({required this.outfitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitAsync = ref.watch(outfitStreamProvider(outfitId));

    return outfitAsync.when(
      loading: () => const AspectRatio(
        aspectRatio: 1.5,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (outfit) {
        if (outfit == null) return const SizedBox.shrink();

        return AspectRatio(
          aspectRatio: 1.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: AppColors.pearl,
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                children: [
                  _ItemThumb(itemId: outfit.items.topId),
                  _ItemThumb(itemId: outfit.items.bottomId),
                  _ItemThumb(itemId: outfit.items.shoesId),
                  _ItemThumb(itemId: outfit.items.accessoryId),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ItemThumb extends ConsumerWidget {
  final String? itemId;
  const _ItemThumb({this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itemId == null) {
      return Container(color: AppColors.mist.withValues(alpha: 0.1));
    }

    final itemAsync = ref.watch(wardrobeItemStreamProvider(itemId!));

    return itemAsync.when(
      loading: () => Container(color: AppColors.mist.withValues(alpha: 0.1)),
      error: (error, stackTrace) => Container(color: AppColors.mist.withValues(alpha: 0.1)),
      data: (item) {
        if (item == null) return Container(color: AppColors.mist.withValues(alpha: 0.1));
        return CachedNetworkImage(
          imageUrl: item.bgRemovedUrl ?? item.imageUrl ?? '',
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(color: AppColors.mist.withValues(alpha: 0.1)),
          errorWidget: (context, url, error) => Container(color: AppColors.mist.withValues(alpha: 0.1)),
        );
      },
    );
  }
}
