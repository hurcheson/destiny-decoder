import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/iap/subscription_manager.dart';
import '../../core/iap/purchase_service.dart';

/// Subscription settings and management page
class SubscriptionSettingsPage extends ConsumerWidget {
  const SubscriptionSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        elevation: 0,
      ),
      body: subscriptionStatus.when(
        data: (status) => _buildContent(context, ref, status),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, SubscriptionStatus? status) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current plan card
          _buildCurrentPlanCard(status),
          const SizedBox(height: 24),

          // Features list
          _buildFeaturesSection(status),
          const SizedBox(height: 24),

          // Usage statistics
          _buildUsageSection(status),
          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(context, ref, status),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(SubscriptionStatus? status) {
    final tier = status?.tier ?? SubscriptionTier.free;
    final isActive = status?.isActive ?? false;

    Color tierColor;
    IconData tierIcon;

    switch (tier) {
      case SubscriptionTier.free:
        tierColor = Colors.grey;
        tierIcon = Icons.person;
        break;
      case SubscriptionTier.premium:
        tierColor = Colors.blue;
        tierIcon = Icons.star;
        break;
      case SubscriptionTier.pro:
        tierColor = Colors.amber;
        tierIcon = Icons.workspace_premium;
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [tierColor, tierColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tierIcon, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tier.price,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: tierColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (status?.expiresAt != null) ...[
              const SizedBox(height: 16),
              Text(
                'Renews ${DateFormat.yMMMd().format(status!.expiresAt!)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(SubscriptionStatus? status) {
    final features = [
      {
        'icon': Icons.all_inclusive,
        'title': 'Saved Readings',
        'value': status?.hasUnlimitedReadings == true ? 'Unlimited' : '${status?.readingLimit ?? 3} remaining',
        'unlocked': status?.hasUnlimitedReadings ?? false,
      },
      {
        'icon': Icons.article,
        'title': 'Full Interpretations',
        'value': status?.hasFullInterpretations == true ? 'Enabled' : 'Basic only',
        'unlocked': status?.hasFullInterpretations ?? false,
      },
      {
        'icon': Icons.picture_as_pdf,
        'title': 'PDF Exports',
        'value': status?.hasUnlimitedPdf == true ? 'Unlimited' : '${status?.pdfMonthlyLimit ?? 1}/month',
        'unlocked': status?.hasUnlimitedPdf ?? false,
      },
      {
        'icon': Icons.favorite,
        'title': 'Detailed Compatibility',
        'value': status?.hasDetailedCompatibility == true ? 'Enabled' : 'Score only',
        'unlocked': status?.hasDetailedCompatibility ?? false,
      },
      {
        'icon': Icons.analytics,
        'title': 'Advanced Analytics',
        'value': status?.hasAdvancedAnalytics == true ? 'Enabled' : 'Basic',
        'unlocked': status?.hasAdvancedAnalytics ?? false,
      },
      {
        'icon': Icons.block,
        'title': 'Ad-Free',
        'value': status?.isAdFree == true ? 'Yes' : 'No',
        'unlocked': status?.isAdFree ?? false,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: (feature['unlocked'] as bool) ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            feature['value'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      (feature['unlocked'] as bool) ? Icons.check_circle : Icons.lock,
                      color: (feature['unlocked'] as bool) ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageSection(SubscriptionStatus? status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usage This Month',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUsageItem(
              icon: Icons.book,
              title: 'Readings Saved',
              current: 0, // TODO: Get from backend
              limit: status?.readingLimit ?? 3,
            ),
            const SizedBox(height: 12),
            _buildUsageItem(
              icon: Icons.picture_as_pdf,
              title: 'PDFs Exported',
              current: 0, // TODO: Get from backend
              limit: status?.pdfMonthlyLimit ?? 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageItem({
    required IconData icon,
    required String title,
    required int current,
    required int limit,
  }) {
    final isUnlimited = limit == -1;
    final percentage = isUnlimited ? 1.0 : (current / limit).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            Text(
              isUnlimited ? 'Unlimited' : '$current / $limit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!isUnlimited)
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage < 0.8 ? Colors.blue : Colors.orange,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, SubscriptionStatus? status) {
    final tier = status?.tier ?? SubscriptionTier.free;
    final isActive = status?.isActive ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (tier == SubscriptionTier.free) ...[
          ElevatedButton.icon(
            onPressed: () => _upgradeToPremium(context),
            icon: const Icon(Icons.star),
            label: const Text('Upgrade to Premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _upgradeToPro(context),
            icon: const Icon(Icons.workspace_premium),
            label: const Text('Upgrade to Pro'),
          ),
        ] else if (isActive) ...[
          OutlinedButton.icon(
            onPressed: () => _manageSubscription(context, ref, status),
            icon: const Icon(Icons.settings),
            label: const Text('Manage Subscription'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _cancelSubscription(context, ref, status),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel Subscription'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => _restorePurchases(context, ref),
          icon: const Icon(Icons.restore),
          label: const Text('Restore Purchases'),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load subscription',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _upgradeToPremium(BuildContext context) {
    // TODO: Navigate to paywall
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Premium upgrade...')),
    );
  }

  void _upgradeToPro(BuildContext context) {
    // TODO: Navigate to paywall
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Pro upgrade...')),
    );
  }

  void _manageSubscription(BuildContext context, WidgetRef ref, SubscriptionStatus? status) {
    // TODO: Open platform-specific subscription management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage subscription in App Store/Play Store')),
    );
  }

  Future<void> _cancelSubscription(BuildContext context, WidgetRef ref, SubscriptionStatus? status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'You will retain access until the end of your billing period. '
          'Are you sure you want to cancel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final manager = ref.read(subscriptionManagerProvider);
      final userId = status?.userId ?? 'anonymous'; // TODO: Get from auth
      
      final success = await manager.cancelSubscription(userId);
      
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription cancelled')),
          );
          ref.invalidate(subscriptionStatusProvider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to cancel subscription')),
          );
        }
      }
    }
  }

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    final purchaseService = ref.read(purchaseServiceProvider);
    
    try {
      await purchaseService.restorePurchases();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored successfully')),
        );
        ref.invalidate(subscriptionStatusProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore: $e')),
        );
      }
    }
  }
}
