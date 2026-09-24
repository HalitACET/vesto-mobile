# CLAUDE.md — Vesto Mobile

> Önce kök dizindeki `../CLAUDE.md`'yi oku (ürün hedefi, repo düzeni, veri sözleşmesi, doğrulama komutları, güncel faz durumu). Bu dosya sadece mobile'a özgü kalıcı bilgileri içerir.

---

## 🎯 Proje Vizyonu

**Vesto**, kullanıcıların kıyafetlerini dijital bir gardıroba dönüştüren ve dış verileri (hava durumu, lokasyon) kullanarak **kullanıcının kendi dolabındaki parçalarla** kişiselleştirilmiş kombin önerileri sunan bir platformdur. Topluluk tabanlı stil danışmanlığı ve stilist desteği içerir.

**USP:** Pinterest'teki kombinler hayalî, Instagram'daki influencer parçaları ulaşılmaz. Vesto'da sana önerilen her kombin **senin kendi dolabındaki parçalarla** yapılır — yani uygulanabilir.

**Temel Özellikler:**
1. Dijital gardırop (fotoğraf çek → Cloud Function + Vision API ile etiketleme)
2. Kombin önerisi (hava + dolap bazlı)
3. Manuel kombin editörü
4. Sosyal forum ("Ne giysem" postları)
5. Granüler dolap paylaşımı (forum postunda sadece seçili parçalar açılır)
6. Topluluk stilist önerisi (başkasının dolabıyla kombin yapma)
7. Doğrulanmış stilist rozeti (admin onaylı profesyoneller)
8. Profesyonel stilist danışmanlığı

---

## 🛠️ Teknoloji Yığını

- **Framework:** Flutter, Dart SDK `>=3.11.0 <4.0.0`
- **State Management:** Riverpod 3.x (`flutter_riverpod` ^3, `riverpod_annotation` ^4 + `riverpod_generator` code generation)
- **Modeller:** Freezed 3 + `json_serializable`
- **Routing:** go_router 17
- **Backend:** Firebase (Auth, Firestore, Cloud Storage, Cloud Messaging) + Cloud Functions (`../firebase/functions`)
- **Bildirim:** `firebase_messaging` + `flutter_local_notifications`
- **Hava durumu:** Open-Meteo (API anahtarı gerekmez) — `lib/features/today/data/services/weather_service.dart`
- **Görsel analiz:** Google Vision API (sadece Cloud Function içinde, istemcide değil)
- **Hedef Platform:** Sadece Android (iOS klasörü yok)

Kesin paket sürümleri için `pubspec.yaml` tek doğru kaynaktır.

---

## 🔧 Proje Kimlik Bilgileri

- **Package name:** `app.vesto.mobile`
- **Org:** `app.vesto`
- **Project name (pubspec):** `mobile`
- **Lokasyon:** `D:\projects\vesto-app\mobile`

---

## 📂 Klasör Yapısı (Feature-First Mimari)

```
/mobile/lib
├── main.dart
├── app/
│   ├── app.dart                       # MaterialApp + tema
│   ├── router.dart                    # go_router yapılandırması (AppRoutes)
│   ├── main_shell.dart                # ShellRoute + bottom nav
│   └── theme/                         # colors, typography, spacing, radius, durations, extensions
│
├── core/                              # Tüm feature'larda kullanılan ortak şeyler
│   ├── constants/
│   ├── errors/                        # app_exception.dart, failure.dart
│   ├── network/                       # firebase_providers.dart (Auth, Firestore, Storage instance'ları)
│   ├── permissions/                   # PermissionService + PermissionDeniedView
│   ├── services/                      # fcm, image (compression), upload
│   ├── utils/
│   └── widgets/                       # Vesto* prefix'li componentler (atoms / molecules / organisms)
│
└── features/                          # Her feature kendi data/ + presentation/ katmanıyla
    ├── auth/
    ├── home/
    ├── today/                         # Hava + günlük kombin önerisi
    ├── wardrobe/
    ├── outfits/
    ├── forum/
    ├── stylist/
    ├── profile/
    └── _dev/                          # Geliştirme showcase ekranları
```

Feature içi düzen:
```
features/<feature>/
├── data/          # models/, repositories/, services/
└── presentation/  # providers/, screens/, widgets/
```

**Layer-First (yanlış):** `/models`, `/views`, `/services` — kullanma!
**Feature-First (doğru):** Her feature kendi `data/` ve `presentation/` katmanına sahip.

---

## ⚡ Riverpod Provider Hiyerarşisi

```
firebaseAuthProvider     (Provider)         ← FirebaseAuth instance
firestoreProvider        (Provider)         ← FirebaseFirestore instance
storageProvider          (Provider)         ← FirebaseStorage instance
        ↓
authStateChangesProvider (StreamProvider)   ← Firebase auth durumu
        ↓
currentUserProvider      (StreamProvider)   ← Firestore'dan AppUser
        ↓
[wardrobeProvider, outfitsProvider, vs.]
```

**Provider Tipi Seçim Rehberi:**

| Tip | Ne zaman? | Örnek |
|---|---|---|
| `Provider` | Sabit değer | Firebase instance'ları |
| `FutureProvider` | Tek seferlik async | "Bu kıyafetin AI analizini getir" |
| `StreamProvider` | Real-time veri | Firestore'dan auth, gardırop, kombin listesi |
| `NotifierProvider` | Karmaşık state + metodlar | Kombin editörü canvas state'i |
| `AsyncNotifierProvider` | Async + karmaşık state | Kıyafet ekleme akışı |

**Genel kural:** Firestore'dan gelen veriler `StreamProvider` (real-time olsun), kullanıcı etkileşimi gerektiren state'ler `NotifierProvider`.

Model/provider değiştirdikten sonra: `dart run build_runner build --delete-conflicting-outputs`.

---

## 🛣️ Routing Stratejisi (go_router)

- Route sabitleri `AppRoutes` içinde; tam liste için `lib/app/router.dart` tek doğru kaynaktır.
- **ShellRoute (bottom nav görünür):** Today, Wardrobe, Outfits, Forum, Profile (+ profil düzenleme/ayarlar).
- **ShellRoute dışı (full-screen):** splash, onboarding, login/signup/forgot password, profile setup, kıyafet ekleme, kıyafet detayı, forum post detay/oluştur/paylaş, public profile, stilist akışları, bildirimler.
- **Auth-aware redirect:** `authStateChangesProvider` değiştiğinde router otomatik tepki verir (`refreshListenable` köprüsü ile).

---

## 🎨 Tema Sistemi (Lüks Moda Dergisi Estetiği)

**Felsefe:** Vogue/Harper's Bazaar hissi. Renk yok, sadece gri tonları. Geniş whitespace.

**Renk Paleti:**
```dart
class AppColors {
  static const Color onyx = Color(0xFF0A0A0A);       // Primary
  static const Color charcoal = Color(0xFF1F1F1F);   // Surface dark
  static const Color graphite = Color(0xFF404040);   // Border, divider
  static const Color stone = Color(0xFF737373);      // Secondary text
  static const Color mist = Color(0xFFD4D4D4);       // Disabled
  static const Color pearl = Color(0xFFF5F5F5);      // Background light
  static const Color white = Color(0xFFFFFFFF);      // Pure white
}
```

**Tipografi:**
- **Başlıklar (display/headline):** `Cormorant` serif — `assets/fonts/` altında paketli (pubspec `fonts`)
- **Title/Body:** `Inter` — `google_fonts` ile
- **Buton metinleri:** `Manrope` — `google_fonts` ile

**Whitespace Prensibi:** Padding'ler agresif (16-24-32px). Material default "kalabalık" hisseder, kaçın.

**Aksent Renk Yok:** Lüks markaların yaptığı gibi (Chanel, Hermès) sadece gri tonları kullan.

---

## 🗄️ Firestore

Mobile ve web aynı Firestore'u kullanır. Koleksiyon listesi ve ortak veri sözleşmesi için kök `../CLAUDE.md` → "Veri modeli" bölümüne bak. Güvenlik kuralları ve index'ler `../firebase/` altındadır.

**Kalıcı Mimari Kararlar:**

1. **Top-level collections (subcollection değil)** — Global istatistikler için cross-user query gerekli
2. **Hibrit denormalization:** `itemIds` source of truth + `itemSnapshots` UI snapshot
3. **AI analizi async:** Storage'a görsel yüklenince Cloud Function tetiklenir, `aiAnalysis` field'ı nullable
4. **Composite ID pattern:** `{postId}_{userId}` ile duplicate prevention (likes, follows)
5. **Defense-in-depth security (hedef):** `stats`, `aiAnalysis`, `likeCount`, `role` gibi field'lar istemciden yazılamamalı. ⚠️ Şu an kurallar bunu tam uygulamıyor — bkz. kök CLAUDE.md, Faz 1.
6. **Granüler dolap paylaşımı:** Forum postunda `exposedItemIds: string[]` ile sadece seçili parçalar açılır
7. **Web'in yazdığı field'lar** (ör. `adminReview`) mobile modellerinde nullable tanımlanır

---

## 🏛️ Mimari Kararlar

- **Optimistic UI Pattern:** Save eyleminde Firestore doc önce oluşturuluyor (status: 'uploading'), kullanıcı anında yönlendiriliyor, image upload background'da yapılıp doc güncelleniyor (status: 'ready'). `notifier.reset()` çağrılMAZ — Riverpod `AutoDispose` otomatik temizler.
- **Sealed Class Re-export Pattern:** `wardrobe_exceptions.dart` dosyası `failure.dart`'taki sealed class failures'ı re-export eder (Dart sealed class kısıtlaması). Yeni `Failure` tipleri sadece `failure.dart`'a eklenir.
- **Client-side Image Compression:** 1920x1920 max q85 (~500KB) original + 200x200 q80 (~30KB) thumbnail. EXIF stripping (`keepExif: false`) ile GPS privacy korunur.
- **Riverpod AutoDispose:** Form notifier'larında `@riverpod` `AutoDispose` pattern kullanılır. Manuel `reset()` çağrılmaz — sayfa kapanınca framework otomatik temizler. Manuel reset glitch'e sebep olur.
- **Client-side Filter:** 200-300 kıyafet seviyesinde optimal. 1000+ kıyafet için server-side filter veya arama servisine geçilebilir. `filteredWardrobeItems` computed provider belleği filtreler.
- **ShellRoute + Bottom Nav Pattern:** Auth flow ve modal akışlar ShellRoute DIŞINDA (full-screen). Sadece tab'lı ekranlar ShellRoute içinde. `MainShell` location'a göre FAB visibility'sini de yönetir.
- **Search Bar Pattern (Vogue/NYT):** Borderless underline-only. Sadece bottom border, transparent background. Material default border + `focusedBorder` + `enabledBorder` üçü de `InputBorder.none` olmalı (yaygın hata).
- **Chip Optical Centering:** Inter font'un default line-height container'a sığmıyor. Çözüm: `height: 40` (fixed) + `alignment: Alignment.center` + TextStyle'da `height: 1.0`. Padding hack'i değil, doğru pattern.

---

## ⚙️ Bilinen Konfigürasyon Notları

- `image_cropper` paketi kullanırken `AndroidManifest.xml`'e `UCropActivity` tanımı manuel eklenmeli. Vesto temasıyla custom `styles.xml` entry var (`Theme.Vesto.UCrop`).
- Firebase Storage rules `../firebase/rules/storage.rules`. Proje: `vesto-ai-a7ad6`. Region: `europe-west1`.
- Firestore composite indexes `../firebase/indexes/firestore.indexes.json` dosyasında. Yeni multi-field query (where + where + orderBy) ekleyince composite index gerekir; Firebase hata mesajındaki link ile oluşturulabilir, sonra dosyaya eklenmeli.
- `keepExif: false` image compression sırasında her zaman uygulanmalı (GPS privacy).
- Yeni paket eklerken README'deki Android-specific setup (manifest entries, theme entries) kontrol et.
- `lib/firebase_options.dart` ve `android/app/google-services.json` commit edilmez.

---

## ⚖️ Mimari Prensipler (Kritik)

1. **Clean Code & SOLID** — özellikle Single Responsibility ve Dependency Inversion
2. **Tip güvenliği önceliği** — `dynamic` yasak, `Object?` minimal kullanım
3. **Repository pattern** — UI katmanı Firestore'a direkt erişmez, repository üzerinden
4. **Riverpod provider'lar küçük ve composable** — büyük god-provider'lardan kaçın
5. **Hiçbir hard-coded string yok** — sabitler `core/constants` altında
6. **Hata yönetimi** — `Failure` sınıfı, exception fırlatma yerine `Either<Failure, Success>` veya `AsyncValue` pattern'ı
7. **Naming convention:** Custom widget'lar `Vesto*` prefix'li (`VestoButton`, `VestoCard`)
8. **Async/await tercih edilir** — `.then()` callback chain'lerinden kaçın

---

## 🚫 Yapma Listesi

- ❌ **Layer-first klasör yapısı** (`/models`, `/views`) — Feature-first kullan
- ❌ **`dynamic` tipi** — her zaman explicit tip
- ❌ **Hard-coded string'ler** — `core/constants` altında sabit tanımla
- ❌ **UI'dan direkt Firestore çağrısı** — Repository pattern'a uy
- ❌ **God-provider'lar** — küçük, composable provider'lar yaz
- ❌ **Material default padding/margin** — agresif whitespace kullan (16-24-32)
- ❌ **Renkli aksent ekleme** — sadece gri palet (Onyx, Charcoal, Graphite, Stone, Mist, Pearl, White)
- ❌ **Bold font ağırlık abusing** — sadece h1-h3 ve label'larda kullan
- ❌ **Deprecated paket kullanmak** — pub.dev'de güncel versiyonu kontrol et
- ❌ **Yeni kategori kodu yazmak** — ortak taksonomi gelene kadar (kök CLAUDE.md, Faz 4)

---

## 💬 İletişim Stili

- **Dil:** Türkçe konuş, kodlar/commit/yorumlar İngilizce
- **Tarz:** Kıdemli yazılım mimarı + ürün yöneticisi gibi davran
- **Kararlar:** Her öneride gerekçeyi açıkla, mimari kırmızı bayrakları erkenden işaretle
- **Format:** Trade-off'ları tablo ile göster, kâğıda çizilebilir mental modeller kur
- **Adım adım:** Karmaşık konuları küçük parçalara böl
- **Öğrenme tarzı:** Stratejik özet → Feynman tekniği (analoji) → bilgi boşluğu tespiti → tek tek soru
- **Encouragement** ölçülü ve içten olsun, abartılı olmasın

---

## 📌 Mobile'da Çalışırken

1. Kod önerirken yukarıdaki klasör yapısına ve naming convention'a birebir uy
2. Hata loglu bir mesajda önce **mimari prensipleri ihlal eden kısım var mı** kontrol et
3. Yeni paket eklerken gerekçesini açıkla — gerekli mi, alternatif var mı?
4. Bir Firestore alanını/enum'u değiştiriyorsan web tarafını da güncelle (kök CLAUDE.md)
5. Bitirmeden önce `flutter analyze` ve `flutter test` çalıştır
