import 'package:destiny_decoder_app/core/network/api_client.dart';
import 'models.dart';

class DailyInsightsService {
  final ApiClient api;

  DailyInsightsService(this.api);

  Future<DailyInsightResponse> getDailyInsight({
    required int lifeSeal,
    required int dayOfBirth,
    String? targetDate,
  }) async {
    final data = await api.post('/daily/insight', data: {
      'life_seal': lifeSeal,
      'day_of_birth': dayOfBirth,
      if (targetDate != null) 'target_date': targetDate,
    });
    return DailyInsightResponse.fromJson(data);
  }

  Future<WeeklyInsightsResponse> getWeeklyInsights({
    required int lifeSeal,
    String? startDate,
  }) async {
    final data = await api.post('/daily/weekly', data: {
      'life_seal': lifeSeal,
      if (startDate != null) 'start_date': startDate,
    });
    return WeeklyInsightsResponse.fromJson(data);
  }

  Future<BlessedDaysResponse> getBlessedDays({
    required int dayOfBirth,
    int? month,
    int? year,
  }) async {
    final data = await api.post('/daily/blessed-days', data: {
      'day_of_birth': dayOfBirth,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    });
    return BlessedDaysResponse.fromJson(data);
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
