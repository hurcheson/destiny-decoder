import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationPreferencesService {
  static const String _apiBaseUrl = 'https://destiny-decoder-production.up.railway.app/api'; // Production Railway
  static const String _deviceIdKey = 'device_id';

  late Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  NotificationPreferencesService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _apiBaseUrl,
        contentType: Headers.jsonContentType,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Add interceptors for logging (debug only)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) {},
        ),
      );
    }
  }

  /// Get device ID or generate a new one
  Future<String> _getDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);

    if (deviceId == null) {
      // Generate a new device ID (in production, get from device platform)
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    }

    return deviceId;
  }

  /// Save user notification preferences to backend
  Future<Map<String, dynamic>> savePreferences({
    required bool blessedDayAlerts,
    required bool dailyInsights,
    required bool lunarPhaseAlerts,
    required bool motivationalQuotes,
    required bool quietHoursEnabled,
    required String quietHoursStart,
    required String quietHoursEnd,
  }) async {
    try {
      final deviceId = await _getDeviceId();

      final response = await _dio.post(
        '/notifications/preferences',
        data: {
          'device_id': deviceId,
          'blessed_day_alerts': blessedDayAlerts,
          'daily_insights': dailyInsights,
          'lunar_phase_alerts': lunarPhaseAlerts,
          'motivational_quotes': motivationalQuotes,
          'quiet_hours_enabled': quietHoursEnabled,
          'quiet_hours_start': quietHoursEnabled ? quietHoursStart : null,
          'quiet_hours_end': quietHoursEnabled ? quietHoursEnd : null,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to save preferences: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error saving preferences: $e');
    }
  }

  /// Retrieve user notification preferences from backend
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final deviceId = await _getDeviceId();

      final response = await _dio.get(
        '/notifications/preferences',
        queryParameters: {
          'device_id': deviceId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['preferences'] ?? {};
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch preferences');
        }
      } else {
        throw Exception('Failed to fetch preferences: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // If device is not found, return defaults
      if (e.response?.statusCode == 404) {
        return _getDefaultPreferences();
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching preferences: $e');
    }
  }

  /// Get default notification preferences
  Map<String, dynamic> _getDefaultPreferences() {
    return {
      'blessed_day_alerts': true,
      'daily_insights': true,
      'lunar_phase_alerts': false,
      'motivational_quotes': true,
      'quiet_hours_enabled': false,
      'quiet_hours_start': '22:00',
      'quiet_hours_end': '06:00',
    };
  }

  /// Clear device ID (useful for testing or logout)
  Future<void> clearDeviceId() async {
    await _secureStorage.delete(key: _deviceIdKey);
  }
}
