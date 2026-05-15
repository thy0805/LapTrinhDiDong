import 'package:flutter/material.dart';

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve decelerate = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve easeInOut = Curves.easeInOut;

  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: decelerate,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  static Widget slideUp({
    required Widget child,
    Duration duration = normal,
    double offset = 30.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: duration,
      curve: decelerate,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * offset),
          child: Opacity(
            opacity: 1.0 - value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
