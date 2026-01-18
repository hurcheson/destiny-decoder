import 'package:flutter/material.dart';

/// Skip button with confirmation dialog
class SkipOnboardingButton extends StatelessWidget {
  final VoidCallback onSkip;
  final String? customText;
  final bool requireConfirmation;

  const SkipOnboardingButton({
    super.key,
    required this.onSkip,
    this.customText,
    this.requireConfirmation = true,
  });

  Future<void> _handleSkip(BuildContext context) async {
    if (!requireConfirmation) {
      onSkip();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Onboarding?'),
        content: const Text(
          'You can always come back to this tutorial later from Settings.\n\nAre you sure you want to skip?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _handleSkip(context),
      icon: const Icon(Icons.skip_next, size: 18),
      label: Text(customText ?? 'Skip'),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

/// Skip step dialog (for skipping individual steps)
class SkipStepDialog extends StatelessWidget {
  final String stepName;
  final VoidCallback onSkip;
  final VoidCallback onStay;

  const SkipStepDialog({
    super.key,
    required this.stepName,
    required this.onSkip,
    required this.onStay,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String stepName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => SkipStepDialog(
        stepName: stepName,
        onSkip: () => Navigator.of(context).pop(true),
        onStay: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.info_outline, size: 48),
      title: Text('Skip "$stepName"?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This step helps you understand important features.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can revisit this tutorial anytime from Settings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onStay,
          child: const Text('Stay'),
        ),
        FilledButton(
          onPressed: onSkip,
          child: const Text('Skip This Step'),
        ),
      ],
    );
  }
}

/// Onboarding completion celebration dialog
class OnboardingCompleteDialog extends StatefulWidget {
  final VoidCallback onGetStarted;
  final int stepsCompleted;
  final int totalSteps;

  const OnboardingCompleteDialog({
    super.key,
    required this.onGetStarted,
    required this.stepsCompleted,
    required this.totalSteps,
  });

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onGetStarted,
    required int stepsCompleted,
    required int totalSteps,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OnboardingCompleteDialog(
        onGetStarted: onGetStarted,
        stepsCompleted: stepsCompleted,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  State<OnboardingCompleteDialog> createState() =>
      _OnboardingCompleteDialogState();
}

class _OnboardingCompleteDialogState extends State<OnboardingCompleteDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completionPercentage =
        (widget.stepsCompleted / widget.totalSteps * 100).toInt();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated celebration icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🎉',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'You\'re All Set!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Completion stats
            Text(
              'You completed $completionPercentage% of the onboarding',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Achievement badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AchievementBadge(
                  icon: Icons.check_circle,
                  label: '${widget.stepsCompleted}/${widget.totalSteps} Steps',
                  color: Theme.of(context).colorScheme.primary,
                ),
                _AchievementBadge(
                  icon: Icons.auto_awesome,
                  label: 'Ready to Go',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Call to action
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onGetStarted();
                },
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Start Exploring'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('I\'ll explore later'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Help/Info button for contextual help
class ContextualHelpButton extends StatelessWidget {
  final String helpText;
  final String? title;

  const ContextualHelpButton({
    super.key,
    required this.helpText,
    this.title,
  });

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Help'),
        content: Text(helpText),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      onPressed: () => _showHelp(context),
      tooltip: 'Show help',
    );
  }
}
