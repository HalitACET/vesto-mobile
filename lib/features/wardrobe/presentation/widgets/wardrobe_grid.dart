import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_item_card.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_skeleton_card.dart';

import 'package:mobile/features/today/presentation/providers/weather_provider.dart';
import 'package:mobile/core/constants/weather_outfit_rules.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';

/// Kıyafet grid görünümü (2 sütunlu).
class WardrobeGrid extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(currentWeatherProvider).value;
    final rule = weather != null ? _getWeatherRule(weather.temperature) : null;

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
        itemBuilder: (_, _) => const WardrobeSkeletonCard(isListMode: false),
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
        final isSuitable = _checkSuitability(item, rule);

        return WardrobeItemCard(
          item: item,
          onTap: () => onTap(item),
          onLongPress: () => onLongPress(item),
          isListMode: false,
          isSuitableForToday: isSuitable,
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
    final weather = ref.watch(currentWeatherProvider).value;
    final rule = weather != null ? _getWeatherRule(weather.temperature) : null;

    if (isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, _) => const WardrobeSkeletonCard(isListMode: true),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final item = items[index];
        final isSuitable = _checkSuitability(item, rule);

        return WardrobeItemCard(
          item: item,
          onTap: () => onTap(item),
          onLongPress: () => onLongPress(item),
          isListMode: true,
          isSuitableForToday: isSuitable,
        );
      },
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

WeatherOutfitRule _getWeatherRule(double temp) {
  if (temp < 5) return weatherOutfitRules[WeatherTier.freezing]!;
  if (temp < 15) return weatherOutfitRules[WeatherTier.cold]!;
  if (temp < 22) return weatherOutfitRules[WeatherTier.cool]!;
  if (temp < 28) return weatherOutfitRules[WeatherTier.mild]!;
  return weatherOutfitRules[WeatherTier.hot]!;
}

bool _checkSuitability(WardrobeItem item, WeatherOutfitRule? rule) {
  if (rule == null) return false;

  final categories = switch (item.category) {
    ItemCategory.top => rule.topCategories,
    ItemCategory.bottom => rule.bottomCategories,
    ItemCategory.footwear => rule.shoeCategories,
    _ => <String>[],
  };

  return categories.any((cat) => 
    item.subcategory.toLowerCase().contains(cat.toLowerCase()) || 
    item.category.displayLabel.contains(cat)
  );
}
