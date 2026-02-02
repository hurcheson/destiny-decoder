/// Dashboard welcome card showing personalized greeting
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardWelcomeCard extends StatelessWidget {
  final String firstName;
  final bool isDarkMode;

  const DashboardWelcomeCard({
    super.key,
    required this.firstName,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = isDarkMode
        ? [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.primary.withValues(alpha: 0.1),
          ]
        : [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryLight.withValues(alpha: 0.05),
          ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $firstName! 🌙',
            style: AppTypography.headingMedium.copyWith(
              color: isDarkMode ? AppColors.darkText : AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ready to explore your destiny today?',
            style: AppTypography.bodyMedium.copyWith(
              color: (isDarkMode ? AppColors.darkText : AppColors.textDark)
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
