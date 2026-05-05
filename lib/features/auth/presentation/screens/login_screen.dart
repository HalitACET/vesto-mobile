import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/app/router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/constants/app_strings.dart';
import 'package:mobile/core/utils/validators.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';
import 'package:mobile/core/widgets/atoms/vesto_text_field.dart';
import 'package:mobile/core/widgets/molecules/vesto_snack_bar.dart';
import 'package:mobile/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:mobile/features/auth/presentation/providers/login_notifier.dart';
import 'package:mobile/features/auth/presentation/widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _emailError;
  String? _passwordError;
  int _logoBrandTapCount = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogoBrandTap() {
    _logoBrandTapCount++;
    if (_logoBrandTapCount >= 5) {
      _logoBrandTapCount = 0;
      context.push(AppRoutes.devShowcase);
    }
  }

  bool _validate() {
    final emailErr = Validators.email(_emailController.text);
    final passErr = Validators.password(_passwordController.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    return emailErr == null && passErr == null;
  }

  Future<void> _login() async {
    if (!_validate()) return;
    await ref.read(loginNotifierProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
  }

  Future<void> _loginWithGoogle() async {
    await ref.read(loginNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    ref.listen(loginNotifierProvider, (_, next) {
      if (next.hasError) {
        final failure = next.error;
        final message = failure is AuthFailure
            ? failure.toUserMessage()
            : AppStrings.genericError;
        if (message.isNotEmpty) {
          VestoSnackBar.show(
            context,
            message: message,
            type: VestoSnackBarType.error,
          );
        }
      }
    });

    final isLoading = ref.watch(loginNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: spacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing.xxl * 1.5),
              _Header(onLogoBrandTap: _handleLogoBrandTap),
              SizedBox(height: spacing.xl),
              VestoTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                label: AppStrings.emailLabel,
                hint: 'ornek@vesto.app',
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                onChanged: (_) => setState(() => _emailError = null),
                onSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              SizedBox(height: spacing.md),
              VestoTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: AppStrings.passwordLabel,
                errorText: _passwordError,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onChanged: (_) => setState(() => _passwordError = null),
                onSubmitted: (_) => _login(),
              ),
              SizedBox(height: spacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.forgotPassword),
                  child: Text(
                    AppStrings.forgotPassword,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.stone,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.mist,
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing.xl),
              VestoButton(
                label: AppStrings.loginButton,
                onPressed: isLoading ? null : _login,
                isLoading: isLoading,
              ),
              SizedBox(height: spacing.lg),
              _OrDivider(),
              SizedBox(height: spacing.lg),
              SocialLoginButton(
                label: AppStrings.loginWithGoogle,
                onPressed: isLoading ? null : _loginWithGoogle,
              ),
              SizedBox(height: spacing.xl),
              _SignupLink(),
              SizedBox(height: spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onLogoBrandTap});
  final VoidCallback onLogoBrandTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onLogoBrandTap,
          child: Text(
            'VESTO',
            style: AppTypography.labelLarge.copyWith(
              letterSpacing: 8,
              color: AppColors.stone,
            ),
          ),
        ),
        SizedBox(height: spacing.lg),
        Text(AppStrings.loginTitle, style: AppTypography.displayMedium),
        SizedBox(height: spacing.sm),
        Text(
          AppStrings.loginSubtitle,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.mist, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppStrings.orDivider, style: AppTypography.labelSmall),
        ),
        const Expanded(child: Divider(color: AppColors.mist, thickness: 1)),
      ],
    );
  }
}

class _SignupLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.signup),
        child: RichText(
          text: TextSpan(
            style: AppTypography.bodySmall,
            children: [
              const TextSpan(text: 'Hesabın yok mu?  '),
              TextSpan(
                text: AppStrings.noAccount,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onyx,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.graphite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
