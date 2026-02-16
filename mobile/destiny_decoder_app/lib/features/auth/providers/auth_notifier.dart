import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/auth_service.dart';
import '../../../../core/api/auth_providers.dart';

/// Auth state notifier to manage login/logout state
class AuthStateNotifier extends AsyncNotifier<bool> {
    /// Google Sign-In
    Future<void> signInWithGoogle() async {
      final authService = ref.read(authServiceProvider);
      try {
        await authService.signInWithGoogle();
        state = const AsyncValue.data(true);
      } on AuthException catch (e) {
        throw Exception(e.message);
      }
    }
  @override
  Future<bool> build() async {
    final authService = ref.watch(authServiceProvider);
    return authService.isAuthenticated();
  }

  /// Sign up with email and password
  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
  }) async {
    final authService = ref.read(authServiceProvider);
    
    try {
      await authService.signup(
        email: email,
        password: password,
        firstName: firstName,
      );
      
      // Update state to authenticated on success
      state = const AsyncValue.data(true);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Log in with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final authService = ref.read(authServiceProvider);
    
    try {
      final response = await authService.login(
        email: email,
        password: password,
      );
      
      // Immediately update state to authenticated
      state = const AsyncValue.data(true);
      
      // Verify token was stored
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token storage failed');
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Log out
  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    
    // Update state to not authenticated
    state = const AsyncValue.data(false);
  }
}

/// Provider for auth state
final authStateNotifierProvider = AsyncNotifierProvider<AuthStateNotifier, bool>(
  AuthStateNotifier.new,
);
