import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_service.g.dart';

/// İzin türleri — şu an kamera ve galeri.
/// Gelecekte bildirim, konum gibi izinler buraya eklenir.
enum AppPermissionType { camera, gallery }

/// İzin durumu özet tipi — permission_handler'ı saran ince wrapper.
/// UI katmanı doğrudan permission_handler tiplerini kullanmaz.
enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied, // Kullanıcı "Bir daha sorma" seçtiyse
}

/// Kamera ve galeri izinlerini yöneten servis.
/// UI katmanında direkt `permission_handler` çağrısı yasaklıdır — bu sınıf üzerinden geçilir.
class PermissionService {
  const PermissionService();

  // ── Durum sorgula ─────────────────────────────────────────────────────────

  Future<AppPermissionStatus> checkStatus(AppPermissionType type) async {
    final perm = _toPermission(type);
    final status = await perm.status;
    return _toAppStatus(status);
  }

  // ── İzin iste ─────────────────────────────────────────────────────────────

  Future<AppPermissionStatus> request(AppPermissionType type) async {
    final perm = _toPermission(type);

    // Zaten verilmişse tekrar sorma
    final current = await perm.status;
    if (current.isGranted) return AppPermissionStatus.granted;

    // Kalıcı ret durumunda sistem dialog'u açılmaz — ayarlara yönlendir
    if (current.isPermanentlyDenied) {
      return AppPermissionStatus.permanentlyDenied;
    }

    final result = await perm.request();
    return _toAppStatus(result);
  }

  // ── Sistem ayarlarına yönlendir ────────────────────────────────────────────

  /// Kalıcı ret durumunda kullanıcıyı uygulama ayarlarına açar.
  Future<void> openSystemSettings() async {
    await openAppSettings();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Permission _toPermission(AppPermissionType type) => switch (type) {
        AppPermissionType.camera => Permission.camera,
        AppPermissionType.gallery => Permission.photos,
      };

  AppPermissionStatus _toAppStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) return AppPermissionStatus.granted;
    if (status.isPermanentlyDenied) return AppPermissionStatus.permanentlyDenied;
    return AppPermissionStatus.denied;
  }
}

@riverpod
PermissionService permissionService(Ref ref) {
  return const PermissionService();
}
