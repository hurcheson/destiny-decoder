import 'package:flutter_test/flutter_test.dart';
import 'package:destiny_decoder_app/features/daily_insights/models.dart';

void main() {
  test('DailyInsightResponse fromJson', () {
    final json = {
      'date': '2026-01-09',
      'day_of_week': 'Friday',
      'power_number': 9,
      'is_blessed_day': true,
      'insight': {
        'title': 'Day of Completion',
        'energy': 'Release & Compassion',
        'insight': 'Today is for letting go...',
        'action_focus': [
          'Forgive someone (including yourself)',
          "Complete or close something that's been dragging",
          'Let go of an attachment, habit, or grudge'
        ],
        'spiritual_guidance': 'Practice surrender without resignation.',
        'energy_color': 'Soft Lavender',
        'affirmation': 'I release with love.',
        'caution': "Don't confuse letting go with giving up."
      },
      'brief_insight': 'Release what no longer serves.'
    };

    final resp = DailyInsightResponse.fromJson(json);

    expect(resp.date, '2026-01-09');
    expect(resp.dayOfWeek, 'Friday');
    expect(resp.powerNumber, 9);
    expect(resp.isBlessedDay, true);
    expect(resp.briefInsight, 'Release what no longer serves.');
    expect(resp.insight.title, 'Day of Completion');
    expect(resp.insight.actionFocus.length, 3);
  });

  test('WeeklyInsightsResponse fromJson', () {
    final json = {
      'week_starting': '2026-01-09',
      'daily_previews': [
        {
          'date': '2026-01-09',
          'day_of_week': 'Friday',
          'power_number': 9,
          'brief_insight': 'Release.'
        },
        {
          'date': '2026-01-10',
          'day_of_week': 'Saturday',
          'power_number': 1,
          'brief_insight': 'Lead.'
        }
      ]
    };

    final resp = WeeklyInsightsResponse.fromJson(json);
    expect(resp.weekStarting, '2026-01-09');
    expect(resp.dailyPreviews.length, 2);
    expect(resp.dailyPreviews.first.powerNumber, 9);
  });

  test('BlessedDaysResponse fromJson', () {
    final json = {
      'month': 1,
      'year': 2026,
      'month_name': 'January',
      'blessed_dates': ['2026-01-09', '2026-01-18', '2026-01-27']
    };

    final resp = BlessedDaysResponse.fromJson(json);
    expect(resp.month, 1);
    expect(resp.year, 2026);
    expect(resp.monthName, 'January');
    expect(resp.blessedDates.length, 3);
  });

  test('PersonalMonthResponse fromJson', () {
    final json = {
      'personal_month': 7,
      'personal_year': 6,
      'calendar_month': 1,
      'calendar_year': 2026,
      'month_name': 'January',
      'theme': 'Introspection and spiritual growth'
    };

    final resp = PersonalMonthResponse.fromJson(json);
    expect(resp.personalMonth, 7);
    expect(resp.personalYear, 6);
    expect(resp.monthName, 'January');
    expect(resp.theme, isNotEmpty);
  });
}
