import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import 'decode_controller.dart';
import 'decode_result_page.dart';
import 'widgets/cards.dart';
import '../../history/presentation/history_page.dart';
import 'widgets/loading_animation.dart';

class DecodeFormPage extends ConsumerStatefulWidget {
  const DecodeFormPage({super.key});

  @override
  ConsumerState<DecodeFormPage> createState() => _DecodeFormPageState();
}

class _DecodeFormPageState extends ConsumerState<DecodeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(decodeControllerProvider.notifier).decode(
          fullName: _fullNameController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
        );

    final state = ref.read(decodeControllerProvider);
    if (state.hasValue && state.value != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DecodeResultPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(decodeControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          GradientContainer(
            startColor: AppColors.primary.withValues(alpha: 0.08),
            endColor: AppColors.accent.withValues(alpha: 0.03),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          const Spacer(),
                          IconButton(
                            tooltip: 'History',
                            icon: const Icon(Icons.history),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const HistoryPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                  // Header
                  Text(
                    '🌙 Destiny Decoder 🌙',
                    textAlign: TextAlign.center,
                    style: AppTypography.headingLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Discover Your Numerological Path',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Decorative divider
                  Container(
                    height: 2,
                    width: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.accent,
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(1)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Form card
                  Card(
                    elevation: AppElevation.md,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          Text(
                            'Your Full Name',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              hintText: 'e.g., John Smith',
                              prefixIcon: Icon(Icons.person),
                              prefixIconColor: AppColors.primary,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter your full name'
                                    : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // DOB field
                          Text(
                            'Date of Birth',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _dobController,
                            decoration: const InputDecoration(
                              hintText: 'YYYY-MM-DD',
                              prefixIcon: Icon(Icons.calendar_today),
                              prefixIconColor: AppColors.primary,
                            ),
                            keyboardType: TextInputType.datetime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your date of birth';
                              }
                              if (!RegExp(r'^\d{4}-\d{2}-\d{2}$')
                                  .hasMatch(value)) {
                                return 'Use format YYYY-MM-DD';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _submit,
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.auto_awesome),
                              label: Text(
                                isLoading ? 'Decoding...' : 'Reveal Your Destiny',
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // Error message
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.md),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  state.error.toString(),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Info section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Your birth date and name unlock your unique numerological profile.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
          
          // Loading overlay with premium animation
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
}
