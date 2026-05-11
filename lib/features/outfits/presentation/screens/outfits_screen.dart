import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/outfits/presentation/screens/outfit_detail_screen.dart';
import 'package:mobile/features/outfits/presentation/screens/outfit_editor_screen.dart';
import 'package:mobile/features/outfits/presentation/widgets/outfit_card.dart';
import 'package:mobile/features/outfits/presentation/widgets/outfit_empty_state.dart';

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
            onPressed: () {
              // TODO: Search outfits
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: outfitsAsync.when(
        data: (allOutfits) {
          if (allOutfits.isEmpty) return const OutfitEmptyState();

          return Column(
            children: [
              // Filter Bar
              SingleChildScrollView(
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
              
              // Grid
              Expanded(
                child: filteredOutfits.isEmpty
                    ? const Center(child: Text('Bu filtreye uygun outfit bulunamadı', style: TextStyle(color: AppColors.stone)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredOutfits.length,
                        itemBuilder: (context, index) {
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
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
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
