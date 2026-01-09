/// SIRAT Application Configuration
/// Centralized configuration management for the app

class AppConfig {
  AppConfig._();

  // App Information
  static const String appName = 'SIRAT';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.sirat.sirat';

  // Firebase Configuration
  static const bool useFirebaseEmulator = false;
  static const String firestoreEmulatorHost = 'localhost';
  static const int firestoreEmulatorPort = 8080;

  // Gemini AI Configuration
  static const String geminiModel = 'gemini-pro';
  static const int geminiMaxTokens = 2048;
  static const double geminiTemperature = 0.7;

  // Remote Config Defaults
  static const Map<String, dynamic> remoteConfigDefaults = {
    'feature_ar_qibla': true,
    'feature_ai_assistant': true,
    'feature_zikirmatik': true,
    'feature_quran_audio': true,
    'daily_message_enabled': true,
    'admob_enabled': false,
    'maintenance_mode': false,
  };

  // API Endpoints
  static const String baseApiUrl = 'https://api.sirat.app';
  static const String prayerTimesApiUrl = 'https://api.aladhan.com/v1';

  // Prayer Time Calculation Methods
  static const Map<int, String> calculationMethods = {
    0: 'Jafari / Shia Ithna-Ashari',
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America',
    3: 'Muslim World League',
    4: 'Umm Al-Qura University, Makkah',
    5: 'Egyptian General Authority of Survey',
    7: 'Institute of Geophysics, University of Tehran',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Majlis Ugama Islam Singapura, Singapore',
    12: 'Diyanet İşleri Başkanlığı, Turkey',
    13: 'Spiritual Administration of Muslims of Russia',
  };

  // Madhab (School of Jurisprudence)
  static const Map<int, String> madhabs = {
    0: 'Shafi',
    1: 'Hanafi',
  };

  // Supported Languages
  static const List<String> supportedLocales = [
    'tr', // Turkish
    'en', // English
    'ar', // Arabic
    'de', // German
    'fr', // French
    'id', // Indonesian
    'ms', // Malay
    'ur', // Urdu
  ];

  // Kabe Coordinates
  static const double kabeLatitude = 21.4225;
  static const double kabeLongitude = 39.8262;
}
