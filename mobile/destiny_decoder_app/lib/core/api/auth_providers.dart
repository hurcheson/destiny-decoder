// Riverpod providers for Firebase authentication state management.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

// Auth service provider (using Firebase)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(firebaseAuth: FirebaseAuth.instance);
});

// Check if user is authenticated (async)
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated();
});

// Get current user token
final userTokenProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getToken();
});

// Get current user ID
final userIdProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getUserId();
});

// Get current user email
final userEmailProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getEmail();
});

// Get subscription tier
final subscriptionTierProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getSubscriptionTier();
});

// Auth state notifier
class AuthStateNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final authService = ref.watch(authServiceProvider);
    
    // Check if already logged in
    final isAuth = await authService.isAuthenticated();
    
    if (isAuth) {
      // Verify token is still valid
      final isValid = await authService.verifyToken();
      return isValid;
    }
    
    return false;
  }

  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signup(
        email: email,
        password: password,
        firstName: firstName,
      );
      
      state = const AsyncValue.data(true);
      
      // Invalidate cached providers
      ref.invalidate(userTokenProvider);
      ref.invalidate(userIdProvider);
      ref.invalidate(userEmailProvider);
      ref.invalidate(subscriptionTierProvider);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final authService = ref.read(authServiceProvider);
      await authService.login(
        email: email,
        password: password,
      );
      
      state = const AsyncValue.data(true);
      
      // Invalidate cached providers
      ref.invalidate(userTokenProvider);
      ref.invalidate(userIdProvider);
      ref.invalidate(userEmailProvider);
      ref.invalidate(subscriptionTierProvider);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
      state = const AsyncValue.data(false);
      
      // Clear all user data
      ref.invalidate(userTokenProvider);
      ref.invalidate(userIdProvider);
      ref.invalidate(userEmailProvider);
      ref.invalidate(subscriptionTierProvider);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final authStateProvider = AsyncNotifierProvider<AuthStateNotifier, bool>(
  () => AuthStateNotifier(),
);
