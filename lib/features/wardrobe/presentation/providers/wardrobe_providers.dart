import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_view.dart';
import 'package:mobile/features/wardrobe/data/repositories/wardrobe_repository.dart';

part 'wardrobe_providers.g.dart';

@riverpod
Stream<List<WardrobeItem>> userWardrobeItems(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value([]);
  
  return ref.watch(wardrobeRepositoryProvider).watchUserItems(uid);
}

@riverpod
class WardrobeFilter extends _$WardrobeFilter {
  @override
  ItemCategory? build() => null;

  void setFilter(ItemCategory? category) {
    state = category;
  }
}

@riverpod
class WardrobeSearch extends _$WardrobeSearch {
  @override
  String build() => '';

  void setSearch(String query) {
    state = query;
  }
}

@riverpod
class WardrobeViewMode extends _$WardrobeViewMode {
  @override
  WardrobeView build() => WardrobeView.grid;

  void toggle() {
    state = state == WardrobeView.grid ? WardrobeView.list : WardrobeView.grid;
  }
}

@riverpod
List<WardrobeItem> filteredWardrobeItems(Ref ref) {
  final allItems = ref.watch(userWardrobeItemsProvider).valueOrNull ?? [];
  final filter = ref.watch(wardrobeFilterProvider);
  final search = ref.watch(wardrobeSearchProvider);

  return allItems.where((item) {
    if (filter != null && item.category != filter) return false;
    if (search.isNotEmpty) {
      final lower = search.toLowerCase();
      final brandMatch = item.brand?.toLowerCase().contains(lower) ?? false;
      final notesMatch = item.notes?.toLowerCase().contains(lower) ?? false;
      final subcategoryMatch = item.subcategory.toLowerCase().contains(lower);
      return brandMatch || notesMatch || subcategoryMatch;
    }
    return true;
  }).toList();
}
