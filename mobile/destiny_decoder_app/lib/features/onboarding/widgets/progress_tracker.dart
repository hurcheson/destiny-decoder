import 'package:flutter/material.dart';

/// Visual progress indicator for onboarding flow
/// Shows current step, total steps, percentage, and checkmarks for completed steps
class OnboardingProgressTracker extends StatelessWidget {
  final int currentStep; // 0-indexed
  final int totalSteps;
  final List<String> stepTitles;
  final bool showPercentage;
  final bool showStepNumbers;

  const OnboardingProgressTracker({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitles = const [],
    this.showPercentage = true,
    this.showStepNumbers = true,
  });

  double get _progressPercentage => (currentStep + 1) / totalSteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with step count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Getting Started',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (showPercentage)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(_progressPercentage * 100).toInt()}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Step counter text
          if (showStepNumbers)
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
            ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: _progressPercentage),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          // Step titles with checkmarks (if provided)
          if (stepTitles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildStepList(context),
          ],
        ],
      ),
    );
  }

  Widget _buildStepList(BuildContext context) {
    return Column(
      children: List.generate(
        totalSteps,
        (index) => _buildStepItem(
          context,
          index,
          stepTitles.length > index ? stepTitles[index] : 'Step ${index + 1}',
        ),
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, int index, String title) {
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;
    final isPending = index > currentStep;

    IconData icon;
    Color iconColor;

    if (isCompleted) {
      icon = Icons.check_circle;
      iconColor = Theme.of(context).colorScheme.primary;
    } else if (isCurrent) {
      icon = Icons.radio_button_checked;
      iconColor = Theme.of(context).colorScheme.primary;
    } else {
      icon = Icons.radio_button_unchecked;
      iconColor = Theme.of(context).colorScheme.outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              key: ValueKey('$index-$isCompleted-$isCurrent'),
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    color: isPending
                        ? Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.4)
                        : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact circular progress indicator for top of screen
class CompactProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const CompactProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: currentStep == index ? 32 : 8,
          decoration: BoxDecoration(
            color: currentStep >= index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// Animated checkmark for completed steps
class AnimatedCheckmark extends StatefulWidget {
  final bool completed;
  final Color? color;
  final double size;

  const AnimatedCheckmark({
    super.key,
    required this.completed,
    this.color,
    this.size = 80,
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.completed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completed && !oldWidget.completed) {
      _controller.forward();
    } else if (!widget.completed && oldWidget.completed) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: CustomPaint(
              painter: _CheckmarkPainter(
                progress: _checkAnimation.value,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Define checkmark path
    path.moveTo(width * 0.25, height * 0.5);
    path.lineTo(width * 0.4, height * 0.65);
    path.lineTo(width * 0.75, height * 0.35);

    // Draw partial checkmark based on progress
    final metric = path.computeMetrics().first;
    final extractPath = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
