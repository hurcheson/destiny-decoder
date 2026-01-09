import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

/// Notification service provider.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// FCM device token provider (async).
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getDeviceToken();
});
