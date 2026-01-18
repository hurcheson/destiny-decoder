import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../decode/presentation/decode_form_page.dart';
import '../../../core/onboarding/onboarding_service.dart';
import '../widgets/onboarding_steps.dart';

/// Main Onboarding Page
///
/// Guides users through a 7-step onboarding flow:
/// 0. Welcome
/// 1. Birth Info
/// 2. Calculate Life Seal
/// 3. Life Seal Display
/// 4. Features Overview
/// 5. Permissions
/// 6. Ready
///
/// Uses Riverpod for state management and SharedPreferences for persistence.
class OnboardingPage extends ConsumerStatefulWidget {
  final VoidCallback? onCompleted;

  const OnboardingPage({super.key, this.onCompleted});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Log onboarding started
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logOnboardingStarted();
    });
  }

  void _logOnboardingStarted() {
    try {
      // Log that user started onboarding (using screen view as proxy)
      AnalyticsService.logScreenView(screenName: 'onboarding_page');
      AnalyticsService.setUserProperty(
        name: 'onboarding_started',
        value: 'true',
      );
    } catch (e) {
      debugPrint('Error logging onboarding start: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    final state = ref.read(onboardingStateProvider);
    if (state.currentStep < 6) {
      // Log step completion
      _logStepCompleted(state.currentStep);
      ref.read(onboardingStateProvider.notifier).nextStep();
      _animatePageChange();
    }
  }

  void _goToPreviousStep() {
    final state = ref.read(onboardingStateProvider);
    if (state.currentStep > 0) {
      ref.read(onboardingStateProvider.notifier).previousStep();
      _animatePageChange();
    }
  }

  void _skipCurrentStep() {
    final state = ref.read(onboardingStateProvider);
    // Log step skipped
    _logStepSkipped(state.currentStep);
    ref.read(onboardingStateProvider.notifier).skipStep();
    _animatePageChange();
  }

  void _animatePageChange() {
    _animationController.forward(from: 0.0);
  }

  void _logStepCompleted(int stepNumber) {
    try {
      final stepNames = [
        'welcome',
        'birth_info',
        'calculate_life_seal',
        'life_seal_display',
        'features',
        'permissions',
        'ready'
      ];
      AnalyticsService.logScreenView(
        screenName: 'onboarding_step_${stepNames[stepNumber]}_completed',
      );
    } catch (e) {
      debugPrint('Error logging step completion: $e');
    }
  }

  void _logStepSkipped(int stepNumber) {
    try {
      final stepNames = [
        'welcome',
        'birth_info',
        'calculate_life_seal',
        'life_seal_display',
        'features',
        'permissions',
        'ready'
      ];
      AnalyticsService.logScreenView(
        screenName: 'onboarding_step_${stepNames[stepNumber]}_skipped',
      );
    } catch (e) {
      debugPrint('Error logging step skip: $e');
    }
  }

  void _handleOnboardingComplete() {
    // Log completion
    try {
      AnalyticsService.logOnboardingCompleted();
    } catch (e) {
      debugPrint('Error logging onboarding completion: $e');
    }

    // Call completion callback
    widget.onCompleted?.call();

    // Navigate to the main decode page
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DecodeFormPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingStateProvider);
    final serviceAsync = ref.watch(onboardingServiceProvider);

    // Listen to onboarding state changes and move the page accordingly
    ref.listen<OnboardingState>(onboardingStateProvider, (previous, next) {
      if (next.currentStep >= 0 && next.currentStep <= 6) {
        _pageController.animateToPage(
          next.currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    // Show loading while service initializes
    return serviceAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error initializing onboarding: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(onboardingServiceProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (_) => _buildOnboardingContent(context, state),
    );
  }

  Widget _buildOnboardingContent(BuildContext context, OnboardingState state) {
    return PopScope(
      canPop: state.currentStep == 0,
      onPopInvoked: (didPop) {
        if (!didPop && state.currentStep > 0) {
          _goToPreviousStep();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(state),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Step 0: Welcome
            WelcomeStep(onNext: _goToNextStep),

            // Step 1: Birth Info
            BirthInfoStep(
              onNext: _goToNextStep,
              onSkip: _skipCurrentStep,
              onPrevious: _goToPreviousStep,
            ),

            // Step 2: Calculate Life Seal
            CalculateStep(
              onNext: _goToNextStep,
              onSkip: _skipCurrentStep,
              onPrevious: _goToPreviousStep,
            ),

            // Step 3: Life Seal Display
            LifeSealDisplayStep(
              onNext: _goToNextStep,
              onSkip: _skipCurrentStep,
              onPrevious: _goToPreviousStep,
            ),

            // Step 4: Features
            FeaturesStep(
              onNext: _goToNextStep,
              onSkip: _skipCurrentStep,
              onPrevious: _goToPreviousStep,
            ),

            // Step 5: Permissions
            PermissionsStep(
              onNext: _goToNextStep,
              onSkip: _skipCurrentStep,
              onPrevious: _goToPreviousStep,
            ),

            // Step 6: Ready
            ReadyStep(onComplete: _handleOnboardingComplete),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(OnboardingState state) {
    // Don't show app bar on first and last steps
    if (state.currentStep == 0 || state.currentStep == 6) {
      return null;
    }

    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      actions: [
        if (state.currentStep > 0)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goToPreviousStep,
            tooltip: 'Previous',
          ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              'Step ${state.currentStep}/6',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: _buildProgressBar(state.currentStep),
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(0),
      ),
      child: LinearProgressIndicator(
        value: (currentStep + 1) / 7,
        minHeight: 4,
        backgroundColor:
            Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Dialog to show before exiting onboarding
Future<bool> showOnboardingExitDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Exit Onboarding?'),
      content: const Text(
        'You can always complete onboarding later from Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Continue'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Exit'),
        ),
      ],
    ),
  );
  return result ?? false;
}


