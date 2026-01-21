import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_service.dart';
import '../../../core/onboarding/onboarding_service.dart';
import '../../onboarding/presentation/onboarding_page.dart';
import '../../../core/notifications/notification_service.dart';
import '../../debug/deep_link_test_page.dart';
import 'widgets/notification_preferences_widget.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _testingBlessedDay = false;
  bool _testingPersonalYear = false;
  String? _fcmToken;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadFcmToken();
  }

  Future<void> _loadFcmToken() async {
    // Only load FCM token in debug mode for development/testing
    if (!kDebugMode) {
      setState(() {
        _fcmToken = 'Push notifications enabled';
      });
      return;
    }

    try {
      final firebaseService = FirebaseService();
      final token = await firebaseService.getFCMToken();
      setState(() {
        _fcmToken = token ?? 'Firebase not configured';
      });
    } catch (e) {
      setState(() {
        _fcmToken = 'Firebase not configured: $e';
      });
    }
  }

  Future<void> _testBlessedDay() async {
    setState(() => _testingBlessedDay = true);
    try {
      final notificationService = NotificationService();
      await notificationService.showTestBlessedDayNotification();
      setState(() => _message = '✅ Blessed day notification sent!');
    } catch (e) {
      setState(() => _message = '❌ Failed: $e');
    } finally {
      setState(() => _testingBlessedDay = false);
      _clearMessage();
    }
  }

  Future<void> _testPersonalYear() async {
    setState(() => _testingPersonalYear = true);
    try {
      final notificationService = NotificationService();
      await notificationService.showTestPersonalYearNotification();
      setState(() => _message = '✅ Personal year notification sent!');
    } catch (e) {
      setState(() => _message = '❌ Failed: $e');
    } finally {
      setState(() => _testingPersonalYear = false);
      _clearMessage();
    }
  }

  void _clearMessage() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _message = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications section
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show FCM token only in debug mode
                    if (kDebugMode) ...[
                      Text(
                        'FCM Device Token (Debug Only)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _fcmToken == 'Firebase not configured'
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: _fcmToken == 'Firebase not configured'
                              ? Border.all(color: Colors.orange, width: 1)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              _fcmToken ?? 'Loading...',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (_fcmToken == 'Firebase not configured') ...[
                              const SizedBox(height: 8),
                              Text(
                                '⚠️ For development: Ensure google-services.json is in android/app/',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.orange,
                                      fontSize: 11,
                                    ),
                              ),
                            ] else if (_fcmToken != null && _fcmToken != 'Push notifications enabled') ...[
                              const SizedBox(height: 8),
                              Text(
                                '✓ This token is unique to your device. Use for testing notifications.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.green,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      // Production mode: just show status
                      Text(
                        'Push Notifications',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Push notifications are enabled on this device',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Test Notifications',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: (_testingBlessedDay ||
                              (!kDebugMode && _fcmToken == 'Firebase not configured') ||
                              (kDebugMode && _fcmToken == 'Firebase not configured'))
                          ? null
                          : _testBlessedDay,
                      icon: _testingBlessedDay
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.star),
                      label: const Text('Test Blessed Day'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: (_testingPersonalYear ||
                              (!kDebugMode && _fcmToken == 'Firebase not configured') ||
                              (kDebugMode && _fcmToken == 'Firebase not configured'))
                          ? null
                          : _testPersonalYear,
                      icon: _testingPersonalYear
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.cake),
                      label: const Text('Test Personal Year'),
                    ),
                    if (_message.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _message.contains('✅')
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _message,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Onboarding section
            Text(
              'Onboarding',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restart Onboarding',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reset onboarding progress and walk through the setup again. Useful for testing.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              // Reset service state and SharedPreferences flag
                              await ref.read(onboardingStateProvider.notifier).reset();

                              // Navigate to onboarding
                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const OnboardingPage()),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to restart onboarding: $e')),
                              );
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Restart Onboarding'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Notification Preferences Section
            const NotificationPreferencesWidget(),
            
            // Debug tools (only in debug mode)
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              Text(
                'Debug Tools',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Test Deep Links'),
                  subtitle: const Text('Test article deep linking and referral tracking'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DeepLinkTestPage()),
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            // About section
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Version',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '1.0.0',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Destiny Decoder',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock your numerological destiny with personalized daily insights, weekly previews, and blessed day alerts.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
