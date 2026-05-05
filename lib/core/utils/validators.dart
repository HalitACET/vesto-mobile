/// Merkezi form validator'ları — DRY principle.
/// Tüm form'lar bu sınıfı kullanır, validation mantığı UI'da tekrarlanmaz.
/// Flutter'ın TextFormField.validator parametresine direkt geçilebilir.
abstract class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-posta adresi gerekli.';
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Geçerli bir e-posta adresi girin.';
    return null;
  }

  /// Login için — Firebase'in minimum 6 karakter kuralı.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Şifre gerekli.';
    if (value.length < 6) return 'Şifre en az 6 karakter olmalıdır.';
    return null;
  }

  /// Signup için — daha güçlü kural (UX dengeli, karmaşık kural yok).
  static String? passwordSignup(String? value) {
    if (value == null || value.isEmpty) return 'Şifre gerekli.';
    if (value.length < 8) return 'Şifre en az 8 karakter olmalıdır.';
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName gerekli.' : 'Bu alan gerekli.';
    }
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.trim().isEmpty) return 'Bu alan gerekli.';
    if (value.trim().length < min) return 'En az $min karakter olmalıdır.';
    return null;
  }

  /// confirm şifre eşleşme kontrolü. [other] = ilk şifre alanının değeri.
  static String? matchField(String? value, String? other) {
    if (value == null || value.isEmpty) return 'Bu alan gerekli.';
    if (value != other) return 'Şifreler eşleşmiyor.';
    return null;
  }

  /// Doğum yılı — null dönmek "geçerli" anlamına gelir (opsiyonel alan).
  static String? year(String? value, {int min = 1950, int max = 2010}) {
    if (value == null || value.trim().isEmpty) return null;
    final year = int.tryParse(value.trim());
    if (year == null) return 'Geçerli bir yıl girin.';
    if (year < min || year > max) return '$min ile $max arasında bir yıl girin.';
    return null;
  }

  static String? cm(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = int.tryParse(value.trim());
    if (v == null || v < 100 || v > 250) return 'Geçerli bir boy girin (100-250 cm).';
    return null;
  }

  static String? kg(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = int.tryParse(value.trim());
    if (v == null || v < 30 || v > 300) return 'Geçerli bir kilo girin (30-300 kg).';
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'İsim gerekli.';
    if (value.trim().length < 2) return 'İsim en az 2 karakter olmalıdır.';
    if (value.trim().length > 50) return 'İsim en fazla 50 karakter olabilir.';
    return null;
  }
}
