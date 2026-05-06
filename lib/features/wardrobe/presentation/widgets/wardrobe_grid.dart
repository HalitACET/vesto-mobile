import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_item_card.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_skeleton_card.dart';

/// Kıyafet grid görünümü (2 sütunlu).
class WardrobeGrid extends StatelessWidget {
  const WardrobeGrid({
    super.key,
    required this.items,
    required this.onTap,
    required this.onLongPress,
    this.isLoading = false,
  });

  final List<WardrobeItem> items;
  final void Function(WardrobeItem) onTap;
  final void Function(WardrobeItem) onLongPress;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const WardrobeSkeletonCard(isListMode: false),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return WardrobeItemCard(
          item: item,
          onTap: () => onTap(item),
          onLongPress: () => onLongPress(item),
          isListMode: false,
        );
      },
    );
  }
}

/// Kıyafet liste görünümü (1 sütunlu, kompakt).
class WardrobeList extends ConsumerWidget {
  const WardrobeList({
    super.key,
    required this.items,
    required this.onTap,
    required this.onLongPress,
    this.isLoading = false,
  });

  final List<WardrobeItem> items;
  final void Function(WardrobeItem) onTap;
  final void Function(WardrobeItem) onLongPress;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wardrobeViewModeProvider); // reaktivite için

    if (isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => const WardrobeSkeletonCard(isListMode: true),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final item = items[index];
        return WardrobeItemCard(
          item: item,
          onTap: () => onTap(item),
          onLongPress: () => onLongPress(item),
          isListMode: true,
        );
      },
    );
  }
}
