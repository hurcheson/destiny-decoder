/// Profile repository for local and remote profile management
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user_profile.dart';

class ProfileRepository {
  final Dio _dio;
  final SharedPreferencesAsync _prefs;

  static const String _profileCacheKey = 'user_profile_cache_v1';

  ProfileRepository({
    required Dio dio,
    required SharedPreferencesAsync prefs,
  })  : _dio = dio,
        _prefs = prefs;

  /// Create new profile during onboarding
  Future<UserProfile> createProfile({
    required String deviceId,
    required String firstName,
    required String dateOfBirth,
    required String lifeStage,
    required String spiritualPreference,
    required String communicationStyle,
    required List<String> interests,
  }) async {
    try {
      final response = await _dio.post(
        '/profile/create',
        data: {
          'device_id': deviceId,
          'first_name': firstName,
          'date_of_birth': dateOfBirth,
          'life_stage': lifeStage,
          'spiritual_preference': spiritualPreference,
          'communication_style': communicationStyle,
          'interests': interests,
          'notification_style': 'motivational',
        },
      );

      if (response.statusCode == 201) {
        final profile = UserProfile.fromJson(response.data);
        
        // Cache locally
        await _cacheProfile(profile);
        
        return profile;
      } else {
        throw Exception('Failed to create profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error creating profile: $e');
    }
  }

  /// Get current user's profile
  Future<UserProfile?> getProfile({
    required String deviceId,
    bool forceRefresh = false,
  }) async {
    try {
      // Try to get from cache first if not forcing refresh
      if (!forceRefresh) {
        final cached = await _getCachedProfile();
        if (cached != null) {
          return cached;
        }
      }

      // Fetch from API
      final response = await _dio.get(
        '/profile/me',
        queryParameters: {'device_id': deviceId},
      );

      if (response.statusCode == 200) {
        final profile = UserProfile.fromJson(response.data);
        
        // Cache locally
        await _cacheProfile(profile);
        
        return profile;
      } else {
        return null;
      }
    } on DioException catch (e) {
      // If network error, try to return cached version
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        return await _getCachedProfile();
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      // Return cached as fallback
      return await _getCachedProfile();
    }
  }

  /// Update user profile preferences
  Future<UserProfile> updateProfile({
    required String deviceId,
    String? firstName,
    String? lifeStage,
    String? spiritualPreference,
    String? communicationStyle,
    List<String>? interests,
    String? notificationStyle,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lifeStage != null) data['life_stage'] = lifeStage;
      if (spiritualPreference != null) data['spiritual_preference'] = spiritualPreference;
      if (communicationStyle != null) data['communication_style'] = communicationStyle;
      if (interests != null) data['interests'] = interests;
      if (notificationStyle != null) data['notification_style'] = notificationStyle;

      final response = await _dio.put(
        '/profile/me',
        queryParameters: {'device_id': deviceId},
        data: data,
      );

      if (response.statusCode == 200) {
        final profile = UserProfile.fromJson(response.data);
        
        // Cache locally
        await _cacheProfile(profile);
        
        return profile;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  /// Increment readings count after successful decode
  Future<int> incrementReadingsCount({
    required String deviceId,
  }) async {
    try {
      final response = await _dio.post(
        '/profile/me/increment-readings',
        queryParameters: {'device_id': deviceId},
      );

      if (response.statusCode == 200) {
        final readingsCount = response.data['readings_count'] ?? 0;
        
        // Update cache with new count
        final cached = await _getCachedProfile();
        if (cached != null) {
          final updated = cached.copyWith(readingsCount: readingsCount);
          await _cacheProfile(updated);
        }
        
        return readingsCount;
      } else {
        throw Exception('Failed to increment readings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error incrementing readings: $e');
    }
  }

  /// Mark dashboard intro as seen
  Future<void> markDashboardSeen({
    required String deviceId,
  }) async {
    try {
      final response = await _dio.post(
        '/profile/me/mark-dashboard-seen',
        queryParameters: {'device_id': deviceId},
      );

      if (response.statusCode == 200) {
        // Update cache
        final cached = await _getCachedProfile();
        if (cached != null) {
          final updated = cached.copyWith(hasSeenDashboardIntro: true);
          await _cacheProfile(updated);
        }
      }
    } on DioException catch (e) {
      // Fail silently for non-critical operation
      debugPrint('Error marking dashboard seen: ${e.message}');
    } catch (e) {
      // Fail silently
      debugPrint('Error marking dashboard seen: $e');
    }
  }

  /// Cache profile locally
  Future<void> _cacheProfile(UserProfile profile) async {
    try {
      await _prefs.setString(_profileCacheKey, jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('Error caching profile: $e');
    }
  }

  /// Get cached profile
  Future<UserProfile?> _getCachedProfile() async {
    try {
      final cached = await _prefs.getString(_profileCacheKey);
      if (cached != null) {
        final json = jsonDecode(cached);
        return UserProfile.fromJson(json);
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving cached profile: $e');
      return null;
    }
  }

  /// Clear local cache (for logout, testing)
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_profileCacheKey);
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
