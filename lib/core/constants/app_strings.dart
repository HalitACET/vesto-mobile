/// Uygulama genelinde kullanılan string sabitler.
/// Hard-coded string yasak — tüm metinler buradan gelir.
abstract class AppStrings {
  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'Vesto';
  static const String appTagline = 'Your wardrobe, intelligently styled.';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const String onboardingSkip = 'ATLA';
  static const String onboardingGetStarted = 'BAŞLAYIN';
  static const String onboarding1Title = 'Dolabınız, dijitalleşti.';
  static const String onboarding1Body =
      'Kıyafetlerinizi fotoğraflayın, yapay zeka otomatik etiketlesin. Tüm gardırobunuz parmaklarınızın ucunda.';
  static const String onboarding2Title = 'Yapay zeka stilistiniz.';
  static const String onboarding2Body =
      'Hava durumu, konum ve tarz tercihlerinize göre her gün kişiselleştirilmiş kombin önerileri.';
  static const String onboarding3Title = 'Topluluk size kombin önerir.';
  static const String onboarding3Body =
      'Gerçek insanlar, sizin gerçek kıyafetlerinizle. Pinterest\'teki hayaller değil, çıkabileceğiniz kombinler.';

  // ── Auth — Genel ──────────────────────────────────────────────────────────
  static const String emailLabel = 'E-posta';
  static const String passwordLabel = 'Şifre';
  static const String displayNameLabel = 'Ad Soyad';

  // ── Login ─────────────────────────────────────────────────────────────────
  static const String loginTitle = 'Hoş geldin.';
  static const String loginSubtitle = 'Stilinizi yönetin, kombinlerinizi keşfedin.';
  static const String loginButton = 'GİRİŞ YAP';
  static const String loginWithGoogle = 'Google ile Giriş Yap';
  static const String forgotPassword = 'Şifremi unuttum';
  static const String noAccount = 'Henüz üye değilim';
  static const String orDivider = 'veya';

  // ── Signup ────────────────────────────────────────────────────────────────
  static const String signupTitle = 'Hesap oluştur.';
  static const String signupSubtitle = 'Vesto\'ya katılın.';
  static const String signupButton = 'HESAP OLUŞTUR';
  static const String confirmPasswordLabel = 'Şifre tekrar';
  static const String hasAccount = 'Zaten hesabım var';
  static const String termsAgree = 'Kullanım koşullarını kabul ediyorum';

  // ── Forgot Password ───────────────────────────────────────────────────────
  static const String forgotPasswordTitle = 'Şifre sıfırla.';
  static const String forgotPasswordSubtitle =
      'E-posta adresinizi girin, sıfırlama bağlantısı gönderelim.';
  static const String forgotPasswordButton = 'BAĞLANTI GÖNDER';
  static const String forgotPasswordSuccess =
      'E-posta\'nıza bir bağlantı gönderdik.';
  static const String forgotPasswordSuccessBody =
      'Spam klasörünü de kontrol etmeyi unutmayın.';
  static const String backToLogin = 'Giriş ekranına dön';

  // ── Profile Setup ─────────────────────────────────────────────────────────
  static const String profileSetupStep1Title = 'Sizi tanıyalım.';
  static const String profileSetupStep2Title = 'Daha iyi öneri için.';
  static const String profileSetupStep2Subtitle =
      'Bu bilgiler beden ölçülerinize uygun kombinler önerilmesi için kullanılır. İstediğiniz zaman atlayabilirsiniz.';
  static const String profileSetupStep3Title = 'Neredesiniz?';
  static const String profileSetupStep3Subtitle =
      'Hava durumuna göre kombinler önerebilmemiz için şehrinizi paylaşın.';
  static const String profileSetupStep4Title = 'Tarzınızı söyleyin.';
  static const String profileSetupContinue = 'DEVAM ET';
  static const String profileSetupComplete = 'TAMAMLA';
  static const String profileSetupSkip = 'Bu adımı atla';
  static const String profileSetupSkipStep = 'Atla';
  static const String genderLabel = 'Cinsiyet';
  static const String birthYearLabel = 'Doğum yılı';
  static const String heightLabel = 'Boy (cm)';
  static const String weightLabel = 'Kilo (kg)';
  static const String cityLabel = 'Şehir';
  static const String autoLocate = 'Konumumu otomatik bul';
  static const String aestheticsLabel = 'Estetik';
  static const String occasionsLabel = 'Kullanım amacı';

  // ── Home ──────────────────────────────────────────────────────────────────
  static const String homeTitle = 'Gardırop';
  static const String welcomeMessage = 'Hoş geldin';
  static const String signOut = 'Çıkış Yap';

  // ── Eski isimler — geriye dönük uyumluluk (Faz 2'de kaldırılacak) ─────────
  static const String signIn = loginButton;
  static const String continueAnonymously = 'MİSAFİR OLARAK DEVAM ET';
  static const String welcomeBack = loginTitle;

  // ── Errors ────────────────────────────────────────────────────────────────
  static const String genericError = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String networkError = 'İnternet bağlantınızı kontrol edin.';
  static const String loading = 'Yükleniyor...';
}
