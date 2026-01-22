import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized Device ID management
/// Used for: subscriptions, analytics, notifications, sharing
class DeviceIdService {
  static const String _deviceIdKey = 'device_id';
  final _secureStorage = const FlutterSecureStorage();

  /// Get device ID or generate a new one
  Future<String> getDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);

    if (deviceId == null) {
      // Generate a new device ID (timestamp-based)
      // In production, could use device_info_plus for actual device fingerprint
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    }

    return deviceId;
  }

  /// Clear device ID (for testing or logout)
  Future<void> clearDeviceId() async {
    await _secureStorage.delete(key: _deviceIdKey);
  }
}

/// Riverpod provider for DeviceIdService
final deviceIdServiceProvider = Provider<DeviceIdService>((ref) {
  return DeviceIdService();
});

/// Provider for getting current device ID
final deviceIdProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(deviceIdServiceProvider);
  return await service.getDeviceId();
});
