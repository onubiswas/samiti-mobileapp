import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  Future<void> logEvent({required String name, Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
