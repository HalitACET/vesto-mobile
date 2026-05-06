import 'package:mobile/features/wardrobe/data/models/item_category.dart';

/// Kıyafet kategorisi hiyerarşisi.
/// Hard-coded string yasak — tüm kategori/subcategory string'leri buradan gelir.
///
/// Kullanım:
///   WardrobeCategories.subcategories[ItemCategory.top]  // → ['tshirt', 'shirt', ...]
///   WardrobeCategories.subcategoryLabel('tshirt')       // → 'Tişört'
abstract class WardrobeCategories {
  /// Her kategori altındaki alt kategori key'leri.
  static const Map<ItemCategory, List<String>> subcategories = {
    ItemCategory.top: [
      'tshirt',
      'shirt',
      'blouse',
      'sweater',
      'hoodie',
      'tank_top',
      'polo',
    ],
    ItemCategory.bottom: [
      'jeans',
      'trousers',
      'shorts',
      'skirt',
      'leggings',
    ],
    ItemCategory.outerwear: [
      'jacket',
      'coat',
      'blazer',
      'cardigan',
      'vest',
    ],
    ItemCategory.footwear: [
      'sneakers',
      'boots',
      'heels',
      'flats',
      'sandals',
    ],
    ItemCategory.accessory: [
      'belt',
      'scarf',
      'hat',
      'bag',
      'jewelry',
      'sunglasses',
      'watch',
    ],
    ItemCategory.underwear: [
      'underwear_general',
      'socks',
      'bra',
      'boxers',
    ],
  };

  /// Subcategory key → Türkçe görüntü adı.
  static const Map<String, String> _subcategoryLabels = {
    // Top
    'tshirt': 'Tişört',
    'shirt': 'Gömlek',
    'blouse': 'Bluz',
    'sweater': 'Kazak',
    'hoodie': 'Sweatshirt',
    'tank_top': 'Atlet',
    'polo': 'Polo',
    // Bottom
    'jeans': 'Kot Pantolon',
    'trousers': 'Pantolon',
    'shorts': 'Şort',
    'skirt': 'Etek',
    'leggings': 'Tayt',
    // Outerwear
    'jacket': 'Ceket',
    'coat': 'Palto',
    'blazer': 'Blazer',
    'cardigan': 'Hırka',
    'vest': 'Yelek',
    // Footwear
    'sneakers': 'Spor Ayakkabı',
    'boots': 'Bot',
    'heels': 'Topuklu',
    'flats': 'Babet',
    'sandals': 'Sandalet',
    // Accessory
    'belt': 'Kemer',
    'scarf': 'Eşarp',
    'hat': 'Şapka',
    'bag': 'Çanta',
    'jewelry': 'Takı',
    'sunglasses': 'Güneş Gözlüğü',
    'watch': 'Saat',
    // Underwear
    'underwear_general': 'İç Çamaşır',
    'socks': 'Çorap',
    'bra': 'Sütyen',
    'boxers': 'Boxer',
  };

  /// Subcategory key'inden Türkçe etiketi döndürür.
  static String subcategoryLabel(String key) =>
      _subcategoryLabels[key] ?? key;

  /// Bir kategori için subcategory listesini döndürür.
  static List<String> getSubcategories(ItemCategory category) =>
      subcategories[category] ?? [];
}
