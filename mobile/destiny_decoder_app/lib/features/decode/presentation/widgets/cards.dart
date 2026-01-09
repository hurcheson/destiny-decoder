import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Hero card for displaying Life Seal number prominently
class HeroNumberCard extends StatelessWidget {
  final int number;
  final String label;
  final String subtitle;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;

  const HeroNumberCard({
    super.key,
    required this.number,
    required this.label,
    this.subtitle = '',
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? AppColors.getPlanetColorForTheme(number, isDarkMode);
    final txtColor = textColor ?? Colors.white; // Always white for max contrast

    return Card(
      elevation: AppElevation.lg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              bgColor.withValues(alpha: 0.90),
            ],
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              '✨ $label ✨',
              textAlign: TextAlign.center,
              style: AppTypography.labelLarge.copyWith(
                color: txtColor, // Pure white for maximum clarity
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              number.toString(),
              textAlign: TextAlign.center,
              style: AppTypography.displayLarge.copyWith(
                color: txtColor,
                fontSize: 72,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.headingSmall.copyWith(
                color: txtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Number card for core numbers grid
class NumberCard extends StatelessWidget {
  final int number;
  final String label;
  final String? description;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const NumberCard({
    super.key,
    required this.number,
    required this.label,
    this.description,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? AppColors.getPlanetColorForTheme(number, isDarkMode);
    final lightBg = bgColor.withValues(alpha: isDarkMode ? 0.15 : 0.08);
    final borderColor = bgColor.withValues(alpha: isDarkMode ? 0.35 : 0.25);
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: AppElevation.md,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            color: lightBg,
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number.toString(),
                style: AppTypography.displayMedium.copyWith(
                  color: bgColor,
                  fontSize: 48,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Section card for grouping related content
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? accentColor;
  final VoidCallback? onTap;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = accentColor ?? (isDarkMode ? AppColors.primaryLight : AppColors.primary);
    final headerBg = color.withValues(alpha: isDarkMode ? 0.12 : 0.06);
    final borderColor = color.withValues(alpha: isDarkMode ? 0.35 : 0.25);

    return Card(
      elevation: AppElevation.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored header with better contrast
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
              border: Border(
                bottom: BorderSide(
                  color: borderColor,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              title,
              style: AppTypography.headingSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Stat/metric card for displaying key values
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: cardColor.withValues(alpha: 0.1),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTypography.headingLarge.copyWith(
                    color: cardColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Gradient background container
class GradientContainer extends StatelessWidget {
  final Widget child;
  final Color? startColor;
  final Color? endColor;

  const GradientContainer({
    super.key,
    required this.child,
    this.startColor,
    this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            startColor ?? AppColors.primary.withValues(alpha: 0.05),
            endColor ?? AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Planet symbol helper
class PlanetSymbol extends StatelessWidget {
  final int number;
  final double size;
  final Color? color;

  const PlanetSymbol({
    super.key,
    required this.number,
    this.size = 32,
    this.color,
  });

  String _getSymbol(int num) {
    switch (num) {
      case 1:
        return '☉'; // Sun
      case 2:
        return '☽'; // Moon
      case 3:
        return '♃'; // Jupiter
      case 4:
        return '♅'; // Uranus
      case 5:
        return '☿'; // Mercury
      case 6:
        return '♀'; // Venus
      case 7:
        return '♆'; // Neptune
      case 8:
        return '♄'; // Saturn
      case 9:
        return '♂'; // Mars
      default:
        return '✧';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _getSymbol(number),
      style: TextStyle(
        fontSize: size,
        color: color ?? AppColors.getPlanetColor(number),
      ),
    );
  }
}
