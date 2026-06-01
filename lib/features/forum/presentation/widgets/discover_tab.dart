import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/widgets/atoms/vesto_divider.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/forum/presentation/providers/forum_providers.dart';

class DiscoverTab extends ConsumerStatefulWidget {
  const DiscoverTab({super.key});

  @override
  ConsumerState<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<DiscoverTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Arama çubuğu
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _isSearching
                      ? AppColors.onyx
                      : AppColors.stone,
                  width: _isSearching ? 1.0 : 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search,
                    size: 18, color: AppColors.graphite),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onTap: () => setState(() => _isSearching = true),
                    onEditingComplete: () =>
                        setState(() => _isSearching = false),
                    decoration: const InputDecoration(
                      hintText: 'Kullanıcı ara...',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.stone,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _isSearching = false);
                    },
                    child: const Icon(Icons.close,
                        size: 18, color: AppColors.graphite),
                  ),
              ],
            ),
          ),
        ),

        // İçerik
        Expanded(
          child: _searchQuery.trim().length >= 2
              ? _SearchResults(query: _searchQuery.trim())
              : const _DiscoverContent(),
        ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(userSearchProvider(query));

    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (List<AppUser> users) {
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_search_outlined,
                    size: 40, color: AppColors.stone),
                const SizedBox(height: 12),
                Text(
                  '"$query" için sonuç bulunamadı',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.stone,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: users.length,
          separatorBuilder: (_, _) => const VestoDivider(),
          itemBuilder: (context, index) =>
              _UserListTile(user: users[index]),
        );
      },
    );
  }
}

class _DiscoverContent extends ConsumerWidget {
  const _DiscoverContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bölüm 1: Stilistler
        _DiscoverSection(
          title: 'STİLİSTLER',
          icon: Icons.auto_awesome_outlined,
          futureProvider: topStylistsProvider,
        ),
        const SizedBox(height: 24),

        // Bölüm 2: Öne Çıkanlar
        _DiscoverSection(
          title: 'ÖNE ÇIKANLAR',
          icon: Icons.trending_up_outlined,
          futureProvider: featuredUsersProvider,
        ),
        const SizedBox(height: 24),

        // Bölüm 3: Yeni Katılanlar
        _DiscoverSection(
          title: 'YENİ KATILDI',
          icon: Icons.fiber_new_outlined,
          futureProvider: newUsersProvider,
        ),
      ],
    );
  }
}

class _DiscoverSection extends ConsumerWidget {
  final String title;
  final IconData icon;
  final dynamic futureProvider;

  const _DiscoverSection({
    required this.title,
    required this.icon,
    required this.futureProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(futureProvider) as AsyncValue<List<AppUser>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.stone),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppColors.stone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Yatay scroll kullanıcı listesi
        usersAsync.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (List<AppUser> users) {
            final currentUid = FirebaseAuth.instance.currentUser?.uid;
            final filtered = users.where((u) => u.uid != currentUid).toList();

            if (filtered.isEmpty) {
              return const Text(
                'Henüz kimse yok',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.stone,
                ),
              );
            }

            return SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) =>
                    _UserAvatar(user: filtered[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final AppUser user;
  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/u/${user.uid}'),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.mist,
                  backgroundImage: user.photoURL != null
                      ? CachedNetworkImageProvider(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(
                          user.displayName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.onyx,
                          ),
                        )
                      : null,
                ),
                // Stilist rozeti
                if (user.isStylistModeActive)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.onyx,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 10,
                        color: AppColors.pearl,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              user.displayName.split(' ').first, // Sadece ilk isim
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.onyx,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListTile extends ConsumerWidget {
  final AppUser user;
  const _UserListTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => context.push('/u/${user.uid}'),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.mist,
        backgroundImage: user.photoURL != null
            ? CachedNetworkImageProvider(user.photoURL!)
            : null,
        child: user.photoURL == null
            ? Text(user.displayName.substring(0, 1).toUpperCase())
            : null,
      ),
      title: Text(
        user.displayName,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.onyx,
        ),
      ),
      subtitle: user.username != null
          ? Text(
              '@${user.username}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.stone,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user.isStylistModeActive)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.onyx,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Stilist',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: AppColors.pearl,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right,
              color: AppColors.stone, size: 18),
        ],
      ),
    );
  }
}
