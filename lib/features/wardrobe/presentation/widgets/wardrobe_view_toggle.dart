import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_view.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';

/// AppBar'da kullanılan grid/list toggle butonu.
class WardrobeViewToggle extends ConsumerWidget {
  const WardrobeViewToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(wardrobeViewModeProvider);
    final isGrid = viewMode == WardrobeView.grid;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: IconButton(
        key: ValueKey(isGrid),
        icon: Icon(
          isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
          color: AppColors.onyx,
          size: 22,
        ),
        onPressed: () => ref.read(wardrobeViewModeProvider.notifier).toggle(),
        tooltip: isGrid ? 'Liste görünümü' : 'Izgara görünümü',
      ),
    );
  }
}
