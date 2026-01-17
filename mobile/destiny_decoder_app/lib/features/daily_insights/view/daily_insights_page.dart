import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../widgets/daily_insight_tile.dart';
import '../widgets/weekly_preview_carousel.dart';
import '../widgets/blessed_days_calendar.dart';

class DailyInsightsPage extends ConsumerWidget {
  final int lifeSeal;
  final int dayOfBirth;
  final String? targetDate; // ISO YYYY-MM-DD

  const DailyInsightsPage({
    super.key,
    required this.lifeSeal,
    required this.dayOfBirth,
    this.targetDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = DailyInsightParams(
      lifeSeal: lifeSeal,
      dayOfBirth: dayOfBirth,
      targetDate: targetDate,
    );

    final insightAsync = ref.watch(dailyInsightProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Insights')),
      body: insightAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.refresh(dailyInsightProvider(params).future);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DailyInsightTile(data: data),
              const SizedBox(height: 16),
              Text('Weekly Preview', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              WeeklyPreviewCarousel(
                lifeSeal: lifeSeal,
                onSelect: (preview) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DailyInsightsPage(
                        lifeSeal: lifeSeal,
                        dayOfBirth: dayOfBirth,
                        targetDate: preview.date,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('Blessed Days', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              BlessedDaysCalendar(
                dayOfBirth: dayOfBirth,
                initialMonth: targetDate != null
                    ? DateTime.parse(targetDate!)
                    : DateTime.now(),
                onSelectDate: (selected) {
                  final iso = "${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}";
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DailyInsightsPage(
                        lifeSeal: lifeSeal,
                        dayOfBirth: dayOfBirth,
                        targetDate: iso,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load daily insights',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async => await ref.refresh(dailyInsightProvider(params).future),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
