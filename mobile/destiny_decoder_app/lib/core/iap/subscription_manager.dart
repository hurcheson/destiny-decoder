import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import '../config/app_config.dart';
import '../device/device_id_provider.dart';

/// Subscription tier enumeration
enum SubscriptionTier {
  free,
  premium,
  pro;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }

  String get price {
    switch (this) {
      case SubscriptionTier.free:
        return '\$0';
      case SubscriptionTier.premium:
        return '\$2.99/mo';
      case SubscriptionTier.pro:
        return '\$49.99/yr';
    }
  }
}

/// Subscription status model
class SubscriptionStatus {
  final String userId;
  final SubscriptionTier tier;
  final bool isActive;
  final DateTime? expiresAt;
  final Map<String, dynamic> features;

  SubscriptionStatus({
    required this.userId,
    required this.tier,
    required this.isActive,
    this.expiresAt,
    required this.features,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      userId: json['user_id'],
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      isActive: json['is_active'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      features: json['features'] ?? {},
    );
  }

  // Feature access helpers
  bool get hasUnlimitedReadings => features['unlimited_readings'] == true;
  bool get hasFullInterpretations => features['full_interpretations'] == true;
  bool get hasUnlimitedPdf => features['unlimited_pdf'] == true;
  bool get hasDetailedCompatibility => features['detailed_compatibility'] == true;
  bool get hasAdvancedAnalytics => features['advanced_analytics'] == true;
  bool get isAdFree => features['ad_free'] == true;
  
  int get readingLimit => features['reading_limit'] ?? 3;
  int get pdfMonthlyLimit => features['pdf_monthly_limit'] ?? 1;
}

/// Service for managing subscriptions and communicating with backend
class SubscriptionManager {
  final String baseUrl;

  SubscriptionManager({required this.baseUrl});

  /// Validate a purchase receipt with the backend
  Future<bool> validatePurchase({
    required String userId,
    required String platform,
    required String receiptData,
    required String productId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/subscription/validate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'platform': platform,
          'receipt_data': receiptData,
          'product_id': productId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      Logger.e('❌ Validation failed: ${response.statusCode}');
      return false;
    } catch (e) {
      Logger.e('❌ Error validating purchase: $e');
      return false;
    }
  }

  /// Get subscription status for a user
  Future<SubscriptionStatus?> getSubscriptionStatus(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/subscription/status/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubscriptionStatus.fromJson(data);
      }

      Logger.e('❌ Failed to get status: ${response.statusCode}');
      return null;
    } catch (e) {
      Logger.e('❌ Error getting status: $e');
      return null;
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/subscription/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      Logger.e('❌ Error cancelling subscription: $e');
      return false;
    }
  }

  /// Get subscription history
  Future<List<Map<String, dynamic>>> getSubscriptionHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/subscription/history/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      Logger.e('❌ Error getting history: $e');
      return [];
    }
  }

  /// Get feature list for comparison
  Future<Map<String, dynamic>> getFeatureList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/subscription/features'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {};
    } catch (e) {
      Logger.e('❌ Error getting features: $e');
      return {};
    }
  }
}

/// Riverpod provider for SubscriptionManager
final subscriptionManagerProvider = Provider<SubscriptionManager>((ref) {
  return SubscriptionManager(baseUrl: AppConfig.apiBaseUrl);
});

/// Provider for current subscription status
final subscriptionStatusProvider = FutureProvider<SubscriptionStatus?>((ref) async {
  final manager = ref.watch(subscriptionManagerProvider);
  final deviceId = await ref.watch(deviceIdProvider.future);
  
  return await manager.getSubscriptionStatus(deviceId);
});
