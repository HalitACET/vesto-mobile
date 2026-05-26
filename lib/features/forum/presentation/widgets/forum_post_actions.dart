import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/forum/data/models/forum_post.dart';
import 'package:mobile/features/forum/presentation/providers/forum_providers.dart';
import 'package:mobile/features/forum/presentation/widgets/suggest_outfit_sheet.dart';

class ForumPostActions extends ConsumerStatefulWidget {
  final ForumPost post;
  const ForumPostActions({required this.post, super.key});

  @override
  ConsumerState<ForumPostActions> createState() => _ForumPostActionsState();
}

class _ForumPostActionsState extends ConsumerState<ForumPostActions> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _checkLike();
  }

  @override
  void didUpdateWidget(covariant ForumPostActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likeCount != widget.post.likeCount) {
      setState(() {
        _likeCount = widget.post.likeCount;
      });
    }
  }

  Future<void> _checkLike() async {
    final liked = await ref.read(forumRepositoryProvider).isLiked(widget.post.id);
    if (mounted) setState(() => _isLiked = liked);
  }

  Future<void> _toggleLike() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    await ref.read(forumRepositoryProvider).toggleLike(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Like Button
        GestureDetector(
          onTap: _toggleLike,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(_isLiked),
                    color: _isLiked ? Colors.red : AppColors.graphite,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$_likeCount',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.stone,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Comment Button
        GestureDetector(
          onTap: () => context.push('/forum/post/${widget.post.id}'),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.graphite,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.post.commentCount}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.stone,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Kombin Öner Button
        GestureDetector(
          onTap: () {
            showSuggestOutfitSheet(
              context: context,
              postId: widget.post.id,
              postAuthorId: widget.post.authorId,
              postAuthorDisplayName: widget.post.authorDisplayName,
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.checkroom,
                  color: AppColors.onyx,
                  size: 22,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Kombin Öner',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onyx,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
