import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/domain/user_profile.dart' as domain;
import '../../features/profile/presentation/providers/profile_providers.dart'
    as profile_providers;

typedef UserProfile = domain.UserProfile;

/// Provider to get current user profile (cached)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  return ref.watch(profile_providers.userProfileProvider.future);
});

/// Provider to refresh user profile
final refreshUserProfileProvider = FutureProvider<void>((ref) async {
  ref.invalidate(profile_providers.userProfileProvider);
  ref.invalidate(userProfileProvider);
});
