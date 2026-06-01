import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/forum/data/models/forum_post.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_post_actions.dart';
import 'package:mobile/features/forum/presentation/providers/forum_providers.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';

class ForumPostCard extends ConsumerStatefulWidget {
  final ForumPost post;
  const ForumPostCard({required this.post, super.key});

  @override
  ConsumerState<ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends ConsumerState<ForumPostCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/forum/post/${widget.post.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            _AuthorRow(post: widget.post),
            const SizedBox(height: 12),

            // Caption
            if (widget.post.caption.isNotEmpty) ...[
              Text(
                widget.post.caption,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.onyx,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Outfit preview (2x2 mini grid)
            if (widget.post.outfitId != null && widget.post.outfitId!.isNotEmpty) ...[
              Hero(
                tag: 'forum-post-${widget.post.id}',
                child: _OutfitPreview(outfitId: widget.post.outfitId!),
              ),
              const SizedBox(height: 12),
            ],

            // Actions (like + comment)
            ForumPostActions(post: widget.post),
          ],
        ),
      ),
    );
  }
}

class _AuthorRow extends ConsumerWidget {
  final ForumPost post;
  const _AuthorRow({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnPost = currentUserId == post.authorId;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/u/${post.authorId}'),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.mist,
                  backgroundImage: post.authorPhotoUrl != null
                      ? CachedNetworkImageProvider(post.authorPhotoUrl!)
                      : null,
                  child: post.authorPhotoUrl == null
                      ? Text(
                          post.authorDisplayName.isNotEmpty
                              ? post.authorDisplayName.substring(0, 1).toUpperCase()
                              : 'K',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.onyx,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),

                // Name + time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorDisplayName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onyx,
                        ),
                      ),
                      Text(
                        _timeAgo(post.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.stone,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Options (only for own post)
        if (isOwnPost)
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.graphite),
            onPressed: () => _showOptions(context, ref),
          ),
      ],
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Paylaşımı Sil'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Paylaşımı Sil?'),
                    content: const Text('Bu paylaşımı forumdan kaldırmak istediğinize emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Vazgeç'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref.read(forumRepositoryProvider).deletePost(post.id);
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Sil'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    return '${diff.inDays} gün önce';
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
        aspectRatio: 1,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (outfit) {
        if (outfit == null) return const SizedBox.shrink();

        return AspectRatio(
          aspectRatio: 1,
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
          fadeInDuration: const Duration(milliseconds: 300),
          placeholder: (context, url) => Container(color: AppColors.mist.withValues(alpha: 0.1)),
          errorWidget: (context, url, error) => Container(color: AppColors.mist.withValues(alpha: 0.1)),
        );
      },
    );
  }
}
