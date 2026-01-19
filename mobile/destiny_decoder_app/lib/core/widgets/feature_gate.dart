import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../iap/subscription_manager.dart';
import '../../features/paywall/paywall_page.dart';

/// Feature gate widget that shows paywall if feature is locked
class FeatureGate extends ConsumerWidget {
  final Widget child;
  final String featureName;
  final PaywallTrigger trigger;
  final bool Function(SubscriptionStatus?) checkAccess;

  const FeatureGate({
    super.key,
    required this.child,
    required this.featureName,
    required this.trigger,
    required this.checkAccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);

    return subscriptionStatus.when(
      data: (status) {
        final hasAccess = checkAccess(status);
        
        if (hasAccess) {
          return child;
        } else {
          return _buildLockedState(context);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => child, // On error, allow access (fail open)
    );
  }

  Widget _buildLockedState(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPaywall(context),
      child: Stack(
        children: [
          Opacity(opacity: 0.5, child: child),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, color: Colors.amber, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock $featureName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to upgrade',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaywallPage(
          trigger: trigger,
          onDismiss: () => Navigator.of(context).pop(),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Feature gate for specific actions (shows dialog instead of overlay)
class ActionFeatureGate {
  final BuildContext context;
  final WidgetRef ref;

  ActionFeatureGate(this.context, this.ref);

  /// Check if user can perform action, show paywall if not
  Future<bool> checkAccess({
    required String featureName,
    required PaywallTrigger trigger,
    required bool Function(SubscriptionStatus?) checkAccess,
  }) async {
    final subscriptionStatus = await ref.read(subscriptionStatusProvider.future);
    final hasAccess = checkAccess(subscriptionStatus);

    if (!hasAccess && context.mounted) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => PaywallPage(
            trigger: trigger,
            onDismiss: () => Navigator.of(context).pop(false),
            onSuccess: () => Navigator.of(context).pop(true),
          ),
          fullscreenDialog: true,
        ),
      );
      return result ?? false;
    }

    return hasAccess;
  }

  /// Check reading limit before saving
  Future<bool> canSaveReading() async {
    return checkAccess(
      featureName: 'Unlimited Readings',
      trigger: PaywallTrigger.readingLimit,
      checkAccess: (status) {
        if (status == null) return false;
        final limit = status.readingLimit;
        // TODO: Check actual saved reading count
        return limit == -1 || limit > 0; // -1 = unlimited
      },
    );
  }

  /// Check PDF limit before export
  Future<bool> canExportPDF() async {
    return checkAccess(
      featureName: 'Unlimited PDF Exports',
      trigger: PaywallTrigger.pdfLimit,
      checkAccess: (status) {
        if (status == null) return false;
        final limit = status.pdfMonthlyLimit;
        // TODO: Check actual PDF export count this month
        return limit == -1 || limit > 0; // -1 = unlimited
      },
    );
  }

  /// Check if should show full interpretation
  bool shouldTruncateInterpretation(SubscriptionStatus? status) {
    if (status == null) return true;
    return !status.hasFullInterpretations;
  }

  /// Get truncated text if needed
  String getInterpretationText(SubscriptionStatus? status, String fullText) {
    if (shouldTruncateInterpretation(status)) {
      return fullText.length > 50 
        ? '${fullText.substring(0, 50)}...' 
        : fullText;
    }
    return fullText;
  }
}

/// Widget for showing truncated text with upgrade prompt
class TruncatedTextWidget extends ConsumerWidget {
  final String fullText;
  final int truncateLength;

  const TruncatedTextWidget({
    super.key,
    required this.fullText,
    this.truncateLength = 50,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);

    return subscriptionStatus.when(
      data: (status) {
        final shouldTruncate = status == null || !status.hasFullInterpretations;
        
        if (!shouldTruncate) {
          return Text(fullText);
        }

        final truncatedText = fullText.length > truncateLength
            ? '${fullText.substring(0, truncateLength)}...'
            : fullText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(truncatedText),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showPaywall(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_open, size: 16, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      'View Full Text',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Text(fullText), // Show full text while loading
      error: (_, __) => Text(fullText), // Show full text on error
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaywallPage(
          trigger: PaywallTrigger.truncatedText,
          onDismiss: () => Navigator.of(context).pop(),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
