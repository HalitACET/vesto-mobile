/// Uygulama genelinde kullanılan string sabitler.
/// Hard-coded string yasak — tüm metinler buradan gelir.
abstract class AppStrings {
  // App
  static const String appName = 'Vesto';
  static const String appTagline = 'Your wardrobe, intelligently styled.';

  // Auth
  static const String welcomeBack = 'Hoş geldin.';
  static const String signIn = 'GİRİŞ YAP';
  static const String signOut = 'Çıkış Yap';
  static const String continueAnonymously = 'MISAFIR OLARAK DEVAM ET';
  static const String emailLabel = 'E-posta';
  static const String passwordLabel = 'Şifre';
  static const String authError = 'Giriş yapılırken bir hata oluştu.';

  // Home
  static const String homeTitle = 'Gardırop';
  static const String welcomeMessage = 'Hoş geldin';

  // Errors
  static const String genericError = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String networkError = 'İnternet bağlantınızı kontrol edin.';

  // Loading
  static const String loading = 'Yükleniyor...';
}
