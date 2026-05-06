import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_view.dart';
import 'package:mobile/features/wardrobe/data/repositories/wardrobe_repository.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_empty_state.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_filter_bar.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_grid.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_search_bar.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_view_toggle.dart';

/// Hafta 5: Gardırop ana ekranı — home'un yerini alan gerçek içerik.
/// Riverpod stream'inden canlı Firestore verisi, filter + search + view toggle.
class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(userWardrobeItemsProvider);
    final filteredItems = ref.watch(filteredWardrobeItemsProvider);
    final viewMode = ref.watch(wardrobeViewModeProvider);
    final allItems = itemsAsync.value ?? [];
    final isLoading = itemsAsync.isLoading;
    final hasSearch = ref.watch(wardrobeSearchProvider).isNotEmpty;
    final hasFilter = ref.watch(wardrobeFilterProvider) != null;

    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: AppBar(
        backgroundColor: AppColors.pearl,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Gardırobum',
          style: AppTypography.headlineSmall,
        ),
        centerTitle: false,
        actions: const [
          WardrobeViewToggle(),
          SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.onyx,
        onRefresh: () async {
          ref.invalidate(userWardrobeItemsProvider);
          // Stream kendisi güncellenir, sadece kısa bir gecikme yeterli
          await Future<void>.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Arama çubuğu
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: WardrobeSearchBar(),
              ),
            ),
            // Kategori filtre chip'leri — sadece kıyafet varsa göster
            if (!isLoading && allItems.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: WardrobeFilterBar(),
                ),
              ),
            // Ana içerik
            SliverFillRemaining(
              child: _WardrobeBody(
                isLoading: isLoading,
                allItems: allItems,
                filteredItems: filteredItems,
                viewMode: viewMode,
                hasSearch: hasSearch,
                hasFilter: hasFilter,
                onTap: (item) => context.push('/wardrobe/item/${item.id}'),
                onLongPress: (item) =>
                    _showItemBottomSheet(context, item, ref),
                onAddItem: () => context.push('/wardrobe/add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemBottomSheet(
    BuildContext context,
    WardrobeItem item,
    WidgetRef ref,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ItemActionSheet(item: item, ref: ref),
    );
  }
}

// ── Body orchestrator ─────────────────────────────────────────────────────────

class _WardrobeBody extends StatelessWidget {
  const _WardrobeBody({
    required this.isLoading,
    required this.allItems,
    required this.filteredItems,
    required this.viewMode,
    required this.hasSearch,
    required this.hasFilter,
    required this.onTap,
    required this.onLongPress,
    required this.onAddItem,
  });

  final bool isLoading;
  final List<WardrobeItem> allItems;
  final List<WardrobeItem> filteredItems;
  final WardrobeView viewMode;
  final bool hasSearch;
  final bool hasFilter;
  final void Function(WardrobeItem) onTap;
  final void Function(WardrobeItem) onLongPress;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context) {
    // Loading skeleton
    if (isLoading) {
      return viewMode == WardrobeView.grid
          ? WardrobeGrid(
              items: const [],
              onTap: (_) {},
              onLongPress: (_) {},
              isLoading: true,
            )
          : WardrobeList(
              items: const [],
              onTap: (_) {},
              onLongPress: (_) {},
              isLoading: true,
            );
    }

    // Gardırop tamamen boş
    if (allItems.isEmpty) {
      return WardrobeEmptyState(
        variant: WardrobeEmptyVariant.wardrobeEmpty,
        onAddItem: onAddItem,
      );
    }

    // Arama veya filtre sonucu boş
    if (filteredItems.isEmpty) {
      return WardrobeEmptyState(
        variant: hasSearch
            ? WardrobeEmptyVariant.noSearchResult
            : WardrobeEmptyVariant.noFilterResult,
      );
    }

    // Normal içerik
    return viewMode == WardrobeView.grid
        ? WardrobeGrid(
            items: filteredItems,
            onTap: onTap,
            onLongPress: onLongPress,
          )
        : WardrobeList(
            items: filteredItems,
            onTap: onTap,
            onLongPress: onLongPress,
          );
  }
}

// ── Long-press action sheet ───────────────────────────────────────────────────

class _ItemActionSheet extends StatelessWidget {
  const _ItemActionSheet({required this.item, required this.ref});

  final WardrobeItem item;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Kıyafet bilgisi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text(
                    item.brand ?? item.subcategory,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.category.displayLabel,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(height: 24, indent: 20, endIndent: 20),
            // Detayları Gör
            _SheetAction(
              icon: Icons.open_in_new_rounded,
              label: 'Detayları Gör',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/wardrobe/item/${item.id}');
              },
            ),
            // Arşivle
            _SheetAction(
              icon: Icons.archive_outlined,
              label: 'Arşivle',
              onTap: () async {
                Navigator.of(context).pop();
                await ref
                    .read(wardrobeRepositoryProvider)
                    .archiveItem(item.id);
              },
            ),
            // Sil
            _SheetAction(
              icon: Icons.delete_outline,
              label: 'Sil',
              color: AppColors.error,
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(context, item, ref);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WardrobeItem item, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Kıyafeti Sil', style: AppTypography.headlineSmall),
        content: Text(
          'Bu kıyafet kalıcı olarak silinecek.\nEmin misin?',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'İptal',
              style: AppTypography.labelMedium.copyWith(color: AppColors.stone),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await _deleteItem(item, ref);
            },
            child: Text(
              'Sil',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(WardrobeItem item, WidgetRef ref) async {
    // Firestore'dan sil (hard delete: imagePath üzerinden storage da temizlenebilir
    // Hafta 6'da Cloud Function bunu otomatik yapar, şimdi sadece Firestore)
    await ref
        .read(wardrobeRepositoryProvider)
        .archiveItem(item.id); // Şimdilik arşivle = soft delete
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.onyx;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: effectiveColor),
            const SizedBox(width: 16),
            Text(
              label,
              style:
                  AppTypography.bodyMedium.copyWith(color: effectiveColor),
            ),
          ],
        ),
      ),
    );
  }
}
