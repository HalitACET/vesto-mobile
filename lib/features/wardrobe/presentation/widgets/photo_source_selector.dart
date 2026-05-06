import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';

/// Kullanıcıya fotoğraf kaynağı seçtiren Bottom Sheet.
/// Dışarıdan `PhotoSourceSelector.show()` ile çağrılır.
/// Kullanıcı boşluğa dokunup kapatırsa `null` döner, hata vermez.
class PhotoSourceSelector extends StatelessWidget {
  const PhotoSourceSelector({super.key});

  /// Bottom sheet'i gösterir ve seçilen kaynağı döner.
  /// İptal durumunda `null` döner.
  static Future<ImageSource?> show(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.pearl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const PhotoSourceSelector(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(spacing.xl, spacing.xl, spacing.xl, spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: spacing.xl),
            
            Text(
              'Fotoğraf Ekle',
              style: AppTypography.headlineMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              'Kıyafetini nasıl eklemek istersin?',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
            ),
            SizedBox(height: spacing.xxl),

            // Tap Targets
            Row(
              children: [
                Expanded(
                  child: _SourceButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'KAMERA',
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library_outlined,
                    label: 'GALERİ',
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md), // Bottom padding
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(radius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.mist),
            borderRadius: BorderRadius.circular(radius.md),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: AppColors.onyx),
              const SizedBox(height: 16),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(letterSpacing: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
