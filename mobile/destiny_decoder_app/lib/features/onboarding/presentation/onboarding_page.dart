import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../decode/presentation/decode_form_page.dart';
import '../widgets/progress_tracker.dart';
import '../widgets/example_preview_cards.dart';
import '../widgets/skip_button.dart';
import 'onboarding_controller.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Welcome to Destiny Decoder',
      description:
          'Discover your numerological destiny. Unlock insights into your Life Seal, Soul Number, and Personality Number.',
      icon: Icons.auto_awesome,
      color: AppColors.primary,
      showExamples: true, // Show preview on first step
    ),
    OnboardingStep(
      title: 'Your Life Seal',
      description:
          'Your Life Seal is your foundational life number, derived from your birth date. It reveals your core life purpose and direction.',
      icon: Icons.stars,
      color: const Color(0xFFFF6B6B),
      features: [
        'Discover your core life purpose',
        'Understand your natural strengths',
        'See your life path direction',
      ],
    ),
    OnboardingStep(
      title: 'Numerological Insights',
      description:
          'Explore detailed interpretations of your core numbers: Soul Number, Personality Number, and Personal Year influence.',
      icon: Icons.lightbulb_outline,
      color: const Color(0xFFFFA500),
      features: [
        'Soul Number - Your inner desires',
        'Personality Number - How others see you',
        'Personal Year - Current life phase',
      ],
    ),
    OnboardingStep(
      title: 'Your Life Journey',
      description:
          'View your life cycles, turning points, and major transitions. Understand the phases of your life path.',
      icon: Icons.timeline,
      color: const Color(0xFF4ECDC4),
      features: [
        'Track important life transitions',
        'See major turning points',
        'Understand your life cycles',
      ],
    ),
    OnboardingStep(
      title: 'Compatibility Analysis',
      description:
          'Compare numerological profiles with your partner or loved ones. Discover compatibility insights.',
      icon: Icons.people_outline,
      color: const Color(0xFFB19CD9),
      features: [
        'Check relationship compatibility',
        'Understand partner dynamics',
        'Improve communication',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    // Show completion celebration
    await OnboardingCompleteDialog.show(
      context: context,
      onGetStarted: () async {
        await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DecodeFormPage()),
          (route) => false,
        );
      },
      stepsCompleted: _currentPage + 1,
      totalSteps: _steps.length,
    );
  }

  Future<void> _skipOnboarding() async {
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DecodeFormPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _animationController.reset();
              _animationController.forward();
            },
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              return _buildOnboardingStep(
                _steps[index],
                isDarkMode,
              );
            },
          ),

          // Progress indicator at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Compact progress dots
                    CompactProgressIndicator(
                      currentStep: _currentPage,
                      totalSteps: _steps.length,
                    ),
                    // Skip button
                    SkipOnboardingButton(
                      onSkip: _skipOnboarding,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation and indicators
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _steps.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          height: 8,
                          width: _currentPage == index ? 32 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? _steps[index].color
                                : Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Step title
                    Text(
                      'Step ${_currentPage + 1} of ${_steps.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button (hidden on first page)
                        if (_currentPage > 0)
                          TextButton.icon(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                          )
                        else
                          const SizedBox(width: 60),

                        // Skip button
                        if (_currentPage < _steps.length - 1)
                          TextButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Next button
                        if (_currentPage < _steps.length - 1)
                          FloatingActionButton.small(
                            backgroundColor: _steps[_currentPage].color,
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Icon(Icons.arrow_forward),
                          )
                        else
                          FloatingActionButton.small(
                            backgroundColor: _steps[_currentPage].color,
                            onPressed: _completeOnboarding,
                            child: const Icon(Icons.check),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingStep(OnboardingStep step, bool isDarkMode) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              step.color.withValues(alpha: 0.1),
              step.color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl * 2, // Space for top progress bar
              AppSpacing.xl,
              AppSpacing.xxl * 3, // Space for bottom navigation
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo on first step, icon on others
                if (_currentPage == 0)
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0, 0.5, curve: Curves.easeOut),
                      ),
                    ),
                    child: const AppLogo.large(),
                  )
                else
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0, 0.5, curve: Curves.easeOut),
                      ),
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: step.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Icon(
                        step.icon,
                        size: 64,
                        color: step.color,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),

                // Title
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.headingLarge.copyWith(
                    color: isDarkMode ? AppColors.darkText : AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Description
                Text(
                  step.description,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: isDarkMode
                        ? AppColors.darkText.withValues(alpha: 0.7)
                        : AppColors.textDark.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                
                // Show example previews on first step
                if (step.showExamples == true) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  const ExampleDecodePreview(),
                ],

                // Show features list for other steps
                if (step.features != null && step.features!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  ...step.features!.map((feature) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: step.color,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                feature,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isDarkMode
                                      ? AppColors.darkText
                                      : AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool? showExamples; // Show example preview cards
  final List<String>? features; // Feature bullet points

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.showExamples,
    this.features,
  });
}
