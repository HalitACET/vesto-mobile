# CLAUDE.md — Vesto AI Mobile

> Bu dosya, Vesto AI mobil projesinde çalışan AI asistanları için kalıcı bağlamı içerir.
> Yeni bir session açtığında bu dosyayı okuyup içeriğine göre davranmalısın.

---

## 🎯 Proje Vizyonu

**Vesto AI**, kullanıcıların kıyafetlerini dijital bir gardıroba dönüştüren, yapay zeka ile analiz eden ve dış verileri (hava durumu, lokasyon) kullanarak kişiselleştirilmiş kombin önerileri sunan hibrit bir platformdur. Topluluk tabanlı stil danışmanlığı ve profesyonel stilist desteği içerir.

**USP (Unique Selling Proposition):**
Pinterest'teki kombinler hayalî, Instagram'daki influencer parçaları ulaşılmaz. Vesto'da sana önerilen her kombin **senin kendi dolabındaki parçalarla** yapılır — yani uygulanabilir.

**Temel Özellikler:**
1. Dijital gardırop (fotoğraf çek → AI otomatik etiketler)
2. AI kombin önerisi (hava + stil + dolap bazlı)
3. Manuel kombin editörü (sürükle-bırak canvas)
4. Sosyal forum ("Ne giysem" postları)
5. Granüler dolap paylaşımı (forum postunda sadece seçili parçalar açılır)
6. Topluluk stilist önerisi (başkasının dolabıyla kombin yapma)
7. Doğrulanmış stilist rozeti (admin onaylı profesyoneller)
8. Profesyonel stilist danışmanlığı

---

## 🛠️ Teknoloji Yığını

**Bu Proje (Mobil):**
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod 2.x (riverpod_annotation + code generation)
- **Routing:** go_router
- **Backend:** Firebase (Auth + Firestore + Cloud Storage + Cloud Functions)
- **Hedef Platform:** Sadece Android (iOS sonra eklenecek)

**Paralel Proje (Web):**
- Next.js + TypeScript
- Tailwind CSS + Shadcn/ui
- dnd-kit (canvas)

**AI & Dış Servisler:**
- Google Vision API (renk, kategori, materyal tespiti)
- OpenWeatherMap (hava durumu)

---

## 📁 Monorepo Yapısı

```
/vesto-app
├── /mobile          ← BU PROJE (Flutter)
├── /web             ← Next.js admin/stilist paneli
└── /firebase        ← Ortak Firestore rules, Cloud Functions
```

**Kritik:** Mobil ve web **aynı Firebase projesini** paylaşır. Firestore schema, security rules ve Cloud Storage ortaktır.

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
│   ├── router.dart                    # go_router yapılandırması
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_typography.dart
│
├── core/                              # Tüm feature'larda kullanılan ortak şeyler
│   ├── constants/
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── failure.dart
│   ├── extensions/
│   ├── network/
│   │   └── firebase_providers.dart    # FirebaseAuth, Firestore, Storage instance'ları
│   ├── utils/
│   └── widgets/                       # Atomik componentler (Vesto* prefix'li)
│       ├── vesto_button.dart
│       ├── vesto_card.dart
│       └── vesto_loading.dart
│
├── features/                          # Her feature kendi mini-mimarisiyle
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── wardrobe/                      # 4-5. hafta
│   ├── outfit_editor/                 # 8. hafta
│   ├── forum/                         # 9-10. hafta
│   ├── profile/                       # 11. hafta
│   └── weather/                       # 7. hafta
│
└── shared/                            # Birden fazla feature'ın paylaştığı modeller
    └── models/
        └── wardrobe_item.dart
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

---

## 🛣️ Routing Stratejisi (go_router)

```
/splash    → Splash screen (auth durumu kontrolü, otomatik redirect)
/login     → Giriş ekranı (auth yoksa redirect)
/home      → Ana ekran (auth varsa redirect)
/onboarding → Profil tamamlama wizard'ı (3. hafta)
/wardrobe  → Gardırop listesi (5. hafta)
/wardrobe/add → Kıyafet ekleme (4. hafta)
/outfit/editor → Kombin editörü (8. hafta)
/forum     → Forum feed'i (9. hafta)
/profile/:userId → Kullanıcı profili (11. hafta)
```

**Auth-aware redirect mantığı:** `authStateChangesProvider` değiştiğinde router otomatik tepki verir (`refreshListenable` köprüsü ile).

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
- **Başlıklar:** Serif font (`Playfair Display` veya `Cormorant`) — moda dergisi hissi
- **Body:** Sans-serif (`Inter` veya `Manrope`) — temiz okunabilirlik
- `google_fonts` paketi ile yüklenir

**Whitespace Prensibi:** Padding'ler agresif (16-24-32px). Material default "kalabalık" hisseder, kaçın.

**Aksent Renk Yok:** Lüks markaların yaptığı gibi (Chanel, Hermès) sadece gri tonları kullan.

---

## 🗄️ Firestore Veritabanı Şeması

Web tarafında zaten kurulu, mobil bu modellere bağlanır.

**Ana Koleksiyonlar:**

| Koleksiyon | Amaç |
|---|---|
| `users/{userId}` | Profil + role + denormalized stats |
| `wardrobeItems/{itemId}` | Kıyafetler + AI analiz (nullable) |
| `outfits/{outfitId}` | Kombinler + canvas layout |
| `outfitLikes/{likeId}` | Composite ID: `{outfitId}_{userId}` |
| `comments/{commentId}` | Outfit yorumları |
| `follows/{followId}` | Composite ID: `{followerId}_{followingId}` |
| `forumPosts/{postId}` | "Ne giysem" postları + `exposedItemIds` |
| `outfitSuggestions/{id}` | Topluluk kombin önerileri |
| `stylistConsultations/{id}` | Profesyonel danışmanlık |
| `globalStats/{statId}` | Aggregated metrics (10. hafta) |

**Kritik Mimari Kararlar:**

1. **Top-level collections (subcollection değil)** — Global istatistikler için cross-user query gerekli
2. **Hibrit denormalization:** `itemIds` source of truth + `itemSnapshots` UI snapshot
3. **AI analizi async:** Cloud Function ile post-create tetiklenir, `aiAnalysis` field'ı nullable
4. **Composite ID pattern:** `{postId}_{userId}` ile duplicate prevention (likes, follows)
5. **Defense-in-depth security:** `stats`, `aiAnalysis`, `likeCount`, `role` field'ları sadece Cloud Functions'tan yazılabilir
6. **Granüler dolap paylaşımı:** Forum postunda `exposedItemIds: string[]` ile sadece seçili parçalar açılır
7. **Outfit suggestion'lar ayrı koleksiyon:** Kabul/red akışı için (post sahibi bir öneriyi `outfits`'a kopyalayabilir)

---

## 👤 AppUser Modeli

**Hafta 1 için minimal versiyon:**
```dart
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final UserRole role;
  final DateTime createdAt;
}

enum UserRole { user, verifiedStylist, admin }
```

**İleride eklenecek (3. hafta onboarding):**
- `gender`, `birthYear`, `heightCm`, `weightKg`
- `location: { city, country, lat, lng }`
- `stylePreferences: { aesthetics, favoriteColors, occasions }`
- `stats: { wardrobeItemCount, outfitCount, followerCount, followingCount }`

**Önemli:** Şimdi gereksiz field'lar ekleme — gereksiz kompleksite getirir.

---

## 📦 Pubspec.yaml Bağımlılıkları

**Firebase:**
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`

**State Management & Routing:**
- `flutter_riverpod`
- `riverpod_annotation`
- `go_router`

**UI:**
- `google_fonts`
- `flutter_svg`

**Utils:**
- `intl`
- `equatable`

**Dev Dependencies:**
- `riverpod_generator`
- `build_runner`
- `custom_lint`
- `riverpod_lint`

Versiyon olarak Flutter 3.x ile uyumlu en güncel **stable** versiyonları kullan.

---

## 📊 İlerleme Özeti

- Mobil: 5/14 hafta tamamlandı (%36)
- Web: 8/14 hafta tamamlandı (%57)
- Toplam: ~%46

---

## 📅 14 Haftalık Yol Haritası

| Hafta | Faz | İş Paketi | Durum |
|---|---|---|---|
| 1 | 🏗️ Planlama | Mimari Kurulum | ✅ |
| 2 | 🎨 Tasarım | Design System | ✅ |
| 3 | 🔐 Altyapı | Auth Akışı (onboarding, login, profil wizard) | ✅ |
| 4 | 📸 Veri | Kıyafet Ekleme (kamera + galeri + upload) | ✅ |
| 5 | 👗 Veri | Gardırop Görünümü | ✅ |
| 6 | 🧠 AI | AI Analiz, Cloud Functions, Vision API | 🚧 |
| 7 | 🌤️ Akıllı | Hava + Öneri Modülü | ⏳ |
| 8 | 🖱️ İnteraktif | Mobil Kombin Editörü | ⏳ |
| 9 | 💬 Sosyal | Forum + Feed | ⏳ |
| 10 | 👔 Sosyal | Topluluk Stilist Önerisi | ⏳ |
| 11 | 👤 Sosyal | Profil + Takip | ⏳ |
| 12 | 🔔 Etkileşim | Bildirimler (FCM) | ⏳ |
| 13 | 🚀 Polish | Performans + Animasyon | ⏳ |
| 14 | 🏁 Final | Test + Yayın | ⏳ |

---

## ✅ Tamamlanan İşler (Hafta Özeti)

**Hafta 4 — Kıyafet Ekleme Akışı**
- `lib/features/wardrobe/` feature klasörü kuruldu
- `WardrobeItem` modeli (mobile schema, web ile uyumlu, `adminReview` nullable)
- `WardrobeRepository` (CRUD + Storage paths + pagination + filter)
- `ImageService` (compression: 1920x1920 q85 + thumbnail 200x200 q80, `keepExif: false`)
- `UploadService` (Cloud Storage upload + progress tracking)
- `PermissionService` + `PermissionDeniedView`
- `AddItemNotifier` (Riverpod `AutoDispose AsyncNotifier`)
- 3-step wizard: `PhotoCaptureStep` + `PhotoCropStep` + `ItemDetailsStep`
- Optimistic UI Pattern: Save → Firestore doc anında oluşturulur (status: 'uploading') → SnackBar → Home'a yönlendirme → background image upload → Firestore update (status: 'ready')
- Storage security rules deploy edildi (per-user, 5MB, image/* only)
- Bug fix log: UCropActivity AndroidManifest entry, ItemDetailsStep beyaz ekran (force unwrap → null safety + AutoDispose)

**Hafta 5 — Gardırop Görünümü**
- `WardrobeScreen` (filter + search + view mode toggle + pull-to-refresh)
- `ItemDetailScreen` (Hero animation, manuel `_timeAgo` helper, `FutureBuilder` pattern)
- 8 yeni widget: `WardrobeItemCard`, `WardrobeFilterBar`, `WardrobeSearchBar` (borderless), `WardrobeViewToggle`, `WardrobeEmptyState`, `WardrobeSkeletonCard`, `WardrobeGrid`, `WardrobeList`
- Long-press Action Sheet (Detay/Arşivle/Sil) + AlertDialog confirm
- `cached_network_image` + `shimmer` paketleri
- `MainShell` widget + `ShellRoute` (bottom nav iskeleti)
- Bottom nav 2 tab: Gardırop + Profil (Hafta 7+'da Bugün, Outfits, Forum eklenecek)
- `ProfileScreen` (minimal — logout + "Yakında" placeholder'lar)
- `VestoBottomNav` molecular component (`VestoBottomNavItem` ile)
- Firestore composite index: `wardrobeItems` (`userId` + `isArchived` + `createdAt`) deploy edildi
- UI Polish: Search bar borderless (Vogue pattern), chip optical centering (`height: 1.0`)

---

## 🏛️ Mimari Kararlar (Güncel)

- **Optimistic UI Pattern:** Save eyleminde Firestore doc önce oluşturuluyor, kullanıcı anında yönlendiriliyor, image upload background'da yapılıyor. Lüks moda dergisi UX hissini koruyor. `notifier.reset()` çağrılMAZ — Riverpod `AutoDispose` otomatik temizler.
- **Sealed Class Re-export Pattern:** `wardrobe_exceptions.dart` dosyası `failure.dart`'taki sealed class failures'ı re-export eder (Dart sealed class kısıtlaması). Yeni `Failure` tipleri sadece `failure.dart`'a eklenir.
- **Client-side Image Compression:** 1920x1920 max q85 (~500KB) original + 200x200 q80 (~30KB) thumbnail. EXIF stripping (`keepExif: false`) ile GPS privacy korundu. Thumbnail Hafta 6'da Cloud Function'a taşınacak (`TODO(Hafta 6)` notu kodda mevcut).
- **Riverpod AutoDispose:** Form notifier'larında `@riverpod` `AutoDispose` pattern kullanılır. Manuel `reset()` çağrılmaz — sayfa kapanınca framework otomatik temizler. Manuel reset glitch'e sebep olur.
- **Client-side Filter (Hafta 5 pragmatik tercih):** 200-300 kıyafet seviyesinde optimal. 1000+ kıyafet için ileride server-side filter veya Algolia'ya geçilebilir. `filteredWardrobeItems` computed provider belleği filtreler.
- **ShellRoute + Bottom Nav Pattern:** Auth flow ve modal akışlar (AddItem, ItemDetail) ShellRoute DIŞINDA (full-screen). Sadece tab'lı ekranlar (Wardrobe, Profile) ShellRoute içinde, bottom nav görünür. `MainShell` location'a göre FAB visibility'sini de yönetir.
- **Search Bar Pattern (Vogue/NYT):** Borderless underline-only. Sadece bottom border, transparent background. Material default border + `focusedBorder` + `enabledBorder` üçü de `InputBorder.none` olmalı (yaygın hata).
- **Chip Optical Centering:** Inter font'un default line-height container'a sığmıyor. Çözüm: `height: 40` (fixed) + `alignment: Alignment.center` + TextStyle'da `height: 1.0`. Padding hack'i değil, doğru pattern.

---

## ⚙️ Bilinen Konfigürasyon Notları

- `image_cropper` paketi kullanırken `AndroidManifest.xml`'e `UCropActivity` tanımı manuel eklenmeli. Vesto temasıyla custom `styles.xml` entry var (`Theme.Vesto.UCrop`).
- Firebase Storage rules `firebase/rules/storage.rules`. Default alias: `vesto-ai-a7ad6`. Region: `europe-west1` (Firestore ile aynı, cross-region fee yok).
- Firestore composite indexes `firebase/indexes/firestore.indexes.json` dosyasında. Yeni multi-field query (where + where + orderBy) ekleyince composite index gerekecek. Firebase hata mesajındaki magic link ile otomatik oluşturulabilir, sonra dosyaya eklenmeli.
- `keepExif: false` image compression sırasında her zaman uygulanmalı (GPS privacy).
- Yeni paket eklerken README'deki Android-specific setup (manifest entries, theme entries) kontrol et.

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
- ❌ **Bir hafta içinde sonraki haftanın hedeflerine atlamak** — scope'u koru
- ❌ **Deprecated paket kullanmak** — pub.dev'de güncel versiyonu kontrol et

---

## 💬 İletişim Stili (Kullanıcı Tercihleri)

**Halit (geliştirici) için:**
- **Dil:** Türkçe konuş, kodlar İngilizce
- **Tarz:** Kıdemli yazılım mimarı + ürün yöneticisi gibi davran
- **Kararlar:** Her öneride gerekçeyi açıkla, mimari kırmızı bayrakları erkenden işaretle
- **Format:** Trade-off'ları tablo ile göster, kâğıda çizilebilir mental modeller kur
- **Adım adım:** Karmaşık konuları küçük parçalara böl, "sen yap" denilince re-engage et
- **Türkçe öğrenme tarzı:** Stratejik özet → Feynman tekniği (analoji) → bilgi boşluğu tespiti → tek tek soru
- **Tablolu cevap değerlendirmesi** ve kısa "ezberleme reçetesi" özetleri kullan
- **Encouragement** ölçülü ve içten olsun, abartılı olmasın

**Halit'in geçmiş bağlamı:**
- Fırat Üniversitesi 3. sınıf Yazılım Mühendisliği öğrencisi
- GitHub: HalitACET
- Yalnız geliştiriyor (solo developer)
- Vesto AI bitirme/dönem projesi
- Önceki projeler: Vesto, VisionGuide, restoran otomasyonu
- Stack deneyimi: Python, Java/C#, JavaScript/React/Next.js, Flutter, cloud araçları
- "Lüks/minimalist/modern moda dergisi" estetiğini savunur

---

## 📌 Yeni Session Açtığında Yapılacaklar

1. Bu CLAUDE.md dosyasını okuduğunu varsay (otomatik yüklenir)
2. Halit'ten **şu an hangi haftada/işte olduğunu** sor (1 cümle yeterli)
3. Eğer hata loglu bir mesaj atarsa, önce **mimari prensipleri ihlal eden kısım var mı** kontrol et
4. Kod önerirken yukarıdaki klasör yapısına ve naming convention'a birebir uy
5. Yeni paket eklerken Halit'e gerekçesini açıkla — gerekli mi, alternatif var mı?
6. Hafta scope'undan dışarı çıkma — sonraki haftanın özelliklerini bu haftaya sıkıştırma
