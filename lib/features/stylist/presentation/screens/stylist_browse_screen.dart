import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/core/widgets/molecules/vesto_app_bar.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/stylist/presentation/providers/stylist_providers.dart';

class StylistBrowseScreen extends ConsumerWidget {
  const StylistBrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followedAsync = ref.watch(followedStylistsProvider);
    final featuredAsync = ref.watch(featuredStylistsProvider);

    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: const VestoAppBar(title: 'Stilistler'),
      body: RefreshIndicator(
        color: AppColors.onyx,
        onRefresh: () async {
          ref.invalidate(followedStylistsProvider);
          ref.invalidate(featuredStylistsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Takip Ettiklerim ─────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
                child: Text(
                  'TAKİP ETTİKLERİM',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.stone,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            followedAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                      child: CircularProgressIndicator(color: AppColors.onyx)),
                ),
              ),
              error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (stylists) {
                if (stylists.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text(
                        'Takip ettiğin aktif stilist yok.',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.stone,
                            fontSize: 13),
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: stylists.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, i) =>
                          _StylistAvatar(user: stylists[i]),
                    ),
                  ),
                );
              },
            ),

            // ── Öne Çıkan Stilistler ─────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
                child: Text(
                  'ÖNE ÇIKAN STİLİSTLER',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.stone,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            featuredAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                      child: CircularProgressIndicator(color: AppColors.onyx)),
                ),
              ),
              error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (stylists) {
                if (stylists.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Center(
                        child: Text(
                          'Henüz aktif stilist bulunmuyor.',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.stone,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _StylistListTile(user: stylists[i]),
                    childCount: stylists.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _StylistAvatar extends StatelessWidget {
  final AppUser user;
  const _StylistAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/u/${user.uid}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.mist,
            backgroundImage: user.photoURL != null
                ? CachedNetworkImageProvider(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Text(
                    user.displayName.isNotEmpty
                        ? user.displayName.substring(0, 1).toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.onyx,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            user.displayName.length > 10
                ? '${user.displayName.substring(0, 10)}…'
                : user.displayName,
            style: AppTypography.bodySmall.copyWith(color: AppColors.onyx),
          ),
        ],
      ),
    );
  }
}

class _StylistListTile extends StatelessWidget {
  final AppUser user;
  const _StylistListTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/u/${user.uid}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.mist,
              backgroundImage: user.photoURL != null
                  ? CachedNetworkImageProvider(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? Text(
                      user.displayName.isNotEmpty
                          ? user.displayName.substring(0, 1).toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        fontSize: 18,
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
                  Row(
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onyx,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.onyx,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          '✦ Stilist',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (user.bio.isNotEmpty)
                    Text(
                      user.bio,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.stone),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    '${user.followerCount} takipçi',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.stone),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.stone),
          ],
        ),
      ),
    );
  }
}
