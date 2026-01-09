import 'package:equatable/equatable.dart';

class DailyInsightInterpretation extends Equatable {
  final String title;
  final String energy;
  final String insight;
  final List<String> actionFocus;
  final String spiritualGuidance;
  final String energyColor;
  final String affirmation;
  final String caution;

  const DailyInsightInterpretation({
    required this.title,
    required this.energy,
    required this.insight,
    required this.actionFocus,
    required this.spiritualGuidance,
    required this.energyColor,
    required this.affirmation,
    required this.caution,
  });

  factory DailyInsightInterpretation.fromJson(Map<String, dynamic> json) {
    return DailyInsightInterpretation(
      title: json['title'] as String,
      energy: json['energy'] as String,
      insight: json['insight'] as String,
      actionFocus: (json['action_focus'] as List<dynamic>).cast<String>(),
      spiritualGuidance: json['spiritual_guidance'] as String,
      energyColor: json['energy_color'] as String,
      affirmation: json['affirmation'] as String,
      caution: json['caution'] as String,
    );
  }

  @override
  List<Object?> get props => [
        title,
        energy,
        insight,
        actionFocus,
        spiritualGuidance,
        energyColor,
        affirmation,
        caution,
      ];
}

class DailyInsightResponse extends Equatable {
  final String date;
  final String dayOfWeek;
  final int powerNumber;
  final bool isBlessedDay;
  final DailyInsightInterpretation insight;
  final String briefInsight;

  const DailyInsightResponse({
    required this.date,
    required this.dayOfWeek,
    required this.powerNumber,
    required this.isBlessedDay,
    required this.insight,
    required this.briefInsight,
  });

  factory DailyInsightResponse.fromJson(Map<String, dynamic> json) {
    return DailyInsightResponse(
      date: json['date'] as String,
      dayOfWeek: json['day_of_week'] as String,
      powerNumber: json['power_number'] as int,
      isBlessedDay: json['is_blessed_day'] as bool,
      insight: DailyInsightInterpretation.fromJson(json['insight'] as Map<String, dynamic>),
      briefInsight: json['brief_insight'] as String,
    );
  }

  @override
  List<Object?> get props => [
        date,
        dayOfWeek,
        powerNumber,
        isBlessedDay,
        insight,
        briefInsight,
      ];
}

class DailyPowerPreview extends Equatable {
  final String date;
  final String dayOfWeek;
  final int powerNumber;
  final String briefInsight;

  const DailyPowerPreview({
    required this.date,
    required this.dayOfWeek,
    required this.powerNumber,
    required this.briefInsight,
  });

  factory DailyPowerPreview.fromJson(Map<String, dynamic> json) {
    return DailyPowerPreview(
      date: json['date'] as String,
      dayOfWeek: json['day_of_week'] as String,
      powerNumber: json['power_number'] as int,
      briefInsight: json['brief_insight'] as String,
    );
  }

  @override
  List<Object?> get props => [date, dayOfWeek, powerNumber, briefInsight];
}

class WeeklyInsightsResponse extends Equatable {
  final String weekStarting;
  final List<DailyPowerPreview> dailyPreviews;

  const WeeklyInsightsResponse({
    required this.weekStarting,
    required this.dailyPreviews,
  });

  factory WeeklyInsightsResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyInsightsResponse(
      weekStarting: json['week_starting'] as String,
      dailyPreviews: (json['daily_previews'] as List<dynamic>)
          .map((e) => DailyPowerPreview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [weekStarting, dailyPreviews];
}

class BlessedDaysResponse extends Equatable {
  final int month;
  final int year;
  final String monthName;
  final List<String> blessedDates;

  const BlessedDaysResponse({
    required this.month,
    required this.year,
    required this.monthName,
    required this.blessedDates,
  });

  factory BlessedDaysResponse.fromJson(Map<String, dynamic> json) {
    return BlessedDaysResponse(
      month: json['month'] as int,
      year: json['year'] as int,
      monthName: json['month_name'] as String,
      blessedDates: (json['blessed_dates'] as List<dynamic>).cast<String>(),
    );
  }

  @override
  List<Object?> get props => [month, year, monthName, blessedDates];
}

class PersonalMonthResponse extends Equatable {
  final int personalMonth;
  final int personalYear;
  final int calendarMonth;
  final int calendarYear;
  final String monthName;
  final String theme;

  const PersonalMonthResponse({
    required this.personalMonth,
    required this.personalYear,
    required this.calendarMonth,
    required this.calendarYear,
    required this.monthName,
    required this.theme,
  });

  factory PersonalMonthResponse.fromJson(Map<String, dynamic> json) {
    return PersonalMonthResponse(
      personalMonth: json['personal_month'] as int,
      personalYear: json['personal_year'] as int,
      calendarMonth: json['calendar_month'] as int,
      calendarYear: json['calendar_year'] as int,
      monthName: json['month_name'] as String,
      theme: json['theme'] as String,
    );
  }

  @override
  List<Object?> get props => [
        personalMonth,
        personalYear,
        calendarMonth,
        calendarYear,
        monthName,
        theme,
      ];
}
