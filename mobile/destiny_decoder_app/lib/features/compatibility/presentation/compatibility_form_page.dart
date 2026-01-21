import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../decode/presentation/widgets/cards.dart';
import 'compatibility_controller.dart';
import 'compatibility_result_page.dart';

class CompatibilityFormPage extends ConsumerStatefulWidget {
  const CompatibilityFormPage({super.key});

  @override
  ConsumerState<CompatibilityFormPage> createState() => _CompatibilityFormPageState();
}

class _CompatibilityFormPageState extends ConsumerState<CompatibilityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameAController = TextEditingController();
  final _dobAController = TextEditingController();
  final _nameBController = TextEditingController();
  final _dobBController = TextEditingController();

  @override
  void dispose() {
    _nameAController.dispose();
    _dobAController.dispose();
    _nameBController.dispose();
    _dobBController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(compatibilityControllerProvider.notifier).calculateCompatibility(
          nameA: _nameAController.text.trim(),
          dobA: _dobAController.text.trim(),
          nameB: _nameBController.text.trim(),
          dobB: _dobBController.text.trim(),
        );

    final state = ref.read(compatibilityControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.error}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } else if (state.hasValue && state.value != null && mounted) {
      // Log compatibility check
      await AnalyticsService.logCompatibilityCheck();
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CompatibilityResultPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compatibilityControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compatibility Check'),
        centerTitle: true,
      ),
      body: GradientContainer(
        startColor: AppColors.primary.withValues(alpha: 0.05),
        endColor: AppColors.accent.withValues(alpha: 0.02),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  
                  // Header with icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF6B9D),
                            Color(0xFFC239B3),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Compare Two Souls',
                    textAlign: TextAlign.center,
                    style: AppTypography.headingLarge.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Discover the numerological compatibility between two people',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Person A Card
                  Card(
                    elevation: AppElevation.md,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  'A',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'Person A',
                                style: AppTypography.headingMedium.copyWith(
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          Text(
                            'Full Name',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _nameAController,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Alice Johnson',
                              prefixIcon: Icon(Icons.person),
                              prefixIconColor: AppColors.primary,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter name'
                                    : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          Text(
                            'Date of Birth',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _dobAController,
                            decoration: const InputDecoration(
                              hintText: 'YYYY-MM-DD',
                              prefixIcon: Icon(Icons.calendar_today),
                              prefixIconColor: AppColors.primary,
                            ),
                            keyboardType: TextInputType.datetime,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter date of birth';
                              }
                              if (!RegExp(r'^\d{4}-\d{2}-\d{2}$')
                                  .hasMatch(value)) {
                                return 'Use format YYYY-MM-DD';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Person B Card
                  Card(
                    elevation: AppElevation.md,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      side: BorderSide(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppColors.accent,
                                child: Text(
                                  'B',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'Person B',
                                style: AppTypography.headingMedium.copyWith(
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          Text(
                            'Full Name',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _nameBController,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Bob Smith',
                              prefixIcon: Icon(Icons.person),
                              prefixIconColor: AppColors.accent,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter name'
                                    : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          Text(
                            'Date of Birth',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _dobBController,
                            decoration: const InputDecoration(
                              hintText: 'YYYY-MM-DD',
                              prefixIcon: Icon(Icons.calendar_today),
                              prefixIconColor: AppColors.accent,
                            ),
                            keyboardType: TextInputType.datetime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter date of birth';
                              }
                              if (!RegExp(r'^\d{4}-\d{2}-\d{2}$')
                                  .hasMatch(value)) {
                                return 'Use format YYYY-MM-DD';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

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
                          : const Icon(Icons.favorite),
                      label: Text(
                        isLoading ? 'Analyzing...' : 'Check Compatibility',
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

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
