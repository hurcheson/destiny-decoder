import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../models.dart';

class WeeklyPreviewCarousel extends ConsumerWidget {
  final int lifeSeal;
  final String? startDate; // ISO YYYY-MM-DD
  final void Function(DailyPowerPreview)? onSelect;

  const WeeklyPreviewCarousel({
    super.key,
    required this.lifeSeal,
    this.startDate,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(
      weeklyInsightsProvider(WeeklyParams(lifeSeal: lifeSeal, startDate: startDate)),
    );

    return weeklyAsync.when(
      data: (data) {
        final items = data.dailyPreviews;
        if (items.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final d = items[index];
              return _PreviewCard(
                data: d,
                onTap: onSelect == null ? null : () => onSelect!(d),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: items.length,
          ),
        );
      },
      loading: () => const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Failed to load weekly preview',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final DailyPowerPreview data;
  final VoidCallback? onTap;
  const _PreviewCard({required this.data, this.onTap});

  Color _accent(int n) {
    switch (n) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.blueGrey;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.brown.shade400;
      case 5:
        return Colors.blue.shade600;
      case 6:
        return Colors.pink.shade400;
      case 7:
        return Colors.purple.shade500;
      case 8:
        return Colors.amber.shade700;
      case 9:
      default:
        return Colors.deepPurple.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent(data.powerNumber);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accent,
                  child: Text(
                    data.powerNumber.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.dayOfWeek, style: Theme.of(context).textTheme.labelMedium),
                      Text(data.date, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                data.briefInsight,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
