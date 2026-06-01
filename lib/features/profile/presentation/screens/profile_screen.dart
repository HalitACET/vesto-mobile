import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/stylist/presentation/providers/stylist_providers.dart';
import 'package:mobile/features/stylist/presentation/providers/notifications_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: AppBar(
        backgroundColor: AppColors.pearl,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Profil',
          style: AppTypography.headlineSmall,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.onyx),
            onPressed: () => context.push('/profile/edit'),
          ),
          // Bildirim ikonu
          const _NotificationBadgeButton(),
          // Inbox butonu (badge)
          const _InboxBadgeButton(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.onyx),
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.onyx),
        ),
        error: (e, stack) {
          debugPrint('ProfileScreen userAsync error: $e');
          debugPrint(stack.toString());
          return Center(
            child: Text(
              'Bir hata oluştu: $e',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
            ),
          );
        },
        data: (user) {
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.onyx),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                _ProfileHeader(user: user),

                // Stats row
                _StatsRow(userId: user.uid),

                const Divider(color: AppColors.mist, height: 1),

                // Privacy section
                _PrivacySection(user: user),

                const Divider(color: AppColors.mist, height: 1),

                // Public Profile Link
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.link, size: 18, color: AppColors.onyx),
                      label: const Text(
                        'Kamuya Açık Profilini Gör',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.onyx,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onPressed: () => context.push('/u/${user.uid}'),
                    ),
                  ),
                ),

                // Stilist Seçenekleri
                _StylistSection(user: user),

                const SizedBox(height: 32),

                // Logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: VestoButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signOut();
                    },
                    variant: VestoButtonVariant.secondary,
                    label: 'Çıkış Yap',
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppUser user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.mist,
            backgroundImage: user.photoURL != null
                ? CachedNetworkImageProvider(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Text(
                    user.displayName.isNotEmpty
                        ? user.displayName.substring(0, 1).toUpperCase()
                        : 'V',
                    style: AppTypography.headlineMedium.copyWith(color: AppColors.onyx),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            style: AppTypography.headlineSmall.copyWith(color: AppColors.onyx),
            textAlign: TextAlign.center,
          ),
          if (user.username != null && user.username!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '@${user.username}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.stone,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              user.bio,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final String userId;
  const _StatsRow({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobeAsync = ref.watch(userWardrobeItemsProvider);
    final outfitsAsync = ref.watch(outfitsStreamProvider);
    final postsCountAsync = ref.watch(userPostCountProvider(userId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(
            count: wardrobeAsync.value?.length ?? 0,
            label: 'Kıyafet',
          ),
          const _StatDivider(),
          _Stat(
            count: outfitsAsync.value?.length ?? 0,
            label: 'Kombin',
          ),
          const _StatDivider(),
          _Stat(
            count: postsCountAsync.value ?? 0,
            label: 'Paylaşım',
          ),
          const _StatDivider(),
          _Stat(
            count: currentUser?.followerCount ?? 0,
            label: 'Takipçi',
            onTap: () => context.push('/u/$userId/followers'),
          ),
          const _StatDivider(),
          _Stat(
            count: currentUser?.followingCount ?? 0,
            label: 'Takip',
            onTap: () => context.push('/u/$userId/following'),
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

class _PrivacySection extends ConsumerWidget {
  final AppUser user;
  const _PrivacySection({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GİZLİLİK',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.stone,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Gardırobumu Paylaş',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onyx,
              ),
            ),
            subtitle: const Text(
              'Açıksa tüm kıyafetlerin herkes tarafından görülebilir',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.stone,
              ),
            ),
            value: user.wardrobePublic,
            activeThumbColor: AppColors.onyx,
            onChanged: (value) async {
              await ref.read(userRepositoryProvider).setWardrobePublic(
                    user.uid,
                    value,
                  );
            },
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/wardrobe'),
            child: const Text(
              'Her kıyafet için ayrı ayrı da ayarlayabilirsin →',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.stone,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification Badge Button ─────────────────────────────────────────────────

class _NotificationBadgeButton extends ConsumerWidget {
  const _NotificationBadgeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);
    final unreadCount =
        notifsAsync.value?.where((n) => !n.isRead).length ?? 0;

    return IconButton(
      icon: Badge(
        label: unreadCount > 0 ? Text('$unreadCount') : null,
        isLabelVisible: unreadCount > 0,
        backgroundColor: AppColors.onyx,
        textColor: AppColors.pearl,
        child: const Icon(
          Icons.notifications_outlined,
          color: AppColors.onyx,
        ),
      ),
      onPressed: () => context.push('/notifications'),
      tooltip: 'Bildirimler',
    );
  }
}

// ── Inbox Badge Button ────────────────────────────────────────────────────────

class _InboxBadgeButton extends ConsumerWidget {
  const _InboxBadgeButton();


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(pendingRecommendationCountProvider);
    final count = countAsync.value ?? 0;

    return IconButton(
      icon: Badge(
        label: count > 0 ? Text('$count') : null,
        isLabelVisible: count > 0,
        backgroundColor: AppColors.onyx,
        textColor: AppColors.pearl,
        child: const Icon(
          Icons.inbox_outlined,
          color: AppColors.onyx,
        ),
      ),
      onPressed: () => context.push('/recommendations/inbox'),
      tooltip: 'Kombin Önerileri',
    );
  }
}

// ── Stylist Section ───────────────────────────────────────────────────────────

class _StylistSection extends ConsumerWidget {
  final AppUser user;
  const _StylistSection({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Divider(color: AppColors.mist, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'STİLİSTLİK',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.stone,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (user.isStylistModeActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.onyx,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        '✦ Aktif',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StylistNavCard(
                      icon: Icons.people_outline,
                      label: 'Stilistleri Keşfet',
                      onTap: () => context.push('/stylist/browse'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StylistNavCard(
                      icon: Icons.mail_outline,
                      label: 'Gelen Öneriler',
                      onTap: () => context.push('/recommendations/inbox'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StylistNavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _StylistNavCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mist),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.onyx),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onyx,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


