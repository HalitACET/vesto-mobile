import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';

enum WardrobeEmptyVariant {
  /// Gardırop tamamen boş — CTA: Kıyafet ekle
  wardrobeEmpty,

  /// Arama sonucu yok
  noSearchResult,

  /// Seçili kategoride kıyafet yok
  noFilterResult,
}

/// Gardırop ekranının boş durum widget'ı.
/// 3 farklı içerik varyantı destekler.
class WardrobeEmptyState extends StatelessWidget {
  const WardrobeEmptyState({
    super.key,
    required this.variant,
    this.onAddItem,
  });

  final WardrobeEmptyVariant variant;
  final VoidCallback? onAddItem;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final (icon, title, description) = switch (variant) {
      WardrobeEmptyVariant.wardrobeEmpty => (
          Icons.checkroom_outlined,
          'Gardırobun henüz boş',
          'İlk kıyafetini ekleyerek dijital\ngardırobunu oluşturmaya başla.',
        ),
      WardrobeEmptyVariant.noSearchResult => (
          Icons.search_off_rounded,
          'Sonuç bulunamadı',
          'Arama kriterlerine uyan\nbir kıyafet bulunamadı.',
        ),
      WardrobeEmptyVariant.noFilterResult => (
          Icons.filter_list_off_rounded,
          'Bu kategoride kıyafet yok',
          'Seçili kategoriye ait\nhenüz kıyafet eklenmemiş.',
        ),
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.pearl,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.stone),
            ),
            SizedBox(height: spacing.lg),
            Text(
              title,
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            Text(
              description,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
              textAlign: TextAlign.center,
            ),
            if (variant == WardrobeEmptyVariant.wardrobeEmpty &&
                onAddItem != null) ...[
              SizedBox(height: spacing.xl),
              VestoButton(
                label: 'İlk kıyafeti ekle',
                onPressed: onAddItem,
                size: VestoButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
