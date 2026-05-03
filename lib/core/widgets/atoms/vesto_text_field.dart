import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';

/// Özel metin alanı — Material TextField wrapper, sıfırdan border sistemi.
/// Hata durumunda kırmızı yok: Stone rengi border kullanılır (lüks dergisi soğukkanlılığı).
class VestoTextField extends StatefulWidget {
  const VestoTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<VestoTextField> createState() => _VestoTextFieldState();
}

class _VestoTextFieldState extends State<VestoTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (!widget.enabled) return AppColors.mist;
    if (widget.errorText != null) return AppColors.stone;
    if (_isFocused) return AppColors.onyx;
    return AppColors.graphite;
  }

  double get _borderWidth => _isFocused ? 1.5 : 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final radius = context.radius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isDark ? AppColors.charcoal : AppColors.white,
            borderRadius: radius.smBorderRadius,
            border: Border.all(color: _borderColor, width: _borderWidth),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscure,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            autofillHints: widget.autofillHints,
            style: AppTypography.bodyMedium.copyWith(
              color: widget.enabled
                  ? (isDark ? AppColors.pearl : AppColors.onyx)
                  : AppColors.stone,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: AppTypography.bodySmall.copyWith(
                color: _isFocused ? AppColors.onyx : AppColors.stone,
              ),
              hintStyle:
                  AppTypography.bodyMedium.copyWith(color: AppColors.stone),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: widget.obscureText
                  ? GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: AppColors.stone,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.stone,
              letterSpacing: 0.3,
            ),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: AppTypography.labelSmall,
          ),
        ],
      ],
    );
  }
}
