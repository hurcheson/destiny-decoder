import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/base_layout.dart';
import '../../core/iap/purchase_service.dart';
import '../../core/api/auth_providers.dart';

/// Beautiful paywall screen showing subscription tiers.
/// Displayed when user tries to access premium features without a subscription.
class PaywallScreen extends ConsumerWidget {
  final String? fromFeature; // Which feature triggered the paywall

  const PaywallScreen({
    super.key,
    this.fromFeature,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseLayout(
      appBar: AppBar(
        title: const Text('Unlock Premium Features'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section
              _buildHeroSection(),
              const SizedBox(height: 32),

              // Features comparison
              _buildFeaturesComparison(),
              const SizedBox(height: 32),

              // Pricing cards
              _buildPricingCards(context, ref),
              const SizedBox(height: 24),

              // Terms
              _buildTermsSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primary.withValues(alpha: 0.4),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '👑',
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Unlock Your Full Potential',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Access daily insights, compatibility readings, and personalized guidance',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesComparison() {
    final features = [
      {'name': 'Life Seal Reading', 'free': true, 'premium': true, 'pro': true},
      {'name': 'Daily Insights', 'free': false, 'premium': true, 'pro': true},
      {'name': 'Compatibility Check', 'free': false, 'premium': true, 'pro': true},
      {'name': 'Monthly Guidance', 'free': false, 'premium': true, 'pro': true},
      {'name': 'Blessed Day Alerts', 'free': false, 'premium': true, 'pro': true},
      {'name': 'Priority Support', 'free': false, 'premium': false, 'pro': true},
      {'name': 'Advanced Analytics', 'free': false, 'premium': false, 'pro': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What You Get',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  feature['premium'] as bool ? Icons.check_circle : Icons.lock,
                  color: feature['premium'] as bool
                      ? AppColors.primary
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  feature['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: feature['premium'] as bool ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPricingCards(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Premium card
        _buildPricingCard(
          context,
          title: 'Premium',
          price: '\$4.99',
          period: '/month',
          description: 'Perfect for spiritual seekers',
          features: [
            'Daily personalized insights',
            'Unlimited compatibility checks',
            'Blessed day notifications',
            'PDF export readings',
          ],
          isPopular: true,
          onTap: () => _showPurchaseDialog(context, ref, 'premium'),
        ),
        const SizedBox(height: 12),

        // Pro card
        _buildPricingCard(
          context,
          title: 'Pro',
          price: '\$9.99',
          period: '/month',
          description: 'For serious practitioners',
          features: [
            'Everything in Premium, plus:',
            'Priority email support',
            'Advanced numerology analytics',
            'Monthly guidance updates',
          ],
          isPopular: false,
          onTap: () => _showPurchaseDialog(context, ref, 'pro'),
        ),
      ],
    );
  }

  Widget _buildPricingCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isPopular ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
            width: isPopular ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isPopular ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '\$',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                price.replaceAll('\$', ''),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            period,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...features.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPopular
                            ? AppColors.primary
                            : Colors.grey.withValues(alpha: 0.2),
                        foregroundColor: isPopular ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'SUBSCRIBE NOW',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isPopular ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'Subscription Details',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Subscribe to access premium features\n'
          '• Cancel anytime from your account settings\n'
          '• Prices may vary by region and currency\n'
          '• Automatic renewal unless cancelled\n'
          '• Your subscription is managed by Apple/Google',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to privacy policy
                },
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 12,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to terms
                },
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPurchaseDialog(BuildContext context, WidgetRef ref, String tier) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Subscription',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Subscribe to ${tier.capitalize()} tier\n'
                'Your subscription will start immediately.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _initiatePurchase(context, ref, tier);
                  },
                  child: const Text('Continue to Payment'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _initiatePurchase(BuildContext context, WidgetRef ref, String tier) async {
    try {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening payment...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Get purchase service
      final purchaseService = ref.read(purchaseServiceProvider);

      // Check if IAP is available
      if (!purchaseService.isAvailable) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('In-app purchases not available on this device'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Determine product ID from tier
      String productId;
      if (tier == 'premium') {
        productId = ProductIds.premiumMonthly;
      } else if (tier == 'pro') {
        productId = ProductIds.proAnnual;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid subscription tier'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get product details
      final product = purchaseService.getProduct(productId);
      if (product == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Initiate purchase
      final success = await purchaseService.purchaseProduct(product);
      
      if (success && context.mounted) {
        // Purchase initiated successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing purchase...'),
            duration: Duration(seconds: 3),
          ),
        );
        
        // Wait a bit for the purchase to complete and navigate back
        await Future.delayed(const Duration(seconds: 3));
        if (context.mounted) {
          Navigator.pop(context);
          
          // Refresh auth providers to get updated subscription
          ref.invalidate(subscriptionTierProvider);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}


