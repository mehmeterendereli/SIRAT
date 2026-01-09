import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// User Preferences Repository
/// Persists user choices for Language, Mezhep, and Methodology.

@lazySingleton
class UserPreferencesRepository {
  static const _keyLanguage = 'language';
  static const _keyMezhep = 'mezhep';
  static const _keyCalculationMethod = 'calculation_method';
  static const _keyOnboardingComplete = 'onboarding_complete';

  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, languageCode);
  }

  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  Future<void> saveMezhep(int mezhepId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMezhep, mezhepId);
  }

  Future<int?> getMezhep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMezhep);
  }

  Future<void> saveCalculationMethod(int methodId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCalculationMethod, methodId);
  }

  Future<int?> getCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCalculationMethod);
  }

  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, complete);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }
}
