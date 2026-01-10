# SIRAT - Sonraki Session için Prompt

## 📋 Proje Özeti
SIRAT, Flutter ile geliştirilmiş premium bir İslami namaz vakitleri uygulamasıdır. Firebase backend kullanır.

---

## 🎯 Bu Session'da Yapılacaklar

### 1. Hızlı İşlemler Kartlarını Düzelt (ÖNCELİK: YÜKSEK)
Dashboard'daki "Hızlı İşlemler" grid'i boş/eksik görünüyor. Düzeltilmesi gereken:
- **Zikirmatik** → `ZikirmatikPage`'e yönlendir
- **Kıble Bul** → `QiblaPage`'e yönlendir  
- **Islam AI** → `IslamAIPage`'e yönlendir
- **Ayarlar** → `SettingsPage`'e yönlendir

Dosya: `lib/presentation/pages/home_page.dart` → `_buildQuickActions()` metodu

### 2. Daily Story Widget Düzelt (ÖNCELİK: YÜKSEK)
Şu anda loading spinner gösteriyor çünkü Firestore koleksiyonu yok. Seçenekler:
- **Seçenek A**: Statik içerik göster (Ayet/Hadis)
- **Seçenek B**: Firestore'da `daily_content` koleksiyonu oluştur

Dosya: `lib/presentation/widgets/daily_story_widget.dart`

### 3. (OPSİYONEL) Header Renk Senkronizasyonu
`DynamicPrayerHeader` ve `app_theme.dart`'taki gradient'leri tam senkronize et.

---

## 🔧 Test Komutu
```bash
cd c:\Users\pc\Desktop\SIRAT
flutter run -d chrome --web-port=7777
```

---

## 📁 Kritik Dosyalar (Bu session için)

| Dosya | Açıklama |
|-------|----------|
| `lib/presentation/pages/home_page.dart` | Ana sayfa, Quick Actions |
| `lib/presentation/widgets/daily_story_widget.dart` | Günün içeriği widget |
| `lib/presentation/widgets/dynamic_sky/dynamic_prayer_header.dart` | Apple Weather kalitesinde header |
| `lib/presentation/widgets/dynamic_sky/sky_controller.dart` | Gradient lerp engine |
| `TODO.md` | Tüm görev listesi |

---

## ✅ Önceki Session'da Tamamlananlar
1. DynamicPrayerHeader - 4 katmanlı sky widget
2. SkyColorController - prayer time bazlı gradient lerp
3. SmartGreeting - bağlama duyarlı selamlama
4. CelestialPosition - güneş/ay ark hareketi
5. Responsive Prayer Chips - ekrana göre ölçeklenen
6. Card ortalama düzeltmesi

---

## 💡 Notlar
- Uygulama çalışıyor, compile error yok
- Port 7777'de test edilebilir
- DashboardHeader ve NextPrayerCard artık kullanılmıyor, yerine DynamicPrayerHeader var
