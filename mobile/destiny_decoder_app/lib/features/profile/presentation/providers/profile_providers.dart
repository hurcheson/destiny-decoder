/// Profile state management with Riverpod
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/api/auth_providers.dart';
import '../../data/profile_repository.dart';
import '../../domain/user_profile.dart';

// Device ID provider - generates/retrieves unique device identifier
final deviceIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  var deviceId = prefs.getString('device_id');
  
  if (deviceId == null) {
    deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('device_id', deviceId);
  }
  
  return deviceId;
});

// Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = SharedPreferencesAsync();
  return ProfileRepository(dio: dio, prefs: prefs);
});

// Dio provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: '${AppConfig.apiBaseUrl}/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  return dio;
});

// Current user profile provider - loads and caches profile data
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final deviceIdAsync = await ref.watch(deviceIdProvider.future);
  final userId = await ref.watch(userIdProvider.future);
  
  return repository.getProfile(deviceId: deviceIdAsync, userId: userId);
});

// Notifier for profile operations (Riverpod 3.x)
class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);
  Future<String> get _deviceId => ref.read(deviceIdProvider.future);
  Future<String?> get _userId => ref.read(userIdProvider.future);

  @override
  Future<UserProfile?> build() async {
    // Load initial profile
    final deviceId = await _deviceId;
    final userId = await _userId;
    return _repository.getProfile(deviceId: deviceId, userId: userId);
  }

  /// Create new profile during onboarding
  Future<UserProfile> createProfile({
    required String firstName,
    required String dateOfBirth,
    required LifeStage lifeStage,
    required SpiritualPreference spiritualPreference,
    required CommunicationStyle communicationStyle,
    required List<String> interests,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final deviceId = await _deviceId;
      final userId = await _userId;
      final profile = await _repository.createProfile(
        deviceId: deviceId,
        userId: userId,
        firstName: firstName,
        dateOfBirth: dateOfBirth,
        lifeStage: lifeStage.toBackend(),
        spiritualPreference: spiritualPreference.toBackend(),
        communicationStyle: communicationStyle.toBackend(),
        interests: interests,
      );
      
      state = AsyncValue.data(profile);
      return profile;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Refresh profile from API
  Future<UserProfile?> refreshProfile() async {
    state = const AsyncValue.loading();
    
    try {
      final deviceId = await _deviceId;
      final userId = await _userId;
      final profile = await _repository.getProfile(
        deviceId: deviceId,
        userId: userId,
        forceRefresh: true,
      );
      
      state = AsyncValue.data(profile);
      return profile;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update profile preferences
  Future<UserProfile> updateProfile({
    String? firstName,
    LifeStage? lifeStage,
    SpiritualPreference? spiritualPreference,
    CommunicationStyle? communicationStyle,
    List<String>? interests,
    String? notificationStyle,
  }) async {
    try {
      final deviceId = await _deviceId;
      final userId = await _userId;
      final profile = await _repository.updateProfile(
        deviceId: deviceId,
        userId: userId,
        firstName: firstName,
        lifeStage: lifeStage?.toBackend(),
        spiritualPreference: spiritualPreference?.toBackend(),
        communicationStyle: communicationStyle?.toBackend(),
        interests: interests,
        notificationStyle: notificationStyle,
      );
      
      state = AsyncValue.data(profile);
      return profile;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Increment readings count after decode
  Future<void> incrementReadings() async {
    try {
      final deviceId = await _deviceId;
      final userId = await _userId;
      await _repository.incrementReadingsCount(deviceId: deviceId, userId: userId);
      
      // Refresh profile to get updated count
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(
          current.copyWith(readingsCount: current.readingsCount + 1),
        );
      }
    } catch (e) {
      debugPrint('Error incrementing readings: $e');
      // Don't fail the whole operation for this non-critical update
    }
  }

  /// Increment monthly PDF export count
  Future<void> incrementPdfExports() async {
    try {
      final deviceId = await _deviceId;
      final userId = await _userId;
      final count = await _repository.incrementPdfExportsCount(deviceId: deviceId, userId: userId);

      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(
          current.copyWith(
            pdfExportsCount: count,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error incrementing PDF exports: $e');
    }
  }

  /// Mark dashboard intro as seen
  Future<void> markDashboardSeen() async {
    try {
      final deviceId = await _deviceId;
      final userId = await _userId;
      await _repository.markDashboardSeen(deviceId: deviceId, userId: userId);
      
      // Update local state
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(
          current.copyWith(hasSeenDashboardIntro: true),
        );
      }
    } catch (e) {
      debugPrint('Error marking dashboard seen: $e');
      // Don't fail for this non-critical operation
    }
  }
}

// Profile notifier provider (Riverpod 3.x)
final profileNotifierProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);

// Convenience selectors
final userFirstNameProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(profileNotifierProvider);
  return profileAsync.when(
    data: (profile) => profile?.firstName ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
});

final userLifeSealProvider = Provider<int?>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.lifeSeal,
    loading: () => null,
    error: (_, __) => null,
  );
});

final userLifeStageProvider = Provider<LifeStage>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.lifeStage ?? LifeStage.unknown,
    loading: () => LifeStage.unknown,
    error: (_, __) => LifeStage.unknown,
  );
});

final userSpirituaiPreferenceProvider = Provider<SpiritualPreference>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.spiritualPreference ?? SpiritualPreference.notSpecified,
    loading: () => SpiritualPreference.notSpecified,
    error: (_, __) => SpiritualPreference.notSpecified,
  );
});

final userReadingsCountProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(profileNotifierProvider);
  return profileAsync.when(
    data: (profile) => profile?.readingsCount ?? 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final userPdfExportsCountProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.pdfExportsCount ?? 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final userHasCompletedOnboardingProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.hasCompletedOnboarding ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

final userHasSeenDashboardIntroProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(profileNotifierProvider);
  return profileAsync.when(
    data: (profile) => profile?.hasSeenDashboardIntro ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});
