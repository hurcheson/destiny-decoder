import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../compatibility/presentation/compatibility_controller.dart';
import '../../compatibility/presentation/compatibility_result_page.dart';
import '../../decode/presentation/decode_controller.dart';
import '../../decode/presentation/decode_result_page.dart';
import '../domain/history_entry.dart';
import 'history_controller.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final controller = ref.read(historyControllerProvider.notifier);
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkText
        : AppColors.textDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            onPressed: state.valueOrNull?.isNotEmpty == true
                ? () => _confirmClear(context, controller)
                : null,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: state.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Text(
                'No saved readings yet',
                style: AppTypography.bodyMedium.copyWith(color: textColor),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _HistoryCard(
                  entry: entry,
                  onDelete: () => controller.delete(entry.id),
                  onTap: () {
                    if (entry.type == EntryType.decode && entry.decodeResult != null) {
                      ref.read(decodeControllerProvider.notifier).setResult(entry.decodeResult!);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DecodeResultPage(),
                        ),
                      );
                    } else if (entry.type == EntryType.compatibility && entry.compatibilityResult != null) {
                      ref.read(compatibilityControllerProvider.notifier)
                          .setResult(entry.compatibilityResult!);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CompatibilityResultPage(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: AppTypography.bodyMedium.copyWith(color: Colors.red),
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, HistoryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This will remove all saved readings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.clear();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entry,
    required this.onDelete,
    required this.onTap,
  });

  final HistoryEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;
    final savedDate = entry.savedAt;

    // Handle different entry types
    if (entry.type == EntryType.compatibility && entry.compatibilityResult != null) {
      final compat = entry.compatibilityResult!;
      return Card(
        elevation: AppElevation.sm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: Colors.pink.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.pink,
                      child: Icon(Icons.favorite, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${compat.personA.input.fullName} & ${compat.personB.input.fullName}',
                            style: AppTypography.headingSmall.copyWith(color: textColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Compatibility: ${compat.compatibility.overall}',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Saved ${savedDate.toLocal()}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Decode entry - should not be null if we got here due to filtering
    if (entry.decodeResult == null) {
      return const SizedBox.shrink();
    }
    
    final result = entry.decodeResult!;
    final lifeSealNumber = result.lifeSeal.number;
    final personalYear = result.personalYear.number;

    return Card(
      elevation: AppElevation.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: AppColors.getPlanetColorBorder(lifeSealNumber),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      AppColors.getPlanetColorForTheme(lifeSealNumber, isDarkMode),
                  child: Text(
                    lifeSealNumber.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.input.fullName,
                        style: AppTypography.headingSmall.copyWith(color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'DOB: ${result.input.dateOfBirth} · PY: $personalYear',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Saved ${savedDate.toLocal()}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
