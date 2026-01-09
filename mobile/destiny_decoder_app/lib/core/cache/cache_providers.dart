import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_insights_cache_service.dart';

final sharedPreferencesAsyncProvider =
    Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final dailyInsightsCacheServiceProvider =
    Provider<DailyInsightsCacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesAsyncProvider);
  return DailyInsightsCacheService(prefs);
});
