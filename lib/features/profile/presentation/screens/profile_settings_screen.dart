import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/core/widgets/molecules/vesto_app_bar.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/profile/presentation/providers/profile_providers.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: const VestoAppBar(
        title: 'Ayarlar',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'GİZLİLİK',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.stone,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mist),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Gardırobumu Paylaş',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onyx),
                    ),
                    subtitle: const Text(
                      'Açıksa kıyafetlerin profilinde herkese görünür',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.stone,
                      ),
                    ),
                    value: user?.wardrobePublic ?? false,
                    activeThumbColor: AppColors.onyx,
                    onChanged: (value) async {
                      if (user == null) return;
                      await ref.read(userRepositoryProvider).setWardrobePublic(
                            user.uid,
                            value,
                          );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'UYGULAMA',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.stone,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mist),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Versiyon',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.onyx),
                    ),
                    trailing: Text(
                      'v1.0.0',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
