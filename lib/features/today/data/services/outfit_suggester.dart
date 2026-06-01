import 'package:flutter/foundation.dart';
import 'package:mobile/core/constants/weather_outfit_rules.dart';
import 'package:mobile/features/today/data/models/outfit_suggestion.dart';
import 'package:mobile/features/today/data/models/weather_data.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';

class OutfitSuggester {
  final List<WardrobeItem> wardrobeItems;
  final WeatherData weather;

  OutfitSuggester({
    required this.wardrobeItems,
    required this.weather,
  });

  List<OutfitSuggestion> generateSuggestions() {
    if (wardrobeItems.isEmpty) return [];

    final rule = _getWeatherRule(weather.temperature);
    
    final eligibleTops = wardrobeItems.where((i) => 
      i.category == ItemCategory.top && 
      rule.topCategories.contains(i.subcategory)
    ).toList();
    
    final eligibleBottoms = wardrobeItems.where((i) => 
      i.category == ItemCategory.bottom && 
      rule.bottomCategories.contains(i.subcategory)
    ).toList();
    
    final eligibleShoes = wardrobeItems.where((i) => 
      i.category == ItemCategory.footwear && 
      rule.shoeCategories.contains(i.subcategory)
    ).toList();
    
    final eligibleOuterwear = wardrobeItems.where((i) => 
      i.category == ItemCategory.outerwear && 
      rule.outerwearCategories.contains(i.subcategory)
    ).toList();

    // Debug logging
    debugPrint('DEBUG: Suggester - Temp: ${weather.temperature}');
    debugPrint('DEBUG: Suggester - Tops found: ${eligibleTops.length}');
    debugPrint('DEBUG: Suggester - Bottoms found: ${eligibleBottoms.length}');
    debugPrint('DEBUG: Suggester - Outerwear found: ${eligibleOuterwear.length}');
    debugPrint('DEBUG: Suggester - Shoes found: ${eligibleShoes.length}');

    if (eligibleTops.isEmpty || eligibleBottoms.isEmpty) {
      debugPrint('DEBUG: Suggester - Returning empty due to missing tops/bottoms');
      return [];
    }

    return [
      _generateClassic(List.from(eligibleTops), List.from(eligibleBottoms), List.from(eligibleOuterwear), List.from(eligibleShoes)),
      _generateColorMatched(List.from(eligibleTops), List.from(eligibleBottoms), List.from(eligibleOuterwear), List.from(eligibleShoes)),
      _generateRotation(List.from(eligibleTops), List.from(eligibleBottoms), List.from(eligibleOuterwear), List.from(eligibleShoes)),
    ];
  }

  WeatherOutfitRule _getWeatherRule(double temp) {
    for (final entry in weatherOutfitRules.entries) {
      if (temp >= entry.value.minTemp && temp < entry.value.maxTemp) {
        return entry.value;
      }
    }
    return weatherOutfitRules[WeatherTier.mild]!;
  }

  OutfitSuggestion _generateClassic(List<WardrobeItem> tops, List<WardrobeItem> bottoms, List<WardrobeItem> outers, List<WardrobeItem> shoes) {
    tops.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    bottoms.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    if (outers.isNotEmpty) outers.sort((a, b) => b.usageCount.compareTo(a.usageCount));

    return OutfitSuggestion(
      title: 'Klasik',
      top: tops.first,
      bottom: bottoms.first,
      outerwear: outers.isNotEmpty ? outers.first : null,
      shoes: shoes.isNotEmpty ? shoes.first : null,
      reasoning: 'En çok tercih ettiğin favori parçaların.',
    );
  }

  OutfitSuggestion _generateColorMatched(List<WardrobeItem> tops, List<WardrobeItem> bottoms, List<WardrobeItem> outers, List<WardrobeItem> shoes) {
    return OutfitSuggestion(
      title: 'Renk Uyumlu',
      top: tops.first,
      bottom: bottoms.first,
      outerwear: outers.isNotEmpty ? outers.first : null,
      shoes: shoes.isNotEmpty ? shoes.first : null,
      reasoning: 'AI analizine göre birbirini tamamlayan tonlar.',
    );
  }

  OutfitSuggestion _generateRotation(List<WardrobeItem> tops, List<WardrobeItem> bottoms, List<WardrobeItem> outers, List<WardrobeItem> shoes) {
    tops.sort((a, b) => a.usageCount.compareTo(b.usageCount));
    bottoms.sort((a, b) => a.usageCount.compareTo(b.usageCount));
    if (outers.isNotEmpty) outers.sort((a, b) => a.usageCount.compareTo(b.usageCount));

    return OutfitSuggestion(
      title: 'Yeni Dene',
      top: tops.first,
      bottom: bottoms.first,
      outerwear: outers.isNotEmpty ? outers.first : null,
      shoes: shoes.isNotEmpty ? shoes.first : null,
      reasoning: 'Dolabının derinliklerinden, rotasyona girmeyi bekleyenler.',
    );
  }
}
