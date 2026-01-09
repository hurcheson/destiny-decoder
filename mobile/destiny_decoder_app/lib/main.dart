import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/notifications/notification_service.dart';
import 'features/decode/presentation/decode_form_page.dart';
import 'features/onboarding/presentation/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  // Initialize notifications (optional - will fail gracefully if Firebase not configured)
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
  } catch (e) {
    print('⚠️ Firebase not configured - notifications disabled: $e');
  }

  runApp(
    ProviderScope(
      child: DestinyDecoderApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class DestinyDecoderApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const DestinyDecoderApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Destiny Decoder',
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: ThemeMode.system,
      home: hasSeenOnboarding ? const DecodeFormPage() : const OnboardingPage(),
    );
  }
}
