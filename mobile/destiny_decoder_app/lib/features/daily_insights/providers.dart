import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:destiny_decoder_app/core/network/api_client_provider.dart';
import 'service.dart';
import 'models.dart';

// Service provider
final dailyInsightsServiceProvider = Provider<DailyInsightsService>((ref) {
  final api = ref.watch(apiClientProvider);
  return DailyInsightsService(api);
});

// Params
class DailyInsightParams extends Equatable {
  final int lifeSeal;
  final int dayOfBirth;
  final String? targetDate; // ISO YYYY-MM-DD
  const DailyInsightParams({
    required this.lifeSeal,
    required this.dayOfBirth,
    this.targetDate,
  });

  @override
  List<Object?> get props => [lifeSeal, dayOfBirth, targetDate];
}

class WeeklyParams extends Equatable {
  final int lifeSeal;
  final String? startDate; // ISO YYYY-MM-DD
  const WeeklyParams({required this.lifeSeal, this.startDate});

  @override
  List<Object?> get props => [lifeSeal, startDate];
}

class BlessedDaysParams extends Equatable {
  final int dayOfBirth;
  final int? month;
  final int? year;
  const BlessedDaysParams({
    required this.dayOfBirth,
    this.month,
    this.year,
  });

  @override
  List<Object?> get props => [dayOfBirth, month, year];
}

class PersonalMonthParams extends Equatable {
  final int dayOfBirth;
  final int monthOfBirth;
  final int yearOfBirth;
  final int? targetMonth;
  final int? targetYear;
  const PersonalMonthParams({
    required this.dayOfBirth,
    required this.monthOfBirth,
    required this.yearOfBirth,
    this.targetMonth,
    this.targetYear,
  });

  @override
  List<Object?> get props => [
        dayOfBirth,
        monthOfBirth,
        yearOfBirth,
        targetMonth,
        targetYear,
      ];
}

// Providers
final dailyInsightProvider = FutureProvider.family<DailyInsightResponse, DailyInsightParams>((ref, params) async {
  final svc = ref.watch(dailyInsightsServiceProvider);
  return svc.getDailyInsight(
    lifeSeal: params.lifeSeal,
    dayOfBirth: params.dayOfBirth,
    targetDate: params.targetDate,
  );
});

final weeklyInsightsProvider = FutureProvider.family<WeeklyInsightsResponse, WeeklyParams>((ref, params) async {
  final svc = ref.watch(dailyInsightsServiceProvider);
  return svc.getWeeklyInsights(
    lifeSeal: params.lifeSeal,
    startDate: params.startDate,
  );
});

final blessedDaysProvider = FutureProvider.family<BlessedDaysResponse, BlessedDaysParams>((ref, params) async {
  final svc = ref.watch(dailyInsightsServiceProvider);
  return svc.getBlessedDays(
    dayOfBirth: params.dayOfBirth,
    month: params.month,
    year: params.year,
  );
});

final personalMonthProvider = FutureProvider.family<PersonalMonthResponse, PersonalMonthParams>((ref, params) async {
  final svc = ref.watch(dailyInsightsServiceProvider);
  return svc.getPersonalMonth(
    dayOfBirth: params.dayOfBirth,
    monthOfBirth: params.monthOfBirth,
    yearOfBirth: params.yearOfBirth,
    targetMonth: params.targetMonth,
    targetYear: params.targetYear,
  );
});
