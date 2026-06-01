import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/core/network/firebase_providers.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_item_card.dart';
import 'package:mobile/core/widgets/organisms/vesto_error_view.dart';
import 'package:mobile/features/profile/presentation/widgets/public_profile_skeleton.dart';

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
        loading: () => const PublicProfileSkeleton(),
        error: (err, _) => Scaffold(
          backgroundColor: AppColors.pearl,
          appBar: AppBar(backgroundColor: AppColors.pearl, elevation: 0),
          body: VestoErrorView(
            message: 'Kullanıcı bulunamadı',
            onRetry: () => ref.invalidate(userProfileProvider(userId)),
          ),
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
                                if (user.isStylistModeActive)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.onyx,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Text(
                                      '✦ Stilist',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final currentUserAsync = ref.watch(currentUserProvider);
                          final currentUser = currentUserAsync.value;
                          final isSelf = currentUser?.uid == userId;
                          final isStylist = currentUser?.isStylistModeActive == true;

                          if (isSelf) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                // Follow butonu (mevcut, dokunma)
                                Expanded(
                                  child: _FollowButton(userId: userId),
                                ),

                                // Kombin Öner — SADECE stilist modundaki kullanıcıya göster
                                if (isStylist) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.push(
                                        '/stylist/editor/$userId',
                                        extra: user,
                                      ),
                                      icon: const Icon(
                                        Icons.auto_awesome_outlined,
                                        size: 16,
                                        color: AppColors.onyx,
                                      ),
                                      label: const Text(
                                        'Kombin Öner',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onyx,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.onyx),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
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
                      // Stilist ise stats kartını göster
                      if (user.isStylistModeActive) ...[
                        const SizedBox(height: 8),
                        _StylistStatsCard(user: user),
                      ],
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

// ── Stylist Stats Card ────────────────────────────────────────────────────────

class _StylistStatsCard extends StatelessWidget {
  final AppUser user;
  const _StylistStatsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final acceptRate = user.suggestionsSent > 0
        ? (user.suggestionsAccepted / user.suggestionsSent * 100).round()
        : 0;

    final isTrusted = acceptRate >= 70 && user.suggestionsSent >= 5;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mist),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppColors.stone),
              const SizedBox(width: 6),
              const Text(
                'STİLİST İSTATİSTİKLERİ',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.stone,
                ),
              ),
              const Spacer(),
              if (isTrusted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 12, color: Colors.amber.shade700),
                      const SizedBox(width: 3),
                      Text(
                        'Güvenilir',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StylistStatItem(
                value: '${user.suggestionsSent}',
                label: 'Öneri',
              ),
              _StylistStatItem(
                value: '%$acceptRate',
                label: 'Kabul',
              ),
              _StylistStatItem(
                value: user.ratingCount > 0
                    ? user.averageRating.toStringAsFixed(1)
                    : '—',
                label: 'Puan',
                icon: user.ratingCount > 0 ? Icons.star : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StylistStatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const _StylistStatItem({
    required this.value,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.amber),
              const SizedBox(width: 2),
            ],
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.onyx,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: AppColors.stone,
          ),
        ),
      ],
    );
  }
}

