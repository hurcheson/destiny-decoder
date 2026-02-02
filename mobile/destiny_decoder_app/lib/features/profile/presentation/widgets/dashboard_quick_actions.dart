/// Dashboard quick action buttons for main features
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardQuickActions extends StatelessWidget {
  final VoidCallback onNewReading;
  final VoidCallback onDailyInsights;
  final VoidCallback onViewHistory;

  const DashboardQuickActions({
    super.key,
    required this.onNewReading,
    required this.onDailyInsights,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: AppTypography.headingSmall.copyWith(
            color: isDarkMode ? AppColors.darkText : AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.auto_awesome,
                label: "New Reading",
                color: AppColors.primary,
                isDarkMode: isDarkMode,
                onTap: onNewReading,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.sunny,
                label: "Daily Insights",
                color: AppColors.accent,
                isDarkMode: isDarkMode,
                onTap: onDailyInsights,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.history,
                label: "View History",
                color: AppColors.accent,
                isDarkMode: isDarkMode,
                onTap: onViewHistory,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.color.withValues(alpha: 0.12),
              widget.color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: widget.color.withValues(alpha: _isPressed ? 0.5 : 0.25),
            width: 1.5,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: widget.color,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: widget.isDarkMode
                    ? AppColors.darkText
                    : AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
