import 'package:flutter/material.dart';
import '../models.dart';

class DailyInsightTile extends StatelessWidget {
  final DailyInsightResponse data;

  const DailyInsightTile({super.key, required this.data});


  @override
  Widget build(BuildContext context) {
    final accent = () {
      switch (data.powerNumber) {
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
    }();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accent,
                  child: Text(
                    data.powerNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data.dayOfWeek} • ${data.date}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        data.insight.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (data.isBlessedDay)
                  const Icon(Icons.auto_awesome, color: Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data.briefInsight,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.insight.actionFocus
                  .map((a) => Chip(label: Text(a)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
