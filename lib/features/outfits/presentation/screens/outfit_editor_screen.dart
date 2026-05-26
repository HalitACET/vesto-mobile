import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_editor_notifier.dart';
import 'package:mobile/features/outfits/presentation/widgets/outfit_slot.dart';
import 'package:mobile/features/outfits/presentation/widgets/wardrobe_picker_sheet.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/core/utils/mannequin_utils.dart';

class OutfitEditorScreen extends ConsumerWidget {
  const OutfitEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(outfitEditorProvider(null));
    final notifier = ref.read(outfitEditorProvider(null).notifier);
    final mannequin = ref.watch(mannequinTypeProvider);

    return PopScope(
      canPop: !state.hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Değişiklikleri Kaybet?'),
            content: const Text('Yaptığınız değişiklikler kaydedilmedi. Çıkmak istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Çık'),
              ),
            ],
          ),
        );
        
        if (shouldPop ?? false) {
          if (context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            state.outfitId == null ? 'Yeni Outfit' : 'Outfit Düzenle',
            style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
          ),
          actions: [
            if (state.isSaving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              )
            else
              TextButton(
                onPressed: state.isValid ? () async {
                  await notifier.save();
                  if (context.mounted) Navigator.pop(context);
                } : null,
                child: Text(
                  'KAYDET',
                  style: TextStyle(
                    color: state.isValid ? AppColors.onyx : AppColors.stone,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Outfit Name Input (Elegant)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: TextField(
                onChanged: (val) => notifier.updateName(val),
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onyx,
                ),
                decoration: InputDecoration(
                  hintText: 'Outfit ismi (Örn: Hafta sonu şıklığı)',
                  hintStyle: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    color: AppColors.stone.withValues(alpha: 0.5),
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const Divider(height: 1, indent: 24, endIndent: 24),
            const SizedBox(height: 24),

            // Canvas Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Center(
                  child: Builder(
                    builder: (context) {
                      const double canvasW = 300;
                      const double canvasH = 540;
                      
                      final accessory = kSlotBounds['accessory']!.toPixels(canvasWidth: canvasW, canvasHeight: canvasH);
                      final top = kSlotBounds['top']!.toPixels(canvasWidth: canvasW, canvasHeight: canvasH);
                      final bottom = kSlotBounds['bottom']!.toPixels(canvasWidth: canvasW, canvasHeight: canvasH);
                      final shoes = kSlotBounds['shoes']!.toPixels(canvasWidth: canvasW, canvasHeight: canvasH);

                      return Container(
                        width: canvasW,
                        height: canvasH,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mist.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Mannequin Layer
                            Positioned.fill(
                              child: SvgPicture.asset(
                                getMannequinAsset(mannequin),
                                fit: BoxFit.contain,
                              ),
                            ),
                            // Accessory Slot
                            Positioned(
                              top: accessory.top,
                              left: accessory.left,
                              width: accessory.width,
                              height: accessory.height,
                              child: OutfitSlot(
                                category: ItemCategory.accessory,
                                itemId: state.accessoryId,
                                height: accessory.height,
                                width: accessory.width,
                                onTap: () => _openPicker(context, ItemCategory.accessory, notifier),
                                onRemove: () => notifier.setSlot(ItemCategory.accessory, null),
                                onSelected: (id) => notifier.setSlot(ItemCategory.accessory, id),
                              ),
                            ),
                            // Top Slot
                            Positioned(
                              top: top.top,
                              left: top.left,
                              width: top.width,
                              height: top.height,
                              child: OutfitSlot(
                                category: ItemCategory.top,
                                itemId: state.topId,
                                height: top.height,
                                width: top.width,
                                onTap: () => _openPicker(context, ItemCategory.top, notifier),
                                onRemove: () => notifier.setSlot(ItemCategory.top, null),
                                onSelected: (id) => notifier.setSlot(ItemCategory.top, id),
                              ),
                            ),
                            // Bottom Slot
                            Positioned(
                              top: bottom.top,
                              left: bottom.left,
                              width: bottom.width,
                              height: bottom.height,
                              child: OutfitSlot(
                                category: ItemCategory.bottom,
                                itemId: state.bottomId,
                                height: bottom.height,
                                width: bottom.width,
                                onTap: () => _openPicker(context, ItemCategory.bottom, notifier),
                                onRemove: () => notifier.setSlot(ItemCategory.bottom, null),
                                onSelected: (id) => notifier.setSlot(ItemCategory.bottom, id),
                              ),
                            ),
                            // Shoes Slot
                            Positioned(
                              top: shoes.top,
                              left: shoes.left,
                              width: shoes.width,
                              height: shoes.height,
                              child: OutfitSlot(
                                category: ItemCategory.footwear,
                                itemId: state.shoesId,
                                height: shoes.height,
                                width: shoes.width,
                                onTap: () => _openPicker(context, ItemCategory.footwear, notifier),
                                onRemove: () => notifier.setSlot(ItemCategory.footwear, null),
                                onSelected: (id) => notifier.setSlot(ItemCategory.footwear, id),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context, ItemCategory category, OutfitEditor notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WardrobePickerSheet(
        category: category,
        onSelected: (itemId) => notifier.setSlot(category, itemId),
      ),
    );
  }
}
