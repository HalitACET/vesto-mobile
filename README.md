# 📱 Vesto AI — Mobile Application

> Akıllı gardırop ve AI destekli stil danışmanlığı platformunun Flutter mobil uygulaması.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-purple)](https://riverpod.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](#)

---

## 🎯 Proje Hakkında

**Vesto AI**, kullanıcıların kıyafetlerini dijital bir gardıroba dönüştüren, yapay zeka ile analiz eden ve dış verileri (hava durumu, lokasyon) kullanarak kişiselleştirilmiş kombin önerileri sunan hibrit bir platformdur. Topluluk tabanlı stil danışmanlığı ve profesyonel stilist desteği içerir.

**Vesto'nun Farkı:** Pinterest'teki kombinler hayalî, Instagram'daki influencer parçaları ulaşılmaz. Vesto'da sana önerilen her kombin **senin kendi dolabındaki parçalarla** yapılır — yani uygulanabilir.

---

## 🛠️ Teknoloji Yığını

| Katman | Teknoloji |
|---|---|
| **Framework** | Flutter (Dart) |
| **State Management** | Riverpod 2.x |
| **Routing** | go_router |
| **Backend** | Firebase (Auth + Firestore + Cloud Storage + Cloud Functions) |
| **AI** | Google Vision API |
| **Dış Servis** | OpenWeatherMap API |
| **Hedef Platform** | Android |

---

## 📅 14 Haftalık Yol Haritası

| Hafta | Faz | İş Paketi | Mobil Odaklı Detaylar | Durum |
|:---:|:---:|---|---|:---:|
| **1** | 🏗️ Planlama | **Mimari Kurulum** | Flutter projesi + Riverpod + go_router + Firebase entegrasyonu (Firestore, Auth, Storage). Feature-first klasör yapısı. | ✅ |
| **2** | 🎨 Tasarım | **Design System** | Tema (siyah/beyaz/gri palet), tipografi, atomik componentler (`VestoButton`, `VestoCard`, `VestoTextField`). Lüks moda dergisi estetiği. | ✅ |
| **3** | 🔐 Altyapı | **Auth Akışı** | Onboarding ekranı, kayıt/giriş (Email + Google Sign-In), profil oluşturma wizard'ı (cinsiyet, lokasyon, stil tercihleri). | ⏳ |
| **4** | 📸 Veri | **Kıyafet Ekleme** | Kamera + galeri entegrasyonu, fotoğraf cropping, manuel form, Cloud Storage upload, optimistic UI. | ⏳ |
| **5** | 👗 Veri | **Gardırop Görünümü** | Grid/liste görünümü, kategori filtreleri, arama, detay sayfası. Lazy loading + cache stratejisi. | ⏳ |
| **6** | 🧠 AI | **AI Analiz UX** | Yüklenen kıyafetin AI analizini bekleme (loading state), sonucu gösterme, kullanıcının manuel düzeltme yapabilmesi. | ⏳ |
| **7** | 🌤️ Akıllı | **Hava + Öneri Modülü** | Lokasyon izinleri, OpenWeatherMap entegrasyonu, "Bugün ne giysem" anasayfa kartı, AI'lı kombin önerisi. | ⏳ |
| **8** | 🖱️ İnteraktif | **Mobil Kombin Editörü** | Mobil-friendly canvas (pinch-zoom, drag, küçük ekrana uyarlanmış UX). Tek elle kullanılabilir tasarım. | ⏳ |
| **9** | 💬 Sosyal | **Forum + Feed** | "Ne giysem" postu açma, feed görünümü, post detayı, başka kullanıcının açık parçalarını görme. | ⏳ |
| **10** | 👔 Sosyal | **Topluluk Stilist Önerisi** | Başkasının dolabıyla canvas açma, kombin önerisi gönderme, like/yorum, post sahibi tarafından kabul akışı. | ⏳ |
| **11** | 👤 Sosyal | **Profil + Takip Sistemi** | Kullanıcı profili, takip et/takipten çık, takip akışı, doğrulanmış stilist rozeti gösterimi. | ⏳ |
| **12** | 🔔 Etkileşim | **Bildirimler** | Push notification (FCM), in-app bildirim listesi, deep linking ("X seni takip etti", "Önerin beğenildi"). | ⏳ |
| **13** | 🚀 Polish | **Performans + Animasyon** | Image caching, list virtualization, geçiş animasyonları (Hero), loading skeletons, hata ekranları. | ⏳ |
| **14** | 🏁 Final | **Test + Yayın** | Widget testleri, kritik akış integration testleri, Play Store hazırlığı (icon, screenshot, açıklama). | ⏳ |

**Durum Açıklaması:** ✅ Tamamlandı &nbsp;•&nbsp; 🚧 Devam Ediyor &nbsp;•&nbsp; ⏳ Bekliyor

---

## ✨ Temel Özellikler

- 📸 **Dijital Gardırop** — Fotoğraf çek, AI otomatik etiketler (renk, kategori, materyal, desen)
- 🤖 **AI Kombin Önerisi** — Hava durumu + stil tercihi + dolap içeriği bazlı akıllı öneriler
- 🎨 **Manuel Kombin Editörü** — Sürükle-bırak canvas üzerinde kombin yaratma
- 💬 **Sosyal Forum** — "Ne giysem" postları, topluluk tabanlı kombin önerileri
- 🔒 **Granüler Dolap Paylaşımı** — Forum postunda sadece seçili parçalar/kategoriler açılır
- ⭐ **Doğrulanmış Stilist Rozeti** — Profesyoneller admin onayıyla rozet alır, önerileri öne çıkar
- 👔 **Profesyonel Danışmanlık** — Web paneli üzerinden 1-1 stilist hizmeti

---

## 🏗️ Mimari Prensipler

- **Feature-First Klasör Yapısı** — Her feature kendi `data/` ve `presentation/` katmanına sahip
- **Repository Pattern** — UI katmanı Firestore'a direkt erişmez, repository üzerinden
- **Tip Güvenliği** — `dynamic` yasak, explicit tip kullanımı
- **Clean Code & SOLID** — Single Responsibility, Dependency Inversion
- **Composable Riverpod Provider'lar** — Küçük, test edilebilir, god-provider'sız

---

## 📁 Klasör Yapısı

```
/lib
├── app/                    # MaterialApp, router, theme
├── core/                   # Tüm feature'larda kullanılan ortak şeyler
│   ├── errors/             # Failure, AppException
│   ├── network/            # Firebase provider'ları
│   └── widgets/            # Atomik componentler (Vesto*)
├── features/               # Feature-first mimari
│   ├── auth/
│   ├── wardrobe/
│   ├── outfit_editor/
│   ├── forum/
│   └── profile/
└── shared/                 # Birden fazla feature'ın paylaştığı modeller
```

---

## 🔗 İlgili Projeler

Bu uygulama **Vesto AI monorepo**'sunun bir parçasıdır:

- 📱 **Mobile** (Bu repo) — Flutter ile son kullanıcı uygulaması
- 🌐 **Web** — Next.js ile admin/stilist paneli
- ☁️ **Firebase** — Ortak güvenlik kuralları ve Cloud Functions

---

## 👨‍💻 Geliştirici

**Halit ACET** — Fırat Üniversitesi Yazılım Mühendisliği

[![GitHub](https://img.shields.io/badge/GitHub-HalitACET-181717?logo=github)](https://github.com/HalitACET)

---

> *Vesto AI — Your wardrobe, reimagined.*
