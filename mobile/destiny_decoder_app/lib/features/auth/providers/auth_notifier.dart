import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/auth_service.dart';
import '../../../../core/api/auth_providers.dart';

/// Auth state notifier to manage login/logout state
class AuthStateNotifier extends AsyncNotifier<bool> {
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
    final authService = ref.watch(authServiceProvider);
    
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
    final authService = ref.watch(authServiceProvider);
    
    try {
      await authService.login(
        email: email,
        password: password,
      );
      
      // Update state to authenticated on success
      state = const AsyncValue.data(true);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Log out
  Future<void> logout() async {
    final authService = ref.watch(authServiceProvider);
    await authService.logout();
    
    // Update state to not authenticated
    state = const AsyncValue.data(false);
  }
}

/// Provider for auth state
final authStateNotifierProvider = AsyncNotifierProvider<AuthStateNotifier, bool>(
  AuthStateNotifier.new,
);

/// Check if user is authenticated
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(authStateNotifierProvider.future);
});
