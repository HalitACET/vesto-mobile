import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/today/data/models/outfit_suggestion.dart';
import 'package:mobile/features/today/presentation/widgets/outfit_suggestion_card.dart';
import 'package:mobile/features/wardrobe/data/repositories/wardrobe_repository.dart';
import 'package:mobile/features/outfits/data/models/outfit.dart';
import 'package:mobile/features/outfits/data/models/outfit_items.dart';
import 'package:mobile/features/outfits/presentation/providers/outfit_providers.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';

class SuggestionCarousel extends ConsumerStatefulWidget {
  final List<OutfitSuggestion> suggestions;

  const SuggestionCarousel({super.key, required this.suggestions});

  @override
  ConsumerState<SuggestionCarousel> createState() => _SuggestionCarouselState();
}

class _SuggestionCarouselState extends ConsumerState<SuggestionCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.suggestions.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 420,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = widget.suggestions[index];
          return OutfitSuggestionCard(
            suggestion: suggestion,
            onWearToday: () => _handleWearToday(suggestion),
            onSaveOutfit: () => _handleSaveOutfit(suggestion),
          );
        },
      ),
    );
  }

  Future<void> _handleWearToday(OutfitSuggestion suggestion) async {
    final itemIds = suggestion.items.map((i) => i.id).toList();
    await ref.read(wardrobeRepositoryProvider).markItemsAsWorn(itemIds);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harika seçim! İyi günler.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleSaveOutfit(OutfitSuggestion suggestion) async {
    final userId = ref.read(authStateChangesProvider).value?.uid;
    if (userId == null) return;

    final outfit = Outfit(
      id: '', // Firestore will generate
      userId: userId,
      name: '${suggestion.title} Öneri',
      items: OutfitItems(
        topId: suggestion.top?.id,
        bottomId: suggestion.bottom?.id,
        shoesId: suggestion.shoes?.id,
        accessoryId: suggestion.accessory?.id,
      ),
      createdAt: DateTime.now(),
    );

    await ref.read(outfitRepositoryProvider).createOutfit(outfit);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kombin kaydedildi!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
