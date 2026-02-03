// Riverpod providers for subscription status and reading limits.
// ignore_for_file: unused_result

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_providers.dart';


class LimitStatus {
  final bool allowed;
  final int remaining;
  final int limit;
  final String? resetDate;
  final String tier;
  final String message;

  LimitStatus({
    required this.allowed,
    required this.remaining,
    required this.limit,
    this.resetDate,
    required this.tier,
    required this.message,
  });

  factory LimitStatus.fromJson(Map<String, dynamic> json) {
    return LimitStatus(
      allowed: json['allowed'] ?? false,
      remaining: json['remaining'] ?? 0,
      limit: json['limit'] ?? 3,
      resetDate: json['reset_date'],
      tier: json['tier'] ?? 'free',
      message: json['message'] ?? 'Unknown status',
    );
  }
}


// Get reading limit status
final readingLimitProvider = FutureProvider<LimitStatus>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  
  try {
    final response = await apiClient.get('/api/limits/reading-check');
    return LimitStatus.fromJson(response);
  } catch (e) {
    throw Exception('Failed to check reading limit: $e');
  }
});


// Refresh reading limit (invalidate cache)
final refreshLimitProvider = FutureProvider<void>((ref) async {
  // This provider exists only to be invalidated
  // When invalidated, reading limit will be refetched
});

// Helper function to refresh limits
void refreshReadingLimit(WidgetRef ref) {
  ref.refresh(readingLimitProvider);
}

// Check if user can create a reading without payment
final canCreateReadingProvider = FutureProvider<bool>((ref) async {
  final limitStatus = await ref.watch(readingLimitProvider.future);
  return limitStatus.allowed;
});
