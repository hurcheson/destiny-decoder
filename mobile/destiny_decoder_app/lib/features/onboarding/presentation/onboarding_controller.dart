import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends StateNotifier<bool> {
  OnboardingController(this._prefs) : super(_prefs?.getBool('has_seen_onboarding') ?? false);

  final SharedPreferences? _prefs;

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await _prefs?.setBool('has_seen_onboarding', true);
    state = true;
  }

  /// Reset onboarding (useful for testing)
  Future<void> resetOnboarding() async {
    await _prefs?.setBool('has_seen_onboarding', false);
    state = false;
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, bool>((ref) {
  // In a real app, you'd initialize SharedPreferences here
  // For now, we'll use a workaround in the app
  return OnboardingController(null);
});

/// Provider to check if onboarding has been seen
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('has_seen_onboarding') ?? false;
});
