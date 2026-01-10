import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/prayer_time.dart';

/// =============================================================================
/// DAY PHASE - Günün Evreleri
/// =============================================================================

enum DayPhase {
  night,      // Yatsı - İmsak arası
  dawn,       // İmsak - Güneş arası (şafak)
  morning,    // Güneş - Öğle arası
  afternoon,  // Öğle - İkindi arası
  evening,    // İkindi - Akşam arası
  sunset,     // Akşam - Yatsı arası (alacakaranlık)
}

/// =============================================================================
/// SKY CONTROLLER - Ana Kontrol Sınıfı
/// =============================================================================

class SkyController {
  final PrayerTime prayerTime;
  final DateTime now;
  
  // Parsed prayer times as minutes
  late final int imsakMinutes;
  late final int sunriseMinutes;
  late final int dhuhrMinutes;
  late final int asrMinutes;
  late final int maghribMinutes;
  late final int ishaMinutes;
  late final int currentMinutes;
  
  SkyController({required this.prayerTime, DateTime? currentTime})
      : now = currentTime ?? DateTime.now() {
    imsakMinutes = _parseTime(prayerTime.imsak);
    sunriseMinutes = _parseTime(prayerTime.gunes);
    dhuhrMinutes = _parseTime(prayerTime.ogle);
    asrMinutes = _parseTime(prayerTime.ikindi);
    maghribMinutes = _parseTime(prayerTime.aksam);
    ishaMinutes = _parseTime(prayerTime.yatsi);
    currentMinutes = now.hour * 60 + now.minute;
  }
  
  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }
  
  /// Günün hangi evresinde olduğunu belirle
  DayPhase getCurrentPhase() {
    // Yatsı sonrası veya imsak öncesi → Gece
    if (currentMinutes >= ishaMinutes || currentMinutes < imsakMinutes) {
      return DayPhase.night;
    }
    // İmsak - Güneş → Şafak
    else if (currentMinutes >= imsakMinutes && currentMinutes < sunriseMinutes) {
      return DayPhase.dawn;
    }
    // Güneş - Öğle → Sabah
    else if (currentMinutes >= sunriseMinutes && currentMinutes < dhuhrMinutes) {
      return DayPhase.morning;
    }
    // Öğle - İkindi → Öğleden sonra
    else if (currentMinutes >= dhuhrMinutes && currentMinutes < asrMinutes) {
      return DayPhase.afternoon;
    }
    // İkindi - Akşam → Akşamüstü
    else if (currentMinutes >= asrMinutes && currentMinutes < maghribMinutes) {
      return DayPhase.evening;
    }
    // Akşam - Yatsı → Gün batımı
    else {
      return DayPhase.sunset;
    }
  }
  
  /// Önceki ve sonraki faza geçiş için progress (0.0 - 1.0)
  double getPhaseProgress() {
    final phase = getCurrentPhase();
    int startMinutes, endMinutes;
    
    switch (phase) {
      case DayPhase.night:
        if (currentMinutes >= ishaMinutes) {
          startMinutes = ishaMinutes;
          endMinutes = 24 * 60 + imsakMinutes;
          return (currentMinutes - startMinutes) / (endMinutes - startMinutes);
        } else {
          startMinutes = ishaMinutes - 24 * 60;
          endMinutes = imsakMinutes;
          return (currentMinutes - startMinutes) / (endMinutes - startMinutes);
        }
      case DayPhase.dawn:
        startMinutes = imsakMinutes;
        endMinutes = sunriseMinutes;
        break;
      case DayPhase.morning:
        startMinutes = sunriseMinutes;
        endMinutes = dhuhrMinutes;
        break;
      case DayPhase.afternoon:
        startMinutes = dhuhrMinutes;
        endMinutes = asrMinutes;
        break;
      case DayPhase.evening:
        startMinutes = asrMinutes;
        endMinutes = maghribMinutes;
        break;
      case DayPhase.sunset:
        startMinutes = maghribMinutes;
        endMinutes = ishaMinutes;
        break;
    }
    
    if (endMinutes <= startMinutes) return 0.0;
    return ((currentMinutes - startMinutes) / (endMinutes - startMinutes)).clamp(0.0, 1.0);
  }
  
  /// Gökyüzü gradyanlarını al
  SkyGradient getGradient() {
    final phase = getCurrentPhase();
    final progress = getPhaseProgress();
    
    // Her faz için başlangıç ve bitiş renkleri
    final startColors = _getPhaseStartColors(phase);
    final endColors = _getPhaseEndColors(phase);
    
    return SkyGradient(
      topColor: Color.lerp(startColors[0], endColors[0], progress)!,
      middleColor: Color.lerp(startColors[1], endColors[1], progress)!,
      bottomColor: Color.lerp(startColors[2], endColors[2], progress)!,
      starsOpacity: _getStarsOpacity(phase, progress),
      phase: phase,
    );
  }
  
  List<Color> _getPhaseStartColors(DayPhase phase) {
    switch (phase) {
      case DayPhase.night:
        return [
          const Color(0xFF0D1B2A),  // Koyu mavi
          const Color(0xFF1B2838),
          const Color(0xFF1B3A4B),
        ];
      case DayPhase.dawn:
        return [
          const Color(0xFF1A237E),  // Mor-mavi
          const Color(0xFF311B92),
          const Color(0xFF4A148C),
        ];
      case DayPhase.morning:
        return [
          const Color(0xFF3949AB),  // Şafak mavisi
          const Color(0xFFFF6F00),  // Turuncu
          const Color(0xFFFFEB3B),  // Sarı
        ];
      case DayPhase.afternoon:
        return [
          const Color(0xFF1E88E5),  // Açık mavi
          const Color(0xFF42A5F5),
          const Color(0xFFBBDEFB),
        ];
      case DayPhase.evening:
        return [
          const Color(0xFF1565C0),  // Mavi
          const Color(0xFF42A5F5),
          const Color(0xFF81C784),  // Yeşilimsi
        ];
      case DayPhase.sunset:
        return [
          const Color(0xFF5C6BC0),  // Mor-mavi
          const Color(0xFFE65100),  // Turuncu
          const Color(0xFFFF8F00),  // Altın
        ];
    }
  }
  
  List<Color> _getPhaseEndColors(DayPhase phase) {
    switch (phase) {
      case DayPhase.night:
        return [
          const Color(0xFF1A237E),  // Şafak öncesi
          const Color(0xFF311B92),
          const Color(0xFF4A148C),
        ];
      case DayPhase.dawn:
        return [
          const Color(0xFF3949AB),  // Gün doğumu
          const Color(0xFFFF6F00),
          const Color(0xFFFFEB3B),
        ];
      case DayPhase.morning:
        return [
          const Color(0xFF1E88E5),  // Öğleye doğru
          const Color(0xFF42A5F5),
          const Color(0xFFBBDEFB),
        ];
      case DayPhase.afternoon:
        return [
          const Color(0xFF1565C0),  // İkindiye doğru
          const Color(0xFF42A5F5),
          const Color(0xFF81C784),
        ];
      case DayPhase.evening:
        return [
          const Color(0xFF5C6BC0),  // Akşama doğru
          const Color(0xFFE65100),
          const Color(0xFFFF8F00),
        ];
      case DayPhase.sunset:
        return [
          const Color(0xFF0D1B2A),  // Geceye doğru
          const Color(0xFF1B2838),
          const Color(0xFF1B3A4B),
        ];
    }
  }
  
  double _getStarsOpacity(DayPhase phase, double progress) {
    switch (phase) {
      case DayPhase.night:
        return 1.0;
      case DayPhase.dawn:
        return 1.0 - progress;  // Yavaşça kaybol
      case DayPhase.morning:
      case DayPhase.afternoon:
      case DayPhase.evening:
        return 0.0;
      case DayPhase.sunset:
        return progress;  // Yavaşça belir
    }
  }
}

/// =============================================================================
/// SKY GRADIENT - Sonuç Sınıfı
/// =============================================================================

class SkyGradient {
  final Color topColor;
  final Color middleColor;
  final Color bottomColor;
  final double starsOpacity;
  final DayPhase phase;
  
  const SkyGradient({
    required this.topColor,
    required this.middleColor,
    required this.bottomColor,
    required this.starsOpacity,
    required this.phase,
  });
  
  bool get isNight => phase == DayPhase.night;
  
  LinearGradient toLinearGradient() => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [topColor, middleColor, bottomColor],
    stops: const [0.0, 0.5, 1.0],
  );
}

/// =============================================================================
/// CELESTIAL CALCULATOR - Güneş/Ay Pozisyonu
/// =============================================================================

class CelestialCalculator {
  final PrayerTime prayerTime;
  final DateTime now;
  
  late final int sunriseMinutes;
  late final int sunsetMinutes;
  late final int ishaMinutes;
  late final int imsakMinutes;
  late final int currentMinutes;
  
  CelestialCalculator({required this.prayerTime, DateTime? currentTime})
      : now = currentTime ?? DateTime.now() {
    sunriseMinutes = _parseTime(prayerTime.gunes);
    sunsetMinutes = _parseTime(prayerTime.aksam);
    ishaMinutes = _parseTime(prayerTime.yatsi);
    imsakMinutes = _parseTime(prayerTime.imsak);
    currentMinutes = now.hour * 60 + now.minute;
  }
  
  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }
  
  /// Güneş pozisyonu (gündüz: sunrise → sunset arası yay)
  CelestialData calculateSunPosition(Size size) {
    // Gündüz mü kontrol et
    if (currentMinutes < sunriseMinutes || currentMinutes > sunsetMinutes) {
      return CelestialData(position: Offset.zero, isVisible: false, isSun: true);
    }
    
    final totalMinutes = sunsetMinutes - sunriseMinutes;
    final elapsedMinutes = currentMinutes - sunriseMinutes;
    final progress = (elapsedMinutes / totalMinutes).clamp(0.0, 1.0);
    
    // Trigonometrik ark hesaplama
    // angle: 0 = sol (doğuş), π = sağ (batış)
    final angle = progress * math.pi;
    
    // X: Soldan sağa hareket (cos ile ters yön)
    final x = size.width * 0.5 + math.cos(angle + math.pi) * size.width * 0.4;
    
    // Y: Yukarı-aşağı ark (sin ile)
    final y = size.height * 0.7 - math.sin(angle) * size.height * 0.5;
    
    return CelestialData(
      position: Offset(x, y),
      isVisible: true,
      isSun: true,
      progress: progress,
    );
  }
  
  /// Ay pozisyonu (gece: yatsı → imsak arası yay)
  CelestialData calculateMoonPosition(Size size) {
    // Gece mi kontrol et
    bool isNight = currentMinutes >= ishaMinutes || currentMinutes < imsakMinutes;
    if (!isNight) {
      return CelestialData(position: Offset.zero, isVisible: false, isSun: false);
    }
    
    // Gece süresi hesapla (yatsı → ertesi gün imsak)
    int adjustedCurrent = currentMinutes;
    if (currentMinutes < ishaMinutes) {
      adjustedCurrent += 24 * 60;  // Gece yarısından sonra
    }
    
    final nightStart = ishaMinutes;
    final nightEnd = imsakMinutes + 24 * 60;
    final totalMinutes = nightEnd - nightStart;
    final elapsedMinutes = adjustedCurrent - nightStart;
    final progress = (elapsedMinutes / totalMinutes).clamp(0.0, 1.0);
    
    // Trigonometrik ark hesaplama (güneş ile aynı mantık)
    final angle = progress * math.pi;
    
    final x = size.width * 0.5 + math.cos(angle + math.pi) * size.width * 0.4;
    final y = size.height * 0.7 - math.sin(angle) * size.height * 0.5;
    
    return CelestialData(
      position: Offset(x, y),
      isVisible: true,
      isSun: false,
      progress: progress,
    );
  }
}

class CelestialData {
  final Offset position;
  final bool isVisible;
  final bool isSun;
  final double progress;
  
  const CelestialData({
    required this.position,
    required this.isVisible,
    required this.isSun,
    this.progress = 0.0,
  });
}

/// =============================================================================
/// SMART GREETING - Selamlama Mantığı
/// =============================================================================

class SmartGreeting {
  final PrayerTime prayerTime;
  final DateTime now;
  
  SmartGreeting({required this.prayerTime, DateTime? currentTime})
      : now = currentTime ?? DateTime.now();
  
  String getGreeting() {
    final controller = SkyController(prayerTime: prayerTime, currentTime: now);
    final phase = controller.getCurrentPhase();
    
    switch (phase) {
      case DayPhase.night:
        // Gece yarısı öncesi/sonrası kontrolü
        if (now.hour >= 0 && now.hour < 3) {
          return 'Teheccüd Vakti';
        }
        return 'Hayırlı Geceler';
      case DayPhase.dawn:
        return 'Sahur Vakti';
      case DayPhase.morning:
        return 'Hayırlı Sabahlar';
      case DayPhase.afternoon:
        return 'Vakit: Öğle';
      case DayPhase.evening:
        return 'Vakit: İkindi';
      case DayPhase.sunset:
        return 'İftar Vakti';
    }
  }
}

/// =============================================================================
/// STAR DATA - Yıldız Verisi
/// =============================================================================

class Star {
  final double x;  // 0.0 - 1.0
  final double y;  // 0.0 - 1.0
  final double size;
  final double twinkleSpeed;  // Parıldama hızı
  
  const Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
  });
  
  factory Star.random(math.Random random) {
    return Star(
      x: random.nextDouble(),
      y: random.nextDouble() * 0.6,  // Üst kısımda
      size: random.nextDouble() * 2 + 0.5,
      twinkleSpeed: random.nextDouble() * 0.5 + 0.5,
    );
  }
}

/// Pre-cached stars list
final List<Star> cachedStars = List.generate(
  100,
  (i) => Star.random(math.Random(42 + i)),
);

/// =============================================================================
/// MOON PHASE - Ay Fazları
/// =============================================================================

enum MoonPhase {
  newMoon,        // 🌑 Yeni Ay
  waxingCrescent, // 🌒 Hilal (büyüyen)
  firstQuarter,   // 🌓 İlk Dördün
  waxingGibbous,  // 🌔 Şişkin Ay (büyüyen)
  fullMoon,       // 🌕 Dolunay
  waningGibbous,  // 🌖 Şişkin Ay (küçülen)
  lastQuarter,    // 🌗 Son Dördün
  waningCrescent, // 🌘 Hilal (küçülen)
}

/// =============================================================================
/// MOON PHASE CALCULATOR - Ay Fazı Hesaplayıcı
/// =============================================================================

class MoonPhaseCalculator {
  final DateTime date;
  
  /// Synodic month (Ay'ın dünya etrafındaki tam döngüsü) = 29.53 gün
  static const double synodicMonth = 29.53058867;
  
  /// Referans yeni ay tarihi: 6 Ocak 2000, 18:14 UTC
  static final DateTime referenceNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
  
  MoonPhaseCalculator({DateTime? currentDate}) : date = currentDate ?? DateTime.now();
  
  /// Ay döngüsü içindeki pozisyon (0.0 - 1.0)
  /// 0.0 = Yeni Ay, 0.25 = İlk Dördün, 0.5 = Dolunay, 0.75 = Son Dördün
  double getMoonCycle() {
    final daysSinceReference = date.difference(referenceNewMoon).inHours / 24.0;
    final cycle = (daysSinceReference % synodicMonth) / synodicMonth;
    return cycle;
  }
  
  /// Mevcut ay fazını al
  MoonPhase getPhase() {
    final cycle = getMoonCycle();
    
    if (cycle < 0.0625) return MoonPhase.newMoon;
    if (cycle < 0.1875) return MoonPhase.waxingCrescent;
    if (cycle < 0.3125) return MoonPhase.firstQuarter;
    if (cycle < 0.4375) return MoonPhase.waxingGibbous;
    if (cycle < 0.5625) return MoonPhase.fullMoon;
    if (cycle < 0.6875) return MoonPhase.waningGibbous;
    if (cycle < 0.8125) return MoonPhase.lastQuarter;
    if (cycle < 0.9375) return MoonPhase.waningCrescent;
    return MoonPhase.newMoon;
  }
  
  /// Ay fazı verisi (görselleştirme için)
  MoonPhaseData getPhaseData() {
    final cycle = getMoonCycle();
    final phase = getPhase();
    
    // İllumination: 0.0 = karanlık, 1.0 = tam aydınlık
    // Cycle 0-0.5 arası büyüyor, 0.5-1.0 arası küçülüyor
    final illumination = cycle <= 0.5 
        ? cycle * 2  // 0 -> 1
        : 2 - (cycle * 2);  // 1 -> 0
    
    // Açı: Hilal yönü için (sağdan mı soldan mı aydınlık)
    final isWaxing = cycle <= 0.5;
    
    return MoonPhaseData(
      phase: phase,
      cycle: cycle,
      illumination: illumination,
      isWaxing: isWaxing,
      phaseName: _getPhaseName(phase),
      phaseNameTR: _getPhaseNameTR(phase),
    );
  }
  
  String _getPhaseName(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon: return 'New Moon';
      case MoonPhase.waxingCrescent: return 'Waxing Crescent';
      case MoonPhase.firstQuarter: return 'First Quarter';
      case MoonPhase.waxingGibbous: return 'Waxing Gibbous';
      case MoonPhase.fullMoon: return 'Full Moon';
      case MoonPhase.waningGibbous: return 'Waning Gibbous';
      case MoonPhase.lastQuarter: return 'Last Quarter';
      case MoonPhase.waningCrescent: return 'Waning Crescent';
    }
  }
  
  String _getPhaseNameTR(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon: return 'Yeni Ay';
      case MoonPhase.waxingCrescent: return 'Hilal';
      case MoonPhase.firstQuarter: return 'İlk Dördün';
      case MoonPhase.waxingGibbous: return 'Dolunay\'a Doğru';
      case MoonPhase.fullMoon: return 'Dolunay';
      case MoonPhase.waningGibbous: return 'Dolunay Sonrası';
      case MoonPhase.lastQuarter: return 'Son Dördün';
      case MoonPhase.waningCrescent: return 'Hilal (Küçülen)';
    }
  }
}

/// Ay fazı verisi
class MoonPhaseData {
  final MoonPhase phase;
  final double cycle;          // 0.0 - 1.0 (döngü pozisyonu)
  final double illumination;   // 0.0 - 1.0 (aydınlık yüzdesi)
  final bool isWaxing;         // Büyüyor mu?
  final String phaseName;      // İngilizce isim
  final String phaseNameTR;    // Türkçe isim
  
  const MoonPhaseData({
    required this.phase,
    required this.cycle,
    required this.illumination,
    required this.isWaxing,
    required this.phaseName,
    required this.phaseNameTR,
  });
}
