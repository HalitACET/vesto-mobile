import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/forum/data/models/forum_comment.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';
import 'package:mobile/features/forum/presentation/providers/forum_providers.dart';

class ForumCommentCard extends ConsumerStatefulWidget {
  final ForumComment comment;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;

  const ForumCommentCard({
    required this.comment,
    this.onDelete,
    this.onReply,
    super.key,
  });

  @override
  ConsumerState<ForumCommentCard> createState() => _ForumCommentCardState();
}

class _ForumCommentCardState extends ConsumerState<ForumCommentCard> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.comment.likeCount;
    _checkLike();
  }

  @override
  void didUpdateWidget(covariant ForumCommentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment.id != widget.comment.id) {
      _likeCount = widget.comment.likeCount;
      _checkLike();
    } else if (oldWidget.comment.likeCount != widget.comment.likeCount) {
      _likeCount = widget.comment.likeCount;
    }
  }

  Future<void> _checkLike() async {
    if (!mounted) return;
    final liked = await ref.read(forumRepositoryProvider).isCommentLiked(widget.comment.id);
    if (mounted) {
      setState(() {
        _isLiked = liked;
      });
    }
  }

  Future<void> _toggleLike() async {
    final liked = !_isLiked;
    setState(() {
      _isLiked = liked;
      _likeCount += liked ? 1 : -1;
    });
    try {
      await ref.read(forumRepositoryProvider).toggleCommentLike(widget.comment.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = !liked;
          _likeCount += (!liked) ? 1 : -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnComment = currentUserId == comment.authorId;
    final isSuggestion = comment.commentType == 'outfit_suggestion';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: isSuggestion ? const EdgeInsets.all(12) : null,
        decoration: isSuggestion
            ? BoxDecoration(
                color: AppColors.pearl,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mist),
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.mist,
              backgroundImage: comment.authorPhotoUrl != null
                  ? CachedNetworkImageProvider(comment.authorPhotoUrl!)
                  : null,
              child: comment.authorPhotoUrl == null
                  ? Text(
                      comment.authorDisplayName.isNotEmpty
                          ? comment.authorDisplayName.substring(0, 1).toUpperCase()
                          : 'K',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.onyx,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Comment Text Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        comment.authorDisplayName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onyx,
                        ),
                      ),
                      if (comment.replyToDisplayName != null) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          size: 12,
                          color: AppColors.stone,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '@${comment.replyToDisplayName}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onyx,
                          ),
                        ),
                      ],
                      if (isSuggestion) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.onyx,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.checkroom, size: 10, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'Kombin Önerisi',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Text(
                        _timeAgo(comment.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.stone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  if (isSuggestion && comment.outfitSuggestion != null) ...[
                    // 2x2 Grid of suggested items
                    Container(
                      width: 140,
                      height: 140,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.mist),
                      ),
                      child: GridView.count(
                        crossAxisCount: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        children: [
                          _ItemThumb(itemId: comment.outfitSuggestion!.topId),
                          _ItemThumb(itemId: comment.outfitSuggestion!.bottomId),
                          _ItemThumb(itemId: comment.outfitSuggestion!.shoesId),
                          _ItemThumb(itemId: comment.outfitSuggestion!.accessoryId),
                        ],
                      ),
                    ),
                  ],

                  Text(
                    comment.text,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.onyx,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Actions Row
                  Row(
                    children: [
                      // Like Action
                      GestureDetector(
                        onTap: _toggleLike,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? Colors.red : AppColors.stone,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_likeCount',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: AppColors.stone,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Reply Action
                      if (widget.onReply != null)
                        GestureDetector(
                          onTap: widget.onReply,
                          behavior: HitTestBehavior.opaque,
                          child: const Text(
                            'Yanıtla',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.stone,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Options button for deleting comment
            if (isOwnComment && widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.stone, size: 18),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Yorumu Sil?'),
                      content: const Text('Bu yorumu silmek istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Vazgeç'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onDelete?.call();
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

class _ItemThumb extends ConsumerWidget {
  final String? itemId;
  const _ItemThumb({this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itemId == null) {
      return Container(
        color: AppColors.pearl,
        child: const Center(
          child: Icon(Icons.checkroom_outlined, color: AppColors.mist, size: 16),
        ),
      );
    }

    final itemAsync = ref.watch(wardrobeItemStreamProvider(itemId!));

    return itemAsync.when(
      loading: () => Container(color: AppColors.pearl),
      error: (error, stackTrace) => Container(
        color: AppColors.pearl,
        child: const Icon(Icons.broken_image, size: 16, color: AppColors.stone),
      ),
      data: (item) {
        if (item == null) {
          return Container(
            color: AppColors.pearl,
            child: const Center(
              child: Icon(Icons.checkroom_outlined, color: AppColors.mist, size: 16),
            ),
          );
        }
        return Container(
          color: AppColors.pearl,
          child: CachedNetworkImage(
            imageUrl: item.bgRemovedUrl ?? item.imageUrl ?? '',
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(color: AppColors.pearl),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 16, color: AppColors.stone),
          ),
        );
      },
    );
  }
}
