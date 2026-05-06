import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/widgets/atoms/vesto_empty_state.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/photo_source_selector.dart';

/// Kıyafet ekleme akışının ilk adımı: Fotoğraf seçimi/çekimi.
/// Başlangıçta [initialSource] verilmişse doğrudan o kaynağı açar.
/// İptal durumunda veya hata durumunda "Yeniden Dene" görünümü sunar.
class PhotoCaptureStep extends StatefulWidget {
  const PhotoCaptureStep({
    super.key,
    this.initialSource,
    required this.onPhotoCaptured,
  });

  final ImageSource? initialSource;
  final ValueChanged<File> onPhotoCaptured;

  @override
  State<PhotoCaptureStep> createState() => _PhotoCaptureStepState();
}

class _PhotoCaptureStepState extends State<PhotoCaptureStep> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSource != null) {
      // initState içinde dialog/picker açmak için frame sonunu bekle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage(widget.initialSource!);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null && mounted) {
        widget.onPhotoCaptured(File(image.path));
      }
    } catch (e) {
      // İzin hataları vs. yakalanabilir, permission_service'i Notifier'da kullanacağız
      // Şimdilik sadece fail state'e düşsün
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  Future<void> _showSelectorAndPick() async {
    final source = await PhotoSourceSelector.show(context);
    if (source != null && mounted) {
      await _pickImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPicking) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.onyx),
      );
    }

    return Center(
      child: VestoEmptyState(
        icon: Icons.add_a_photo_outlined,
        title: 'Fotoğraf Seçilmedi',
        description: 'Kıyafet eklemek için bir fotoğraf çekin veya galeriden seçin.',
        actionLabel: 'FOTOĞRAF SEÇ',
        onAction: _showSelectorAndPick,
      ),
    );
  }
}
