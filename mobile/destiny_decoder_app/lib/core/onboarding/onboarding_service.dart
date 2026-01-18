import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Model for onboarding state
class OnboardingState {
  final int currentStep; // 0-6 for 7 steps
  final bool completed;
  final int? birthDay;
  final int? birthMonth;
  final int? birthYear;
  final String? calculatedLifeSeal;
  final bool permissionsRequested;
  final List<int> skippedSteps;
  final DateTime startedAt;

  OnboardingState({
    this.currentStep = 0,
    this.completed = false,
    this.birthDay,
    this.birthMonth,
    this.birthYear,
    this.calculatedLifeSeal,
    this.permissionsRequested = false,
    this.skippedSteps = const [],
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  /// Create a copy with modified fields
  OnboardingState copyWith({
    int? currentStep,
    bool? completed,
    int? birthDay,
    int? birthMonth,
    int? birthYear,
    String? calculatedLifeSeal,
    bool? permissionsRequested,
    List<int>? skippedSteps,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      completed: completed ?? this.completed,
      birthDay: birthDay ?? this.birthDay,
      birthMonth: birthMonth ?? this.birthMonth,
      birthYear: birthYear ?? this.birthYear,
      calculatedLifeSeal: calculatedLifeSeal ?? this.calculatedLifeSeal,
      permissionsRequested: permissionsRequested ?? this.permissionsRequested,
      skippedSteps: skippedSteps ?? this.skippedSteps,
      startedAt: startedAt,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
        'currentStep': currentStep,
        'completed': completed,
        'birthDay': birthDay,
        'birthMonth': birthMonth,
        'birthYear': birthYear,
        'calculatedLifeSeal': calculatedLifeSeal,
        'permissionsRequested': permissionsRequested,
        'skippedSteps': skippedSteps,
        'startedAt': startedAt.toIso8601String(),
      };

  /// Create from JSON
  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      currentStep: json['currentStep'] ?? 0,
      completed: json['completed'] ?? false,
      birthDay: json['birthDay'],
      birthMonth: json['birthMonth'],
      birthYear: json['birthYear'],
      calculatedLifeSeal: json['calculatedLifeSeal'],
      permissionsRequested: json['permissionsRequested'] ?? false,
      skippedSteps: List<int>.from(json['skippedSteps'] ?? []),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : DateTime.now(),
    );
  }
}

/// Service to manage onboarding flow
class OnboardingService {
  static const String _storageKey = 'onboarding_state';
  late SharedPreferences _prefs;
  OnboardingState _state = OnboardingState();

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadState();
  }

  /// Load state from persistent storage
  Future<void> _loadState() async {
    try {
      final jsonString = _prefs.getString(_storageKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        _state = OnboardingState.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading onboarding state: $e');
      _state = OnboardingState();
    }
  }

  /// Save state to persistent storage
  Future<void> _saveState() async {
    try {
      await _prefs.setString(_storageKey, jsonEncode(_state.toJson()));
    } catch (e) {
      debugPrint('Error saving onboarding state: $e');
    }
  }

  /// Get current state
  OnboardingState getState() => _state;

  /// Move to next step
  Future<void> nextStep() async {
    if (_state.currentStep < 6) {
      _state = _state.copyWith(currentStep: _state.currentStep + 1);
      await _saveState();
    }
  }

  /// Move to previous step
  Future<void> previousStep() async {
    if (_state.currentStep > 0) {
      _state = _state.copyWith(currentStep: _state.currentStep - 1);
      await _saveState();
    }
  }

  /// Skip current step
  Future<void> skipStep() async {
    final updated = List<int>.from(_state.skippedSteps);
    if (!updated.contains(_state.currentStep)) {
      updated.add(_state.currentStep);
    }
    _state = _state.copyWith(skippedSteps: updated);
    if (_state.currentStep < 6) {
      await nextStep();
    }
  }

  /// Jump to specific step
  Future<void> jumpToStep(int step) async {
    if (step >= 0 && step <= 6) {
      _state = _state.copyWith(currentStep: step);
      await _saveState();
    }
  }

  /// Update birth date
  Future<void> setBirthDate(int day, int month, int year) async {
    _state = _state.copyWith(
      birthDay: day,
      birthMonth: month,
      birthYear: year,
    );
    await _saveState();
  }

  /// Set calculated life seal
  Future<void> setCalculatedLifeSeal(String lifeSeal) async {
    _state = _state.copyWith(calculatedLifeSeal: lifeSeal);
    await _saveState();
  }

  /// Mark permissions as requested
  Future<void> setPermissionsRequested(bool requested) async {
    _state = _state.copyWith(permissionsRequested: requested);
    await _saveState();
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    _state = _state.copyWith(completed: true, currentStep: 6);
    await _saveState();
    // Also set the legacy flag used by main.dart for routing
    try {
      await _prefs.setBool('has_seen_onboarding', true);
    } catch (e) {
      debugPrint('Error setting has_seen_onboarding flag: $e');
    }
  }

  /// Reset onboarding (for debugging or restart)
  Future<void> reset() async {
    _state = OnboardingState();
    await _prefs.remove(_storageKey);
  }

  /// Check if onboarding is complete
  bool isComplete() => _state.completed;

  /// Get time spent on onboarding
  Duration getTimeSpent() => DateTime.now().difference(_state.startedAt);
}

/// Riverpod provider for onboarding service
final onboardingServiceProvider =
    FutureProvider<OnboardingService>((ref) async {
  final service = OnboardingService();
  await service.initialize();
  return service;
});

/// Riverpod provider for onboarding state
final onboardingStateProvider =
    StateNotifierProvider<OnboardingStateNotifier, OnboardingState>((ref) {
  return OnboardingStateNotifier(ref);
});

/// State notifier for managing onboarding state
class OnboardingStateNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;
  OnboardingService? _service;
  bool _isInitialized = false;

  OnboardingStateNotifier(this._ref) : super(OnboardingState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _service = await _ref.read(onboardingServiceProvider.future);
      _isInitialized = true;
      state = _service!.getState();
    } catch (e) {
      debugPrint('Error initializing onboarding: $e');
      _isInitialized = true; // Set to true even on error to prevent hanging
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initialize();
    }
  }

  Future<void> nextStep() async {
    await _ensureInitialized();
    if (_service != null) {
      await _service!.nextStep();
      state = _service!.getState();
    }
  }

  Future<void> previousStep() async {
    await _ensureInitialized();
    if (_service != null) {
      await _service!.previousStep();
      state = _service!.getState();
    }
  }

  Future<void> skipStep() async {
    await _ensureInitialized();
    if (_service != null) {
      await _service!.skipStep();
      state = _service!.getState();
    }
  }

  Future<void> jumpToStep(int step) async {
    await _ensureInitialized();
    if (_service != null) {
      await _service!.jumpToStep(step);
      state = _service!.getState();
    }
  }

  Future<void> setBirthDate(int day, int month, int year) async {
    await _ensureInitialized();
    if (_service != null) {
      await _service!.setBirthDate(day, month, year);
      state = _service!.getState();
    }
  }

  Future<void> setCalculatedLifeSeal(String lifeSeal) async {
    await _ensureInitialized();
    if (_service != null) {
      await _service!.setCalculatedLifeSeal(lifeSeal);
      state = _service!.getState();
    }
  }

  Future<void> setPermissionsRequested(bool requested) async {
    await _ensureInitialized();
    if (_service != null) {
      await _service!.setPermissionsRequested(requested);
      state = _service!.getState();
    }
  }

  Future<void> completeOnboarding() async {
    await _ensureInitialized();
    if (_service != null) {
      await _service!.completeOnboarding();
      state = _service!.getState();
    }
  }

  Future<void> reset() async {
    await _ensureInitialized();
    if (_service != null) {
      await _service!.reset();
      state = OnboardingState();
    }
  }

  bool isComplete() {
    return _service?.isComplete() ?? false;
  }

  Duration getTimeSpent() {
    return _service?.getTimeSpent() ?? Duration.zero;
  }
}
