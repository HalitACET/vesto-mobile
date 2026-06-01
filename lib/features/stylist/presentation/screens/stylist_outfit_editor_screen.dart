import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/utils/mannequin_utils.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/outfits/data/models/outfit_items.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/outfits/presentation/widgets/outfit_slot.dart';
import 'package:mobile/features/stylist/data/models/outfit_recommendation.dart';
import 'package:mobile/features/stylist/data/repositories/stylist_repository.dart';
import 'package:mobile/features/stylist/presentation/widgets/public_wardrobe_picker_sheet.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stylist_outfit_editor_screen.freezed.dart';
part 'stylist_outfit_editor_screen.g.dart';

// ── State ────────────────────────────────────────────────────────────────────

@freezed
abstract class StylistEditorState with _$StylistEditorState {
  const factory StylistEditorState({
    String? topId,
    String? bottomId,
    String? shoesId,
    String? accessoryId,
    @Default('') String note,
    @Default(false) bool isSending,
    @Default(false) bool sent,
  }) = _StylistEditorState;
}

extension StylistEditorStateX on StylistEditorState {
  bool get isValid =>
      topId != null || bottomId != null || shoesId != null || accessoryId != null;
}

@riverpod
class StylistEditor extends _$StylistEditor {
  @override
  StylistEditorState build() => const StylistEditorState();

  void setSlot(ItemCategory category, String? itemId) {
    switch (category) {
      case ItemCategory.top:
        state = state.copyWith(topId: itemId);
        break;
      case ItemCategory.bottom:
        state = state.copyWith(bottomId: itemId);
        break;
      case ItemCategory.footwear:
        state = state.copyWith(shoesId: itemId);
        break;
      case ItemCategory.accessory:
        state = state.copyWith(accessoryId: itemId);
        break;
      default:
        break;
    }
  }

  void updateNote(String note) {
    state = state.copyWith(note: note);
  }

  Future<void> send(AppUser targetUser, AppUser currentUser) async {
    if (!state.isValid) return;
    state = state.copyWith(isSending: true);

    try {
      final recommendation = OutfitRecommendation(
        id: '',
        stylistId: currentUser.uid,
        stylistDisplayName: currentUser.displayName,
        stylistPhotoUrl: currentUser.photoURL,
        targetUserId: targetUser.uid,
        items: OutfitItems(
          topId: state.topId,
          bottomId: state.bottomId,
          shoesId: state.shoesId,
          accessoryId: state.accessoryId,
        ),
        note: state.note,
        createdAt: DateTime.now(),
      );

      await StylistRepository().sendRecommendation(recommendation);
      state = state.copyWith(isSending: false, sent: true);
    } catch (e) {
      state = state.copyWith(isSending: false);
      rethrow;
    }
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class StylistOutfitEditorScreen extends ConsumerWidget {
  final AppUser targetUser;
  const StylistOutfitEditorScreen({required this.targetUser, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(stylistEditorProvider);
    final notifier = ref.read(stylistEditorProvider.notifier);
    final currentUserAsync = ref.watch(currentUserProvider);
    final mannequin = ref.watch(mannequinTypeProvider);

    // Sent → pop geri
    if (editorState.sent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Öneri gönderildi! ✦'),
              backgroundColor: Colors.black,
            ),
          );
          context.pop();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.onyx, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kombin Öner',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onyx,
              ),
            ),
            Text(
              '${targetUser.displayName} için',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.stone,
              ),
            ),
          ],
        ),
        actions: [
          if (editorState.isSending)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: AppColors.onyx)),
              ),
            )
          else
            TextButton(
              onPressed: editorState.isValid
                  ? () async {
                      final currentUser = currentUserAsync.value;
                      if (currentUser == null) return;
                      try {
                        await notifier.send(targetUser, currentUser);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hata: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              child: Text(
                'GÖNDER',
                style: TextStyle(
                  color:
                      editorState.isValid ? AppColors.onyx : AppColors.stone,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Note field
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
            child: TextField(
              onChanged: notifier.updateNote,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Kısa bir not yaz (isteğe bağlı)…',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.stone.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterStyle:
                    const TextStyle(fontFamily: 'Inter', fontSize: 11),
              ),
            ),
          ),

          const Divider(height: 1, indent: 24, endIndent: 24),
          const SizedBox(height: 16),

          // Canvas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Center(
                child: Builder(builder: (context) {
                  const double canvasW = 300;
                  const double canvasH = 540;

                  final accessory = kSlotBounds['accessory']!
                      .toPixels(canvasWidth: canvasW, canvasHeight: canvasH);
                  final top = kSlotBounds['top']!
                      .toPixels(canvasWidth: canvasW, canvasHeight: canvasH);
                  final bottom = kSlotBounds['bottom']!
                      .toPixels(canvasWidth: canvasW, canvasHeight: canvasH);
                  final shoes = kSlotBounds['shoes']!
                      .toPixels(canvasWidth: canvasW, canvasHeight: canvasH);

                  return SizedBox(
                    width: canvasW,
                    height: canvasH,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: SvgPicture.asset(
                            getMannequinAsset(mannequin),
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Accessory
                        Positioned(
                          top: accessory.top,
                          left: accessory.left,
                          width: accessory.width,
                          height: accessory.height,
                          child: OutfitSlot(
                            category: ItemCategory.accessory,
                            itemId: editorState.accessoryId,
                            height: accessory.height,
                            width: accessory.width,
                            onTap: () => _openPicker(
                                context, ItemCategory.accessory, notifier),
                            onRemove: () =>
                                notifier.setSlot(ItemCategory.accessory, null),
                            onSelected: (id) =>
                                notifier.setSlot(ItemCategory.accessory, id),
                          ),
                        ),
                        // Top
                        Positioned(
                          top: top.top,
                          left: top.left,
                          width: top.width,
                          height: top.height,
                          child: OutfitSlot(
                            category: ItemCategory.top,
                            itemId: editorState.topId,
                            height: top.height,
                            width: top.width,
                            onTap: () =>
                                _openPicker(context, ItemCategory.top, notifier),
                            onRemove: () =>
                                notifier.setSlot(ItemCategory.top, null),
                            onSelected: (id) =>
                                notifier.setSlot(ItemCategory.top, id),
                          ),
                        ),
                        // Bottom
                        Positioned(
                          top: bottom.top,
                          left: bottom.left,
                          width: bottom.width,
                          height: bottom.height,
                          child: OutfitSlot(
                            category: ItemCategory.bottom,
                            itemId: editorState.bottomId,
                            height: bottom.height,
                            width: bottom.width,
                            onTap: () => _openPicker(
                                context, ItemCategory.bottom, notifier),
                            onRemove: () =>
                                notifier.setSlot(ItemCategory.bottom, null),
                            onSelected: (id) =>
                                notifier.setSlot(ItemCategory.bottom, id),
                          ),
                        ),
                        // Shoes
                        Positioned(
                          top: shoes.top,
                          left: shoes.left,
                          width: shoes.width,
                          height: shoes.height,
                          child: OutfitSlot(
                            category: ItemCategory.footwear,
                            itemId: editorState.shoesId,
                            height: shoes.height,
                            width: shoes.width,
                            onTap: () => _openPicker(
                                context, ItemCategory.footwear, notifier),
                            onRemove: () =>
                                notifier.setSlot(ItemCategory.footwear, null),
                            onSelected: (id) =>
                                notifier.setSlot(ItemCategory.footwear, id),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPicker(BuildContext context, ItemCategory category,
      StylistEditor notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PublicWardrobePickerSheet(
        targetUserId: targetUser.uid,
        category: category,
        onSelected: (itemId) => notifier.setSlot(category, itemId),
      ),
    );
  }
}
