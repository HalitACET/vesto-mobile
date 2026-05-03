import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/widgets/atoms/vesto_loading_indicator.dart';

enum VestoButtonVariant { primary, secondary, ghost, destructive }

enum VestoButtonSize { small, medium, large }

/// Tek widget + enum varyant — tüm buton ihtiyacını karşılar.
/// Material ElevatedButton/OutlinedButton kullanılmaz: tam kontrol için sıfırdan.
class VestoButton extends StatefulWidget {
  const VestoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = VestoButtonVariant.primary,
    this.size = VestoButtonSize.large,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final VestoButtonVariant variant;
  final VestoButtonSize size;
  final bool isLoading;
  final IconData? icon;

  @override
  State<VestoButton> createState() => _VestoButtonState();
}

class _VestoButtonState extends State<VestoButton> {
  bool _pressed = false;

  double get _height => switch (widget.size) {
        VestoButtonSize.small => 32,
        VestoButtonSize.medium => 44,
        VestoButtonSize.large => 56,
      };

  bool get _isDisabled => widget.onPressed == null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;

    final Color bg;
    final Color fg;
    final Border? border;

    if (_isDisabled) {
      bg = AppColors.mist;
      fg = AppColors.stone;
      border = null;
    } else {
      switch (widget.variant) {
        case VestoButtonVariant.primary:
        case VestoButtonVariant.destructive:
          bg = AppColors.onyx;
          fg = AppColors.pearl;
          border = null;
        case VestoButtonVariant.secondary:
          bg = Colors.transparent;
          fg = AppColors.onyx;
          border = Border.all(color: AppColors.onyx, width: 1);
        case VestoButtonVariant.ghost:
          bg = Colors.transparent;
          fg = AppColors.onyx;
          border = null;
      }
    }

    final content = widget.isLoading
        ? VestoLoadingIndicator(
            size: _height * 0.4,
            color: fg,
          ).animate().fadeIn(duration: 150.ms)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label.toUpperCase(),
                style: AppTypography.labelLarge.copyWith(color: fg),
              ),
            ],
          ).animate().fadeIn(duration: 150.ms);

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
          height: _height,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius.sm),
            border: border,
          ),
          child: content,
        ),
      ),
    );
  }
}
