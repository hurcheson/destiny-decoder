import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../firebase/firebase_service.dart';

/// Firebase Cloud Messaging notification handler.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  late final FirebaseMessaging _fcm;

  bool _isInitialized = false;

  /// Initialize Firebase and notification channels.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize using FirebaseService (which initializes Firebase)
      final firebaseService = FirebaseService();
      await firebaseService.initialize();
      
      _fcm = FirebaseMessaging.instance;

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listen to background messages (via handler)
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
      }
    }
  }

  /// Get FCM device token for registration (uses FirebaseService).
  Future<String?> getDeviceToken() async {
    try {
      final firebaseService = FirebaseService();
      return await firebaseService.getFCMToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device token: $e');
      }
      return null;
    }
  }

  /// Handle foreground messages (app is open).
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
    }
  }

  /// Handle background messages (app is closed/background).
  /// Must be a top-level function.
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    if (kDebugMode) {
      print('Background message: ${message.notification?.title}');
    }
  }

  /// Subscribe to a notification topic (for server-side targeting).
  Future<void> subscribeTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  /// Unsubscribe from a notification topic.
  Future<void> unsubscribeTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  /// Test: Show a blessed day notification (via print for now).
  Future<void> showTestBlessedDayNotification({String firstName = ''}) async {
    if (kDebugMode) {
      final greeting = firstName.isNotEmpty 
          ? '$firstName, today is your blessed day!'
          : 'Today is your blessed day!';
      print('Test Blessed Day Notification: $greeting');
      print(
          'Harness the divine energy. This is an auspicious day for important decisions.');
    }
  }

  /// Test: Show a personal year notification (via print for now).
  Future<void> showTestPersonalYearNotification({String firstName = '', int personalYear = 0}) async {
    if (kDebugMode) {
      final greeting = firstName.isNotEmpty
          ? '$firstName, personal year $personalYear begins!'
          : 'Personal Year $personalYear Begins!';
      print('Test Personal Year Notification: $greeting');
      print(
          'Happy numerological birthday! You\'re entering a year of wisdom and introspection.');
    }
  }
}
