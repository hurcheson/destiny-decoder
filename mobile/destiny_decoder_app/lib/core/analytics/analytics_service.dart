import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  /// Get the observer for route tracking
  static FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }
  
  /// Log app open
  static Future<void> logAppOpen() async {
    try {
      await _analytics.logEvent(
        name: 'app_open',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        print('Analytics: App opened');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging app open: $e');
      }
    }
  }
  
  /// Log screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      if (kDebugMode) {
        print('Analytics: Screen view logged - $screenName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging screen view: $e');
      }
    }
  }
  
  /// Log calculation completed
  static Future<void> logCalculationCompleted(int lifeSeal) async {
    try {
      await _analytics.logEvent(
        name: 'calculation_completed',
        parameters: {
          'life_seal': lifeSeal,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      // Track as user property
      await setUserProperty(name: 'life_seal_number', value: lifeSeal.toString());
      if (kDebugMode) {
        print('Analytics: Calculation completed - Life Seal $lifeSeal');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging calculation: $e');
      }
    }
  }
  
  /// Log PDF export
  static Future<void> logPdfExport() async {
    try {
      await _analytics.logEvent(
        name: 'pdf_exported',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        print('Analytics: PDF exported');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging PDF export: $e');
      }
    }
  }
  
  /// Log reading saved
  static Future<void> logReadingSaved() async {
    try {
      await _analytics.logEvent(
        name: 'reading_saved',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        print('Analytics: Reading saved');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging reading saved: $e');
      }
    }
  }
  
  /// Log compatibility check
  static Future<void> logCompatibilityCheck() async {
    try {
      await _analytics.logEvent(
        name: 'compatibility_checked',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        print('Analytics: Compatibility checked');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging compatibility check: $e');
      }
    }
  }
  
  /// Log daily insights viewed
  static Future<void> logDailyInsightsViewed() async {
    try {
      await _analytics.logEvent(
        name: 'daily_insights_viewed',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        print('Analytics: Daily insights viewed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging daily insights: $e');
      }
    }
  }
  
  /// Log reading history accessed
  static Future<void> logReadingHistoryAccessed() async {
    try {
      await _analytics.logEvent(
        name: 'reading_history_accessed',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        print('Analytics: Reading history accessed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging reading history: $e');
      }
    }
  }
  
  /// Log notification opened
  static Future<void> logNotificationOpened(String type) async {
    try {
      await _analytics.logEvent(
        name: 'notification_opened',
        parameters: {
          'notification_type': type,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        print('Analytics: Notification opened - $type');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging notification: $e');
      }
    }
  }
  
  /// Log notification settings changed
  static Future<void> logNotificationSettingsChanged(String setting, bool value) async {
    try {
      await _analytics.logEvent(
        name: 'notification_settings_changed',
        parameters: {
          'setting': setting,
          'value': value,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        print('Analytics: Notification settings changed - $setting: $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging notification settings: $e');
      }
    }
  }
  
  /// Log onboarding completed
  static Future<void> logOnboardingCompleted() async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_completed',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      // Mark user as having calculated
      await setUserProperty(name: 'has_calculated', value: 'true');
      if (kDebugMode) {
        print('Analytics: Onboarding completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging onboarding: $e');
      }
    }
  }
  
  /// Log onboarding skipped
  static Future<void> logOnboardingSkipped(int step) async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_skipped',
        parameters: {
          'step': step,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        print('Analytics: Onboarding skipped at step $step');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging onboarding skip: $e');
      }
    }
  }
  
  /// Log FCM token registered
  static Future<void> logFcmTokenRegistered() async {
    try {
      await _analytics.logEvent(
        name: 'fcm_token_registered',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      await setUserProperty(name: 'notification_opt_in', value: 'true');
      if (kDebugMode) {
        print('Analytics: FCM token registered');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging FCM registration: $e');
      }
    }
  }
  
  /// Set user property
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      if (kDebugMode) {
        print('Analytics: User property set - $name: $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user property: $e');
      }
    }
  }
  
  /// Set user ID
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      if (kDebugMode) {
        print('Analytics: User ID set - $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user ID: $e');
      }
    }
  }
}
