import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/constants/app_strings.dart';
import 'package:mobile/core/utils/validators.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';
import 'package:mobile/core/widgets/atoms/vesto_text_field.dart';
import 'package:mobile/core/widgets/molecules/vesto_snack_bar.dart';
import 'package:mobile/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:mobile/features/auth/presentation/providers/signup_notifier.dart';
import 'package:mobile/features/auth/presentation/widgets/password_strength_indicator.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    final nameErr = Validators.displayName(_nameController.text);
    final emailErr = Validators.email(_emailController.text);
    final passErr = Validators.passwordSignup(_passwordController.text);
    final confirmErr =
        Validators.matchField(_confirmController.text, _passwordController.text);
    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
    });
    return nameErr == null &&
        emailErr == null &&
        passErr == null &&
        confirmErr == null;
  }

  Future<void> _signup() async {
    if (!_validate()) return;
    await ref.read(signupNotifierProvider.notifier).signup(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    ref.listen(signupNotifierProvider, (_, next) {
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

    final isLoading = ref.watch(signupNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onyx, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: spacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing.lg),
              Text(AppStrings.signupTitle, style: AppTypography.displayMedium),
              SizedBox(height: spacing.sm),
              Text(
                AppStrings.signupSubtitle,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
              ),
              SizedBox(height: spacing.xl),
              VestoTextField(
                controller: _nameController,
                focusNode: _nameFocus,
                label: AppStrings.displayNameLabel,
                errorText: _nameError,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() => _nameError = null),
                onSubmitted: (_) => _emailFocus.requestFocus(),
              ),
              SizedBox(height: spacing.md),
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
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) {
                  setState(() => _passwordError = null);
                },
                onSubmitted: (_) => _confirmFocus.requestFocus(),
              ),
              SizedBox(height: spacing.sm),
              // Şifre güçlü mü göstergesi
              ValueListenableBuilder(
                valueListenable: _passwordController,
                builder: (_, __, ___) => PasswordStrengthIndicator(
                  password: _passwordController.text,
                ),
              ),
              SizedBox(height: spacing.md),
              VestoTextField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                label: AppStrings.confirmPasswordLabel,
                errorText: _confirmError,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() => _confirmError = null),
                onSubmitted: (_) => _signup(),
              ),
              SizedBox(height: spacing.xl),
              VestoButton(
                label: AppStrings.signupButton,
                onPressed: isLoading ? null : _signup,
                isLoading: isLoading,
              ),
              SizedBox(height: spacing.lg),
              _LoginLink(),
              SizedBox(height: spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.pop(),
        child: RichText(
          text: TextSpan(
            style: AppTypography.bodySmall,
            children: [
              const TextSpan(text: 'Zaten hesabın var mı?  '),
              TextSpan(
                text: AppStrings.hasAccount,
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
