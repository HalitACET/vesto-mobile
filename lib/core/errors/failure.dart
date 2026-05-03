import 'package:equatable/equatable.dart';

/// Repository katmanından dönen tip-güvenli hata modeli.
/// UI katmanı exception yakalamak yerine Failure ile çalışır.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

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
