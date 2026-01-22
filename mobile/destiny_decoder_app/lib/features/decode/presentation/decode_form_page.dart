import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../compatibility/presentation/compatibility_form_page.dart';
import '../../settings/presentation/settings_page.dart';
import 'decode_controller.dart';
import 'decode_result_page.dart';
import 'widgets/cards.dart';
import '../../history/presentation/history_page.dart';
import 'widgets/loading_animation.dart';
import 'widgets/feature_card.dart';

class DecodeFormPage extends ConsumerStatefulWidget {
  const DecodeFormPage({super.key});

  @override
  ConsumerState<DecodeFormPage> createState() => _DecodeFormPageState();
}

class _DecodeFormPageState extends ConsumerState<DecodeFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  bool _showForm = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    await ref.read(decodeControllerProvider.notifier).decode(
          fullName: _fullNameController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
        );

    final state = ref.read(decodeControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.error}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } else if (state.hasValue && mounted) {
      // Log successful calculation
      final result = state.value!;
      final lifeSealNumber = result.lifeSeal.number;
      await AnalyticsService.logCalculationCompleted(lifeSealNumber);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DecodeResultPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(decodeControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Destiny Decoder'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GradientContainer(
            startColor: AppColors.primary.withValues(alpha: 0.05),
            endColor: AppColors.accent.withValues(alpha: 0.02),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.md),

                        // Welcome header
                        Text(
                          'Welcome',
                          style: AppTypography.headingLarge.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Choose your path to discover',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Primary Feature Card - Personal Reading
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.9 + (0.1 * value),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: FeatureCard(
                            title: 'Personal Reading',
                            description: 'Unlock your numerological destiny and life path',
                            icon: Icons.auto_awesome,
                            gradient: FeatureCardGradients.primary,
                            isPrimary: true,
                            onTap: () {
                              setState(() {
                                _showForm = !_showForm;
                              });
                            },
                          ),
                        ),

                        // Expandable form
                        AnimatedSize(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: _showForm
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.lg,
                                  ),
                                  child: _buildForm(isLoading),
                                )
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Secondary Features Header
                        if (!_showForm)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.md,
                              bottom: AppSpacing.md,
                            ),
                            child: Text(
                              'Explore More',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                        // Secondary Feature Cards
                        if (!_showForm) ...[
                          // Compatibility Card
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 700),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: FeatureCard(
                              title: 'Compatibility Check',
                              description: 'Discover the connection between two souls',
                              icon: Icons.favorite_rounded,
                              gradient: FeatureCardGradients.compatibility,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CompatibilityFormPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // History Card
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: FeatureCard(
                              title: 'Reading History',
                              description: 'Review your past readings and insights',
                              icon: Icons.history_rounded,
                              gradient: FeatureCardGradients.history,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const HistoryPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Info callout
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.1),
                                  AppColors.primary.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_outline,
                                    color: AppColors.accent,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    'Each reading is saved to your history for future reference',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: NumerologyLoadingAnimation(
                  message: 'Decoding Your Destiny...',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Card(
      elevation: AppElevation.lg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Enter Your Details',
                      style: AppTypography.headingSmall.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _showForm = false;
                      });
                    },
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Name field
              Text(
                'Full Name',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: 'e.g., John Smith',
                  prefixIcon: const Icon(Icons.person_outline),
                  prefixIconColor: AppColors.primary,
                  filled: true,
                  fillColor: AppColors.background,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your full name'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // DOB field
              Text(
                'Date of Birth',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  prefixIconColor: AppColors.primary,
                  filled: true,
                  fillColor: AppColors.background,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: () => _selectDate(context, _dobController),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, size: 22),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Reveal Your Destiny',
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Open Material date picker and populate DOB field
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      // Format as YYYY-MM-DD
      final String formattedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      controller.text = formattedDate;
    }
  }
}



