import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';
import 'package:mobile/core/widgets/atoms/vesto_text_field.dart';
import 'package:mobile/features/wardrobe/presentation/providers/add_item_notifier.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/category_picker.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/subcategory_chips.dart';

/// Kıyafet ekleme akışının üçüncü adımı: Kategori ve Metadata formu.
class ItemDetailsStep extends ConsumerStatefulWidget {
  const ItemDetailsStep({
    super.key,
    required this.onBack,
    required this.onSave,
    required this.isSaving,
  });

  final VoidCallback onBack;
  final VoidCallback onSave;
  final bool isSaving;

  @override
  ConsumerState<ItemDetailsStep> createState() => _ItemDetailsStepState();
}

class _ItemDetailsStepState extends ConsumerState<ItemDetailsStep> {
  final _brandController = TextEditingController();
  final _sizeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _sizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return _buildContent(context);
    } catch (e, stack) {
      debugPrint('🔴 ItemDetailsStep build error: $e');
      debugPrint('Stack: $stack');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Hata: $e', style: const TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildContent(BuildContext context) {
    debugPrint('🔵 ItemDetailsStep build started');
    final state = ref.watch(addItemProvider);
    final notifier = ref.read(addItemProvider.notifier);
    final spacing = context.spacing;
    final radius = context.radius;

    debugPrint('🔵 State: croppedPhoto=${state.croppedPhoto?.path}, category=${state.category}');

    // Fotoğraf eksikse loading/empty durumu
    if (state.croppedPhoto == null) {
      debugPrint('🟡 croppedPhoto is null, returning loading');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.onyx),
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.only(left: spacing.md, right: spacing.xl, top: spacing.md),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: widget.onBack,
              ),
              const Spacer(),
              Text(
                'Adım 3/3',
                style: AppTypography.labelMedium.copyWith(color: AppColors.stone),
              ),
            ],
          ),
        ),

        // Body (Scrollable form)
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: spacing.md),
                
                // Photo Preview (Guarded by the null check above)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius.md),
                    child: Image.file(
                      state.croppedPhoto!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: AppColors.mist,
                          child: const Icon(Icons.broken_image_outlined, color: AppColors.stone),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: spacing.xxl),

                // Kategori Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                  child: Text('KATEGORİ *', style: AppTypography.labelMedium.copyWith(color: AppColors.stone)),
                ),
                SizedBox(height: spacing.md),
                CategoryPicker(
                  selectedCategory: state.category,
                  onCategorySelected: notifier.setCategory,
                ),
                SizedBox(height: spacing.md),
                
                if (state.category != null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                    child: Text('ALT KATEGORİ *', style: AppTypography.labelMedium.copyWith(color: AppColors.stone)),
                  ),
                  SizedBox(height: spacing.sm),
                  SubcategoryChips(
                    selectedCategory: state.category,
                    selectedSubcategory: state.subcategory,
                    onSubcategorySelected: notifier.setSubcategory,
                  ),
                  SizedBox(height: spacing.xl),
                ],

                // Detaylar Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                  child: Text('DETAYLAR', style: AppTypography.labelMedium.copyWith(color: AppColors.stone)),
                ),
                SizedBox(height: spacing.md),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                  child: Column(
                    children: [
                      VestoTextField(
                        label: 'Marka',
                        controller: _brandController,
                        onChanged: notifier.setBrand,
                        errorText: state.brand != null && state.brand!.length > 50 ? 'En fazla 50 karakter' : null,
                      ),
                      SizedBox(height: spacing.md),
                      VestoTextField(
                        label: 'Beden',
                        controller: _sizeController,
                        onChanged: notifier.setSize,
                        errorText: state.size != null && state.size!.length > 20 ? 'En fazla 20 karakter' : null,
                      ),
                      SizedBox(height: spacing.md),
                      VestoTextField(
                        label: 'Notlar',
                        controller: _notesController,
                        onChanged: notifier.setNotes,
                        maxLines: 4,
                        textInputAction: TextInputAction.done,
                        errorText: state.notes != null && state.notes!.length > 500 ? 'En fazla 500 karakter' : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.xxl), // padding for bottom button
              ],
            ),
          ),
        ),

        // Bottom fixed save button
        Container(
          padding: EdgeInsets.all(spacing.xl),
          decoration: const BoxDecoration(
            color: AppColors.pearl,
            border: Border(top: BorderSide(color: AppColors.mist)),
          ),
          child: SafeArea(
            top: false,
            child: VestoButton(
              label: 'KAYDET',
              onPressed: state.isValid && !widget.isSaving ? widget.onSave : null,
              variant: VestoButtonVariant.primary,
              isLoading: widget.isSaving,
            ),
          ),
        ),
      ],
    );
  }
}
