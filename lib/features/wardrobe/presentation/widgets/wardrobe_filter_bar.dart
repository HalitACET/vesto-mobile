import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/core/widgets/atoms/vesto_chip.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';

/// Yatay kaydırılabilir kategori filtre bar'ı.
/// "Tümü" seçeneği + 6 ItemCategory chip'i.
class WardrobeFilterBar extends ConsumerWidget {
  const WardrobeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(wardrobeFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          VestoChip(
            label: 'TÜMÜ',
            selected: selectedFilter == null,
            onTap: () => ref.read(wardrobeFilterProvider.notifier).setFilter(null),
          ),
          const SizedBox(width: 8),
          // Kategori chip'leri
          ...ItemCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: VestoChip(
                label: category.displayLabel.toUpperCase(),
                selected: selectedFilter == category,
                onTap: () => ref
                    .read(wardrobeFilterProvider.notifier)
                    .setFilter(selectedFilter == category ? null : category),
              ),
            );
          }),
        ],
      ),
    );
  }
}


