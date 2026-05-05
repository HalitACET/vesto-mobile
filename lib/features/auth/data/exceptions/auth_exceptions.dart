/// Auth katmanına özgü tip-güvenli hata modeli.
/// Firebase hata kodları bu sealed class'a dönüştürülür,
/// UI katmanı asla FirebaseAuthException ile muhatap olmaz.
sealed class AuthFailure {
  const AuthFailure();
}

final class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure();
}

final class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure();
}

final class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure();
}

final class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure();
}

final class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure();
}

final class TooManyRequestsFailure extends AuthFailure {
  const TooManyRequestsFailure();
}

final class AuthNetworkFailure extends AuthFailure {
  const AuthNetworkFailure();
}

/// Kullanıcı Google/provider popup'ı kapattı — hata değil, sessizce iptal.
final class CancelledAuthFailure extends AuthFailure {
  const CancelledAuthFailure();
}

final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([this.message = '']);
  final String message;
}

/// Firebase hata kodunu AuthFailure'a çevirir.
AuthFailure mapFirebaseAuthCode(String code, [String? message]) {
  return switch (code) {
    'invalid-email' => const InvalidEmailFailure(),
    'weak-password' => const WeakPasswordFailure(),
    'email-already-in-use' => const EmailAlreadyInUseFailure(),
    'wrong-password' || 'invalid-credential' => const WrongPasswordFailure(),
    'user-not-found' => const UserNotFoundFailure(),
    'too-many-requests' => const TooManyRequestsFailure(),
    'network-request-failed' => const AuthNetworkFailure(),
    _ => UnknownAuthFailure(message ?? ''),
  };
}

/// AuthFailure → Türkçe kullanıcı mesajı.
extension AuthFailureMessage on AuthFailure {
  String toUserMessage() {
    return switch (this) {
      InvalidEmailFailure() => 'Geçerli bir e-posta adresi girin.',
      WeakPasswordFailure() => 'Şifre en az 6 karakter olmalıdır.',
      EmailAlreadyInUseFailure() => 'Bu e-posta adresi zaten kullanımda.',
      WrongPasswordFailure() => 'E-posta veya şifre hatalı.',
      UserNotFoundFailure() => 'Bu e-posta ile kayıtlı hesap bulunamadı.',
      TooManyRequestsFailure() =>
        'Çok fazla deneme yapıldı. Lütfen birkaç dakika bekleyin.',
      AuthNetworkFailure() => 'İnternet bağlantınızı kontrol edin.',
      CancelledAuthFailure() => '',
      UnknownAuthFailure(:final message) =>
        message.isNotEmpty ? message : 'Beklenmedik bir hata oluştu.',
    };
  }
}
