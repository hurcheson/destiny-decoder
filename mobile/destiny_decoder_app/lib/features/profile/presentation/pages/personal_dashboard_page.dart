/// Personal Dashboard Page
/// Shows user's personalized greeting, today's power number, life seal summary,
/// and quick action buttons.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/daily_insights/view/daily_insights_page.dart';
import '../../../../features/decode/presentation/decode_form_page.dart';
import '../../../../features/history/presentation/history_page.dart';
import '../providers/profile_providers.dart';
import '../widgets/dashboard_welcome_card.dart';
import '../widgets/dashboard_life_seal_card.dart';
import '../widgets/dashboard_power_number_card.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_intro_dialog.dart';

class PersonalDashboardPage extends ConsumerWidget {
  const PersonalDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(userProfileProvider);
    final hasSeenIntro = ref.watch(userHasSeenDashboardIntroProvider);
    final firstName = ref.watch(userFirstNameProvider);
    final lifeSeal = ref.watch(userLifeSealProvider);
    final readingsCount = ref.watch(userReadingsCountProvider);

    // Show intro dialog on first visit
    if (profileAsync.hasValue &&
        profileAsync.value != null &&
        !hasSeenIntro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && firstName.isNotEmpty) {
          showDashboardIntroDialog(
            context,
            firstName: firstName,
            onDismiss: () async {
              await ref
                  .read(profileNotifierProvider.notifier)
                  .markDashboardSeen();
            },
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Destiny'),
        elevation: 0,
        centerTitle: false,
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            // Profile not found - return to onboarding
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Profile not found',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/onboarding');
                    },
                    child: const Text('Complete Onboarding'),
                  ),
                ],
              ),
            );
          }

          // Intro dialog is shown above via WidgetsBinding callback

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                DashboardWelcomeCard(
                  firstName: profile.firstName,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Life Seal summary
                if (lifeSeal != null) ...[
                  DashboardLifeSealCard(
                    lifeSeal: lifeSeal,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Today's Power Number (will be fetched separately)
                if (profile.lifeSeal != null) ...[
                  // Calculate today's power number from date
                  _DashboardPowerNumberWidget(
                    dateOfBirth: profile.dateOfBirth,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Stats section
                _buildStatsRow(context, readingsCount, isDarkMode),
                const SizedBox(height: AppSpacing.xl),

                // Quick action buttons
                DashboardQuickActions(
                  onNewReading: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DecodeFormPage()),
                    );
                  },
                  onDailyInsights: () {
                    if (profile.lifeSeal != null) {
                      final parts = profile.dateOfBirth.split('-');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DailyInsightsPage(
                            lifeSeal: profile.lifeSeal!,
                            dayOfBirth: int.parse(parts[2]),
                            monthOfBirth: int.parse(parts[1]),
                            yearOfBirth: int.parse(parts[0]),
                          ),
                        ),
                      );
                    }
                  },
                  onViewHistory: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Inspirational message
                _buildInspirationSection(context, profile.firstName, isDarkMode),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading profile',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userProfileProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build stats row showing readings and engagement
  Widget _buildStatsRow(BuildContext context, int readingsCount, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.analytics_outlined,
            label: 'Total Readings',
            value: readingsCount.toString(),
            color: AppColors.primary,
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_outline,
            label: 'Engaged',
            value: 'Yes',
            color: AppColors.accent,
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  /// Build inspirational/motivational section
  Widget _buildInspirationSection(
    BuildContext context,
    String firstName,
    bool isDarkMode,
  ) {
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;
    final bgColor = isDarkMode
        ? AppColors.primary.withValues(alpha: 0.1)
        : AppColors.primary.withValues(alpha: 0.05);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.accent),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your Journey Awaits',
            style: AppTypography.headingSmall.copyWith(
              color: textColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$firstName, numerology reveals the unique gifts and challenges that make you who you are. Each number tells a story of your purpose and potential.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: textColor.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDarkMode;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode
        ? color.withValues(alpha: 0.1)
        : color.withValues(alpha: 0.05);
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headingSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: textColor.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Helper widget to calculate and display today's power number
class _DashboardPowerNumberWidget extends StatelessWidget {
  final String dateOfBirth;
  final bool isDarkMode;

  const _DashboardPowerNumberWidget({
    required this.dateOfBirth,
    required this.isDarkMode,
  });

  int _calculateTodayPowerNumber() {
    final now = DateTime.now();
    final parts = dateOfBirth.split('-');
    final day = int.parse(parts[2]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[0]);

    // Calculate personal year
    int personalYear = (year + now.year - year + now.year) % 9;
    if (personalYear == 0) personalYear = 9;

    // Calculate today's power number: day + month + personal year + today's date
    int sum = day + month + personalYear + now.day + now.month;
    while (sum > 9) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final powerNumber = _calculateTodayPowerNumber();
    return DashboardPowerNumberCard(
      todayPowerNumber: powerNumber,
      isDarkMode: isDarkMode,
    );
  }
}
