import 'package:flutter/material.dart';

/// Reusable app logo widget for consistent branding across the application
/// 
/// Usage:
/// ```dart
/// AppLogo() // Default size (120x120)
/// AppLogo.small() // Small size (40x40)
/// AppLogo.medium() // Medium size (80x80)
/// AppLogo(size: 100) // Custom size
/// ```
class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 120.0,
    this.color,
    this.fit = BoxFit.contain,
  });

  /// Small logo for navigation bars (40x40)
  const AppLogo.small({
    super.key,
    this.color,
    this.fit = BoxFit.contain,
  }) : size = 40.0;

  /// Medium logo for headers (80x80)
  const AppLogo.medium({
    super.key,
    this.color,
    this.fit = BoxFit.contain,
  }) : size = 80.0;

  /// Large logo for splash/onboarding (120x120)
  const AppLogo.large({
    super.key,
    this.color,
    this.fit = BoxFit.contain,
  }) : size = 120.0;

  /// Watermark logo for exports (60x60 with opacity)
  const AppLogo.watermark({
    super.key,
    this.fit = BoxFit.contain,
  }) : size = 60.0,
       color = null;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/destiny_decoder_logo.png',
      width: size,
      height: size,
      fit: fit,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to icon if logo image is not available
        return Icon(
          Icons.auto_awesome,
          size: size * 0.6,
          color: color ?? Theme.of(context).primaryColor,
        );
      },
    );
  }
}

/// Animated logo for splash screens and loading states
class AnimatedAppLogo extends StatefulWidget {
  final double size;
  final Duration duration;

  const AnimatedAppLogo({
    super.key,
    this.size = 120.0,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: AppLogo(size: widget.size),
    );
  }
}
