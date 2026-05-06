import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/constants/categories.dart';
import 'package:mobile/core/widgets/atoms/vesto_chip.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';

/// Seçilen kategoriye bağlı alt kategorileri listeler.
/// Wrap kullanarak tüm ekranı kaplayacak şekilde (alt alta) dökülür.
class SubcategoryChips extends StatelessWidget {
  const SubcategoryChips({
    super.key,
    required this.selectedCategory,
    required this.selectedSubcategory,
    required this.onSubcategorySelected,
  });

  final ItemCategory? selectedCategory;
  final String? selectedSubcategory;
  final ValueChanged<String> onSubcategorySelected;

  @override
  Widget build(BuildContext context) {
    if (selectedCategory == null) return const SizedBox.shrink();

    final subcategories = WardrobeCategories.getSubcategories(selectedCategory!);
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
      child: Wrap(
        spacing: spacing.sm,
        runSpacing: spacing.sm,
        children: subcategories.map((subKey) {
          final isSelected = subKey == selectedSubcategory;
          return VestoChip(
            label: WardrobeCategories.subcategoryLabel(subKey),
            selected: isSelected,
            onTap: () => onSubcategorySelected(subKey),
          );
        }).toList(),
      ),
    );
  }
}
