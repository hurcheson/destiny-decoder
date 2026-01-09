import 'package:flutter/material.dart';

/// Animated number counter widget that counts from 0 to the target number
/// with smooth easing and customizable styling
class AnimatedNumber extends StatefulWidget {
  final int number;
  final TextStyle? textStyle;
  final Duration duration;
  final Curve curve;
  final String prefix;
  final String suffix;
  final int decimalPlaces;

  const AnimatedNumber(
    this.number, {
    super.key,
    this.textStyle,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 0,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: widget.number.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Start animation after a small delay for visual impact
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      _controller.reset();
      _animation = Tween<double>(begin: 0, end: widget.number.toDouble()).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final displayValue = widget.decimalPlaces > 0
            ? value.toStringAsFixed(widget.decimalPlaces)
            : value.toStringAsFixed(0);

        return Text(
          '${widget.prefix}$displayValue${widget.suffix}',
          style: widget.textStyle,
        );
      },
    );
  }
}

/// Enhanced hero card with animated number reveal
class AnimatedHeroNumberCard extends StatefulWidget {
  final int number;
  final String label;
  final String subtitle;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final Duration animationDuration;

  const AnimatedHeroNumberCard({
    super.key,
    required this.number,
    required this.label,
    this.subtitle = '',
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.animationDuration = const Duration(milliseconds: 1400),
  });

  @override
  State<AnimatedHeroNumberCard> createState() => _AnimatedHeroNumberCardState();
}

class _AnimatedHeroNumberCardState extends State<AnimatedHeroNumberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Start fade animation
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(_fadeAnimation),
        child: _HeroNumberCardContent(
          number: widget.number,
          label: widget.label,
          subtitle: widget.subtitle,
          backgroundColor: widget.backgroundColor,
          textColor: widget.textColor,
          icon: widget.icon,
          animationDuration: widget.animationDuration,
        ),
      ),
    );
  }
}

class _HeroNumberCardContent extends StatelessWidget {
  final int number;
  final String label;
  final String subtitle;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final Duration animationDuration;

  const _HeroNumberCardContent({
    required this.number,
    required this.label,
    required this.subtitle,
    this.backgroundColor,
    this.textColor,
    this.icon,
    required this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDarkMode
            ? const Color(0xFF6B5B8A)
            : const Color(0xFF3F2F5E));
    final txtColor = textColor ?? Colors.white;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              bgColor.withValues(alpha: 0.90),
            ],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: 16),
            ],
            Text(
              '✨ $label ✨',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: txtColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedNumber(
              number,
              textStyle: TextStyle(
                color: txtColor,
                fontSize: 72,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.0,
              ),
              duration: animationDuration,
              curve: Curves.easeOutCubic,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: txtColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
