import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// Analytics API client for tracking share events and referrals
class AnalyticsApiClient {
  final Dio _dio;

  AnalyticsApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: '${AppConfig.apiBaseUrl}/analytics',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  /// Record a share event (fire-and-forget)
  Future<void> recordShareEvent({
    required String eventType,
    int? lifeSealNumber,
    String? slug,
    String? platform,
    String? refCode,
    String source = 'app',
  }) async {
    try {
      await _dio.post(
        '/share-events',
        data: {
          'event_type': eventType,
          if (lifeSealNumber != null) 'life_seal_number': lifeSealNumber,
          if (slug != null) 'slug': slug,
          if (platform != null) 'platform': platform,
          if (refCode != null) 'ref_code': refCode,
          'source': source,
        },
      );
    } catch (e) {
      // Silent fail - don't block user experience
      // In production, you might log to a monitoring service
      Logger.d('Analytics tracking failed (non-blocking): $e');
    }
  }

  /// Record a referral click (when user arrives via shared link)
  Future<void> recordReferralClick({
    required String refCode,
    String? target,
    String? userAgent,
  }) async {
    try {
      await _dio.post(
        '/referral-clicks',
        data: {
          'ref_code': refCode,
          if (target != null) 'target': target,
          if (userAgent != null) 'user_agent': userAgent,
        },
      );
    } catch (e) {
      Logger.d('Referral tracking failed (non-blocking): $e');
    }
  }
}
