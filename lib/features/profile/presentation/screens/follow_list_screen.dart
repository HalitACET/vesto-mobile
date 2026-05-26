import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/widgets/atoms/vesto_divider.dart';
import 'package:mobile/core/widgets/atoms/vesto_loading_indicator.dart';
import 'package:mobile/core/widgets/molecules/vesto_app_bar.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/profile/presentation/providers/profile_providers.dart';

class FollowListScreen extends ConsumerWidget {
  final String userId;
  final bool showFollowers;  // true = followers, false = following

  const FollowListScreen({
    required this.userId,
    required this.showFollowers,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: VestoAppBar(
        title: showFollowers ? 'Takipçiler' : 'Takip Edilenler',
      ),
      body: FutureBuilder<List<AppUser>>(
        future: showFollowers
            ? ref.read(userRepositoryProvider).getFollowers(userId)
            : ref.read(userRepositoryProvider).getFollowing(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: VestoLoadingIndicator(size: 24),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Bir hata oluştu',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.stone,
                ),
              ),
            );
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return Center(
              child: Text(
                showFollowers
                    ? 'Henüz takipçi yok'
                    : 'Henüz kimse takip edilmiyor',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.stone,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            separatorBuilder: (_, _) => const VestoDivider(),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: CircleAvatar(
                  radius: 20,
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
                            fontFamily: 'Inter',
                            color: AppColors.onyx,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  user.displayName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
                onTap: () => context.push('/u/${user.uid}'),
              );
            },
          );
        },
      ),
    );
  }
}
