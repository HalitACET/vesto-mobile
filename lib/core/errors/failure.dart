import 'package:equatable/equatable.dart';

/// Repository katmanından dönen tip-güvenli hata modeli.
/// UI katmanı exception yakalamak yerine Failure ile çalışır.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

// ── Core Failures ─────────────────────────────────────────────────────────────

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Bağlantı hatası oluştu.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Kimlik doğrulama hatası.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'İstenen kaynak bulunamadı.']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Bu işlem için yetkiniz yok.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Sunucu hatası oluştu.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Beklenmedik bir hata oluştu.']);
}

// ── Wardrobe Failures ─────────────────────────────────────────────────────────
// Sealed class aynı kütüphane içinden genişletilebilir.

/// Storage'a yükleme sırasında oluşan hata.
final class StorageUploadFailure extends Failure {
  const StorageUploadFailure(
      [super.message = 'Fotoğraf yüklenirken bir hata oluştu.']);
}

/// Firestore'a document yazma sırasında oluşan hata.
final class FirestoreWriteFailure extends Failure {
  const FirestoreWriteFailure(
      [super.message = 'Kıyafet kaydedilirken bir hata oluştu.']);
}

/// Kıyafet bulunamadı hatası.
final class ItemNotFoundFailure extends Failure {
  const ItemNotFoundFailure([super.message = 'Kıyafet bulunamadı.']);
}

/// Fotoğraf sıkıştırma / işleme sırasında oluşan hata.
final class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure(
      [super.message = 'Fotoğraf işlenirken bir hata oluştu.']);
}

/// Kamera/galeri izni reddedildi.
final class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure(
      [super.message = 'Fotoğraf izni reddedildi. Ayarlardan izin verin.']);
}

/// Kullanıcı oturum açmamış — wardrobe işlemi yapılamaz.
final class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure(
      [super.message = 'Bu işlem için giriş yapmanız gerekiyor.']);
}

/// Genel wardrobe hatası.
final class WardrobeUnexpectedFailure extends Failure {
  const WardrobeUnexpectedFailure(
      [super.message = 'Beklenmedik bir hata oluştu.']);
}
