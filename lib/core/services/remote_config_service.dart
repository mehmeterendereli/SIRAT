import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1), // Production: 1 hour, Dev: 0 can be set here
      ));

      await _remoteConfig.setDefaults(const {
        'welcome_message_teheccud': 'Teheccüd Vakti',
        'welcome_message_sahur': 'Sahur Vakti',
        'welcome_message_morning': 'Hayırlı Sabahlar',
        'welcome_message_noon': 'Vakit: Öğle',
        'welcome_message_afternoon': 'Vakit: İkindi',
        'welcome_message_evening': 'Hayırlı Akşamlar',
        'welcome_message_sunset': 'İftar Vakti',
        'welcome_message_night': 'Hayırlı Geceler',
        'feature_show_mosque_finder': true,
        'feature_show_ar_qibla': true,
        'daily_story_image_url': 'default', // 'default' uses local asset
        'kandil_mode_enabled': false,
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Remote config fetch failed, defaults will be used
      print('Remote Config fetch failed: $e');
    }
  }

  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);
}
