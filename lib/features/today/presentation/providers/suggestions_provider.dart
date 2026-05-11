import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobile/features/today/data/models/outfit_suggestion.dart';
import 'package:mobile/features/today/data/services/outfit_suggester.dart';
import 'package:mobile/features/today/presentation/providers/weather_provider.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suggestions_provider.g.dart';

@riverpod
Future<List<OutfitSuggestion>> outfitSuggestions(Ref ref) async {
  try {
    final weatherAsync = await ref.watch(currentWeatherProvider.future);
    
    final wardrobeItemsAsync = await ref.watch(userWardrobeItemsProvider.future)
        .timeout(const Duration(seconds: 15));

    debugPrint('DEBUG: Wardrobe items found: ${wardrobeItemsAsync.length}');

    if (wardrobeItemsAsync.isEmpty) return [];

    final suggester = OutfitSuggester(
      wardrobeItems: wardrobeItemsAsync,
      weather: weatherAsync,
    );

    return suggester.generateSuggestions();
  } on TimeoutException catch (_) {
    throw Exception('Veriler alınamadı (Zaman aşımı). Lütfen internet bağlantınızı kontrol edin.');
  } catch (e) {
    throw Exception('Öneriler hazırlanamadı: $e');
  }
}
