/// Application Constants
/// Contains all constant values used throughout the app

class AppConstants {
  AppConstants._();

  // Zikir Types
  static const List<Map<String, dynamic>> zikirTypes = [
    {'name': 'Subhanallah', 'arabic': 'سُبْحَانَ اللَّهِ', 'count': 33},
    {'name': 'Elhamdulillah', 'arabic': 'الْحَمْدُ لِلَّهِ', 'count': 33},
    {'name': 'Allahuekber', 'arabic': 'اللَّهُ أَكْبَرُ', 'count': 33},
    {'name': 'La ilahe illallah', 'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ', 'count': 100},
    {'name': 'Salavat', 'arabic': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ', 'count': 100},
    {'name': 'Estağfirullah', 'arabic': 'أَسْتَغْفِرُ اللَّهَ', 'count': 100},
    {'name': 'La havle ve la kuvvete', 'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ', 'count': 100},
  ];

  // Prayer Names
  static const List<String> prayerNames = [
    'Fajr',
    'Sunrise',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  // Prayer Names in Turkish
  static const Map<String, String> prayerNamesTr = {
    'Fajr': 'İmsak',
    'Sunrise': 'Güneş',
    'Dhuhr': 'Öğle',
    'Asr': 'İkindi',
    'Maghrib': 'Akşam',
    'Isha': 'Yatsı',
  };

  // Azan Audio Options
  static const List<Map<String, String>> azanAudios = [
    {'id': 'mecca', 'name': 'Mekke Ezanı'},
    {'id': 'medina', 'name': 'Medine Ezanı'},
    {'id': 'istanbul', 'name': 'İstanbul Makamı'},
    {'id': 'turkey', 'name': 'Türkiye Diyanet'},
    {'id': 'ney', 'name': 'Ney Sesi'},
    {'id': 'classic', 'name': 'Klasik'},
  ];

  // Notification Channels
  static const String prayerNotificationChannel = 'prayer_notifications';
  static const String dailyReminderChannel = 'daily_reminders';
  static const String islamicEventsChannel = 'islamic_events';

  // Cache Durations
  static const Duration prayerTimesCacheDuration = Duration(hours: 24);
  static const Duration quranAudioCacheDuration = Duration(days: 30);
  static const Duration remoteConfigCacheDuration = Duration(hours: 1);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Storage Keys
  static const String keyUserSettings = 'user_settings';
  static const String keyZikirCounts = 'zikir_counts';
  static const String keyPrayerTimes = 'prayer_times';
  static const String keyLastLocation = 'last_location';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keySelectedLanguage = 'selected_language';
  static const String keySelectedMadhab = 'selected_madhab';
  static const String keyCalculationMethod = 'calculation_method';
}

/// App Routes
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String prayerTimes = '/prayer-times';
  static const String qibla = '/qibla';
  static const String quran = '/quran';
  static const String quranSurah = '/quran/:surahNumber';
  static const String zikirmatik = '/zikirmatik';
  static const String aiAssistant = '/ai-assistant';
  static const String mosquesFinder = '/mosques';
  static const String settings = '/settings';
  static const String profile = '/profile';
}
