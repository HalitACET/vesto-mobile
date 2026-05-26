import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/core/network/firebase_providers.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_item_card.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String userId;
  const PublicProfileScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(userId));
    final publicItemsAsync = ref.watch(publicWardrobeProvider(userId));
    final currentUserId = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final isOwnProfile = currentUserId == userId;

    return Scaffold(
      backgroundColor: AppColors.pearl,
      body: profileAsync.when(
        loading: () => const Scaffold(
          backgroundColor: AppColors.pearl,
          body: Center(child: CircularProgressIndicator(color: AppColors.onyx)),
        ),
        error: (err, _) => Scaffold(
          backgroundColor: AppColors.pearl,
          appBar: AppBar(backgroundColor: AppColors.pearl, elevation: 0),
          body: const Center(child: Text('Kullanıcı bulunamadı')),
        ),
        data: (user) {
          if (user == null) {
            return Scaffold(
              backgroundColor: AppColors.pearl,
              appBar: AppBar(backgroundColor: AppColors.pearl, elevation: 0),
              body: const Center(child: Text('Kullanıcı bulunamadı')),
            );
          }

          return CustomScrollView(
            slivers: [
              // Simple Pinned SliverAppBar for Navigation
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.pearl,
                scrolledUnderElevation: 0,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onyx, size: 18),
                  onPressed: () => context.pop(),
                ),
              ),

              // Dynamic scrollable Profile Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.mist,
                            backgroundImage: user.photoURL != null
                                ? CachedNetworkImageProvider(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? Text(
                                    user.displayName.isNotEmpty
                                        ? user.displayName.substring(0, 1).toUpperCase()
                                        : 'K',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: AppColors.onyx,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.displayName,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onyx,
                                  ),
                                ),
                                if (user.username != null && user.username!.isNotEmpty)
                                  Text(
                                    '@${user.username}',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: AppColors.stone,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (!isOwnProfile) ...[
                            const SizedBox(width: 8),
                            _FollowButton(userId: userId),
                          ],
                        ],
                      ),
                      if (user.bio.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          user.bio,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.stone,
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (isOwnProfile) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.onyx.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline, size: 14, color: AppColors.stone),
                              SizedBox(width: 6),
                              Text(
                                'Bu senin profilin. Başkaları bu kıyafetleri görebilir.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: AppColors.stone,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _StatsRow(user: user),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.mist, height: 1),
                    ],
                  ),
                ),
              ),

              // Title Section for Public Wardrobe
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
                  child: Text(
                    'PAYLAŞILAN GİYSİLER',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.stone,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              // Public wardrobe grid list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: publicItemsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(color: AppColors.onyx),
                      ),
                    ),
                  ),
                  error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  data: (items) {
                    if (items.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 64),
                            child: Text(
                              'Henüz herkese açık kıyafet yok',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.stone,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => WardrobeItemCard(
                          item: items[index],
                          onTap: () => context.push('/wardrobe/item/${items[index].id}'),
                          onLongPress: () {},
                        ),
                        childCount: items.length,
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FollowButton extends ConsumerWidget {
  final String userId;
  const _FollowButton({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowingAsync = ref.watch(isFollowingProvider(userId));

    return isFollowingAsync.when(
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.onyx),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (isFollowing) => ElevatedButton(
        onPressed: () async {
          HapticFeedback.lightImpact();
          await ref.read(userRepositoryProvider).toggleFollow(userId);
          ref.invalidate(isFollowingProvider(userId));
          ref.invalidate(userProfileProvider(userId));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? AppColors.pearl : AppColors.onyx,
          foregroundColor: isFollowing ? AppColors.onyx : AppColors.pearl,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: isFollowing ? const BorderSide(color: AppColors.onyx, width: 1) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(100, 36),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(isFollowing ? 'Takip Ediliyor' : 'Takip Et'),
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final AppUser user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicItemsAsync = ref.watch(publicWardrobeProvider(user.uid));
    final postsCountAsync = ref.watch(userPostCountProvider(user.uid));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(
            count: publicItemsAsync.value?.length ?? 0,
            label: 'Kıyafet',
          ),
          const _StatDivider(),
          _Stat(
            count: postsCountAsync.value ?? 0,
            label: 'Paylaşım',
          ),
          const _StatDivider(),
          _Stat(
            count: user.followerCount,
            label: 'Takipçi',
            onTap: () => context.push('/u/${user.uid}/followers'),
          ),
          const _StatDivider(),
          _Stat(
            count: user.followingCount,
            label: 'Takip',
            onTap: () => context.push('/u/${user.uid}/following'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback? onTap;

  const _Stat({
    required this.count,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        Text(
          '$count',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onyx,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.stone),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      );
    }
    return child;
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.mist,
    );
  }
}
