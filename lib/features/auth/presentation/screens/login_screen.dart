import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/app/router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/constants/app_strings.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';
import 'package:mobile/core/widgets/atoms/vesto_text_field.dart';
import 'package:mobile/core/widgets/molecules/vesto_snack_bar.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';

/// Hafta 2: Design system ile yeniden yazılmış login ekranı.
/// Auth fonksiyonlarına dokunulmadı — Hafta 3 hedefi.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final spacing = context.spacing;

    ref.listen(authNotifierProvider, (_, next) {
      if (next.hasError) {
        VestoSnackBar.show(
          context,
          message: next.error.toString(),
          type: VestoSnackBarType.error,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              _LogoBrand(
                onSecretTap: () => context.push(AppRoutes.devShowcase),
              ),
              const Spacer(flex: 1),
              const _InputSection(),
              SizedBox(height: spacing.xl),
              VestoButton(
                label: AppStrings.signIn,
                onPressed: isLoading ? null : () {},
              ),
              SizedBox(height: spacing.md),
              VestoButton(
                label: AppStrings.continueAnonymously,
                variant: VestoButtonVariant.secondary,
                isLoading: isLoading,
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signInAnonymously(),
              ),
              SizedBox(height: spacing.md),
              VestoButton(
                label: 'Henüz üye değilim?',
                variant: VestoButtonVariant.ghost,
                onPressed: isLoading ? null : () {},
              ),
              const Spacer(flex: 3),
              const _Footer(),
              SizedBox(height: spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// VESTO logosu — 5 kez tapa basınca showcase açılır (debug easter egg).
class _LogoBrand extends StatefulWidget {
  const _LogoBrand({required this.onSecretTap});

  final VoidCallback onSecretTap;

  @override
  State<_LogoBrand> createState() => _LogoBrandState();
}

class _LogoBrandState extends State<_LogoBrand> {
  int _tapCount = 0;

  void _handleTap() {
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      widget.onSecretTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _handleTap,
          child: Text(
            'VESTO',
            style: AppTypography.labelLarge.copyWith(
              letterSpacing: 8,
              color: AppColors.stone,
            ),
          ),
        ),
        SizedBox(height: spacing.lg),
        Text(AppStrings.welcomeBack, style: AppTypography.displayMedium),
        SizedBox(height: spacing.sm),
        Text(
          'Stilinizi yönetin, kombinlerinizi keşfedin.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
        ),
      ],
    );
  }
}

class _InputSection extends StatelessWidget {
  const _InputSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      children: [
        const VestoTextField(
          label: AppStrings.emailLabel,
          hint: 'ornek@vesto.app',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: [AutofillHints.email],
          enabled: false,
        ),
        SizedBox(height: spacing.md),
        const VestoTextField(
          label: AppStrings.passwordLabel,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: [AutofillHints.password],
          enabled: false,
        ),
        SizedBox(height: spacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '— Hafta 3\'te aktif olacak —',
            style: AppTypography.labelSmall,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppStrings.appTagline, style: AppTypography.bodySmall),
    );
  }
}
