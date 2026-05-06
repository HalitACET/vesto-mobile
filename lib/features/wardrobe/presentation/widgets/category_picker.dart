import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/widgets/atoms/vesto_chip.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';

/// Kıyafet ekleme formunda üst kategori seçimi.
/// Horizontal scroll edilebilir liste sunar.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final ItemCategory? selectedCategory;
  final ValueChanged<ItemCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      // Kenarlara padding vererek scroll hissini iyileştiriyoruz
      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
      child: Row(
        children: ItemCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: EdgeInsets.only(right: spacing.sm),
            child: VestoChip(
              label: category.displayLabel,
              selected: isSelected,
              onTap: () => onCategorySelected(category),
            ),
          );
        }).toList(),
      ),
    );
  }
}
