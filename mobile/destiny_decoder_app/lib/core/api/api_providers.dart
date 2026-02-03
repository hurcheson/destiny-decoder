// Riverpod providers for HTTP API client with automatic error handling.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'api_client.dart';
import 'auth_providers.dart';
import '../config/app_config.dart';

// Global navigator key for routing
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Helper to show paywall
void showPaywall({String? fromFeature}) {
  navigatorKey.currentState?.pushNamed(
    '/paywall',
    arguments: {'fromFeature': fromFeature},
  );
}

// Helper to show login
void showLogin() {
  navigatorKey.currentState?.pushNamed('/login');
}

// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final authService = ref.watch(authServiceProvider);

  final apiClient = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    getToken: () => authService.getToken(),
    onForbidden: showPaywall,
    onUnauthorized: showLogin,
  );
  
  return apiClient;
});
