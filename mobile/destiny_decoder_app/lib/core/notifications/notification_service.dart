import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Firebase Cloud Messaging notification handler.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize Firebase and notification channels.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Firebase
    await Firebase.initializeApp();

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

    // Initialize local notifications for Android
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen to background messages (via handler)
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    _isInitialized = true;
  }

  /// Get FCM device token for registration.
  Future<String?> getDeviceToken() async {
    return await _fcm.getToken();
  }

  /// Handle foreground messages (app is open).
  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  /// Handle background messages (app is closed/background).
  /// Must be a top-level function.
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    // Notification is automatically shown by FCM on Android/iOS
    // Log or handle additional logic here
  }

  /// Show local notification (for foreground + testing).
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'destiny_decoder_channel',
      'Destiny Decoder',
      channelDescription: 'Blessed days and personal year milestones',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Destiny Decoder',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: data.isEmpty ? null : Uri(queryParameters: data).query,
    );
  }

  /// Handle notification tap.
  void _onNotificationTapped(NotificationResponse response) {
    // Parse payload and navigate to relevant page
    // e.g., if it's a blessed day notification, navigate to Daily Insights
  }

  /// Subscribe to a notification topic (for server-side targeting).
  Future<void> subscribeTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  /// Unsubscribe from a notification topic.
  Future<void> unsubscribeTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  /// Test: Show a local blessed day notification.
  Future<void> showTestBlessedDayNotification() async {
    await _showLocalNotification(
      title: '✨ Today is Your Blessed Day!',
      body: 'Harness the divine energy. This is an auspicious day for important decisions.',
      data: {'type': 'blessed_day', 'day': '9'},
    );
  }

  /// Test: Show a local personal year notification.
  Future<void> showTestPersonalYearNotification() async {
    await _showLocalNotification(
      title: '🎂 Personal Year 7 Begins!',
      body: 'Happy numerological birthday! You\'re entering a year of wisdom and introspection.',
      data: {'type': 'personal_year_milestone', 'new_year': '7'},
    );
  }
}
