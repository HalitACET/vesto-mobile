import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/today/data/models/outfit_suggestion.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';

class OutfitSuggestionCard extends StatelessWidget {
  final OutfitSuggestion suggestion;
  final VoidCallback onWearToday;
  final VoidCallback onSaveOutfit;

  const OutfitSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onWearToday,
    required this.onSaveOutfit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mist.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onyx.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Grid (2x2)
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                children: [
                  _buildThumbnail(suggestion.top),
                  _buildThumbnail(suggestion.bottom),
                  _buildThumbnail(suggestion.shoes),
                  _buildThumbnail(suggestion.accessory),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.onyx,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.reasoning,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.stone,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: onWearToday,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onyx,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('BUGÜN BUNU GİY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onSaveOutfit,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.stone,
                    minimumSize: const Size(double.infinity, 32),
                  ),
                  child: const Text('Outfit Olarak Kaydet', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(WardrobeItem? item) {
    if (item == null) {
      return Container(color: AppColors.pearl.withValues(alpha: 0.5));
    }

    return CachedNetworkImage(
      imageUrl: item.imageUrl ?? '',
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: AppColors.pearl),
      errorWidget: (context, url, error) => const Icon(Icons.error_outline, size: 16),
    );
  }
}
