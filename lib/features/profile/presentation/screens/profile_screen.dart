import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';
import 'package:mobile/core/widgets/molecules/vesto_list_tile.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar + İsim
              if (user != null) ...[
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.onyx,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.displayName.isNotEmpty ? user.displayName.substring(0, 1).toUpperCase() : 'V',
                      style: AppTypography.headlineLarge.copyWith(color: AppColors.pearl),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName,
                  style: AppTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.stone,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Divider(color: AppColors.mist),
                const SizedBox(height: 32),
              ],
              
              // Coming soon placeholder
              const VestoListTile(
                leading: Icon(Icons.edit_outlined, color: AppColors.stone),
                title: 'Profili Düzenle',
                subtitle: 'Yakında',
                onTap: null,
              ),
              const VestoListTile(
                leading: Icon(Icons.settings_outlined, color: AppColors.stone),
                title: 'Ayarlar',
                subtitle: 'Yakında',
                onTap: null,
              ),
              const VestoListTile(
                leading: Icon(Icons.help_outline, color: AppColors.stone),
                title: 'Yardım',
                subtitle: 'Yakında',
                onTap: null,
              ),
              
              const Spacer(),
              
              // Logout
              VestoButton(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                },
                variant: VestoButtonVariant.secondary,
                label: 'Çıkış Yap',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
