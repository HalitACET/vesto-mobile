import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';

/// Özel AppBar — sol hizalı Cormorant başlık, alt 1px border.
/// centerTitle: false çünkü moda dergilerinde başlık sol marjda durur.
class VestoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VestoAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showBorder = true,
  }) : assert(
          actions == null || actions.length <= 2,
          'VestoAppBar max 2 action destekler',
        );

  final String? title;
  final Widget? leading;

  /// Maksimum 2 action icon.
  final List<Widget>? actions;
  final bool showBorder;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? AppColors.onyx : AppColors.white;
    final fg = isDark ? AppColors.pearl : AppColors.onyx;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.graphite : AppColors.mist,
                  width: 1,
                ),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (leading != null)
                  leading!
                else
                  _BackButton(color: fg),
                if (title != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.headlineSmall.copyWith(color: fg),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                if (actions != null)
                  Row(mainAxisSize: MainAxisSize.min, children: actions!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    if (!Navigator.canPop(context)) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Icon(Icons.chevron_left, size: 24, color: color),
      ),
    );
  }
}
