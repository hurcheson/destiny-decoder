import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notifications/notification_service.dart';

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
    final notificationService = NotificationService();
    final token = await notificationService.getDeviceToken();
    setState(() {
      _fcmToken = token ?? 'No token available';
    });
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
                    Text(
                      'FCM Device Token',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _fcmToken ?? 'Loading...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Test Notifications',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _testingBlessedDay ? null : _testBlessedDay,
                      icon: _testingBlessedDay
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.star),
                      label: const Text('Test Blessed Day Alert'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed:
                          _testingPersonalYear ? null : _testPersonalYear,
                      icon: _testingPersonalYear
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.cake),
                      label: const Text('Test Personal Year Alert'),
                    ),
                    if (_message.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _message.startsWith('✅')
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          border: Border.all(
                            color: _message.startsWith('✅')
                                ? Colors.green
                                : Colors.red,
                          ),
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
                      'Destiny Decoder 🔮',
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
