import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

/// Analytics Core Service
/// Handles silent data collection, heatmap logic, and conversion funnels.

@lazySingleton
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log screen view with duration tracking (Heatmap Logic)
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// Log custom events for professional product development
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  /// Conversion Funnel: Onboarding Start
  Future<void> logOnboardingStart() async {
    await logEvent(name: 'onboarding_start');
  }

  /// Conversion Funnel: Permission Granted (Notification/Location)
  Future<void> logPermissionGranted(String type) async {
    await logEvent(
      name: 'permission_granted',
      parameters: {'type': type},
    );
  }

  /// AI Query Analysis (Anonymous)
  Future<void> logAIQuery(String category) async {
    await logEvent(
      name: 'ai_query_analiz',
      parameters: {'category': category},
    );
  }

  /// Heatmap Logic: Track how long user stayed on a menu
  /// Call this when user navigates away from a screen
  Future<void> logMenuStats(String menuName, int durationSeconds) async {
    await logEvent(
      name: 'menu_stats',
      parameters: {
        'menu_name': menuName,
        'duration_sec': durationSeconds,
      },
    );
  }
}
