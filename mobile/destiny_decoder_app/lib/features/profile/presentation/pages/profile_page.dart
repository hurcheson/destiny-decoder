/// Profile page - view-only display of user profile and preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/user_profile.dart';
import '../providers/profile_providers.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfilePage(),
                ),
              );
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return _buildNoProfile(context);
          }
          return _buildProfileContent(context, profile, isDarkMode);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error, ref),
      ),
    );
  }

  Widget _buildNoProfile(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 64, color: Colors.grey),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No profile found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
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

  Widget _buildError(BuildContext context, Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Error loading profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(userProfileProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserProfile profile,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          _buildProfileHeader(context, profile, isDarkMode),
          const SizedBox(height: AppSpacing.xxl),

          // Personal Information section
          _buildSectionHeader('Personal Information', isDarkMode),
          const SizedBox(height: AppSpacing.md),
          _buildInfoCard(
            context,
            'Name',
            profile.firstName,
            Icons.person,
            isDarkMode,
          ),
          _buildInfoCard(
            context,
            'Date of Birth',
            _formatDate(profile.dateOfBirth),
            Icons.cake,
            isDarkMode,
          ),
          if (profile.lifeSeal != null)
            _buildInfoCard(
              context,
              'Life Seal',
              profile.lifeSeal.toString(),
              Icons.favorite,
              isDarkMode,
            ),
          const SizedBox(height: AppSpacing.xl),

          // Preferences section
          _buildSectionHeader('Preferences', isDarkMode),
          const SizedBox(height: AppSpacing.md),
          _buildInfoCard(
            context,
            'Life Stage',
            profile.lifeStage.displayName,
            Icons.timeline,
            isDarkMode,
          ),
          _buildInfoCard(
            context,
            'Spiritual Preference',
            profile.spiritualPreference.displayName,
            Icons.auto_awesome,
            isDarkMode,
          ),
          _buildInfoCard(
            context,
            'Communication Style',
            profile.communicationStyle.displayName,
            Icons.chat_bubble_outline,
            isDarkMode,
          ),
          if (profile.interests.isNotEmpty)
            _buildInfoCard(
              context,
              'Interests',
              profile.interests.join(', '),
              Icons.interests,
              isDarkMode,
            ),
          const SizedBox(height: AppSpacing.xl),

          // Activity Stats section
          _buildSectionHeader('Activity Stats', isDarkMode),
          const SizedBox(height: AppSpacing.md),
          _buildStatsRow(context, profile, isDarkMode),
          const SizedBox(height: AppSpacing.xl),

          // Settings section
          _buildSectionHeader('Settings', isDarkMode),
          const SizedBox(height: AppSpacing.md),
          _buildInfoCard(
            context,
            'Notification Style',
            profile.notificationStyle,
            Icons.notifications_outlined,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserProfile profile,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.accent.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Avatar circle with initials
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile.firstName.isNotEmpty
                    ? profile.firstName[0].toUpperCase()
                    : '?',
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Name and member since
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.firstName,
                  style: AppTypography.headingLarge.copyWith(
                    color: isDarkMode ? AppColors.darkText : AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Member since ${_formatDate(profile.createdAt.toString().split(' ')[0])}',
                  style: AppTypography.bodySmall.copyWith(
                    color: (isDarkMode ? AppColors.darkText : AppColors.textDark)
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Text(
      title,
      style: AppTypography.headingMedium.copyWith(
        color: isDarkMode ? AppColors.darkText : AppColors.textDark,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: (isDarkMode ? Colors.white : Colors.black)
              .withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: (isDarkMode ? AppColors.darkText : AppColors.textDark)
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDarkMode ? AppColors.darkText : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    UserProfile profile,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Readings',
            profile.readingsCount.toString(),
            Icons.analytics_outlined,
            AppColors.primary,
            isDarkMode,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            'Last Reading',
            profile.lastReadingDate != null
                ? _formatDate(profile.lastReadingDate!.toIso8601String().split('T')[0])
                : 'Never',
            Icons.calendar_today,
            AppColors.accent,
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.sm),
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
              color: (isDarkMode ? AppColors.darkText : AppColors.textDark)
                  .withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
