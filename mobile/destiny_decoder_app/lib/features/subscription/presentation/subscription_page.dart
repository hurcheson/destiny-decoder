import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/iap/purchase_service.dart';
import '../../../core/iap/subscription_manager.dart';

/// Subscription management page
class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionStatusProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        elevation: 0,
      ),
      body: subscriptionAsync.when(
        data: (status) => _buildContent(context, ref, status, textColor, isDarkMode),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Error loading subscription',
                style: AppTypography.bodyLarge.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                style: AppTypography.bodySmall.copyWith(
                  color: textColor.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SubscriptionStatus? status,
    Color textColor,
    bool isDarkMode,
  ) {
    final currentTier = status?.tier ?? SubscriptionTier.free;
    final isActive = status?.isActive ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current Tier Card
          _buildCurrentTierCard(currentTier, isActive, textColor, isDarkMode),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Available Tiers
          Text(
            'Available Plans',
            style: AppTypography.headingMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.md),
          
          ...SubscriptionTier.values.map((tier) {
            final isCurrent = tier == currentTier && isActive;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildTierCard(
                tier: tier,
                isCurrent: isCurrent,
                textColor: textColor,
                isDarkMode: isDarkMode,
                onTap: isCurrent ? null : () => _handleUpgrade(context, ref, tier),
              ),
            );
          }),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Feature Comparison
          if (status != null) ...[
            Text(
              'Your Features',
              style: AppTypography.headingMedium.copyWith(color: textColor),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFeaturesList(status, textColor, isDarkMode),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentTierCard(
    SubscriptionTier tier,
    bool isActive,
    Color textColor,
    bool isDarkMode,
  ) {
    final accentColor = AppColors.getAccentColorForTheme(isDarkMode);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.2),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.info_outline,
            color: accentColor,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Current Plan',
            style: AppTypography.labelMedium.copyWith(
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tier.displayName,
            style: AppTypography.headingLarge.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tier.price,
            style: AppTypography.bodyLarge.copyWith(color: textColor),
          ),
          if (!isActive && tier != SubscriptionTier.free) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'Subscription Inactive',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required SubscriptionTier tier,
    required bool isCurrent,
    required Color textColor,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    final primaryColor = AppColors.primary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isCurrent
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isCurrent
                ? primaryColor
                : textColor.withValues(alpha: 0.2),
            width: isCurrent ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tier.displayName,
                        style: AppTypography.headingSmall.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'CURRENT',
                            style: AppTypography.labelSmall.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    tier.price,
                    style: AppTypography.bodyMedium.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (!isCurrent)
              Icon(
                Icons.arrow_forward_ios,
                color: textColor.withValues(alpha: 0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(
    SubscriptionStatus status,
    Color textColor,
    bool isDarkMode,
  ) {
    final features = [
      _Feature(
        'Readings',
        status.hasUnlimitedReadings
            ? 'Unlimited'
            : '${status.readingLimit} per month',
        status.hasUnlimitedReadings,
      ),
      _Feature(
        'PDF Exports',
        status.hasUnlimitedPdf
            ? 'Unlimited'
            : '${status.pdfMonthlyLimit} per month',
        status.hasUnlimitedPdf,
      ),
      _Feature(
        'Full Interpretations',
        status.hasFullInterpretations ? 'Enabled' : 'Basic only',
        status.hasFullInterpretations,
      ),
      _Feature(
        'Detailed Compatibility',
        status.hasDetailedCompatibility ? 'Enabled' : 'Limited',
        status.hasDetailedCompatibility,
      ),
      _Feature(
        'Ad-Free Experience',
        status.isAdFree ? 'Yes' : 'Ads shown',
        status.isAdFree,
      ),
      _Feature(
        'Advanced Analytics',
        status.hasAdvancedAnalytics ? 'Enabled' : 'Not available',
        status.hasAdvancedAnalytics,
      ),
    ];

    return Card(
      elevation: AppElevation.sm,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: features.map((feature) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    feature.isEnabled ? Icons.check_circle : Icons.cancel,
                    color: feature.isEnabled ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.name,
                          style: AppTypography.bodyMedium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          feature.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleUpgrade(
    BuildContext context,
    WidgetRef ref,
    SubscriptionTier tier,
  ) {
    // Trigger in-app purchase for selected tier
    _initiateSubscriptionPurchase(context, ref, tier);
  }
  
  Future<void> _initiateSubscriptionPurchase(
    BuildContext context,
    WidgetRef ref,
    SubscriptionTier tier,
  ) async {
    try {
      // Determine product ID based on tier
      final productId = switch (tier) {
        SubscriptionTier.premium => 'destiny_decoder_premium_monthly',
        SubscriptionTier.pro => 'destiny_decoder_pro_annual',
        SubscriptionTier.free => throw Exception('Cannot purchase free tier'),
      };
      
      // Trigger purchase flow
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Initiating purchase of ${tier.displayName}...'),
          duration: const Duration(seconds: 2),
        ),
      );
      
      final purchaseService = ref.read(purchaseServiceProvider);
      var product = purchaseService.getProduct(productId);
      if (product == null) {
        await purchaseService.loadProducts();
        product = purchaseService.getProduct(productId);
      }

      if (product == null) {
        throw Exception('Product not available in store');
      }

      final success = await purchaseService.purchaseProduct(product);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase could not be started'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _Feature {
  final String name;
  final String description;
  final bool isEnabled;

  _Feature(this.name, this.description, this.isEnabled);
}
