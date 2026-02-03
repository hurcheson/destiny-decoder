import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for user profile data
class UserProfile {
  final String deviceId;
  final String firstName;
  final DateTime dateOfBirth;
  final DateTime createdAt;

  UserProfile({
    required this.deviceId,
    required this.firstName,
    required this.dateOfBirth,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      deviceId: json['device_id'] ?? '',
      firstName: json['first_name'] ?? '',
      dateOfBirth: DateTime.parse(json['date_of_birth'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'first_name': firstName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Provider to get current user profile (cached)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  // TODO: Implement actual profile fetching from backend or local storage
  return null;
});

/// Provider to refresh user profile
final refreshUserProfileProvider = FutureProvider<void>((ref) async {
  // Invalidate the cache to force a refresh
  ref.invalidate(userProfileProvider);
});
