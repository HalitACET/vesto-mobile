import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/widgets/organisms/vesto_error_view.dart';
import 'package:mobile/features/outfits/presentation/screens/outfit_detail_screen.dart';
import 'package:mobile/features/outfits/presentation/screens/outfit_editor_screen.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/outfits/presentation/widgets/outfit_card.dart';
import 'package:mobile/features/outfits/presentation/widgets/outfit_empty_state.dart';
import 'package:mobile/features/outfits/presentation/widgets/outfit_list_skeleton.dart';

class OutfitsScreen extends ConsumerWidget {
  const OutfitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitsAsync = ref.watch(outfitsStreamProvider);
    final filteredOutfits = ref.watch(filteredOutfitsProvider);
    final currentFilter = ref.watch(outfitFilterStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Outfitler',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.onyx,
        onRefresh: () async {
          ref.invalidate(outfitsStreamProvider);
          await Future<void>.delayed(const Duration(milliseconds: 600));
        },
        child: outfitsAsync.when(
          loading: () => const OutfitListSkeleton(),
          error: (e, _) => CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                child: VestoErrorView(
                  message: 'Outfitler yüklenemedi',
                  onRetry: () => ref.invalidate(outfitsStreamProvider),
                ),
              ),
            ],
          ),
          data: (allOutfits) {
            if (allOutfits.isEmpty) {
              return const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: OutfitEmptyState(),
                  ),
                ],
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Filter Bar
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: OutfitFilter.values.map((filter) {
                        final isSelected = currentFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_getFilterLabel(filter)),
                            selected: isSelected,
                            onSelected: (_) => ref.read(outfitFilterStateProvider.notifier).setFilter(filter),
                            selectedColor: AppColors.onyx,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.onyx,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: AppColors.pearl,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppColors.onyx : AppColors.mist,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                // Grid
                if (filteredOutfits.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Bu filtreye uygun outfit bulunamadı', 
                        style: TextStyle(color: AppColors.stone),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final outfit = filteredOutfits[index];
                          return OutfitCard(
                            outfit: outfit,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OutfitDetailScreen(outfit: outfit),
                                ),
                              );
                            },
                          );
                        },
                        childCount: filteredOutfits.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OutfitEditorScreen()),
          );
        },
        backgroundColor: AppColors.onyx,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _getFilterLabel(OutfitFilter filter) {
    switch (filter) {
      case OutfitFilter.all:
        return 'Tümü';
      case OutfitFilter.favorites:
        return 'Favoriler';
      case OutfitFilter.recentlyWorn:
        return 'Son Giyilen';
      case OutfitFilter.neverWorn:
        return 'Hiç Giyilmemiş';
    }
  }
}
