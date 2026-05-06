import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/constants/app_strings.dart';
import 'package:mobile/core/widgets/vesto_card.dart';
import 'package:mobile/core/widgets/vesto_loading.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';

/// Hafta 1: Placeholder home ekranı.
/// Kullanıcı adını gösterir, logout çalışır.
/// Gerçek içerik (gardırop grid, hava durumu kartı) sonraki haftalarda gelecek.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VESTO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
            tooltip: AppStrings.signOut,
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) => _HomeContent(displayName: user?.displayName ?? 'Kullanıcı'),
        loading: () => const VestoLoading(message: AppStrings.loading),
        error: (error, _) => Center(
          child: Text(
            AppStrings.genericError,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/wardrobe/add'),
        backgroundColor: AppColors.onyx,
        foregroundColor: AppColors.pearl,
        child: const Icon(Icons.add),
      ),
    );
  }
}


class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          _Greeting(displayName: displayName),
          const SizedBox(height: AppSpacing.xxl),
          _PlaceholderSections(),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.welcomeMessage},',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          displayName,
          style: AppTypography.headlineLarge,
        ),
      ],
    );
  }
}

class _PlaceholderSections extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUGÜN NE GİYSEM?',
          style: AppTypography.labelMedium.copyWith(color: AppColors.stone),
        ),
        const SizedBox(height: AppSpacing.md),
        VestoCard(
          child: SizedBox(
            height: 120,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wb_sunny_outlined, color: AppColors.mist, size: 32),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Hava durumu modülü — Hafta 7',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'GARDIROBUМ',
          style: AppTypography.labelMedium.copyWith(color: AppColors.stone),
        ),
        const SizedBox(height: AppSpacing.md),
        VestoCard(
          child: SizedBox(
            height: 160,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.checkroom_outlined, color: AppColors.mist, size: 32),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Gardırop görünümü — Hafta 5',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'TOPLULUK',
          style: AppTypography.labelMedium.copyWith(color: AppColors.stone),
        ),
        const SizedBox(height: AppSpacing.md),
        VestoCard(
          child: SizedBox(
            height: 120,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline, color: AppColors.mist, size: 32),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Forum ve stil önerileri — Hafta 9',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
