import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../domain/entities/prayer_time.dart';

/// Sky Color Controller - Lerp Engine
/// Provides smooth gradient interpolation based on prayer times
/// Apple Weather quality gradient transitions

class SkyColorController {
  final PrayerTime prayerTime;
  final DateTime now;
  
  SkyColorController({required this.prayerTime, DateTime? currentTime})
      : now = currentTime ?? DateTime.now();
  
  /// Get interpolated sky colors based on current time and prayer times
  SkyGradient getGradient() {
    final timeSlots = _getTimeSlots();
    final currentMinutes = now.hour * 60 + now.minute;
    
    // Find which time slot we're in
    for (int i = 0; i < timeSlots.length - 1; i++) {
      final start = timeSlots[i];
      final end = timeSlots[i + 1];
      
      if (currentMinutes >= start.minutes && currentMinutes < end.minutes) {
        // Calculate progress (0.0 to 1.0)
        final progress = (currentMinutes - start.minutes) / 
                         (end.minutes - start.minutes);
        
        // Lerp between colors
        return SkyGradient(
          topColor: Color.lerp(start.topColor, end.topColor, progress)!,
          middleColor: Color.lerp(start.middleColor, end.middleColor, progress)!,
          bottomColor: Color.lerp(start.bottomColor, end.bottomColor, progress)!,
          isNight: start.isNight,
          starsOpacity: lerpDouble(start.starsOpacity, end.starsOpacity, progress),
          celestialProgress: progress,
        );
      }
    }
    
    // Fallback to night
    return SkyGradient.night();
  }
  
  List<_TimeSlot> _getTimeSlots() {
    final imsak = _parseTime(prayerTime.imsak);
    final sunrise = _parseTime(prayerTime.gunes);
    final dhuhr = _parseTime(prayerTime.ogle);
    final asr = _parseTime(prayerTime.ikindi);
    final maghrib = _parseTime(prayerTime.aksam);
    final isha = _parseTime(prayerTime.yatsi);
    
    return [
      // Night -> Imsak (00:00 - Imsak)
      _TimeSlot(
        minutes: 0,
        topColor: const Color(0xFF0D1B2A),
        middleColor: const Color(0xFF1B2838),
        bottomColor: const Color(0xFF1B3A4B),
        isNight: true,
        starsOpacity: 1.0,
      ),
      // Imsak -> Sunrise (Dawn)
      _TimeSlot(
        minutes: imsak,
        topColor: const Color(0xFF1A237E),
        middleColor: const Color(0xFF311B92),
        bottomColor: const Color(0xFF4A148C),
        isNight: true,
        starsOpacity: 0.5,
      ),
      // Sunrise (Dawn -> Morning)
      _TimeSlot(
        minutes: sunrise - 30, // 30 min before sunrise
        topColor: const Color(0xFF3949AB),
        middleColor: const Color(0xFFFF6F00),
        bottomColor: const Color(0xFFFFEB3B),
        isNight: false,
        starsOpacity: 0.0,
      ),
      // Sunrise -> Mid Morning
      _TimeSlot(
        minutes: sunrise + 30,
        topColor: const Color(0xFF42A5F5),
        middleColor: const Color(0xFF64B5F6),
        bottomColor: const Color(0xFFE3F2FD),
        isNight: false,
        starsOpacity: 0.0,
      ),
      // Morning -> Noon
      _TimeSlot(
        minutes: dhuhr - 60,
        topColor: const Color(0xFF1E88E5),
        middleColor: const Color(0xFF42A5F5),
        bottomColor: const Color(0xFFBBDEFB),
        isNight: false,
        starsOpacity: 0.0,
      ),
      // Noon (Dhuhr)
      _TimeSlot(
        minutes: dhuhr,
        topColor: const Color(0xFF1565C0),
        middleColor: const Color(0xFF42A5F5),
        bottomColor: const Color(0xFFE3F2FD),
        isNight: false,
        starsOpacity: 0.0,
      ),
      // Afternoon (Asr)
      _TimeSlot(
        minutes: asr,
        topColor: const Color(0xFF1565C0),
        middleColor: const Color(0xFF42A5F5),
        bottomColor: const Color(0xFF81C784),
        isNight: false,
        starsOpacity: 0.0,
      ),
      // Golden Hour (before Maghrib)
      _TimeSlot(
        minutes: maghrib - 45,
        topColor: const Color(0xFF5C6BC0),
        middleColor: const Color(0xFFE65100),
        bottomColor: const Color(0xFFFF8F00),
        isNight: false,
        starsOpacity: 0.0,
      ),
      // Maghrib (Sunset)
      _TimeSlot(
        minutes: maghrib,
        topColor: const Color(0xFF283593),
        middleColor: const Color(0xFFBF360C),
        bottomColor: const Color(0xFFE65100),
        isNight: false,
        starsOpacity: 0.1,
      ),
      // After Maghrib -> Isha
      _TimeSlot(
        minutes: maghrib + 30,
        topColor: const Color(0xFF1A237E),
        middleColor: const Color(0xFF311B92),
        bottomColor: const Color(0xFF4A148C),
        isNight: true,
        starsOpacity: 0.3,
      ),
      // Isha (Night)
      _TimeSlot(
        minutes: isha,
        topColor: const Color(0xFF0D1B2A),
        middleColor: const Color(0xFF1B2838),
        bottomColor: const Color(0xFF1B3A4B),
        isNight: true,
        starsOpacity: 1.0,
      ),
      // End of day
      _TimeSlot(
        minutes: 24 * 60,
        topColor: const Color(0xFF0D1B2A),
        middleColor: const Color(0xFF1B2838),
        bottomColor: const Color(0xFF1B3A4B),
        isNight: true,
        starsOpacity: 1.0,
      ),
    ];
  }
  
  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }
  
  static double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

class _TimeSlot {
  final int minutes;
  final Color topColor;
  final Color middleColor;
  final Color bottomColor;
  final bool isNight;
  final double starsOpacity;
  
  const _TimeSlot({
    required this.minutes,
    required this.topColor,
    required this.middleColor,
    required this.bottomColor,
    required this.isNight,
    required this.starsOpacity,
  });
}

/// Sky Gradient Result
class SkyGradient {
  final Color topColor;
  final Color middleColor;
  final Color bottomColor;
  final bool isNight;
  final double starsOpacity;
  final double celestialProgress;
  
  const SkyGradient({
    required this.topColor,
    required this.middleColor,
    required this.bottomColor,
    required this.isNight,
    required this.starsOpacity,
    required this.celestialProgress,
  });
  
  factory SkyGradient.night() => const SkyGradient(
    topColor: Color(0xFF0D1B2A),
    middleColor: Color(0xFF1B2838),
    bottomColor: Color(0xFF1B3A4B),
    isNight: true,
    starsOpacity: 1.0,
    celestialProgress: 0.5,
  );
  
  LinearGradient toLinearGradient() => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [topColor, middleColor, bottomColor],
    stops: const [0.0, 0.5, 1.0],
  );
}

// =============================================================================
// SMART GREETING LOGIC
// =============================================================================

class SmartGreeting {
  final PrayerTime prayerTime;
  final DateTime now;
  
  SmartGreeting({required this.prayerTime, DateTime? currentTime})
      : now = currentTime ?? DateTime.now();
  
  String getGreeting() {
    final currentMinutes = now.hour * 60 + now.minute;
    
    final imsak = _parseTime(prayerTime.imsak);
    final sunrise = _parseTime(prayerTime.gunes);
    final dhuhr = _parseTime(prayerTime.ogle);
    final asr = _parseTime(prayerTime.ikindi);
    final maghrib = _parseTime(prayerTime.aksam);
    final isha = _parseTime(prayerTime.yatsi);
    
    // Teheccüd (00:00 - Imsak)
    if (currentMinutes >= 0 && currentMinutes < imsak - 30) {
      return 'Teheccüd Vakti';
    }
    
    // Sahur/Imsak approaching
    if (currentMinutes >= imsak - 30 && currentMinutes < imsak) {
      return 'Sahur Vakti';
    }
    
    // Imsak -> Sunrise
    if (currentMinutes >= imsak && currentMinutes < sunrise - 15) {
      return 'Hayırlı Sabahlar';
    }
    
    // Sunrise approaching/happening
    if (currentMinutes >= sunrise - 15 && currentMinutes < sunrise + 30) {
      return 'Güneş Doğuyor';
    }
    
    // Morning
    if (currentMinutes >= sunrise + 30 && currentMinutes < dhuhr - 30) {
      return 'Hayırlı Sabahlar';
    }
    
    // Dhuhr approaching
    if (currentMinutes >= dhuhr - 30 && currentMinutes < dhuhr) {
      return 'Öğle Vaktine Hazırlanın';
    }
    
    // Dhuhr
    if (currentMinutes >= dhuhr && currentMinutes < asr - 30) {
      return 'Vakit: Öğle';
    }
    
    // Asr approaching
    if (currentMinutes >= asr - 30 && currentMinutes < asr) {
      return 'İkindi Vakti Yaklaşıyor';
    }
    
    // Asr
    if (currentMinutes >= asr && currentMinutes < maghrib - 45) {
      return 'Vakit: İkindi';
    }
    
    // Golden hour / Iftar approaching
    if (currentMinutes >= maghrib - 45 && currentMinutes < maghrib) {
      return 'İftar Vakti Yaklaşıyor';
    }
    
    // Maghrib
    if (currentMinutes >= maghrib && currentMinutes < isha) {
      return 'Vakit: Akşam';
    }
    
    // Isha
    if (currentMinutes >= isha) {
      return 'Vakit: Yatsı';
    }
    
    return 'Hayırlı Günler';
  }
  
  /// Get the subtitle (location or status)
  String getSubtitle(String? locationName) {
    if (locationName != null && locationName.isNotEmpty) {
      return locationName;
    }
    return 'Konum alınıyor...';
  }
  
  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }
}

// =============================================================================
// CELESTIAL BODY POSITION CALCULATOR
// =============================================================================

class CelestialPosition {
  final PrayerTime prayerTime;
  final DateTime now;
  
  CelestialPosition({required this.prayerTime, DateTime? currentTime})
      : now = currentTime ?? DateTime.now();
  
  /// Returns position (0.0 = left/sunrise, 1.0 = right/sunset)
  /// and height in arc (0.0 = horizon, 1.0 = zenith)
  CelestialData calculate() {
    final currentMinutes = now.hour * 60 + now.minute;
    final sunrise = _parseTime(prayerTime.gunes);
    final sunset = _parseTime(prayerTime.aksam);
    
    // Daytime: sunrise to sunset
    if (currentMinutes >= sunrise && currentMinutes <= sunset) {
      final dayDuration = sunset - sunrise;
      final progress = (currentMinutes - sunrise) / dayDuration;
      
      // Arc height: sin curve (0 at sunrise/sunset, max at noon)
      final arcHeight = math.sin(progress * math.pi);
      
      return CelestialData(
        horizontalProgress: progress,
        arcHeight: arcHeight,
        isSun: true,
        isVisible: true,
      );
    }
    
    // Nighttime: sunset to next sunrise
    final nightStart = sunset;
    final nightEnd = sunrise + 24 * 60; // next day sunrise
    
    int adjustedCurrent = currentMinutes;
    if (currentMinutes < sunrise) {
      adjustedCurrent += 24 * 60;
    }
    
    if (adjustedCurrent >= nightStart && adjustedCurrent <= nightEnd) {
      final nightDuration = nightEnd - nightStart;
      final progress = (adjustedCurrent - nightStart) / nightDuration;
      final arcHeight = math.sin(progress * math.pi);
      
      return CelestialData(
        horizontalProgress: progress,
        arcHeight: arcHeight,
        isSun: false,
        isVisible: true,
      );
    }
    
    return const CelestialData(
      horizontalProgress: 0.5,
      arcHeight: 0.5,
      isSun: true,
      isVisible: false,
    );
  }
  
  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }
}

class CelestialData {
  final double horizontalProgress; // 0.0 = left, 1.0 = right
  final double arcHeight;          // 0.0 = horizon, 1.0 = zenith
  final bool isSun;
  final bool isVisible;
  
  const CelestialData({
    required this.horizontalProgress,
    required this.arcHeight,
    required this.isSun,
    required this.isVisible,
  });
}
