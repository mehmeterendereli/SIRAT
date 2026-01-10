import 'dart:math' as math;

/// Solar Position Calculator for SIRAT
/// Calculates sun position, sky colors, and time-based gradients
/// Used for realistic day/night cycle in the sky scene

class SolarCalculator {
  SolarCalculator._();

  /// Get the current sky period based on time
  static SkyPeriod getCurrentPeriod() {
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;
    final timeValue = hour + (minute / 60.0);

    if (timeValue >= 4.0 && timeValue < 5.5) return SkyPeriod.fajr;
    if (timeValue >= 5.5 && timeValue < 7.0) return SkyPeriod.sunrise;
    if (timeValue >= 7.0 && timeValue < 12.0) return SkyPeriod.morning;
    if (timeValue >= 12.0 && timeValue < 15.0) return SkyPeriod.noon;
    if (timeValue >= 15.0 && timeValue < 17.0) return SkyPeriod.afternoon;
    if (timeValue >= 17.0 && timeValue < 19.0) return SkyPeriod.sunset;
    if (timeValue >= 19.0 && timeValue < 21.0) return SkyPeriod.maghrib;
    return SkyPeriod.night;
  }

  /// Get normalized sun position (0.0 = horizon, 1.0 = zenith, -1.0 = below horizon)
  static double getSunPosition() {
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;
    final timeValue = hour + (minute / 60.0);

    // Simple sinusoidal model: sun rises at 6, peaks at 12, sets at 18
    // Normalize to 0-24 hours and calculate position
    const sunriseHour = 6.0;
    const sunsetHour = 18.0;
    const noonHour = 12.0;

    if (timeValue < sunriseHour || timeValue > sunsetHour) {
      // Night time - sun below horizon
      return -1.0;
    }

    // Map to 0-π for smooth curve
    final dayProgress = (timeValue - sunriseHour) / (sunsetHour - sunriseHour);
    return math.sin(dayProgress * math.pi);
  }

  /// Get sky gradient colors based on current time
  static SkyGradient getGradientColors() {
    final period = getCurrentPeriod();
    return _gradients[period]!;
  }

  /// Get interpolated gradient between two periods
  static SkyGradient getInterpolatedGradient() {
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;
    final timeValue = hour + (minute / 60.0);

    // Get current and next period for interpolation
    final currentPeriod = getCurrentPeriod();
    final currentGradient = _gradients[currentPeriod]!;

    // Calculate progress within period for smooth transitions
    final periodProgress = _getPeriodProgress(timeValue, currentPeriod);

    // If near transition point, interpolate with next period
    if (periodProgress > 0.7) {
      final nextPeriod = _getNextPeriod(currentPeriod);
      final nextGradient = _gradients[nextPeriod]!;
      final blendFactor = (periodProgress - 0.7) / 0.3;
      return SkyGradient.lerp(currentGradient, nextGradient, blendFactor);
    }

    return currentGradient;
  }

  static double _getPeriodProgress(double timeValue, SkyPeriod period) {
    switch (period) {
      case SkyPeriod.fajr:
        return (timeValue - 4.0) / 1.5;
      case SkyPeriod.sunrise:
        return (timeValue - 5.5) / 1.5;
      case SkyPeriod.morning:
        return (timeValue - 7.0) / 5.0;
      case SkyPeriod.noon:
        return (timeValue - 12.0) / 3.0;
      case SkyPeriod.afternoon:
        return (timeValue - 15.0) / 2.0;
      case SkyPeriod.sunset:
        return (timeValue - 17.0) / 2.0;
      case SkyPeriod.maghrib:
        return (timeValue - 19.0) / 2.0;
      case SkyPeriod.night:
        if (timeValue >= 21.0) return (timeValue - 21.0) / 7.0;
        return (timeValue + 24.0 - 21.0) / 7.0;
    }
  }

  static SkyPeriod _getNextPeriod(SkyPeriod current) {
    switch (current) {
      case SkyPeriod.fajr:
        return SkyPeriod.sunrise;
      case SkyPeriod.sunrise:
        return SkyPeriod.morning;
      case SkyPeriod.morning:
        return SkyPeriod.noon;
      case SkyPeriod.noon:
        return SkyPeriod.afternoon;
      case SkyPeriod.afternoon:
        return SkyPeriod.sunset;
      case SkyPeriod.sunset:
        return SkyPeriod.maghrib;
      case SkyPeriod.maghrib:
        return SkyPeriod.night;
      case SkyPeriod.night:
        return SkyPeriod.fajr;
    }
  }

  /// Pre-defined gradients for each sky period
  static final Map<SkyPeriod, SkyGradient> _gradients = {
    SkyPeriod.fajr: const SkyGradient(
      topColor: Color(0xFF1A237E),      // Deep indigo
      middleColor: Color(0xFF311B92),   // Deep purple
      bottomColor: Color(0xFF4A148C),   // Purple
      starsOpacity: 0.6,
      sunMoonOpacity: 0.8,
      cloudsOpacity: 0.2,
    ),
    SkyPeriod.sunrise: const SkyGradient(
      topColor: Color(0xFF3949AB),      // Indigo
      middleColor: Color(0xFFFF6F00),   // Orange
      bottomColor: Color(0xFFFFEB3B),   // Yellow
      starsOpacity: 0.0,
      sunMoonOpacity: 1.0,
      cloudsOpacity: 0.4,
    ),
    SkyPeriod.morning: const SkyGradient(
      topColor: Color(0xFF42A5F5),      // Blue
      middleColor: Color(0xFF64B5F6),   // Light blue
      bottomColor: Color(0xFFE3F2FD),   // Very light blue
      starsOpacity: 0.0,
      sunMoonOpacity: 0.9,
      cloudsOpacity: 0.5,
    ),
    SkyPeriod.noon: const SkyGradient(
      topColor: Color(0xFF1E88E5),      // Bright blue
      middleColor: Color(0xFF42A5F5),   // Blue
      bottomColor: Color(0xFFBBDEFB),   // Light blue
      starsOpacity: 0.0,
      sunMoonOpacity: 1.0,
      cloudsOpacity: 0.6,
    ),
    SkyPeriod.afternoon: const SkyGradient(
      topColor: Color(0xFF1565C0),      // Dark blue
      middleColor: Color(0xFF42A5F5),   // Blue
      bottomColor: Color(0xFF81C784),   // Light green tint
      starsOpacity: 0.0,
      sunMoonOpacity: 0.95,
      cloudsOpacity: 0.5,
    ),
    SkyPeriod.sunset: const SkyGradient(
      topColor: Color(0xFF5C6BC0),      // Indigo
      middleColor: Color(0xFFE65100),   // Deep orange
      bottomColor: Color(0xFFFF8F00),   // Amber
      starsOpacity: 0.1,
      sunMoonOpacity: 1.0,
      cloudsOpacity: 0.7,
    ),
    SkyPeriod.maghrib: const SkyGradient(
      topColor: Color(0xFF283593),      // Indigo
      middleColor: Color(0xFFBF360C),   // Deep orange
      bottomColor: Color(0xFFE65100),   // Orange
      starsOpacity: 0.3,
      sunMoonOpacity: 0.7,
      cloudsOpacity: 0.4,
    ),
    SkyPeriod.night: const SkyGradient(
      topColor: Color(0xFF0D1B2A),      // Very dark blue
      middleColor: Color(0xFF1B2838),   // Dark blue
      bottomColor: Color(0xFF1B3A4B),   // Dark teal
      starsOpacity: 1.0,
      sunMoonOpacity: 0.9,
      cloudsOpacity: 0.2,
    ),
  };
}

/// Sky time periods
enum SkyPeriod {
  fajr,      // 04:00 - 05:30
  sunrise,   // 05:30 - 07:00
  morning,   // 07:00 - 12:00
  noon,      // 12:00 - 15:00
  afternoon, // 15:00 - 17:00
  sunset,    // 17:00 - 19:00
  maghrib,   // 19:00 - 21:00
  night,     // 21:00 - 04:00
}

/// Color type alias for dart:ui
typedef Color = int;

/// Extension to create Color from int
extension ColorExtension on int {
  int get value => this;
}

/// Sky gradient configuration
class SkyGradient {
  final int topColor;
  final int middleColor;
  final int bottomColor;
  final double starsOpacity;
  final double sunMoonOpacity;
  final double cloudsOpacity;

  const SkyGradient({
    required this.topColor,
    required this.middleColor,
    required this.bottomColor,
    required this.starsOpacity,
    required this.sunMoonOpacity,
    required this.cloudsOpacity,
  });

  /// Linear interpolation between two gradients
  static SkyGradient lerp(SkyGradient a, SkyGradient b, double t) {
    return SkyGradient(
      topColor: _lerpColor(a.topColor, b.topColor, t),
      middleColor: _lerpColor(a.middleColor, b.middleColor, t),
      bottomColor: _lerpColor(a.bottomColor, b.bottomColor, t),
      starsOpacity: _lerpDouble(a.starsOpacity, b.starsOpacity, t),
      sunMoonOpacity: _lerpDouble(a.sunMoonOpacity, b.sunMoonOpacity, t),
      cloudsOpacity: _lerpDouble(a.cloudsOpacity, b.cloudsOpacity, t),
    );
  }

  static int _lerpColor(int a, int b, double t) {
    final aR = (a >> 16) & 0xFF;
    final aG = (a >> 8) & 0xFF;
    final aB = a & 0xFF;
    final bR = (b >> 16) & 0xFF;
    final bG = (b >> 8) & 0xFF;
    final bB = b & 0xFF;

    final r = (aR + (bR - aR) * t).round();
    final g = (aG + (bG - aG) * t).round();
    final blue = (aB + (bB - aB) * t).round();

    return 0xFF000000 | (r << 16) | (g << 8) | blue;
  }

  static double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
