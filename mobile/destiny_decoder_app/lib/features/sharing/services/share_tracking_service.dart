import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for tracking and managing social shares via backend API.
/// Handles share event logging and share statistics retrieval.
class ShareTrackingService {
  static const String _apiBaseUrl = 'http://localhost:8000/api'; // Update for production
  static const String _deviceIdKey = 'device_id';

  late Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  ShareTrackingService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _apiBaseUrl,
        contentType: Headers.jsonContentType,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Add interceptors for logging in debug mode
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

  /// Get device ID, generating one if necessary
  Future<String> _getDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);

    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    }

    return deviceId;
  }

  /// Log a share event to the backend
  /// 
  /// [lifeSealNumber] - The life seal number being shared
  /// [platform] - Platform shared to (whatsapp, instagram, twitter, copy_clipboard)
  /// [shareText] - Optional text preview that was shared
  /// 
  /// Returns the created share log entry as a Map
  Future<Map<String, dynamic>> logShare({
    required int lifeSealNumber,
    required String platform,
    String? shareText,
  }) async {
    try {
      final deviceId = await _getDeviceId();

      final response = await _dio.post(
        '/shares/track',
        data: {
          'device_id': deviceId,
          'life_seal_number': lifeSealNumber,
          'platform': platform,
          'share_text': shareText,
        },
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to log share: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? e.message ?? 'Failed to log share';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error logging share: $e');
    }
  }

  /// Get share statistics for a specific life seal number
  /// 
  /// [lifeSealNumber] - Optional filter by life seal (if null, returns all)
  /// [days] - Number of days to look back (default 30)
  /// 
  /// Returns share statistics including total shares and platform breakdown
  Future<Map<String, dynamic>> getShareStats({
    int? lifeSealNumber,
    int days = 30,
  }) async {
    try {
      final params = <String, dynamic>{
        'days': days,
      };

      if (lifeSealNumber != null) {
        params['life_seal_number'] = lifeSealNumber;
      }

      final response = await _dio.get(
        '/shares/stats',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch share stats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? e.message ?? 'Failed to fetch stats';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error fetching share stats: $e');
    }
  }

  /// Get the most frequently shared life seal numbers
  /// 
  /// [limit] - Number of top items to return (default 10)
  /// [days] - Number of days to look back (default 30)
  /// 
  /// Returns a map with top shared life seal numbers and their counts
  Future<Map<String, dynamic>> getTopShared({
    int limit = 10,
    int days = 30,
  }) async {
    try {
      final response = await _dio.get(
        '/shares/stats/top',
        queryParameters: {
          'limit': limit,
          'days': days,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch top shared: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? e.message ?? 'Failed to fetch top shared';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error fetching top shared: $e');
    }
  }
}
