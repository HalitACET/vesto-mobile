import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/outfits/data/models/outfit.dart';
import 'package:mobile/features/outfits/data/models/outfit_items.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';

part 'outfit_editor_notifier.freezed.dart';
part 'outfit_editor_notifier.g.dart';

@freezed
abstract class OutfitEditorState with _$OutfitEditorState {
  const factory OutfitEditorState({
    String? outfitId,
    @Default('') String name,
    String? topId,
    String? bottomId,
    String? shoesId,
    String? accessoryId,
    @Default([]) List<String> tags,
    @Default(false) bool isSaving,
    @Default(false) bool hasUnsavedChanges,
  }) = _OutfitEditorState;
}

extension OutfitEditorStateX on OutfitEditorState {
  bool get isValid => topId != null || bottomId != null || shoesId != null || accessoryId != null;
}

@riverpod
class OutfitEditor extends _$OutfitEditor {
  @override
  OutfitEditorState build([Outfit? initialOutfit]) {
    if (initialOutfit != null) {
      return OutfitEditorState(
        outfitId: initialOutfit.id,
        name: initialOutfit.name,
        topId: initialOutfit.items.topId,
        bottomId: initialOutfit.items.bottomId,
        shoesId: initialOutfit.items.shoesId,
        accessoryId: initialOutfit.items.accessoryId,
        tags: initialOutfit.tags,
      );
    }
    return const OutfitEditorState();
  }

  void updateName(String name) {
    state = state.copyWith(name: name, hasUnsavedChanges: true);
  }

  void setSlot(ItemCategory category, String? itemId) {
    switch (category) {
      case ItemCategory.top:
        state = state.copyWith(topId: itemId, hasUnsavedChanges: true);
        break;
      case ItemCategory.bottom:
        state = state.copyWith(bottomId: itemId, hasUnsavedChanges: true);
        break;
      case ItemCategory.footwear:
        state = state.copyWith(shoesId: itemId, hasUnsavedChanges: true);
        break;
      case ItemCategory.accessory:
        state = state.copyWith(accessoryId: itemId, hasUnsavedChanges: true);
        break;
      default:
        break;
    }
  }

  void addTag(String tag) {
    if (!state.tags.contains(tag)) {
      state = state.copyWith(
        tags: [...state.tags, tag],
        hasUnsavedChanges: true,
      );
    }
  }

  void removeTag(String tag) {
    state = state.copyWith(
      tags: state.tags.where((t) => t != tag).toList(),
      hasUnsavedChanges: true,
    );
  }

  Future<void> save() async {
    if (!state.isValid) return;
    
    state = state.copyWith(isSaving: true);
    
    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user == null) throw Exception('User not logged in');

      final outfit = Outfit(
        id: state.outfitId ?? '',
        userId: user.uid,
        name: state.name.isEmpty ? 'Kombin #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}' : state.name,
        items: OutfitItems(
          topId: state.topId,
          bottomId: state.bottomId,
          shoesId: state.shoesId,
          accessoryId: state.accessoryId,
        ),
        tags: state.tags,
        createdAt: DateTime.now(),
      );

      if (state.outfitId == null) {
        await ref.read(outfitRepositoryProvider).createOutfit(outfit);
      } else {
        await ref.read(outfitRepositoryProvider).updateOutfit(outfit);
      }
      
      state = state.copyWith(isSaving: false, hasUnsavedChanges: false);
    } catch (e) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }
}
