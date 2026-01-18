import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:destiny_decoder_app/core/onboarding/onboarding_service.dart';
import 'package:destiny_decoder_app/core/analytics/analytics_service.dart';

/// Step 0: Welcome to Destiny Decoder
class WelcomeStep extends ConsumerWidget {
  final VoidCallback onNext;

  const WelcomeStep({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Large welcome icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: const Icon(
                Icons.stars,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Welcome to\nDestiny Decoder',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'Discover your unique numerological profile and unlock personalized daily guidance based on your life numbers.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 60),
            // Feature highlights
            _buildFeatureHighlight(
              context,
              icon: Icons.calculate,
              title: 'Life Number Calculation',
              description: 'Get your personal numerological profile',
            ),
            const SizedBox(height: 16),
            _buildFeatureHighlight(
              context,
              icon: Icons.calendar_today,
              title: 'Daily Insights',
              description: 'Personalized guidance every single day',
            ),
            const SizedBox(height: 16),
            _buildFeatureHighlight(
              context,
              icon: Icons.notifications_active,
              title: 'Smart Notifications',
              description: 'Stay connected with your cosmic timing',
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlight(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 1: Enter Birth Information
class BirthInfoStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onPrevious;

  const BirthInfoStep({
    Key? key,
    required this.onNext,
    required this.onSkip,
    required this.onPrevious,
  }) : super(key: key);

  @override
  ConsumerState<BirthInfoStep> createState() => _BirthInfoStepState();
}

class _BirthInfoStepState extends ConsumerState<BirthInfoStep> {
  late TextEditingController _dayController;
  late TextEditingController _monthController;
  late TextEditingController _yearController;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingStateProvider);
    _dayController = TextEditingController(
      text: state.birthDay?.toString() ?? '',
    );
    _monthController = TextEditingController(
      text: state.birthMonth?.toString() ?? '',
    );
    _yearController = TextEditingController(
      text: state.birthYear?.toString() ?? '',
    );
    _validateInput();
    _dayController.addListener(_validateInput);
    _monthController.addListener(_validateInput);
    _yearController.addListener(_validateInput);
  }

  void _validateInput() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);

    final isValid = day != null &&
        day > 0 &&
        day <= 31 &&
        month != null &&
        month > 0 &&
        month <= 12 &&
        year != null &&
        year >= 1900 &&
        year <= DateTime.now().year;

    setState(() => _isValid = isValid);
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_isValid) {
      ref.read(onboardingStateProvider.notifier).setBirthDate(
            int.parse(_dayController.text),
            int.parse(_monthController.text),
            int.parse(_yearController.text),
          );
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'When Were You Born?',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your birth date is the foundation of your numerological profile.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 48),
            // Date input fields
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    controller: _dayController,
                    label: 'Day',
                    hint: 'DD',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    controller: _monthController,
                    label: 'Month',
                    hint: 'MM',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    controller: _yearController,
                    label: 'Year',
                    hint: 'YYYY',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _handleNext : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onSkip,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Skip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: label == 'Year' ? 4 : 2,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Step 2: Calculate Life Seal
class CalculateStep extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onPrevious;

  const CalculateStep({
    Key? key,
    required this.onNext,
    required this.onSkip,
    required this.onPrevious,
  }) : super(key: key);

  String _calculateLifeSeal(int day, int month, int year) {
    // Numerology calculation: reduce birth date to single digit
    int sum = day + month + year;
    while (sum >= 10) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return sum.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);

    if (state.birthDay == null ||
        state.birthMonth == null ||
        state.birthYear == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Please enter your birth date first',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: onPrevious,
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    final lifeSeal = _calculateLifeSeal(
      state.birthDay!,
      state.birthMonth!,
      state.birthYear!,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Your Life Seal',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your unique numerological essence',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 60),
            // Large life seal display
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  lifeSeal,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Born: ${state.birthDay}/${state.birthMonth}/${state.birthYear}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Life Seal is $lifeSeal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(onboardingStateProvider.notifier)
                      .setCalculatedLifeSeal(lifeSeal);
                  onNext();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSkip,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Skip'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 3: Life Seal Display & Info
class LifeSealDisplayStep extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onPrevious;

  const LifeSealDisplayStep({
    Key? key,
    required this.onNext,
    required this.onSkip,
    required this.onPrevious,
  }) : super(key: key);

  String _getLifeSealMeaning(String lifeSeal) {
    const meanings = {
      '1':
          'Leadership & Independence - You are a natural leader with pioneering spirit.',
      '2':
          'Partnership & Balance - You seek harmony and cooperation with others.',
      '3':
          'Creativity & Expression - You are naturally creative and expressive.',
      '4':
          'Stability & Foundation - You value structure and building lasting foundations.',
      '5': 'Change & Adventure - You embrace change and seek new experiences.',
      '6':
          'Harmony & Service - You are nurturing and find purpose in helping others.',
      '7':
          'Wisdom & Spirituality - You are introspective and spiritually inclined.',
      '8':
          'Abundance & Power - You are driven and capable of great achievements.',
      '9':
          'Completion & Universal Love - You are compassionate with a global perspective.',
    };
    return meanings[lifeSeal] ?? 'Unique and special';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    final lifeSeal = state.calculatedLifeSeal ?? '7';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Your Life Seal Revealed',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  lifeSeal,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                _getLifeSealMeaning(lifeSeal),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next: Features',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 4: Features Overview
class FeaturesStep extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onPrevious;

  const FeaturesStep({
    Key? key,
    required this.onNext,
    required this.onSkip,
    required this.onPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Your Features Await',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Explore what Destiny Decoder offers you',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 48),
            _buildFeatureCard(
              context,
              icon: Icons.calendar_today,
              title: 'Daily Insights',
              description: 'Personalized guidance based on your numbers',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.favorite,
              title: 'Compatibility Check',
              description: 'Discover your compatibility with others',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.library_books,
              title: 'Reading Library',
              description: 'Save and revisit personalized readings',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.trending_up,
              title: 'Monthly Guidance',
              description: 'Understand your monthly numerological cycle',
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next: Permissions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 5: Permissions Request
class PermissionsStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onPrevious;

  const PermissionsStep({
    Key? key,
    required this.onNext,
    required this.onSkip,
    required this.onPrevious,
  }) : super(key: key);

  @override
  ConsumerState<PermissionsStep> createState() => _PermissionsStepState();
}

class _PermissionsStepState extends ConsumerState<PermissionsStep> {
  bool _notificationsGranted = false;
  bool _calendarGranted = false;
  bool _requestingPermissions = false;

  void _handlePermissionRequest() async {
    setState(() => _requestingPermissions = true);

    // Request notification permission (Android 13+/iOS/macOS)
    PermissionStatus notifStatus = PermissionStatus.denied;
    try {
      notifStatus = await Permission.notification.request();
    } catch (_) {}

    // Calendar permissions are platform-specific; handle gracefully as optional
    PermissionStatus calStatus = PermissionStatus.denied;
    try {
      calStatus = await Permission.calendarFullAccess.request();
    } catch (_) {}

    setState(() {
      _notificationsGranted = notifStatus.isGranted;
      _calendarGranted = calStatus.isGranted;
      _requestingPermissions = false;
    });

    // Log analytics for permissions request
    try {
      await AnalyticsService.logScreenView(
        screenName: 'onboarding_permissions_requested',
      );
    } catch (_) {}

    ref.read(onboardingStateProvider.notifier).setPermissionsRequested(true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Enhance Your Experience',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Allow permissions for the best experience',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 48),
            _buildPermissionCard(
              context,
              icon: Icons.notifications_active,
              title: 'Notifications',
              description: 'Get daily insights and cosmic reminders',
              granted: _notificationsGranted,
            ),
            const SizedBox(height: 16),
            _buildPermissionCard(
              context,
              icon: Icons.calendar_today,
              title: 'Calendar Access',
              description: 'Sync your readings with your calendar',
              granted: _calendarGranted,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _requestingPermissions ? null : _handlePermissionRequest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _requestingPermissions
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Enable Permissions',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (!_notificationsGranted || !_calendarGranted)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await openAppSettings();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Open App Settings'),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onSkip,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Skip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool granted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: granted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          width: granted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: granted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
          if (granted)
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}

/// Step 6: Onboarding Complete
class ReadyStep extends ConsumerWidget {
  final VoidCallback onComplete;

  const ReadyStep({Key? key, required this.onComplete}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Success animation
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'You\'re All Set!',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to your cosmic journey with Destiny Decoder',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What\'s Next:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildNextStepItem(
                    context,
                    '1',
                    'Explore Daily Insights for personalized guidance',
                  ),
                  const SizedBox(height: 8),
                  _buildNextStepItem(
                    context,
                    '2',
                    'Check your Compatibility with people you care about',
                  ),
                  const SizedBox(height: 8),
                  _buildNextStepItem(
                    context,
                    '3',
                    'Customize your Notifications in Settings',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(onboardingStateProvider.notifier)
                      .completeOnboarding();
                  onComplete();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Using Destiny Decoder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepItem(BuildContext context, String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.8),
                ),
          ),
        ),
      ],
    );
  }
}

