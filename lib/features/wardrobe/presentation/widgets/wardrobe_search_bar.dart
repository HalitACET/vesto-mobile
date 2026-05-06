import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';

/// Arama kutusu — marka, notlar, subcategory içinde arama yapar.
/// Clear butonu search doluysa otomatik görünür.
class WardrobeSearchBar extends ConsumerStatefulWidget {
  const WardrobeSearchBar({super.key});

  @override
  ConsumerState<WardrobeSearchBar> createState() => _WardrobeSearchBarState();
}

class _WardrobeSearchBarState extends ConsumerState<WardrobeSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _isFocused = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(wardrobeSearchProvider.notifier).setSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isFocused ? AppColors.onyx : AppColors.graphite;
    final hasText = _controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: _isFocused ? 1.0 : 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.graphite),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Marka, kategori veya not ara',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.stone,
                  fontStyle: FontStyle.normal,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {}); // clear butonu için
                ref.read(wardrobeSearchProvider.notifier).setSearch(value);
              },
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: _clear,
              child: const Icon(Icons.close, size: 18, color: AppColors.graphite),
            )
          else
            const SizedBox(width: 18),
        ],
      ),
    );
  }
}
