import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

    // Initialize Firebase
    await Firebase.initializeApp();

    // Now safe to access FCM
    _fcm = FirebaseMessaging.instance;

    // Request notification permissions
    final _ = await _fcm.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen to background messages (via handler)
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    _isInitialized = true;
  }

  /// Get FCM device token for registration.
  Future<String?> getDeviceToken() async {
    if (!_isInitialized) return null;
    return await _fcm.getToken();
  }

  /// Handle foreground messages (app is open).
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
  }

  /// Handle background messages (app is closed/background).
  /// Must be a top-level function.
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Background message: ${message.notification?.title}');
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
  Future<void> showTestBlessedDayNotification() async {
    print('✨ Test Blessed Day Notification: Today is Your Blessed Day!');
    print(
        'Harness the divine energy. This is an auspicious day for important decisions.');
  }

  /// Test: Show a personal year notification (via print for now).
  Future<void> showTestPersonalYearNotification() async {
    print('🎂 Test Personal Year Notification: Personal Year 7 Begins!');
    print(
        'Happy numerological birthday! You\'re entering a year of wisdom and introspection.');
  }
}
