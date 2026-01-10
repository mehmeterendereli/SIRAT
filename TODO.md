# SIRAT - NİHAİ ÜRETİM YAPILACAKLAR LİSTESİ (TODO)
> God-Mode Active | Mimar Odaklı | Performans, Güvenlik, Stabilite Öncelikli

---

## 📅 SON SESSION NOTLARI (2026-01-10 - 21:00)

> [!IMPORTANT]
> **Yeni sohbete geçilecek. Bu notları oku:**
> 
> ### ✅ Bu Session'da Tamamlananlar:
> - **DynamicPrayerHeader** → Apple Weather kalitesinde 4 katmanlı sky widget
>   - `SkyColorController` → Prayer time bazlı gradient lerp engine
>   - `SmartGreeting` → Bağlama duyarlı selamlama ("Vakit: Akşam", "İftar Yaklaşıyor")
>   - `CelestialPosition` → Güneş/Ay ark hareketi hesaplaması
>   - Stars + Clouds animasyonları
>   - Frosted Glass Card (BackdropFilter)
> - **Responsive Prayer Chips** → Ekran boyutuna göre dinamik ölçeklenen chip'ler
>   - `LayoutBuilder` ile genişlik hesabı
>   - Font: 9-12px (label), 11-15px (time) clamp değerleri
> - **Card Ortalama** → Frosted glass card tam ortada
> 
> ### 📁 Bu Session'da Değiştirilen/Oluşturulan Dosyalar:
> - `lib/presentation/widgets/dynamic_sky/sky_controller.dart` (YENİ)
> - `lib/presentation/widgets/dynamic_sky/dynamic_prayer_header.dart` (YENİ)
> - `lib/presentation/widgets/dynamic_sky/dynamic_sky.dart` (YENİ - barrel)
> - `lib/presentation/pages/home_page.dart` (GÜNCELLENDİ)
> 
> ### ⚠️ Bilinen Küçük Sorunlar:
> - `DailyStoryWidget` Firestore'dan veri çekemiyor (koleksiyon oluşturulmadı)
> - Web'de konum izni otomatik alınamıyor, fallback Istanbul koordinatları kullanılıyor
> 
> ### 🔧 Test Komutu:
> ```bash
> cd c:\Users\pc\Desktop\SIRAT
> flutter run -d chrome --web-port=7777
> ```

---

## ⚡ BÖLÜM 1: BACKEND ALTYAPI

### 1.1 Dinamik Headless CMS (Remote Config)
- [ ] **RC-001**: Tüm UI string'lerini Remote Config'e taşı
- [ ] **RC-002**: Dil bazlı JSON paketi çekme sistemi (`tr_TR`, `en_US`, `ar_SA`)
- [ ] **RC-003**: Feature flags entegrasyonu (AR Kıble, AI Asistan, Zikirmatik toggle)
- [ ] **RC-004**: Kandil/Özel gün teması otomatik aktivasyonu

### 1.2 Sessiz Analitik Katmanı
- [ ] **AN-001**: Screen view süre takibi (Heatmap mantığı)
- [ ] **AN-002**: AI sorgu kategorisi analizi (Anonimleştirilmiş)
- [ ] **AN-003**: Conversion funnel: `onboarding_start` → `notification_enabled` → `first_prayer`
- [ ] **AN-004**: Crashlytics cihaz/ekran bazlı raporlama

### 1.3 Gemini AI Entegrasyonu
- [x] **AI-001**: Cloud Function `askIslamicAI` endpoint'ini güçlendir ✅
- [x] **AI-002**: System Prompt katmanı (Fıkıh kuralları, kaynak zorunluluğu) ✅
- [x] **AI-003**: Mezhep bazlı cevap filtresi (Hanefi/Şafi/Hanbeli/Maliki) ✅
- [x] **AI-004**: Cevap kartı görselleştirme (Paylaşılabilir) ✅
- [x] **AI-005**: Psikolojik/Manevi destek modu (Teselli, Dua önerisi) ✅

---

## 🎨 BÖLÜM 2: KULLANICI DENEYİMİ (UX)

### 2.1 Onboarding Akışı
- [x] **OB-001**: Telefon dili algılama + manuel seçim ✅
- [x] **OB-002**: Mezhep seçimi (AI ve vakit hesabı için) ✅
- [x] **OB-003**: Konum izni ikna edici UX yazısı ✅
- [x] **OB-004**: Bildirim izni akışı ✅

### 2.2 Ana Ekran (Dashboard)
- [x] **DS-001**: Zaman duyarlı header (Sabah/Öğle/Akşam/Gece) ✅
- [x] **DS-002**: Canlı geri sayım kartı ✅
- [x] **DS-003**: Dinamik konum gösterimi (GPS + Geocoding) ✅
- [x] **DS-004**: Günün Story'si (Varsayılan içerik) ✅
- [x] **DS-005**: DynamicPrayerHeader - Apple Weather kalitesi ✅
- [x] **DS-006**: Responsive Prayer Chips ✅
- [ ] **DS-007**: Kandil özel tema otomatik geçiş

---

## 🕌 BÖLÜM 3: DETAYLI ÖZELLİK SETİ

### 3.1 Ezan Vakitleri ve Bildirimler (Pro)
- [x] **PRT-001**: Aladhan API entegrasyonu ✅
- [x] **PRT-002**: Mezhep bazlı hesaplama (Method 13 - Diyanet Turkey) ✅
- [x] **PRT-003**: Dinamik konum bazlı vakitler ✅
- [x] **PRT-004**: Akıllı erteleme ("10 dk sonra hatırlat") ✅
- [x] **PRT-005**: Pre-alarm (Temkin vakti, iftara 15dk kala) ✅
- [x] **PRT-006**: Ezan ses kütüphanesi (Mekke, İstanbul, Ney) ✅
- [ ] **PRT-007**: Hicri takvim entegrasyonu
- [ ] **PRT-008**: Kandil günü otomatik bildirim

### 3.2 VR/AR Kıble (Kamera Modu)
- [x] **QIB-001**: Sensor Fusion (GPS + Pusula) ✅
- [x] **QIB-002**: Kamera overlay ile sanal Kabe ikonu ✅
- [x] **QIB-003**: Manyetik parazit uyarısı ✅
- [x] **QIB-004**: Kalibrasyon asistanı ✅

### 3.3 İslam-AI Asistan
- [x] **ISL-001**: Fetva/Bilgi modu (Kaynak zorunlu) ✅
- [x] **ISL-002**: Psikolojik destek modu (Teselli) ✅
- [x] **ISL-003**: İbadet yardımı modu ✅
- [ ] **ISL-004**: Chat geçmişi Firestore senkronizasyonu
- [ ] **ISL-005**: Bilgi kartı paylaşım özelliği

### 3.4 Gelişmiş Zikirmatik
- [x] **ZIK-001**: Ekran herhangi yerinden sayma ✅
- [x] **ZIK-002**: Titreşim profilleri (33, 100) ✅
- [x] **ZIK-003**: Hedef ve rozet sistemi (Gamification) ✅
- [x] **ZIK-004**: Bulut senkronizasyonu ✅

### 3.5 Kuran-ı Kerim Modülü
- [ ] **QUR-001**: Audio player ile kelime takibi (Highlighting)
- [ ] **QUR-002**: Semantik arama ("Miras ile ilgili ayetler")
- [ ] **QUR-003**: Sure/Sayfa bookmark sistemi
- [ ] **QUR-004**: Hatim takibi

### 3.6 Cami Bulucu
- [ ] **MOS-001**: Google Maps SDK entegrasyonu
- [ ] **MOS-002**: Cami detay kartları (Kullanıcı girişli)
- [ ] **MOS-003**: Yakınlık bazlı sıralama

---

## 🌍 BÖLÜM 4: GLOBALİZASYON

### 4.1 Çoklu Dil Desteği
- [x] **L10N-001**: TR/EN temel çeviriler ✅
- [ ] **L10N-002**: AR (Arapça) tam destek
- [ ] **L10N-003**: DE (Almanca) tam destek
- [ ] **L10N-004**: FR (Fransızca) tam destek
- [ ] **L10N-005**: ID (Endonezce) tam destek

### 4.2 Bölgesel İçerik
- [ ] **REG-001**: Ülkeye göre içerik dağıtımı (CMS)
- [ ] **REG-002**: Cuma hutbe özeti (EN)
- [ ] **REG-003**: Yerelleştirilmiş push bildirimleri

---

## 🛡️ BÖLÜM 5: GÜVENLİK VE PERFORMANS

### 5.1 Güvenlik
- [ ] **SEC-001**: Firestore kuralları production-ready
- [ ] **SEC-002**: Cloud Function rate limiting
- [ ] **SEC-003**: API key kısıtlamaları (Maps, Gemini)

### 5.2 Performans
- [ ] **PRF-001**: Image caching stratejisi
- [ ] **PRF-002**: Lazy loading tüm listelerde
- [ ] **PRF-003**: Offline-first mimari (Hive/Isar)

---

## 📊 BÖLÜM 6: ADMIN DASHBOARD

- [ ] **ADM-001**: Canlı kullanıcı istatistikleri
- [ ] **ADM-002**: AI cevap denetimi
- [ ] **ADM-003**: Segmentasyonlu push notification

---

## ✅ TAMAMLANAN KRİTİK GÖREVLER

| # | Görev | Durum |
|---|-------|-------|
| 1 | Dependency Injection rebuild | ✅ |
| 2 | AppLocalizations import düzeltmesi | ✅ |
| 3 | PrayerBloc DI kaydı | ✅ |
| 4 | AI-001~005: Gemini AI entegrasyonu | ✅ |
| 5 | QIB-001~004: AR Kıble modülü | ✅ |
| 6 | ZIK-001~004: Zikirmatik gamification | ✅ |
| 7 | Flutter analyze 0 error | ✅ |
| 8 | Flutter run başarılı test | ✅ |
| 9 | Namaz vakitleri doğruluk (Method 13) | ✅ |
| 10 | Dinamik konum (GPS + Geocoding) | ✅ |
| 11 | DynamicPrayerHeader (Apple Weather) | ✅ |
| 12 | Responsive Prayer Chips | ✅ |

---

## 🚀 SONRAKİ ÖNCELİKLER

| # | Görev | Öncelik |
|---|-------|---------|
| 1 | Hızlı İşlemler kartlarını düzelt (icon + text + navigation) | 🔴 Yüksek |
| 2 | Daily Story widgetı Firestore'a bağla veya statik içerik | 🔴 Yüksek |
| 3 | Kuran modülü (QUR-001~004) | 🟡 Orta |
| 4 | Hicri takvim entegrasyonu (PRT-007) | 🟡 Orta |
| 5 | Çoklu dil desteği (AR, DE) | 🟢 Düşük |

---

> **Son Güncelleme**: 2026-01-10T21:00:00+03:00
