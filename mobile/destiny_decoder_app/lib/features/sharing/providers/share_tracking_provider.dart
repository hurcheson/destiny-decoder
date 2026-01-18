import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/share_tracking_service.dart';

/// Singleton instance of ShareTrackingService
final shareTrackingServiceProvider = Provider((ref) {
  return ShareTrackingService();
});

/// Async notifier for tracking share events
/// Provides reactive state management for share operations
class ShareTrackingNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  late ShareTrackingService _service;

  @override
  Future<Map<String, dynamic>?> build() async {
    _service = ref.watch(shareTrackingServiceProvider);
    return null; // Start with no state
  }

  /// Log a share event and update state
  Future<void> logShare({
    required int lifeSealNumber,
    required String platform,
    String? shareText,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return await _service.logShare(
        lifeSealNumber: lifeSealNumber,
        platform: platform,
        shareText: shareText,
      );
    });
  }
}

/// Provider for share tracking operations
final shareTrackingProvider =
    AsyncNotifierProvider<ShareTrackingNotifier, Map<String, dynamic>?>(
  () => ShareTrackingNotifier(),
);

/// Provider for fetching share statistics
final shareStatsProvider = FutureProvider.family<
    Map<String, dynamic>,
    ({int? lifeSealNumber, int days})>((ref, params) async {
  final service = ref.watch(shareTrackingServiceProvider);
  return service.getShareStats(
    lifeSealNumber: params.lifeSealNumber,
    days: params.days,
  );
});

/// Provider for fetching top shared life seals
final topSharesProvider = FutureProvider.family<
    Map<String, dynamic>,
    ({int limit, int days})>((ref, params) async {
  final service = ref.watch(shareTrackingServiceProvider);
  return service.getTopShared(
    limit: params.limit,
    days: params.days,
  );
});
