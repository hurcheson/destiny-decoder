// ARCHIVED/UNUSED: This tutorial overlay is not currently wired into the onboarding flow.
// Retained for reference only. Do not import into production UI without re-validating.
import 'package:flutter/material.dart';

/// A tutorial overlay that highlights specific UI elements with explanatory tooltips
/// Usage:
/// ```dart
/// TutorialOverlay(
///   targetKey: _buttonKey,
///   title: "Tap to decode",
///   description: "Enter your birthdate and tap this button",
///   onDismiss: () => setState(() => _showTooltip = false),
/// )
/// ```
class TutorialOverlay extends StatefulWidget {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final VoidCallback onDismiss;
  final Color? highlightColor;
  final TooltipPosition position;
  final Widget? actionButton;

  const TutorialOverlay({
    super.key,
    required this.targetKey,
    required this.title,
    required this.description,
    required this.onDismiss,
    this.highlightColor,
    this.position = TooltipPosition.bottom,
    this.actionButton,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Get target widget position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetRect();
    });
  }

  void _updateTargetRect() {
    final renderBox =
        widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      final offset = renderBox.localToGlobal(Offset.zero);
      setState(() {
        _targetRect = Rect.fromLTWH(
          offset.dx,
          offset.dy,
          renderBox.size.width,
          renderBox.size.height,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRect == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final highlightColor = widget.highlightColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.3);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Semi-transparent backdrop
            GestureDetector(
              onTap: _handleDismiss,
              child: Container(
                color: Colors.black54,
                width: screenSize.width,
                height: screenSize.height,
              ),
            ),

            // Highlight cutout around target
            CustomPaint(
              size: screenSize,
              painter: _HighlightPainter(
                targetRect: _targetRect!,
                highlightColor: highlightColor,
              ),
            ),

            // Tooltip card
            _buildTooltipCard(context, screenSize),

            // Pulsing ring around target
            Positioned(
              left: _targetRect!.left - 8,
              top: _targetRect!.top - 8,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: _targetRect!.width + 16,
                    height: _targetRect!.height + 16,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: highlightColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltipCard(BuildContext context, Size screenSize) {
    final tooltipPosition = _calculateTooltipPosition(screenSize);

    return Positioned(
      left: tooltipPosition.dx,
      top: tooltipPosition.dy,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: screenSize.width * 0.8,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _handleDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
              ),
              if (widget.actionButton != null) ...[
                const SizedBox(height: 16),
                widget.actionButton!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Offset _calculateTooltipPosition(Size screenSize) {
    const padding = 20.0;
    final tooltipWidth = screenSize.width * 0.8;

    double left = (screenSize.width - tooltipWidth) / 2;
    double top;

    switch (widget.position) {
      case TooltipPosition.top:
        top = _targetRect!.top - 200 - padding;
        if (top < padding) {
          top = _targetRect!.bottom + padding;
        }
        break;
      case TooltipPosition.bottom:
        top = _targetRect!.bottom + padding;
        if (top + 200 > screenSize.height - padding) {
          top = _targetRect!.top - 200 - padding;
        }
        break;
    }

    return Offset(left.clamp(padding, screenSize.width - tooltipWidth - padding), top);
  }
}

/// Custom painter to create highlight cutout effect
class _HighlightPainter extends CustomPainter {
  final Rect targetRect;
  final Color highlightColor;

  _HighlightPainter({
    required this.targetRect,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw rounded rectangle around target
    final rrect = RRect.fromRectAndRadius(
      targetRect.inflate(8),
      const Radius.circular(12),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_HighlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.highlightColor != highlightColor;
  }
}

/// Position of tooltip relative to target
enum TooltipPosition {
  top,
  bottom,
}

/// Simpler spotlight widget for quick highlights without detailed tooltips
class SpotlightWidget extends StatelessWidget {
  final Widget child;
  final String? hint;
  final bool enabled;

  const SpotlightWidget({
    super.key,
    required this.child,
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
