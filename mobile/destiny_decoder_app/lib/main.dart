import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/firebase/firebase_service.dart';
import 'core/network/api_client_provider.dart';
import 'core/analytics/analytics_service.dart';
import 'core/navigation/main_navigation_page.dart';
import 'core/deep_linking/deep_link_service.dart';
import 'core/screens/splash_screen.dart';
import 'features/onboarding/presentation/onboarding_page.dart';
import 'features/content/presentation/article_reader_page.dart';
import 'features/profile/presentation/providers/profile_providers.dart';
import 'features/profile/presentation/pages/personal_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  // Log app open
  await AnalyticsService.logAppOpen();

  // Initialize Firebase
  try {
    await FirebaseService().initialize();
    if (kDebugMode) {
      print('✅ Firebase initialized successfully');
    }
    
    // Register FCM token with backend
    final firebaseService = FirebaseService();
    final token = await firebaseService.getFCMToken();
    if (token != null) {
      if (kDebugMode) {
        print('📱 FCM Token obtained: $token');
      }
      
      // Register with backend using the API client
      final apiClient = createApiClient();
      final registered = await firebaseService.registerTokenViaApi(
        apiPost: (path, {required data}) => apiClient.post(path, data: data),
      );
      
      if (registered) {
        if (kDebugMode) {
          print('✓ FCM token registered with backend');
        }
        // Log analytics
        await AnalyticsService.logFcmTokenRegistered();
      } else {
        if (kDebugMode) {
          print('⚠️ Failed to register FCM token with backend');
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Firebase initialization failed: $e');
    }
  }

  runApp(
    ProviderScope(
      child: DestinyDecoderApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class DestinyDecoderApp extends ConsumerStatefulWidget {
  final bool hasSeenOnboarding;

  const DestinyDecoderApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  ConsumerState<DestinyDecoderApp> createState() => _DestinyDecoderAppState();
}

class _DestinyDecoderAppState extends ConsumerState<DestinyDecoderApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final _deepLinkService = DeepLinkService();
  bool _splashComplete = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinking();
  }

  Future<void> _initDeepLinking() async {
    _deepLinkService.onLinkReceived = (path, refCode) {
      if (kDebugMode) {
        print('🔗 Handling deep link: $path (ref: $refCode)');
      }

      // Navigate to article if it's an article path
      if (DeepLinkService.isArticlePath(path)) {
        final slug = DeepLinkService.parseArticleSlug(path);
        if (slug != null) {
          _navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => ArticleReaderPage(slug: slug),
            ),
          );
        }
      }
    };

    await _deepLinkService.initialize();
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if profile exists and onboarding is complete
    final hasCompletedOnboarding = ref.watch(userHasCompletedOnboardingProvider);
    
    Widget home;
    if (!_splashComplete) {
      home = SplashScreen(
        onSplashComplete: () {
          setState(() {
            _splashComplete = true;
          });
        },
      );
    } else {
      // Determine home based on profile completion
      if (hasCompletedOnboarding) {
        // Profile exists and onboarding complete → Dashboard
        home = const PersonalDashboardPage();
      } else if (widget.hasSeenOnboarding) {
        // Onboarding seen but no profile → Main navigation (old flow)
        home = const MainNavigationPage();
      } else {
        // Never seen onboarding → Onboarding page
        home = const OnboardingPage();
      }
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Destiny Decoder',
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: ThemeMode.system,
      home: home,
    );
  }
}
