import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';

/// Google Sign-In butonu — secondary VestoButton estetiği ama Google ikonu ile.
/// SVG asset yerine basit "G" harfi kullanılır (resmi Google brand'e uygun basit varyant).
class SocialLoginButton extends StatefulWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton> {
  bool _pressed = false;

  bool get _isDisabled => widget.onPressed == null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;

    return GestureDetector(
      onTapDown: _isDisabled || widget.isLoading
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: _isDisabled || widget.isLoading
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.65 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius.sm),
            border: Border.all(
              color: _isDisabled ? AppColors.mist : AppColors.graphite,
              width: 1,
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.onyx,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GoogleIcon(disabled: _isDisabled),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: AppTypography.labelLarge.copyWith(
                        color: _isDisabled ? AppColors.stone : AppColors.onyx,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon({this.disabled = false});

  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: disabled ? AppColors.mist : AppColors.graphite,
          width: 1,
        ),
      ),
      child: Text(
        'G',
        style: AppTypography.labelSmall.copyWith(
          color: disabled ? AppColors.mist : AppColors.onyx,
          fontSize: 10,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
