import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Premium loading animation with numerology/mandala theme
class NumerologyLoadingAnimation extends StatefulWidget {
  final String message;
  final TextStyle? textStyle;

  const NumerologyLoadingAnimation({
    super.key,
    this.message = 'Decoding Your Destiny...',
    this.textStyle,
  });

  @override
  State<NumerologyLoadingAnimation> createState() =>
      _NumerologyLoadingAnimationState();
}

class _NumerologyLoadingAnimationState extends State<NumerologyLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation for outer ring
    _spinController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.linear),
    );

    // Pulsing animation for inner elements
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primary = isDarkMode ? const Color(0xFF6B5B8A) : const Color(0xFF3F2F5E);
    final accent = isDarkMode ? const Color(0xFFFFD700) : const Color(0xFFD4AF37);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated numerology mandala
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer spinning ring
              RotationTransition(
                turns: _rotateAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: List.generate(9, (index) {
                      final angle = (index * 40) * math.pi / 180;
                      final x = 50 + 40 * math.cos(angle);
                      final y = 50 + 40 * math.sin(angle);
                      return Positioned(
                        left: x,
                        top: y,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withValues(alpha: 0.6),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Middle pulsing ring
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
              ),

              // Center number indicator
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary,
                        primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome,
                      size: 32,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Loading message
        Text(
          widget.message,
          style: widget.textStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primary,
                letterSpacing: 0.5,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Animated dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final delay = (index * 150) / 1500;
                final delayedValue = (_pulseAnimation.value - 1) + delay;
                final opacity = (delayedValue * 2).clamp(0.0, 1.0);

                return Opacity(
                  opacity: opacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
