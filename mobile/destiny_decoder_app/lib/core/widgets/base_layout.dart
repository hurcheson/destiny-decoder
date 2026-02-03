import 'package:flutter/material.dart';

/// Base layout widget providing consistent padding and safe area
class BaseLayout extends StatelessWidget {
  final Widget? appBar;
  final Widget? body;
  final Widget? child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool resizeToAvoidBottomInset;

  const BaseLayout({
    this.appBar,
    this.body,
    this.child,
    this.backgroundColor,
    this.padding,
    this.resizeToAvoidBottomInset = true,
    super.key,
  }) : super();

  @override
  Widget build(BuildContext context) {
    // If using traditional Scaffold pattern (appBar + body)
    if (appBar != null || body != null) {
      return Scaffold(
        backgroundColor: backgroundColor ?? Colors.white,
        appBar: appBar as PreferredSizeWidget?,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: body != null
            ? SafeArea(
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16.0),
                  child: body,
                ),
              )
            : null,
      );
    }

    // If using simple child pattern
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
