import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/widgets/molecules/vesto_app_bar.dart';
import 'package:mobile/features/forum/data/models/forum_comment.dart';
import 'package:mobile/features/forum/presentation/providers/forum_providers.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_post_card.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_comment_card.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_comment_input.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_skeleton.dart';

class ForumPostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  const ForumPostDetailScreen({required this.postId, super.key});

  @override
  ConsumerState<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends ConsumerState<ForumPostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSending = false;
  ForumComment? _replyingTo;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _commentController.clear();

    final parentId = _replyingTo != null ? (_replyingTo!.parentId ?? _replyingTo!.id) : null;
    final replyToDisplayName = _replyingTo?.authorDisplayName;

    await ref.read(forumRepositoryProvider).addComment(
          postId: widget.postId,
          text: text,
          parentId: parentId,
          replyToDisplayName: replyToDisplayName,
        );

    if (mounted) {
      setState(() {
        _isSending = false;
        _replyingTo = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(forumPostStreamProvider(widget.postId));
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));

    return postAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        appBar: VestoAppBar(title: 'Paylaşım'),
        body: ForumSkeleton(),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: const VestoAppBar(title: 'Paylaşım'),
        body: Center(child: Text('Hata: $e')),
      ),
      data: (post) {
        if (post == null || post.isArchived) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const VestoAppBar(title: 'Paylaşım'),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48, color: AppColors.stone),
                  const SizedBox(height: 16),
                  const Text(
                    'Bu paylaşım silinmiş veya bulunamadı.',
                    style: TextStyle(fontFamily: 'Inter', color: AppColors.stone),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.maybePop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onyx,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Geri Dön'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const VestoAppBar(title: 'Paylaşım'),
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Post Card itself
                    SliverToBoxAdapter(
                      child: ForumPostCard(post: post),
                    ),
                    const SliverToBoxAdapter(
                      child: Divider(height: 1),
                    ),
                    // Comments Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                        child: Text(
                          'Yorumlar (${post.commentCount})',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onyx,
                          ),
                        ),
                      ),
                    ),
                    // Comments list
                    commentsAsync.when(
                      loading: () => const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      error: (e, _) => SliverFillRemaining(
                        child: Center(child: Text('Yorumlar yüklenemedi: $e')),
                      ),
                      data: (comments) {
                        if (comments.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                              child: Center(
                                child: Text(
                                  'Henüz yorum yok. İlk yorumu sen yap!',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.stone,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        // Flatten comments tree (1-level nesting)
                        final rootComments = comments.where((c) => c.parentId == null).toList();
                        final repliesMap = <String, List<ForumComment>>{};
                        for (final c in comments) {
                          if (c.parentId != null) {
                            repliesMap.putIfAbsent(c.parentId!, () => []).add(c);
                          }
                        }

                        final flatItems = <CommentListItem>[];
                        for (final root in rootComments) {
                          flatItems.add(CommentListItem(comment: root, isReply: false));
                          final replies = repliesMap[root.id];
                          if (replies != null) {
                            for (final reply in replies) {
                              flatItems.add(CommentListItem(comment: reply, isReply: true));
                            }
                          }
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = flatItems[index];
                                final isReply = item.isReply;

                                final card = ForumCommentCard(
                                  comment: item.comment,
                                  onReply: () {
                                    setState(() {
                                      _replyingTo = item.comment;
                                    });
                                  },
                                  onDelete: () async {
                                    await ref.read(forumRepositoryProvider).deleteComment(item.comment.id, widget.postId);
                                  },
                                );

                                if (isReply) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 28),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 14, right: 6),
                                          child: Icon(
                                            Icons.subdirectory_arrow_right_rounded,
                                            size: 14,
                                            color: AppColors.mist,
                                          ),
                                        ),
                                        Expanded(child: card),
                                      ],
                                    ),
                                  );
                                }

                                return card;
                              },
                              childCount: flatItems.length,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Comment input pinned at the bottom
              ForumCommentInput(
                controller: _commentController,
                isSending: _isSending,
                onSend: _sendComment,
                replyingToDisplayName: _replyingTo?.authorDisplayName,
                onCancelReply: () {
                  setState(() {
                    _replyingTo = null;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommentListItem {
  final ForumComment comment;
  final bool isReply;
  CommentListItem({required this.comment, this.isReply = false});
}
