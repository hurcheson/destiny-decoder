import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'firebase_options.dart';
import '../utils/logger.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    Logger.i('Handling background message: ${message.messageId}');
    Logger.i('Title: ${message.notification?.title}');
    Logger.i('Body: ${message.notification?.body}');
  }
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() {
    return _instance;
  }
  
  FirebaseService._internal();
  
  late FirebaseMessaging _firebaseMessaging;
  String? _fcmToken;
  
  /// Initialize Firebase and FCM
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      _firebaseMessaging = FirebaseMessaging.instance;
      
      // Request permission for notifications (iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        provisional: false,
        sound: true,
      );
      
      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }
      
      // Set up foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Set up notification tap handler
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $_fcmToken');
      }
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (kDebugMode) {
          print('FCM Token refreshed: $newToken');
        }
        // Send new token to backend
        registerTokenWithBackend(newToken);
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
      rethrow;
    }
  }
  
  /// Get current FCM token
  Future<String?> getFCMToken() async {
    try {
      return _fcmToken ?? await _firebaseMessaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }
  
  /// Register token with backend and subscribe to default topics
  Future<void> registerTokenWithBackend(String token) async {
    try {
      // Determine device type
      String deviceType = 'unknown';
      if (Platform.isAndroid) {
        deviceType = 'android';
      } else if (Platform.isIOS) {
        deviceType = 'ios';
      } else if (kIsWeb) {
        deviceType = 'web';
      }
      
      // Subscribe to default topics first
      final defaultTopics = ['daily_insights', 'blessed_days', 'lunar_phases'];
      for (final topic in defaultTopics) {
        await subscribeToTopic(topic);
      }
      
      if (kDebugMode) {
        print('✓ FCM Token: $token');
        print('✓ Device Type: $deviceType');
        print('✓ Subscribed to topics: ${defaultTopics.join(', ')}');
      }
      
      // Call backend to register token
      // Note: This will be done via HTTP client in the app initialization
      // The app should call registerTokenViaApi() after this
      
    } catch (e) {
      if (kDebugMode) {
        print('Error preparing token registration: $e');
      }
    }
  }
  
  /// Register token via backend API (called from main app)
  Future<bool> registerTokenViaApi({
    required Future<Map<String, dynamic>> Function(String path, {required Map<String, dynamic> data}) apiPost,
  }) async {
    try {
      if (_fcmToken == null) {
        if (kDebugMode) print('Error: FCM token not available');
        return false;
      }
      
      String deviceType = 'unknown';
      if (Platform.isAndroid) {
        deviceType = 'android';
      } else if (Platform.isIOS) {
        deviceType = 'ios';
      } else if (kIsWeb) {
        deviceType = 'web';
      }
      
      final response = await apiPost(
        '/notifications/tokens/register',
        data: {
          'fcm_token': _fcmToken,
          'device_type': deviceType,
          'topics': ['daily_insights', 'blessed_days', 'lunar_phases', 'inspirational'],
        },
      );
      
      if (response['success'] == true) {
        if (kDebugMode) {
          print('✓ Token registered with backend');
          print('  Subscribed topics: ${response['topics_subscribed']}');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error registering token with backend: $e');
      }
      return false;
    }
  }
  
  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    final title = message.notification?.title ?? 'Destiny Decoder';
    final body = message.notification?.body ?? '';
    final notificationType = message.data['type'] ?? 'general';

    // Show a snackbar or in-app notification
    // This will be implemented by the app root widget using a provider
    _showForegroundNotification(
      title: title,
      body: body,
      type: notificationType,
      data: message.data,
    );

    // Log analytics event
    _logAnalyticsEvent('notification_received', {
      'type': notificationType,
      'title': title,
    });
  }

  /// Handle notification tap (when app is in background/terminated)
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped');
      print('Data: ${message.data}');
    }

    final notificationType = message.data['type'] ?? 'general';

    // Log analytics event
    _logAnalyticsEvent('notification_opened', {
      'type': notificationType,
    });

    // Navigation will be handled by app root widget using a provider
    _handleNotificationNavigation(
      type: notificationType,
      data: message.data,
    );
  }

  /// Internal method to handle showing foreground notification
  /// This is called when a notification arrives while app is in foreground
  void _showForegroundNotification({
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
  }) {
    // In production, this would trigger showing an in-app notification widget
    // For now, we just log it; the main app can listen to a stream for this
    if (kDebugMode) {
      print('📬 In-app notification: $title - $body');
    }
  }

  /// Internal method to handle notification navigation
  /// This determines where to navigate based on notification type
  void _handleNotificationNavigation({
    required String type,
    required Map<String, dynamic> data,
  }) {
    switch (type) {
      case 'daily_insight':
        // Navigate to Daily Insights page
        if (kDebugMode) print('Navigate to Daily Insights');
        break;
      case 'blessed_day':
        // Navigate to Blessed Days Calendar
        if (kDebugMode) print('Navigate to Blessed Days');
        break;
      case 'lunar_phase':
        // Navigate to Lunar Phase information
        if (kDebugMode) print('Navigate to Lunar Phases');
        break;
      case 'inspiration':
        // Navigate to Home or Daily Insights
        if (kDebugMode) print('Navigate to Home for inspiration');
        break;
      default:
        // Navigate to Home
        if (kDebugMode) print('Navigate to Home');
    }
  }

  /// Log analytics events
  /// This is a placeholder that can be integrated with Firebase Analytics
  void _logAnalyticsEvent(String eventName, Map<String, dynamic> parameters) {
    if (kDebugMode) {
      Logger.d('📊 Analytics: $eventName - $parameters');
    }
    // TODO: Implement actual Firebase Analytics logging
    // example: _analytics.logEvent(name: eventName, parameters: parameters);
  }

  
  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic: $e');
      }
    }
  }
  
  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic: $e');
      }
    }
  }
}
