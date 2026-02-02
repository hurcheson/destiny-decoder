/// Dashboard life seal card showing user's core life path number
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
// TODO: Import interpretations when file is created
// import '../../../interpretations/life_seal_interpretations.dart';

class DashboardLifeSealCard extends StatelessWidget {
  final int lifeSeal;
  final bool isDarkMode;

  const DashboardLifeSealCard({
    super.key,
    required this.lifeSeal,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary; // Simplified for now
    // TODO: Restore when LIFE_SEAL_INTERPRETATIONS available
    // final interpretation = LIFE_SEAL_INTERPRETATIONS[lifeSeal];
    final title = 'Life Seal $lifeSeal';
    final summary = 'Your life path number';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Life Seal number circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                lifeSeal.toString(),
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Life Seal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Life Seal',
                  style: AppTypography.labelMedium.copyWith(
                    color: (isDarkMode ? AppColors.darkText : AppColors.textDark)
                        .withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  title,
                  style: AppTypography.headingSmall.copyWith(
                    color: isDarkMode ? AppColors.darkText : AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  summary,
                  style: AppTypography.bodySmall.copyWith(
                    color: (isDarkMode ? AppColors.darkText : AppColors.textDark)
                        .withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
