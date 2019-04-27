import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class Analytics {
  static final analytics = FirebaseAnalytics();
  static final observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );
}
