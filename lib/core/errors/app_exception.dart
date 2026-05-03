/// Uygulama genelinde fırlatılan tip-güvenli exception hiyerarşisi.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'Bağlantı hatası oluştu.']);
}

final class AuthException extends AppException {
  const AuthException([super.message = 'Kimlik doğrulama hatası.']);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'İstenen kaynak bulunamadı.']);
}

final class PermissionException extends AppException {
  const PermissionException([super.message = 'Bu işlem için yetkiniz yok.']);
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Sunucu hatası oluştu.']);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Önbellek hatası oluştu.']);
}
