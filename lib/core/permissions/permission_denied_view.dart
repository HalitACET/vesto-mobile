import 'package:flutter/material.dart';
import 'package:mobile/core/permissions/permission_service.dart';
import 'package:mobile/core/widgets/atoms/vesto_empty_state.dart';

/// İzin reddedildiğinde gösterilen tam ekran rehber.
/// VestoEmptyState üzerine kurulu — "Ayarlardan İzin Ver" CTA'sı.
class PermissionDeniedView extends StatelessWidget {
  const PermissionDeniedView({
    super.key,
    required this.permissionType,
    required this.onOpenSettings,
  });

  final AppPermissionType permissionType;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isCamera = permissionType == AppPermissionType.camera;

    return Center(
      child: VestoEmptyState(
        icon: isCamera ? Icons.camera_alt_outlined : Icons.photo_library_outlined,
        title: isCamera ? 'Kamera İzni Gerekli' : 'Galeri İzni Gerekli',
        description: isCamera
            ? 'Kıyafet fotoğrafı çekebilmek için kamera iznine ihtiyaç duyuyoruz. '
                'Lütfen ayarlardan Kamera iznini açın.'
            : 'Galeriden fotoğraf seçebilmek için fotoğraf izni gerekiyor. '
                'Lütfen ayarlardan Fotoğraflar iznini açın.',
        actionLabel: 'AYARLARI AÇ',
        onAction: onOpenSettings,
      ),
    );
  }
}
