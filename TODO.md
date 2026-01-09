# SIRAT - NİHAİ ÜRETİM YAPILACAKLAR LİSTESİ (TODO)
> God-Mode Active | Mimar Odaklı | Performans, Güvenlik, Stabilite Öncelikli

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
- [ ] **AI-001**: Cloud Function `askIslamicAI` endpoint'ini güçlendir
- [ ] **AI-002**: System Prompt katmanı (Fıkıh kuralları, kaynak zorunluluğu)
- [ ] **AI-003**: Mezhep bazlı cevap filtresi (Hanefi/Şafi/Hanbeli/Maliki)
- [ ] **AI-004**: Cevap kartı görselleştirme (Paylaşılabilir)
- [ ] **AI-005**: Psikolojik/Manevi destek modu (Teselli, Dua önerisi)

---

## 🎨 BÖLÜM 2: KULLANICI DENEYİMİ (UX)

### 2.1 Onboarding Akışı
- [x] **OB-001**: Telefon dili algılama + manuel seçim ✅
- [x] **OB-002**: Mezhep seçimi (AI ve vakit hesabı için) ✅
- [x] **OB-003**: Konum izni ikna edici UX yazısı ✅
- [ ] **OB-004**: Bildirim izni akışı

### 2.2 Ana Ekran (Dashboard)
- [x] **DS-001**: Zaman duyarlı header (Sabah/Öğle/Akşam/Gece) ✅
- [x] **DS-002**: Canlı geri sayım kartı ✅
- [ ] **DS-003**: AI hızlı erişim arama çubuğu
- [x] **DS-004**: Günün Story'si (Instagram formatı) ✅
- [ ] **DS-005**: Kandil özel tema otomatik geçiş

---

## 🕌 BÖLÜM 3: DETAYLI ÖZELLİK SETİ

### 3.1 Ezan Vakitleri ve Bildirimler (Pro)
- [x] **PRT-001**: Aladhan API entegrasyonu ✅
- [x] **PRT-002**: Mezhep bazlı hesaplama ✅
- [ ] **PRT-003**: Akıllı erteleme ("10 dk sonra hatırlat")
- [ ] **PRT-004**: Pre-alarm (Temkin vakti, iftara 15dk kala)
- [ ] **PRT-005**: Ezan ses kütüphanesi (Mekke, İstanbul, Ney)
- [ ] **PRT-006**: Hicri takvim entegrasyonu
- [ ] **PRT-007**: Kandil günü otomatik bildirim

### 3.2 VR/AR Kıble (Kamera Modu)
- [ ] **QIB-001**: Sensor Fusion (GPS + Pusula)
- [ ] **QIB-002**: Kamera overlay ile sanal Kabe ikonu
- [ ] **QIB-003**: Manyetik parazit uyarısı
- [ ] **QIB-004**: Kalibrasyon asistanı

### 3.3 İslam-AI Asistan
- [ ] **ISL-001**: Fetva/Bilgi modu (Kaynak zorunlu)
- [ ] **ISL-002**: Psikolojik destek modu (Sure önerisi)
- [ ] **ISL-003**: Bilgi kartı görselleştirme + paylaşım
- [ ] **ISL-004**: Chat geçmişi Firestore senkronizasyonu
- [ ] **ISL-005**: Yasaklı kelime filtresi

### 3.4 Gelişmiş Zikirmatik
- [ ] **ZIK-001**: Ekran herhangi yerinden sayma
- [ ] **ZIK-002**: Titreşim profilleri (33, 100)
- [ ] **ZIK-003**: Hedef ve rozet sistemi (Gamification)
- [ ] **ZIK-004**: Bulut senkronizasyonu

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

## ✅ ÖNCE YAPILACAK (ÖNCELİK SIRASI)

| # | Görev | Durum |
|---|-------|-------|
| 1 | Dependency Injection (Injectable) rebuild | 🔄 |
| 2 | AppLocalizations import düzeltmesi | 🔄 |
| 3 | PrayerBloc DI kaydı | ⏳ |
| 4 | AI-001: Cloud Function güçlendirme | ⏳ |
| 5 | QIB-001: AR Kıble temel altyapısı | ⏳ |
| 6 | ZIK-001: Zikirmatik sayaç mantığı | ⏳ |
| 7 | Flutter analyze 0 error | ⏳ |
| 8 | flutter run başarılı test | ⏳ |

---

> **Son Güncelleme**: 2026-01-09T22:30:00+03:00
