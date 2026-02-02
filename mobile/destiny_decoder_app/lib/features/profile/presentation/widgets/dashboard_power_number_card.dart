/// Dashboard power number card showing today's daily power number
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
// TODO: Import calculator when file is created
// import '../../../calculations/destiny_calculator.dart';

class DashboardPowerNumberCard extends StatelessWidget {
  final int todayPowerNumber;
  final bool isDarkMode;

  const DashboardPowerNumberCard({
    super.key,
    required this.todayPowerNumber,
    required this.isDarkMode,
  });

  String _getThemeForNumber(int number) {
    const themes = {
      1: "Leadership & New Beginnings",
      2: "Harmony & Balance",
      3: "Creativity & Expression",
      4: "Stability & Structure",
      5: "Freedom & Change",
      6: "Love & Service",
      7: "Spiritual Wisdom",
      8: "Abundance & Power",
      9: "Completion & Compassion",
    };
    return themes[number] ?? "Universal Energy";
  }

  String _getActionForNumber(int number) {
    const actions = {
      1: "Take initiative on something new",
      2: "Seek harmony in your relationships",
      3: "Express your creative side",
      4: "Build solid foundations",
      5: "Embrace change and movement",
      6: "Show kindness and care",
      7: "Meditate and reflect deeply",
      8: "Pursue financial opportunities",
      9: "Complete what you've started",
    };
    return actions[number] ?? "Trust the universal flow";
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getPlanetColorForTheme(todayPowerNumber, isDarkMode);
    final theme = _getThemeForNumber(todayPowerNumber);
    final action = _getActionForNumber(todayPowerNumber);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with label and number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Power Number",
                    style: AppTypography.labelMedium.copyWith(
                      color: (isDarkMode ? AppColors.darkText : AppColors.textDark)
                          .withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    theme,
                    style: AppTypography.headingSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Large power number
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(
                    color: color.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    todayPowerNumber.toString(),
                    style: AppTypography.displayMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Action suggestion
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.white : Colors.black)
                  .withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: color.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    action,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.textDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
