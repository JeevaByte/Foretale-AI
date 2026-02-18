import 'package:flutter/material.dart';

class CustomAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;

  const CustomAnimatedSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.switchInCurve = Curves.easeInOut,
    this.switchOutCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      // Simplified to use only fade transition to avoid redundancy with page animations
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}
