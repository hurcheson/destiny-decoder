import 'package:destiny_decoder_app/core/network/api_client.dart';
import 'package:destiny_decoder_app/core/cache/daily_insights_cache_service.dart';
import 'models.dart';

class DailyInsightsService {
  final ApiClient api;
  final DailyInsightsCacheService? cache;

  DailyInsightsService(this.api, {this.cache});

  Future<DailyInsightResponse> getDailyInsight({
    required int lifeSeal,
    required int dayOfBirth,
    String? targetDate,
    bool skipCache = false,
  }) async {
    final params = {
      'life_seal': lifeSeal,
      'day_of_birth': dayOfBirth,
      'target_date': targetDate ?? 'today',
    };

    // Try cache first
    if (!skipCache && cache != null) {
      final cached = await cache!.get<DailyInsightResponse>(
        'insight',
        params,
        (json) => DailyInsightResponse.fromJson(json),
      );
      if (cached != null) return cached;
    }

    // Fetch from backend
    final data = await api.post('/daily/insight', data: {
      'life_seal': lifeSeal,
      'day_of_birth': dayOfBirth,
      if (targetDate != null) 'target_date': targetDate,
    });
    final result = DailyInsightResponse.fromJson(data);

    // Cache result
    if (cache != null) {
      await cache!.set(
        'insight',
        params,
        result,
        (r) => data.toString(), // Store original JSON
      );
    }

    return result;
  }

  Future<WeeklyInsightsResponse> getWeeklyInsights({
    required int lifeSeal,
    String? startDate,
    bool skipCache = false,
  }) async {
    final params = {
      'life_seal': lifeSeal,
      'start_date': startDate ?? 'today',
    };

    if (!skipCache && cache != null) {
      final cached = await cache!.get<WeeklyInsightsResponse>(
        'weekly',
        params,
        (json) => WeeklyInsightsResponse.fromJson(json),
      );
      if (cached != null) return cached;
    }

    final data = await api.post('/daily/weekly', data: {
      'life_seal': lifeSeal,
      if (startDate != null) 'start_date': startDate,
    });
    final result = WeeklyInsightsResponse.fromJson(data);

    if (cache != null) {
      await cache!.set('weekly', params, result, (r) => data.toString());
    }

    return result;
  }

  Future<BlessedDaysResponse> getBlessedDays({
    required int dayOfBirth,
    int? month,
    int? year,
    bool skipCache = false,
  }) async {
    final params = {
      'day_of_birth': dayOfBirth,
      'month': month ?? DateTime.now().month,
      'year': year ?? DateTime.now().year,
    };

    if (!skipCache && cache != null) {
      final cached = await cache!.get<BlessedDaysResponse>(
        'blessed',
        params,
        (json) => BlessedDaysResponse.fromJson(json),
      );
      if (cached != null) return cached;
    }

    final data = await api.post('/daily/blessed-days', data: {
      'day_of_birth': dayOfBirth,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    });
    final result = BlessedDaysResponse.fromJson(data);

    if (cache != null) {
      await cache!.set('blessed', params, result, (r) => data.toString());
    }

    return result;
  }

  Future<PersonalMonthResponse> getPersonalMonth({
    required int dayOfBirth,
    required int monthOfBirth,
    required int yearOfBirth,
    int? targetMonth,
    int? targetYear,
  }) async {
    final data = await api.post('/daily/personal-month', data: {
      'day_of_birth': dayOfBirth,
      'month_of_birth': monthOfBirth,
      'year_of_birth': yearOfBirth,
      if (targetMonth != null) 'target_month': targetMonth,
      if (targetYear != null) 'target_year': targetYear,
    });
    return PersonalMonthResponse.fromJson(data);
  }
}
