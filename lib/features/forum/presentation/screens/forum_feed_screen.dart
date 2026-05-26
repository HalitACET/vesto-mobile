import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/widgets/molecules/vesto_app_bar.dart';
import 'package:mobile/core/widgets/atoms/vesto_divider.dart';
import 'package:mobile/features/forum/presentation/providers/forum_providers.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_post_card.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_skeleton.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_empty_state.dart';

class ForumFeedScreen extends ConsumerWidget {
  const ForumFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(forumFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const VestoAppBar(
        title: 'Forum',
        leading: SizedBox.shrink(), // No back button on bottom nav tab
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/forum/new'),
        backgroundColor: AppColors.onyx,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: feedAsync.when(
        loading: () => const ForumSkeleton(),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (posts) {
          if (posts.isEmpty) {
            return const ForumEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(forumFeedProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const VestoDivider(),
              itemBuilder: (context, index) {
                return ForumPostCard(post: posts[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
