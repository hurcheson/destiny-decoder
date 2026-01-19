import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/iap/purchase_service.dart';

/// Paywall trigger context
enum PaywallTrigger {
  postCalculation,   // After viewing a reading
  readingLimit,      // Hit 4th reading attempt
  pdfLimit,          // Hit 2nd PDF attempt
  truncatedText,     // Clicked "View Full" on truncated text
}

/// Paywall page for upgrading to premium/pro
class PaywallPage extends ConsumerStatefulWidget {
  final PaywallTrigger trigger;
  final VoidCallback? onDismiss;
  final VoidCallback? onSuccess;

  const PaywallPage({
    super.key,
    required this.trigger,
    this.onDismiss,
    this.onSuccess,
  });

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  int _selectedPlanIndex = 1; // Default to Premium
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: productsAsync.when(
          data: (products) => _buildContent(products),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(error),
        ),
      ),
    );
  }

  Widget _buildContent(List<ProductDetails> products) {
    return Column(
      children: [
        // Close button
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onDismiss,
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header based on trigger
                _buildHeader(),
                const SizedBox(height: 32),

                // Feature benefits
                _buildBenefits(),
                const SizedBox(height: 32),

                // Pricing cards
                _buildPricingCards(products),
                const SizedBox(height: 24),

                // CTA button
                _buildCTAButton(products),
                const SizedBox(height: 16),

                // Restore purchases (iOS)
                TextButton(
                  onPressed: _restorePurchases,
                  child: const Text(
                    'Restore Purchases',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 16),

                // Terms
                _buildTerms(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    String title;
    String subtitle;

    switch (widget.trigger) {
      case PaywallTrigger.postCalculation:
        title = '✨ Unlock Your Full Potential';
        subtitle = 'Get unlimited readings and detailed insights';
        break;
      case PaywallTrigger.readingLimit:
        title = '🔒 Reading Limit Reached';
        subtitle = 'Upgrade to save unlimited readings';
        break;
      case PaywallTrigger.pdfLimit:
        title = '📄 PDF Limit Reached';
        subtitle = 'Upgrade for unlimited PDF exports';
        break;
      case PaywallTrigger.truncatedText:
        title = '📖 Full Interpretation Locked';
        subtitle = 'Upgrade to read complete interpretations';
        break;
    }

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      {'icon': Icons.all_inclusive, 'text': 'Unlimited Readings'},
      {'icon': Icons.article, 'text': 'Full Interpretation Text'},
      {'icon': Icons.picture_as_pdf, 'text': 'Unlimited PDF Exports'},
      {'icon': Icons.favorite, 'text': 'Detailed Compatibility'},
      {'icon': Icons.analytics, 'text': 'Advanced Analytics'},
      {'icon': Icons.block, 'text': 'Ad-Free Experience'},
    ];

    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                benefit['icon'] as IconData,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                benefit['text'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPricingCards(List<ProductDetails> products) {
    final plans = [
      {
        'name': 'Premium Monthly',
        'price': '\$2.99/month',
        'productId': ProductIds.premiumMonthly,
        'badge': null,
      },
      {
        'name': 'Premium Annual',
        'price': '\$24.99/year',
        'productId': ProductIds.premiumAnnual,
        'badge': 'SAVE 30%',
      },
      {
        'name': 'Pro Annual',
        'price': '\$49.99/year',
        'productId': ProductIds.proAnnual,
        'badge': 'BEST VALUE',
      },
    ];

    return Column(
      children: plans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;
        final isSelected = _selectedPlanIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _selectedPlanIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.amber.withValues(alpha: 0.2) : Colors.white10,
              border: Border.all(
                color: isSelected ? Colors.amber : Colors.white24,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.amber : Colors.white54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (plan['badge'] != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                plan['badge'] as String,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        plan['price'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCTAButton(List<ProductDetails> products) {
    final plans = [
      ProductIds.premiumMonthly,
      ProductIds.premiumAnnual,
      ProductIds.proAnnual,
    ];

    return ElevatedButton(
      onPressed: _isProcessing ? null : () => _handlePurchase(products, plans[_selectedPlanIndex]),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isProcessing
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Start Premium',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildTerms() {
    return const Text(
      'Subscriptions auto-renew unless cancelled 24 hours before period ends. '
      'Manage in App Store/Play Store settings.',
      style: TextStyle(
        color: Colors.white54,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Failed to load products',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.invalidate(productsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(List<ProductDetails> products, String productId) async {
    setState(() => _isProcessing = true);

    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final product = products.firstWhere((p) => p.id == productId);
      
      final success = await purchaseService.purchaseProduct(product);
      
      if (success && mounted) {
        // Wait for purchase to complete and validate
        await Future.delayed(const Duration(seconds: 2));
        
        widget.onSuccess?.call();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isProcessing = true);

    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      await purchaseService.restorePurchases();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
