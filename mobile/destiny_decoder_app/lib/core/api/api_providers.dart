"""
Riverpod providers for HTTP API client with automatic error handling.
"""

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'api_client.dart';
import 'auth_providers.dart';
import '../config/app_config.dart';


// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  // These callbacks need access to Navigator context
  // They will be set in app initialization
  return ApiClient(
    baseUrl: ApiConfig.baseUrl,
    getToken: () => authService.getToken(),
    onForbidden: () {
      // Will be overridden in app initialization
      print('Feature forbidden - 403');
    },
    onUnauthorized: () {
      // Will be overridden in app initialization
      print('Unauthorized - 401');
    },
  );
});


// Create a global key for navigation
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


// Initialize API client with navigation callbacks
void initializeApiClient(WidgetRef ref) {
  final apiClient = ref.read(apiClientProvider);
  
  // Override the callbacks with actual navigation
  apiClient.onForbidden = () => showPaywall();
  apiClient.onUnauthorized = () => showLogin();
}
