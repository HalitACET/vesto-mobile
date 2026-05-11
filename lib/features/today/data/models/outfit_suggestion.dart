import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';

class OutfitSuggestion {
  final String title;            // "Klasik", "Renk Uyumlu", "Yeni Dene"
  final WardrobeItem? top;
  final WardrobeItem? bottom;
  final WardrobeItem? outerwear;
  final WardrobeItem? shoes;
  final WardrobeItem? accessory;
  final String reasoning;        // "En sık giydiğin kıyafetler"

  OutfitSuggestion({
    required this.title,
    this.top,
    this.bottom,
    this.outerwear,
    this.shoes,
    this.accessory,
    required this.reasoning,
  });

  List<WardrobeItem> get items => [
    if (top != null) top!,
    if (bottom != null) bottom!,
    if (outerwear != null) outerwear!,
    if (shoes != null) shoes!,
    if (accessory != null) accessory!,
  ];
}
