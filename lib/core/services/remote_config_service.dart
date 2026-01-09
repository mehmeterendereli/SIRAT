import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import '../config/app_config.dart';

/// Dynamic Headless CMS Service
/// Manages all UI texts, feature flags, and global updates remotely.

@lazySingleton
class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setDefaults(AppConfig.remoteConfigDefaults);
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await fetchAndActivate();
    } catch (e) {
      // Handle or log error
    }
  }

  Future<void> fetchAndActivate() async {
    await _remoteConfig.fetchAndActivate();
  }

  /// Get a string value from CMS (Headless Management)
  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  /// Get a boolean value (Feature Flags)
  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  /// Get an int value
  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  /// Dynamic Text Helper: Returns remote value or fallback
  String getDynamicText(String key, String fallback) {
    final val = getString(key);
    return val.isEmpty ? fallback : val;
  }
}
