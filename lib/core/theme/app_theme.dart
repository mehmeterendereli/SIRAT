import 'package:flutter/material.dart';

/// Dynamic Theme System for SIRAT
/// Adapts based on time of day: Light theme during daylight, Dark theme at night

class AppTheme {
  AppTheme._();

  // Primary Brand Colors
  static const Color primaryGreen = Color(0xFF1B5E20); // Islamic Green
  static const Color primaryGold = Color(0xFFD4AF37);  // Gold Accent
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color deepBlack = Color(0xFF121212);

  // Extended Palette
  static const Color emerald = Color(0xFF2E7D32);
  static const Color teal = Color(0xFF00796B);
  static const Color warmGray = Color(0xFF9E9E9E);
  static const Color softCream = Color(0xFFFFF8E1);
  static const Color nightBlue = Color(0xFF1A237E);

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
    cardTheme: CardTheme(
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
    cardTheme: CardTheme(
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
