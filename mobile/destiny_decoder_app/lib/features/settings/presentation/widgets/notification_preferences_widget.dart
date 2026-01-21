import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:destiny_decoder_app/core/notifications/notification_preferences_service.dart';

/// Provider for notification preferences
final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
  NotificationPreferencesNotifier.new,
);

class NotificationPreferences {
  final bool blessedDayAlerts;
  final bool dailyInsights;
  final bool lunarPhaseAlerts;
  final bool motivationalQuotes;
  final bool quietHoursEnabled;
  final String quietHoursStart; // HH:MM format
  final String quietHoursEnd;   // HH:MM format
  final bool isLoading;
  final String? error;

  NotificationPreferences({
    this.blessedDayAlerts = true,
    this.dailyInsights = true,
    this.lunarPhaseAlerts = false,
    this.motivationalQuotes = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '06:00',
    this.isLoading = false,
    this.error,
  });

  NotificationPreferences copyWith({
    bool? blessedDayAlerts,
    bool? dailyInsights,
    bool? lunarPhaseAlerts,
    bool? motivationalQuotes,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? isLoading,
    String? error,
  }) {
    return NotificationPreferences(
      blessedDayAlerts: blessedDayAlerts ?? this.blessedDayAlerts,
      dailyInsights: dailyInsights ?? this.dailyInsights,
      lunarPhaseAlerts: lunarPhaseAlerts ?? this.lunarPhaseAlerts,
      motivationalQuotes: motivationalQuotes ?? this.motivationalQuotes,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationPreferencesNotifier extends Notifier<NotificationPreferences> {
  @override
  NotificationPreferences build() => NotificationPreferences();

  Future<void> loadPreferences() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = NotificationPreferencesService();
      final prefs = await service.getPreferences();
      state = NotificationPreferences(
        blessedDayAlerts: prefs['blessed_day_alerts'] ?? true,
        dailyInsights: prefs['daily_insights'] ?? true,
        lunarPhaseAlerts: prefs['lunar_phase_alerts'] ?? false,
        motivationalQuotes: prefs['motivational_quotes'] ?? true,
        quietHoursEnabled: prefs['quiet_hours_enabled'] ?? false,
        quietHoursStart: prefs['quiet_hours_start'] ?? '22:00',
        quietHoursEnd: prefs['quiet_hours_end'] ?? '06:00',
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to load preferences: $e');
    }
  }

  Future<void> updateBlessedDayAlerts(bool value) async {
    state = state.copyWith(blessedDayAlerts: value);
    await _savePreferences();
  }

  Future<void> updateDailyInsights(bool value) async {
    state = state.copyWith(dailyInsights: value);
    await _savePreferences();
  }

  Future<void> updateLunarPhaseAlerts(bool value) async {
    state = state.copyWith(lunarPhaseAlerts: value);
    await _savePreferences();
  }

  Future<void> updateMotivationalQuotes(bool value) async {
    state = state.copyWith(motivationalQuotes: value);
    await _savePreferences();
  }

  Future<void> updateQuietHours({
    bool? enabled,
    String? start,
    String? end,
  }) async {
    state = state.copyWith(
      quietHoursEnabled: enabled ?? state.quietHoursEnabled,
      quietHoursStart: start ?? state.quietHoursStart,
      quietHoursEnd: end ?? state.quietHoursEnd,
    );
    await _savePreferences();
  }

  Future<void> _savePreferences() async {
    try {
      final service = NotificationPreferencesService();
      await service.savePreferences(
        blessedDayAlerts: state.blessedDayAlerts,
        dailyInsights: state.dailyInsights,
        lunarPhaseAlerts: state.lunarPhaseAlerts,
        motivationalQuotes: state.motivationalQuotes,
        quietHoursEnabled: state.quietHoursEnabled,
        quietHoursStart: state.quietHoursStart,
        quietHoursEnd: state.quietHoursEnd,
      );
      state = state.copyWith(error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save preferences: $e');
    }
  }
}

class NotificationPreferencesWidget extends ConsumerStatefulWidget {
  const NotificationPreferencesWidget({super.key});

  @override
  ConsumerState<NotificationPreferencesWidget> createState() =>
      _NotificationPreferencesWidgetState();
}

class _NotificationPreferencesWidgetState
    extends ConsumerState<NotificationPreferencesWidget> {
  @override
  void initState() {
    super.initState();
    // Load preferences when widget initializes
    Future.microtask(
      () => ref.read(notificationPreferencesProvider.notifier).loadPreferences(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Notification Types Section
            Text(
              'Notification Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            // Blessed Day Alerts Toggle
            _buildNotificationToggle(
              context: context,
              isDark: isDark,
              icon: Icons.star.toString(),
              title: 'Blessed Days',
              subtitle: 'Get notified on your blessed dates',
              value: prefs.blessedDayAlerts,
              onChanged: (value) =>
                  notifier.updateBlessedDayAlerts(value),
            ),

            // Daily Insights Toggle
            _buildNotificationToggle(
              context: context,
              isDark: isDark,
              icon: Icons.menu_book.toString(),
              title: 'Daily Insights',
              subtitle: 'Receive your daily numerology reading',
              value: prefs.dailyInsights,
              onChanged: (value) =>
                  notifier.updateDailyInsights(value),
            ),

            // Lunar Phase Alerts Toggle
            _buildNotificationToggle(
              context: context,
              isDark: isDark,
              icon: Icons.nights_stay.toString(),
              title: 'Lunar Phase Updates',
              subtitle: 'Stay informed about lunar cycles',
              value: prefs.lunarPhaseAlerts,
              onChanged: (value) =>
                  notifier.updateLunarPhaseAlerts(value),
            ),

            // Motivational Quotes Toggle
            _buildNotificationToggle(
              context: context,
              isDark: isDark,
              icon: Icons.auto_awesome.toString(),
              title: 'Motivational Quotes',
              subtitle: 'Daily inspiration and encouragement',
              value: prefs.motivationalQuotes,
              onChanged: (value) =>
                  notifier.updateMotivationalQuotes(value),
            ),

            const SizedBox(height: 32),

            // Quiet Hours Section
            Text(
              'Quiet Hours',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            // Quiet Hours Toggle
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark
                    ? Colors.grey[900]?.withValues(alpha: 0.5)
                    : Colors.grey[100],
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.nights_stay, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Quiet Hours',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pause notifications during selected hours',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: prefs.quietHoursEnabled,
                    onChanged: (value) => notifier.updateQuietHours(
                      enabled: value,
                    ),
                    activeThumbColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),

            if (prefs.quietHoursEnabled) ...[
              const SizedBox(height: 16),

              // Start Time Picker
              _buildTimePickerRow(
                context: context,
                isDark: isDark,
                label: 'From',
                time: prefs.quietHoursStart,
                onChanged: (newTime) => notifier.updateQuietHours(
                  start: newTime,
                ),
              ),

              const SizedBox(height: 12),

              // End Time Picker
              _buildTimePickerRow(
                context: context,
                isDark: isDark,
                label: 'To',
                time: prefs.quietHoursEnd,
                onChanged: (newTime) => notifier.updateQuietHours(
                  end: newTime,
                ),
              ),

              const SizedBox(height: 12),

              // Info Box
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Notifications are paused between ${prefs.quietHoursStart} and ${prefs.quietHoursEnd}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue[700],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Error Message
            if (prefs.error != null) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        prefs.error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red[700],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle({
    required BuildContext context,
    required bool isDark,
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark
            ? Colors.grey[900]?.withValues(alpha: 0.5)
            : Colors.grey[100],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerRow({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String time,
    required ValueChanged<String> onChanged,
  }) {
    return InkWell(
      onTap: () => _showTimePicker(context, time, onChanged),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark
              ? Colors.grey[900]?.withValues(alpha: 0.5)
              : Colors.grey[100],
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              child: Text(
                time,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    String currentTime,
    ValueChanged<String> onChanged,
  ) async {
    final parts = currentTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );

    if (time != null) {
      final formattedTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      onChanged(formattedTime);
    }
  }
}
