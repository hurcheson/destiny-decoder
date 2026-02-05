/// User profile domain model
/// Contains personalization preferences and user identity
library;

import 'package:equatable/equatable.dart';

/// User's current life stage for context-aware interpretations
enum LifeStage {
  twenties,    // 18-29
  thirties,    // 30-39
  forties,     // 40-49
  fiftiesPlus, // 50+
  unknown;     // User hasn't specified

  String toBackend() {
    switch (this) {
      case LifeStage.twenties:
        return 'twenties';
      case LifeStage.thirties:
        return 'thirties';
      case LifeStage.forties:
        return 'forties';
      case LifeStage.fiftiesPlus:
        return 'fifties+';
      case LifeStage.unknown:
        return 'unknown';
    }
  }

  static LifeStage fromString(String value) {
    switch (value) {
      case 'twenties':
        return LifeStage.twenties;
      case 'thirties':
        return LifeStage.thirties;
      case 'forties':
        return LifeStage.forties;
      case 'fifties+':
        return LifeStage.fiftiesPlus;
      default:
        return LifeStage.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case LifeStage.twenties:
        return "20s";
      case LifeStage.thirties:
        return "30s";
      case LifeStage.forties:
        return "40s";
      case LifeStage.fiftiesPlus:
        return "50+";
      case LifeStage.unknown:
        return "Prefer not to say";
    }
  }
}

/// User's preferred spiritual/religious lens for interpretations
enum SpiritualPreference {
  christian,      // Include Bible verses, Christian context
  universal,      // Non-denominational, spiritual but universal
  practical,      // Focus on psychology and practical wisdom
  custom,         // User will curate their mix
  notSpecified;

  String toBackend() {
    switch (this) {
      case SpiritualPreference.christian:
        return 'christian';
      case SpiritualPreference.universal:
        return 'universal';
      case SpiritualPreference.practical:
        return 'practical';
      case SpiritualPreference.custom:
        return 'custom';
      case SpiritualPreference.notSpecified:
        return 'not_specified';
    }
  }

  static SpiritualPreference fromString(String value) {
    switch (value) {
      case 'christian':
        return SpiritualPreference.christian;
      case 'universal':
        return SpiritualPreference.universal;
      case 'practical':
        return SpiritualPreference.practical;
      case 'custom':
        return SpiritualPreference.custom;
      default:
        return SpiritualPreference.notSpecified;
    }
  }

  String get displayName {
    switch (this) {
      case SpiritualPreference.christian:
        return "Christian";
      case SpiritualPreference.universal:
        return "Universal/Spiritual";
      case SpiritualPreference.practical:
        return "Practical/Secular";
      case SpiritualPreference.custom:
        return "Custom Mix";
      case SpiritualPreference.notSpecified:
        return "Not Specified";
    }
  }
}

/// User's preferred interpretation style
enum CommunicationStyle {
  spiritual,      // Emphasis on spiritual growth and divine meaning
  practical,      // Focus on actionable advice and real-world application
  balanced,       // Mix of both spiritual and practical
  notSpecified;

  String toBackend() {
    switch (this) {
      case CommunicationStyle.spiritual:
        return 'spiritual';
      case CommunicationStyle.practical:
        return 'practical';
      case CommunicationStyle.balanced:
        return 'balanced';
      case CommunicationStyle.notSpecified:
        return 'not_specified';
    }
  }

  static CommunicationStyle fromString(String value) {
    switch (value) {
      case 'spiritual':
        return CommunicationStyle.spiritual;
      case 'practical':
        return CommunicationStyle.practical;
      case 'balanced':
        return CommunicationStyle.balanced;
      default:
        return CommunicationStyle.notSpecified;
    }
  }

  String get displayName {
    switch (this) {
      case CommunicationStyle.spiritual:
        return "Spiritual Guidance";
      case CommunicationStyle.practical:
        return "Practical Advice";
      case CommunicationStyle.balanced:
        return "Balanced Approach";
      case CommunicationStyle.notSpecified:
        return "Not Specified";
    }
  }
}

/// User profile containing personalization preferences
class UserProfile extends Equatable {
  final String id;
  final String deviceId;
  final String firstName;
  final String dateOfBirth; // YYYY-MM-DD
  final int? lifeSeal;
  final LifeStage lifeStage;
  final SpiritualPreference spiritualPreference;
  final CommunicationStyle communicationStyle;
  final List<String> interests; // ["career", "relationships", "spirituality", "personal_growth"]
  final String notificationStyle; // motivational, informational, minimal
  final int readingsCount;
  final DateTime? lastReadingDate;
  final int pdfExportsCount;
  final String? pdfExportsMonth;
  final bool hasCompletedOnboarding;
  final bool hasSeenDashboardIntro;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.deviceId,
    required this.firstName,
    required this.dateOfBirth,
    this.lifeSeal,
    this.lifeStage = LifeStage.unknown,
    this.spiritualPreference = SpiritualPreference.notSpecified,
    this.communicationStyle = CommunicationStyle.notSpecified,
    this.interests = const [],
    this.notificationStyle = 'motivational',
    this.readingsCount = 0,
    this.lastReadingDate,
    this.pdfExportsCount = 0,
    this.pdfExportsMonth,
    this.hasCompletedOnboarding = false,
    this.hasSeenDashboardIntro = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? deviceId,
    String? firstName,
    String? dateOfBirth,
    int? lifeSeal,
    LifeStage? lifeStage,
    SpiritualPreference? spiritualPreference,
    CommunicationStyle? communicationStyle,
    List<String>? interests,
    String? notificationStyle,
    int? readingsCount,
    DateTime? lastReadingDate,
    int? pdfExportsCount,
    String? pdfExportsMonth,
    bool? hasCompletedOnboarding,
    bool? hasSeenDashboardIntro,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      firstName: firstName ?? this.firstName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      lifeSeal: lifeSeal ?? this.lifeSeal,
      lifeStage: lifeStage ?? this.lifeStage,
      spiritualPreference: spiritualPreference ?? this.spiritualPreference,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      interests: interests ?? this.interests,
      notificationStyle: notificationStyle ?? this.notificationStyle,
      readingsCount: readingsCount ?? this.readingsCount,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      pdfExportsCount: pdfExportsCount ?? this.pdfExportsCount,
      pdfExportsMonth: pdfExportsMonth ?? this.pdfExportsMonth,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      hasSeenDashboardIntro: hasSeenDashboardIntro ?? this.hasSeenDashboardIntro,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'first_name': firstName,
      'date_of_birth': dateOfBirth,
      'life_seal': lifeSeal,
      'life_stage': lifeStage.toBackend(),
      'spiritual_preference': spiritualPreference.toBackend(),
      'communication_style': communicationStyle.toBackend(),
      'interests': interests,
      'notification_style': notificationStyle,
      'readings_count': readingsCount,
      'last_reading_date': lastReadingDate?.toIso8601String(),
      'pdf_exports_count': pdfExportsCount,
      'pdf_exports_month': pdfExportsMonth,
      'has_completed_onboarding': hasCompletedOnboarding,
      'has_seen_dashboard_intro': hasSeenDashboardIntro,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      deviceId: json['device_id'] ?? '',
      firstName: json['first_name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      lifeSeal: json['life_seal'],
      lifeStage: LifeStage.fromString(json['life_stage'] ?? 'unknown'),
      spiritualPreference: SpiritualPreference.fromString(json['spiritual_preference'] ?? 'not_specified'),
      communicationStyle: CommunicationStyle.fromString(json['communication_style'] ?? 'not_specified'),
      interests: List<String>.from(json['interests'] ?? []),
      notificationStyle: json['notification_style'] ?? 'motivational',
      readingsCount: json['readings_count'] ?? 0,
      lastReadingDate: json['last_reading_date'] != null
          ? DateTime.parse(json['last_reading_date'])
          : null,
      pdfExportsCount: json['pdf_exports_count'] ?? 0,
      pdfExportsMonth: json['pdf_exports_month'],
      hasCompletedOnboarding: json['has_completed_onboarding'] ?? false,
      hasSeenDashboardIntro: json['has_seen_dashboard_intro'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    firstName,
    dateOfBirth,
    lifeSeal,
    lifeStage,
    spiritualPreference,
    communicationStyle,
    interests,
    notificationStyle,
    readingsCount,
    lastReadingDate,
    pdfExportsCount,
    pdfExportsMonth,
    hasCompletedOnboarding,
    hasSeenDashboardIntro,
    createdAt,
    updatedAt,
  ];
}
