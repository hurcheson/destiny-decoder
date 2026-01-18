import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../daily_insights/models.dart';
import '../daily_insights/providers.dart';

class PersonalMonthGuidanceCard extends ConsumerWidget {
  final int dayOfBirth;
  final int monthOfBirth;
  final int yearOfBirth;

  const PersonalMonthGuidanceCard({
    super.key,
    required this.dayOfBirth,
    required this.monthOfBirth,
    required this.yearOfBirth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = PersonalMonthParams(
      dayOfBirth: dayOfBirth,
      monthOfBirth: monthOfBirth,
      yearOfBirth: yearOfBirth,
    );

    final personalMonthAsync = ref.watch(personalMonthProvider(params));

    return personalMonthAsync.when(
      data: (data) => _buildCard(context, data),
      loading: () => _buildSkeleton(context),
      error: (err, st) => _buildError(context, err),
    );
  }

  Widget _buildCard(BuildContext context, PersonalMonthResponse data) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    // Color based on personal month (1-9)
    final colorMap = {
      1: Colors.red.shade100,
      2: Colors.orange.shade100,
      3: Colors.yellow.shade100,
      4: Colors.green.shade100,
      5: Colors.teal.shade100,
      6: Colors.blue.shade100,
      7: Colors.indigo.shade100,
      8: Colors.purple.shade100,
      9: Colors.pink.shade100,
    };
    
    final accentColorMap = {
      1: Colors.red,
      2: Colors.orange,
      3: Colors.yellow.shade700,
      4: Colors.green,
      5: Colors.teal,
      6: Colors.blue,
      7: Colors.indigo,
      8: Colors.purple,
      9: Colors.pink,
    };

    final bgColor = colorMap[data.personalMonth] ?? Colors.grey.shade100;
    final accentColor = accentColorMap[data.personalMonth] ?? Colors.grey;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? theme.cardColor : bgColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with month info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Month',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.textTheme.labelMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.monthName} ${data.calendarYear}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                // Large number badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.personalMonth.toString(),
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Personal',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Personal year info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Personal Year',
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.personalYear.toString(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.dividerColor,
                  ),
                  Column(
                    children: [
                      Text(
                        'Calendar Month',
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.calendarMonth.toString(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Theme/Guidance text
            Text(
              'Monthly Theme',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.theme,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Actionable guidance based on month
            _buildMonthGuidance(context, data.personalMonth, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGuidance(
    BuildContext context,
    int monthNumber,
    ThemeData theme,
  ) {
    final guidanceMap = {
      1: '✨ Focus on starting new projects and taking initiative. Leadership opportunities abound.',
      2: '🤝 This is a month for cooperation and partnership. Nurture your relationships.',
      3: '🎨 Creative expression is enhanced. Share your talents with others.',
      4: '🏗️ Build solid foundations. Organization and structure bring results.',
      5: '🚀 Embrace change and new experiences. Flexibility is your strength.',
      6: '❤️ Service and family matters take center stage. Balance giving with self-care.',
      7: '🧘 A time for reflection and inner wisdom. Trust your intuition.',
      8: '💪 Manifest your ambitions. This is your power month for material progress.',
      9: '🌙 Release what no longer serves. Completion precedes new beginnings.',
    };

    final guidance = guidanceMap[monthNumber] ?? 'Trust your journey this month.';

    return Container(
      padding: const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        border: Border(
          left: BorderSide(
            color: Colors.blue.shade400,
            width: 3,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        guidance,
        style: theme.textTheme.bodySmall?.copyWith(
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 160,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Could not load monthly guidance',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Check your connection and try again',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
