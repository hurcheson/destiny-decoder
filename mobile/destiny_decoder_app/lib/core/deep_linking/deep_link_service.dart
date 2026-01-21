import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import '../api/analytics_api_client.dart';

/// Service to handle deep links (shared URLs opening in app)
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  final _analyticsClient = AnalyticsApiClient();
  StreamSubscription<Uri>? _linkSubscription;

  /// Callback when a deep link is received
  /// Returns: (path, refCode)
  Function(String path, String? refCode)? onLinkReceived;

  /// Start listening for deep links
  Future<void> initialize() async {
    // Handle initial link if app was opened from a link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial deep link: $e');
      }
    }

    // Listen for links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        if (kDebugMode) {
          print('Deep link error: $err');
        }
      },
    );
  }

  /// Process incoming deep link
  void _handleDeepLink(Uri uri) {
    if (kDebugMode) {
      print('Deep link received: $uri');
    }

    // Extract path and ref code
    final path = uri.path;
    final refCode = uri.queryParameters['ref'];

    // Track referral click if ref code present
    if (refCode != null && refCode.isNotEmpty) {
      _analyticsClient.recordReferralClick(
        refCode: refCode,
        target: path,
        userAgent: 'mobile_app',
      );
      if (kDebugMode) {
        print('Tracked referral click: ref=$refCode, path=$path');
      }
    }

    // Notify listener to handle navigation
    if (onLinkReceived != null) {
      onLinkReceived!(path, refCode);
    }
  }

  /// Dispose and clean up
  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Parse article slug from path like "/articles/life-seal-7-the-seeker"
  static String? parseArticleSlug(String path) {
    final regex = RegExp(r'^/articles/(.+)$');
    final match = regex.firstMatch(path);
    return match?.group(1);
  }

  /// Check if path is an article deep link
  static bool isArticlePath(String path) {
    return path.startsWith('/articles/');
  }
}
