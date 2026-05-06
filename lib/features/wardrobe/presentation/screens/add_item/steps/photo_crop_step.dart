import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';

/// Kıyafet ekleme akışının ikinci adımı: Fotoğraf kırpma ve önizleme.
/// Başlangıçta native image_cropper UI'ını açar.
/// Başarılı kırpma sonrası önizleme sunar (Geri ve Devam butonlarıyla).
class PhotoCropStep extends StatefulWidget {
  const PhotoCropStep({
    super.key,
    required this.sourceFile,
    required this.onCropped,
    required this.onBack,
  });

  final File sourceFile;
  final ValueChanged<File> onCropped;
  final VoidCallback onBack;

  @override
  State<PhotoCropStep> createState() => _PhotoCropStepState();
}

class _PhotoCropStepState extends State<PhotoCropStep> {
  File? _croppedFile;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    // Ekrana girer girmez cropper'ı başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cropImage();
    });
  }

  Future<void> _cropImage() async {
    if (_isCropping) return;
    setState(() => _isCropping = true);

    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: widget.sourceFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square crop
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100, // Quality compression will be done by ImageService
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Kıyafetini Kırp',
            toolbarColor: const Color(0xFF0A0A0A),    // Onyx
            toolbarWidgetColor: const Color(0xFFF5F5F5), // Pearl
            backgroundColor: const Color(0xFFF5F5F5), // Pearl
            activeControlsWidgetColor: const Color(0xFF0A0A0A), // Onyx
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false, // rotate + scale butonları görünür kalır
          ),
          IOSUiSettings(
            title: 'Kıyafetin görünür olmasını sağla',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (cropped != null && mounted) {
        setState(() {
          _croppedFile = File(cropped.path);
        });
      } else if (cropped == null && mounted) {
        // Kullanıcı cropper'dan vazgeçtiyse geri dön
        widget.onBack();
      }
    } finally {
      if (mounted) {
        setState(() => _isCropping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final radius = context.radius;

    if (_isCropping || _croppedFile == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.onyx),
      );
    }

    return Padding(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius.md),
                child: Image.file(
                  _croppedFile!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: spacing.xl),
          Row(
            children: [
              Expanded(
                child: VestoButton(
                  label: 'GERİ',
                  onPressed: widget.onBack,
                  variant: VestoButtonVariant.secondary,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: VestoButton(
                  label: 'DEVAM',
                  onPressed: () => widget.onCropped(_croppedFile!),
                  variant: VestoButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
