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
import 'package:mobile/features/auth/presentation/providers/forgot_password_notifier.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    final emailErr = Validators.email(_emailController.text);
    setState(() => _emailError = emailErr);
    return emailErr == null;
  }

  Future<void> _send() async {
    if (!_validate()) return;
    await ref
        .read(forgotPasswordProvider.notifier)
        .sendResetEmail(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    ref.listen(forgotPasswordProvider, (prev, next) {
      if (next.hasError) {
        final failure = next.error;
        final message = failure is AuthFailure
            ? failure.toUserMessage()
            : AppStrings.genericError;
        if (message.isNotEmpty) {
          VestoSnackBar.show(context, message: message, type: VestoSnackBarType.error);
        }
      } else if (prev?.isLoading == true && next.hasValue) {
        VestoSnackBar.show(
          context,
          message: AppStrings.forgotPasswordSuccess,
          type: VestoSnackBarType.success,
        );
        context.pop();
      }
    });

    final isLoading = ref.watch(forgotPasswordProvider).isLoading;

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
              Text(AppStrings.forgotPasswordTitle, style: AppTypography.displayMedium),
              SizedBox(height: spacing.sm),
              Text(
                AppStrings.forgotPasswordSubtitle,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
              ),
              SizedBox(height: spacing.xl),
              VestoTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                label: AppStrings.emailLabel,
                hint: 'ornek@vesto.app',
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                onChanged: (_) => setState(() => _emailError = null),
                onSubmitted: (_) => _send(),
              ),
              SizedBox(height: spacing.xl),
              VestoButton(
                label: AppStrings.forgotPasswordButton,
                onPressed: isLoading ? null : _send,
                isLoading: isLoading,
              ),
              SizedBox(height: spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
