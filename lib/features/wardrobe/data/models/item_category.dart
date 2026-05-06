/// Kıyafet kategorisi enum'u.
/// Tüm subcategory string'leri `core/constants/categories.dart`'tan gelir.
enum ItemCategory {
  top('top'),
  bottom('bottom'),
  outerwear('outerwear'),
  footwear('footwear'),
  accessory('accessory'),
  underwear('underwear');

  const ItemCategory(this.value);
  final String value;

  static ItemCategory? fromString(String? value) {
    if (value == null) return null;
    for (final c in ItemCategory.values) {
      if (c.value == value) return c;
    }
    return null;
  }

  String get displayLabel => switch (this) {
        ItemCategory.top => 'Üst Giyim',
        ItemCategory.bottom => 'Alt Giyim',
        ItemCategory.outerwear => 'Dış Giyim',
        ItemCategory.footwear => 'Ayakkabı',
        ItemCategory.accessory => 'Aksesuar',
        ItemCategory.underwear => 'İç Giyim',
      };
}
