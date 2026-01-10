import 'package:flutter/material.dart';

/// Dynamic Theme System for SIRAT
/// Adapts based on time of day: Light theme during daylight, Dark theme at night

class AppTheme {
  AppTheme._();

  // Primary Brand Colors
  static const Color primaryGreen = Color(0xFF1B5E20); // Islamic Green
  static const Color primaryGold = Color(0xFFD4AF37);  // Gold Accent
  static const Color gold = primaryGold; // Alias for backward compatibility
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color deepBlack = Color(0xFF121212);

  // Extended Palette
  static const Color emerald = Color(0xFF2E7D32);
  static const Color teal = Color(0xFF00796B);
  static const Color warmGray = Color(0xFF9E9E9E);
  static const Color softCream = Color(0xFFFFF8E1);
  static const Color nightBlue = Color(0xFF1A237E);
  
  // Premium Extended Palette
  static const Color sunriseOrange = Color(0xFFFF6F00);
  static const Color sunsetPurple = Color(0xFF6A1B9A);
  static const Color midnightBlue = Color(0xFF0D1B2A);
  static const Color dawnPurple = Color(0xFF4A148C);

  // Gradient for Headers
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, teal],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFF9A825)],
  );

  // Premium Time-Based Gradients
  static LinearGradient get fajrGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A237E), Color(0xFF311B92), Color(0xFF4A148C)],
  );

  static LinearGradient get sunriseGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6F00), Color(0xFFFFB300), Color(0xFFFFF176)],
  );

  static LinearGradient get dhuhrGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1), Color(0xFFE0F7FA)],
  );

  static LinearGradient get asrGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF81C784)],
  );

  static LinearGradient get maghribGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFBF360C), Color(0xFFE65100), Color(0xFFFF8F00)],
  );

  static LinearGradient get ishaGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1B2A), Color(0xFF1B1B3A), Color(0xFF1B5E20)],
  );

  /// Get gradient based on current time (synced with SkySceneWidget)
  static LinearGradient getHeaderGradientByTime() {
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;
    final timeValue = hour + (minute / 60.0);
    
    // Synced with SkySceneWidget time ranges
    if (timeValue >= 21.0 || timeValue < 4.0) {
      return ishaGradient;           // Night
    } else if (timeValue >= 4.0 && timeValue < 5.5) {
      return fajrGradient;           // Fajr
    } else if (timeValue >= 5.5 && timeValue < 7.0) {
      return sunriseGradient;        // Sunrise
    } else if (timeValue >= 7.0 && timeValue < 12.0) {
      return dhuhrGradient;          // Morning to Dhuhr
    } else if (timeValue >= 12.0 && timeValue < 15.0) {
      return dhuhrGradient;          // Noon
    } else if (timeValue >= 15.0 && timeValue < 17.0) {
      return asrGradient;            // Afternoon/Asr
    } else if (timeValue >= 17.0 && timeValue < 19.0) {
      // Sunset colors - purple + orange (matching sky scene)
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF5C6BC0), Color(0xFFE65100), Color(0xFFFF8F00)],
      );
    } else {
      // Maghrib (19:00 - 21:00) - deep purple + deep orange
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF283593), Color(0xFFBF360C), Color(0xFFE65100)],
      );
    }
  }

  /// Get theme based on current time
  static ThemeData getThemeByTime() {
    final hour = DateTime.now().hour;
    // Light theme between 6 AM and 6 PM
    if (hour >= 6 && hour < 18) {
      return lightTheme;
    }
    return darkTheme;
  }

  /// Light Theme (Daylight Hours)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: primaryGold,
      surface: pureWhite,
      onPrimary: pureWhite,
      onSecondary: deepBlack,
      onSurface: deepBlack,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: primaryGreen,
      foregroundColor: pureWhite,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: pureWhite,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: pureWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: pureWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGold,
      foregroundColor: deepBlack,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: deepBlack,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: deepBlack,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: deepBlack,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: deepBlack,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: deepBlack,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: deepBlack,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: pureWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: pureWhite,
      selectedItemColor: primaryGreen,
      unselectedItemColor: warmGray,
      type: BottomNavigationBarType.fixed,
    ),
  );

  /// Dark Theme (Night Hours)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: emerald,
      secondary: primaryGold,
      surface: Color(0xFF1E1E1E),
      onPrimary: pureWhite,
      onSecondary: deepBlack,
      onSurface: pureWhite,
    ),
    scaffoldBackgroundColor: deepBlack,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: pureWhite,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: pureWhite,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF2D2D2D),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: emerald,
        foregroundColor: pureWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGold,
      foregroundColor: deepBlack,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: pureWhite,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: pureWhite,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: pureWhite,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: pureWhite,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: pureWhite,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: pureWhite,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: emerald, width: 2),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: primaryGold,
      unselectedItemColor: warmGray,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

/// Time-based greeting messages
class TimeBasedGreeting {
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Hayırlı Sabahlar';  // Good Morning
    } else if (hour >= 12 && hour < 17) {
      return 'Hayırlı Öğleler';  // Good Afternoon
    } else if (hour >= 17 && hour < 21) {
      return 'Hayırlı Akşamlar';  // Good Evening
    } else {
      return 'Hayırlı Geceler';  // Good Night
    }
  }

  static String getGreetingKey() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'greeting_morning';
    } else if (hour >= 12 && hour < 17) {
      return 'greeting_afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'greeting_evening';
    } else {
      return 'greeting_night';
    }
  }
}
