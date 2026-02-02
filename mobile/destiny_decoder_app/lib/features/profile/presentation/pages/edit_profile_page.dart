/// Edit profile page - allows users to modify their preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/user_profile.dart';
import '../providers/profile_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Form fields
  LifeStage? _selectedLifeStage;
  SpiritualPreference? _selectedSpiritualPreference;
  CommunicationStyle? _selectedCommunicationStyle;
  List<String> _selectedInterests = [];
  String? _notificationStyle;

  final List<String> _availableInterests = [
    'Numerology',
    'Astrology',
    'Spirituality',
    'Self-improvement',
    'Meditation',
    'Tarot',
    'Dream interpretation',
    'Energy healing',
    'Manifestation',
    'Personal growth',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentProfile();
    });
  }

  void _loadCurrentProfile() {
    final profileAsync = ref.read(userProfileProvider);
    if (profileAsync.hasValue && profileAsync.value != null) {
      final profile = profileAsync.value!;
      setState(() {
        _selectedLifeStage = profile.lifeStage;
        _selectedSpiritualPreference = profile.spiritualPreference;
        _selectedCommunicationStyle = profile.communicationStyle;
        _selectedInterests = List.from(profile.interests);
        _notificationStyle = profile.notificationStyle;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(profileNotifierProvider.notifier).updateProfile(
            lifeStage: _selectedLifeStage,
            spiritualPreference: _selectedSpiritualPreference,
            communicationStyle: _selectedCommunicationStyle,
            interests: _selectedInterests,
            notificationStyle: _notificationStyle,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Life Stage
              _buildSectionHeader('Life Stage', isDarkMode),
              const SizedBox(height: AppSpacing.md),
              _buildLifeStageSelector(isDarkMode),
              const SizedBox(height: AppSpacing.xl),

              // Spiritual Preference
              _buildSectionHeader('Spiritual Preference', isDarkMode),
              const SizedBox(height: AppSpacing.md),
              _buildSpiritualPreferenceSelector(isDarkMode),
              const SizedBox(height: AppSpacing.xl),

              // Communication Style
              _buildSectionHeader('Communication Style', isDarkMode),
              const SizedBox(height: AppSpacing.md),
              _buildCommunicationStyleSelector(isDarkMode),
              const SizedBox(height: AppSpacing.xl),

              // Interests
              _buildSectionHeader('Interests', isDarkMode),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Select topics you\'re interested in:',
                style: AppTypography.bodySmall.copyWith(
                  color: (isDarkMode ? AppColors.darkText : AppColors.textDark)
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInterestsSelector(isDarkMode),
              const SizedBox(height: AppSpacing.xl),

              // Notification Style
              _buildSectionHeader('Notification Style', isDarkMode),
              const SizedBox(height: AppSpacing.md),
              _buildNotificationStyleSelector(isDarkMode),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
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

  Widget _buildLifeStageSelector(bool isDarkMode) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: LifeStage.values
          .where((stage) => stage != LifeStage.unknown)
          .map((stage) {
        final isSelected = _selectedLifeStage == stage;
        return _buildChoiceChip(
          label: stage.displayName,
          isSelected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedLifeStage = selected ? stage : null;
            });
          },
          isDarkMode: isDarkMode,
        );
      }).toList(),
    );
  }

  Widget _buildSpiritualPreferenceSelector(bool isDarkMode) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: SpiritualPreference.values
          .where((pref) => pref != SpiritualPreference.notSpecified)
          .map((pref) {
        final isSelected = _selectedSpiritualPreference == pref;
        return _buildChoiceChip(
          label: pref.displayName,
          isSelected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedSpiritualPreference = selected ? pref : null;
            });
          },
          isDarkMode: isDarkMode,
        );
      }).toList(),
    );
  }

  Widget _buildCommunicationStyleSelector(bool isDarkMode) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: CommunicationStyle.values
          .where((style) => style != CommunicationStyle.notSpecified)
          .map((style) {
        final isSelected = _selectedCommunicationStyle == style;
        return _buildChoiceChip(
          label: style.displayName,
          isSelected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCommunicationStyle = selected ? style : null;
            });
          },
          isDarkMode: isDarkMode,
        );
      }).toList(),
    );
  }

  Widget _buildInterestsSelector(bool isDarkMode) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _availableInterests.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return _buildChoiceChip(
          label: interest,
          isSelected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedInterests.add(interest);
              } else {
                _selectedInterests.remove(interest);
              }
            });
          },
          isDarkMode: isDarkMode,
        );
      }).toList(),
    );
  }

  Widget _buildNotificationStyleSelector(bool isDarkMode) {
    const styles = ['motivational', 'informative', 'minimal'];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: styles.map((style) {
        final isSelected = _notificationStyle == style;
        return _buildChoiceChip(
          label: style[0].toUpperCase() + style.substring(1),
          isSelected: isSelected,
          onSelected: (selected) {
            setState(() {
              _notificationStyle = selected ? style : null;
            });
          },
          isDarkMode: isDarkMode,
        );
      }).toList(),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    required bool isDarkMode,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      backgroundColor: isDarkMode
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.03),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.2),
        width: 1.5,
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: isSelected
            ? AppColors.primary
            : (isDarkMode ? AppColors.darkText : AppColors.textDark),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
