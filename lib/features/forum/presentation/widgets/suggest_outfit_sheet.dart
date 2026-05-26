import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/features/forum/presentation/providers/forum_providers.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';

enum SuggestSlot { top, bottom, shoes, accessory }

class SuggestOutfitSheet extends ConsumerStatefulWidget {
  final String postId;
  final String postAuthorId;
  final String postAuthorDisplayName;

  const SuggestOutfitSheet({
    required this.postId,
    required this.postAuthorId,
    required this.postAuthorDisplayName,
    super.key,
  });

  @override
  ConsumerState<SuggestOutfitSheet> createState() => _SuggestOutfitSheetState();
}

class _SuggestOutfitSheetState extends ConsumerState<SuggestOutfitSheet> {
  SuggestSlot _activeSlot = SuggestSlot.top;
  String? _selectedTopId;
  String? _selectedBottomId;
  String? _selectedShoesId;
  String? _selectedAccessoryId;

  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  bool _isNoteExpanded = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicItemsAsync = ref.watch(userPublicWardrobeItemsProvider(widget.postAuthorId));
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kombin Öner',
                          style: AppTypography.titleLarge.copyWith(
                            fontFamily: 'Cormorant',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.postAuthorDisplayName} kullanıcısının dolabından seç',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.stone),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.graphite),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.mist, height: 24),

            publicItemsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48.0),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.onyx),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text('Kıyafetler yüklenirken bir hata oluştu: $err'),
                ),
              ),
              data: (allItems) {
                if (allItems.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.checkroom, size: 48, color: AppColors.mist),
                        const SizedBox(height: 16),
                        Text(
                          'Bu kullanıcının gardırobunda herkese açık kıyafet bulunmuyor.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
                        ),
                      ],
                    ),
                  );
                }

                // Filter items by active slot
                final tops = allItems.where((i) => i.category == ItemCategory.top || i.category == ItemCategory.outerwear).toList();
                final bottoms = allItems.where((i) => i.category == ItemCategory.bottom).toList();
                final shoes = allItems.where((i) => i.category == ItemCategory.footwear).toList();
                final accessories = allItems.where((i) => i.category == ItemCategory.accessory).toList();

                List<WardrobeItem> currentSlotItems = [];
                String? currentSelectedId;
                switch (_activeSlot) {
                  case SuggestSlot.top:
                    currentSlotItems = tops;
                    currentSelectedId = _selectedTopId;
                    break;
                  case SuggestSlot.bottom:
                    currentSlotItems = bottoms;
                    currentSelectedId = _selectedBottomId;
                    break;
                  case SuggestSlot.shoes:
                    currentSlotItems = shoes;
                    currentSelectedId = _selectedShoesId;
                    break;
                  case SuggestSlot.accessory:
                    currentSlotItems = accessories;
                    currentSelectedId = _selectedAccessoryId;
                    break;
                }

                final topItem = _selectedTopId != null ? allItems.firstWhere((i) => i.id == _selectedTopId) : null;
                final bottomItem = _selectedBottomId != null ? allItems.firstWhere((i) => i.id == _selectedBottomId) : null;
                final shoesItem = _selectedShoesId != null ? allItems.firstWhere((i) => i.id == _selectedShoesId) : null;
                final accItem = _selectedAccessoryId != null ? allItems.firstWhere((i) => i.id == _selectedAccessoryId) : null;

                return Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selected Outfit Preview (2x2 Grid)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SEÇİLEN KOMBİN',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.stone,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 180,
                                    height: 180,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.pearl,
                                      borderRadius: BorderRadius.circular(radius.lg),
                                      border: Border.all(color: AppColors.mist),
                                    ),
                                    child: GridView.count(
                                      crossAxisCount: 2,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisSpacing: 6,
                                      mainAxisSpacing: 6,
                                      children: [
                                        _buildPreviewSlot(SuggestSlot.top, topItem, '👕'),
                                        _buildPreviewSlot(SuggestSlot.bottom, bottomItem, '👖'),
                                        _buildPreviewSlot(SuggestSlot.shoes, shoesItem, '👟'),
                                        _buildPreviewSlot(SuggestSlot.accessory, accItem, '👜'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: spacing.lg),

                        // Custom Tab Bar
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                          child: Row(
                            children: [
                              _buildTabButton(SuggestSlot.top, '👕 Üstler', _selectedTopId != null),
                              SizedBox(width: spacing.sm),
                              _buildTabButton(SuggestSlot.bottom, '👖 Altlar', _selectedBottomId != null),
                              SizedBox(width: spacing.sm),
                              _buildTabButton(SuggestSlot.shoes, '👟 Ayakkabılar', _selectedShoesId != null),
                              SizedBox(width: spacing.sm),
                              _buildTabButton(SuggestSlot.accessory, '👜 Aksesuarlar', _selectedAccessoryId != null),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Category Items Grid
                        Container(
                          height: 160,
                          padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                          child: currentSlotItems.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.info_outline, color: AppColors.stone),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Bu kategoride kıyafet yok',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.stone),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: currentSlotItems.length,
                                  separatorBuilder: (_, __) => SizedBox(width: spacing.sm),
                                  itemBuilder: (context, index) {
                                    final item = currentSlotItems[index];
                                    final isSelected = currentSelectedId == item.id;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _toggleItem(item.id);
                                        });
                                      },
                                      child: Container(
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(radius.md),
                                          border: Border.all(
                                            color: isSelected ? AppColors.onyx : AppColors.mist,
                                            width: isSelected ? 2.0 : 1.0,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: CachedNetworkImage(
                                                imageUrl: item.bgRemovedUrl ?? item.imageUrl ?? '',
                                                fit: BoxFit.contain,
                                                placeholder: (_, __) => Container(color: AppColors.pearl),
                                                errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                                              ),
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                top: 6,
                                                right: 6,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.onyx,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: const EdgeInsets.all(4),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        SizedBox(height: spacing.md),

                        // Optional Note Button & Input
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _isNoteExpanded = !_isNoteExpanded),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isNoteExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: AppColors.stone,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Not ekle (opsiyonel)',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.stone),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isNoteExpanded) ...[
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _noteController,
                                  decoration: InputDecoration(
                                    hintText: 'Bu kombini neden önerdiğini yaz...',
                                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.stone),
                                    filled: true,
                                    fillColor: AppColors.pearl,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(radius.md),
                                      borderSide: const BorderSide(color: AppColors.mist),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(radius.md),
                                      borderSide: const BorderSide(color: AppColors.onyx),
                                    ),
                                    contentPadding: const EdgeInsets.all(12),
                                  ),
                                  style: AppTypography.bodyMedium,
                                  maxLines: 2,
                                  maxLength: 200,
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: spacing.md),

                        // Action Buttons
                        Padding(
                          padding: EdgeInsets.all(spacing.xl),
                          child: ElevatedButton(
                            onPressed: _hasSelection && !_isSubmitting ? _submitSuggestion : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.onyx,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(radius.md),
                              ),
                              disabledBackgroundColor: AppColors.mist,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text(
                                    'ÖNERİYİ PAYLAŞ',
                                    style: TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSlot(SuggestSlot slot, WardrobeItem? item, String emoji) {
    final radius = context.radius;
    final isActive = _activeSlot == slot;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeSlot = slot;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(radius.sm),
          border: Border.all(
            color: isActive ? AppColors.onyx : AppColors.mist,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: item != null
            ? Padding(
                padding: const EdgeInsets.all(4),
                child: CachedNetworkImage(
                  imageUrl: item.bgRemovedUrl ?? item.imageUrl ?? '',
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(color: AppColors.pearl),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              )
            : Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
      ),
    );
  }

  Widget _buildTabButton(SuggestSlot slot, String label, bool isSelected) {
    final radius = context.radius;
    final isActive = _activeSlot == slot;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeSlot = slot;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.onyx : AppColors.pearl,
          borderRadius: BorderRadius.circular(radius.lg),
          border: Border.all(
            color: isActive ? AppColors.onyx : AppColors.mist,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isActive ? AppColors.white : AppColors.onyx,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleItem(String itemId) {
    switch (_activeSlot) {
      case SuggestSlot.top:
        _selectedTopId = _selectedTopId == itemId ? null : itemId;
        break;
      case SuggestSlot.bottom:
        _selectedBottomId = _selectedBottomId == itemId ? null : itemId;
        break;
      case SuggestSlot.shoes:
        _selectedShoesId = _selectedShoesId == itemId ? null : itemId;
        break;
      case SuggestSlot.accessory:
        _selectedAccessoryId = _selectedAccessoryId == itemId ? null : itemId;
        break;
    }
  }

  bool get _hasSelection =>
      _selectedTopId != null ||
      _selectedBottomId != null ||
      _selectedShoesId != null ||
      _selectedAccessoryId != null;

  Future<void> _submitSuggestion() async {
    if (!_hasSelection || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final note = _noteController.text.trim();
      final text = note.isNotEmpty ? note : '🎽 Kombin önerisi';

      await ref.read(forumRepositoryProvider).addComment(
        postId: widget.postId,
        text: text,
        commentType: 'outfit_suggestion',
        outfitSuggestion: {
          'topId': _selectedTopId,
          'bottomId': _selectedBottomId,
          'shoesId': _selectedShoesId,
          'accessoryId': _selectedAccessoryId,
          'note': note.isNotEmpty ? note : null,
        },
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kombin önerisi gönderilemedi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

void showSuggestOutfitSheet({
  required BuildContext context,
  required String postId,
  required String postAuthorId,
  required String postAuthorDisplayName,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SuggestOutfitSheet(
      postId: postId,
      postAuthorId: postAuthorId,
      postAuthorDisplayName: postAuthorDisplayName,
    ),
  );
}
