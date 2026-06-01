import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/data/repositories/wardrobe_repository.dart';
import 'package:mobile/features/outfits/data/models/outfit.dart';
import 'package:mobile/features/outfits/data/repositories/outfit_repository.dart';

part 'outfit_providers.g.dart';

@riverpod
OutfitRepository outfitRepository(Ref ref) {
  return OutfitRepository();
}

@Riverpod(keepAlive: true)
Stream<List<Outfit>> outfitsStream(Ref ref) {
  // Use authStateChanges directly to avoid .value loading state issues
  return ref.watch(authStateChangesProvider).when(
    data: (user) {
      if (user == null) return Stream.value([]);
      debugPrint('DEBUG: Fetching outfits for user: ${user.uid}');
      return ref.watch(outfitRepositoryProvider).watchOutfits(user.uid);
    },
    loading: () {
      debugPrint('DEBUG: Auth state is loading...');
      return const Stream.empty();
    },
    error: (err, stack) {
      debugPrint('DEBUG: Auth error: $err');
      return Stream.error(err);
    },
  );
}

enum OutfitFilter { all, favorites, recentlyWorn, neverWorn }

@riverpod
class OutfitFilterState extends _$OutfitFilterState {
  @override
  OutfitFilter build() => OutfitFilter.all;

  void setFilter(OutfitFilter filter) => state = filter;
}

@riverpod
List<Outfit> filteredOutfits(Ref ref) {
  final outfits = ref.watch(outfitsStreamProvider).value ?? [];
  final filter = ref.watch(outfitFilterStateProvider);

  switch (filter) {
    case OutfitFilter.all:
      return outfits;
    case OutfitFilter.favorites:
      return outfits.where((o) => o.isFavorite).toList();
    case OutfitFilter.recentlyWorn:
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      return outfits.where((o) => o.lastWorn != null && o.lastWorn!.isAfter(sevenDaysAgo)).toList();
    case OutfitFilter.neverWorn:
      return outfits.where((o) => o.wearCount == 0).toList();
  }
}

// Provider to fetch specific items for an outfit
// Use a String instead of List to ensure stable caching in Riverpod
@riverpod
Future<List<WardrobeItem>> wardrobeItemsByIds(Ref ref, String idsString) async {
  if (idsString.isEmpty) return [];
  final ids = idsString.split(',').where((id) => id.isNotEmpty).toList();
  
  debugPrint('DEBUG: Fetching wardrobe items by IDs: $ids');
  return ref.watch(wardrobeRepositoryProvider).getItemsByIds(ids);
}

@riverpod
String mannequinType(Ref ref) {
  final user = ref.watch(currentUserProvider).value;
  
  switch (user?.gender?.value) {
    case 'female': return 'female';
    case 'male': return 'male';
    default: return 'unisex';
  }
}

@riverpod
Stream<Outfit?> outfitStream(Ref ref, String outfitId) {
  return ref.watch(outfitRepositoryProvider).watchOutfit(outfitId);
}
