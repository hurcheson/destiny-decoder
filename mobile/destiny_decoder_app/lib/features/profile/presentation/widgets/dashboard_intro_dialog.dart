/// Dashboard introduction dialog shown on first visit
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

Future<void> showDashboardIntroDialog(
  BuildContext context, {
  required String firstName,
  required VoidCallback onDismiss,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (BuildContext context) {
      return DashboardIntroDialog(
        firstName: firstName,
        onDismiss: onDismiss,
      );
    },
  );
}

class DashboardIntroDialog extends StatefulWidget {
  final String firstName;
  final VoidCallback onDismiss;

  const DashboardIntroDialog({
    super.key,
    required this.firstName,
    required this.onDismiss,
  });

  @override
  State<DashboardIntroDialog> createState() => _DashboardIntroDialogState();
}

class _DashboardIntroDialogState extends State<DashboardIntroDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AlertDialog(
          backgroundColor:
              isDarkMode ? AppColors.darkBackground : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient background
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.8),
                        AppColors.accent.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      topRight: Radius.circular(AppRadius.lg),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Text(
                        '✨ Welcome to Your Dashboard',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${widget.firstName}!',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureItem(
                        icon: '🌙',
                        title: 'Your Personal Space',
                        description:
                            'This is your personalized dashboard with your life seal and daily insights.',
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        icon: '✨',
                        title: 'Quick Actions',
                        description:
                            'Use the quick action buttons to get new readings and daily guidance.',
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        icon: '📊',
                        title: 'Your Progress',
                        description:
                            'Track your readings and see how your journey evolves over time.',
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'You can view and edit your profile anytime in Settings.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDarkMode
                                      ? AppColors.darkText
                                      : AppColors.textDark,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDismiss();
              },
              child: Text(
                'Get Started',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: isDarkMode ? AppColors.darkText : AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: (isDarkMode ? AppColors.darkText : AppColors.textDark)
                      .withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
