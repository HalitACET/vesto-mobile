import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/widgets/atoms/vesto_divider.dart';
import 'package:mobile/features/forum/presentation/providers/forum_providers.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_post_card.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_skeleton.dart';
import 'package:mobile/core/widgets/organisms/vesto_error_view.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_empty_state.dart';

import 'package:mobile/features/forum/presentation/widgets/discover_tab.dart';

class ForumFeedScreen extends ConsumerStatefulWidget {
  const ForumFeedScreen({super.key});

  @override
  ConsumerState<ForumFeedScreen> createState() => _ForumFeedScreenState();
}

class _ForumFeedScreenState extends ConsumerState<ForumFeedScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: AppBar(
        backgroundColor: AppColors.pearl,
        elevation: 0,
        title: const Text(
          'Vesto',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 22,
            color: AppColors.onyx,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.onyx,
          unselectedLabelColor: AppColors.stone,
          indicatorColor: AppColors.onyx,
          indicatorWeight: 1.5,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          tabs: const [
            Tab(text: 'FORUM'),
            Tab(text: 'KEŞFET'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/forum/new'),
        backgroundColor: AppColors.onyx,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ForumFeedTab(),
          DiscoverTab(),
        ],
      ),
    );
  }
}

class ForumFeedTab extends ConsumerWidget {
  const ForumFeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(forumFeedProvider);

    return feedAsync.when(
      loading: () => const ForumSkeleton(),
      error: (e, _) => CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: VestoErrorView(
              message: 'Akış yüklenemedi',
              onRetry: () => ref.invalidate(forumFeedProvider),
            ),
          ),
        ],
      ),
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
    );
  }
}
