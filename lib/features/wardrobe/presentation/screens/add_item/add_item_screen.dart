import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/core/widgets/molecules/vesto_snack_bar.dart';
import 'package:mobile/features/wardrobe/presentation/providers/add_item_notifier.dart';
import 'package:mobile/features/wardrobe/presentation/screens/add_item/steps/item_details_step.dart';
import 'package:mobile/features/wardrobe/presentation/screens/add_item/steps/photo_capture_step.dart';
import 'package:mobile/features/wardrobe/presentation/screens/add_item/steps/photo_crop_step.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/photo_source_selector.dart';

/// Kıyafet ekleme akışının ana container'ı.
/// Riverpod (AddItemNotifier) ile bağlanır.
class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  int _currentStep = 0;
  ImageSource? _initialSource;
  File? _capturedFile; // Kırpılmamış orijinal fotoğraf
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında doğrudan kaynağı sor ve eski state'i temizle
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(addItemProvider.notifier).reset();
      
      final source = await PhotoSourceSelector.show(context);
      if (mounted) {
        setState(() {
          _initialSource = source;
          _initialized = true;
        });
      }
    });
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final notifier = ref.read(addItemProvider.notifier);
    final result = await notifier.save();

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      ok: (_) {
        VestoSnackBar.show(
          context,
          message: 'Gardırobuna eklendi',
          type: VestoSnackBarType.success,
        );
        context.go('/wardrobe'); // Başarıyla eklendi, geri dön
      },
      err: (failure) {
        VestoSnackBar.show(
          context,
          message: failure.message,
          type: VestoSnackBarType.error,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tüm akış boyunca state'in auto-dispose olmasını engellemek için watch ediyoruz
    ref.watch(addItemProvider);

    return Scaffold(
      appBar: _currentStep == 2 
          ? null // Step 3 (ItemDetailsStep) kendi AppBar benzeri yapısını kullanıyor
          : AppBar(
              title: Text(
                'Yeni Kıyafet',
                style: AppTypography.headlineSmall,
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.onyx),
                onPressed: () {
                  ref.read(addItemProvider.notifier).reset();
                  Navigator.of(context).pop();
                },
              ),
            ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator(color: AppColors.onyx))
          : _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return PhotoCaptureStep(
          initialSource: _initialSource,
          onPhotoCaptured: (file) {
            setState(() {
              _capturedFile = file;
              _currentStep = 1;
            });
          },
        );
      case 1:
        return PhotoCropStep(
          sourceFile: _capturedFile!,
          onCropped: (file) {
            // Cropped fotoğrafı notifier'a kaydet
            ref.read(addItemProvider.notifier).setCroppedPhoto(file);
            setState(() {
              _currentStep = 2;
            });
          },
          onBack: () {
            setState(() {
              _currentStep = 0;
              _initialSource = null; // Geri dönüldüğünde seçiciyi baştan açsın diye
            });
          },
        );
      case 2:
        return SafeArea(
          bottom: false,
          child: ItemDetailsStep(
            isSaving: _isSaving,
            onBack: () {
              setState(() {
                _currentStep = 1; // Crop ekranına dön
              });
            },
            onSave: _handleSave,
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
