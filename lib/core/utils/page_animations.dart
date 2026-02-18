import 'package:flutter/material.dart';

/// Page animation utilities based on the landing page animation patterns
class PageAnimationUtils {
  
  /// Creates a fade transition route (used in landing page navigation)
  static PageRouteBuilder<T> createFadeRoute<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: duration,
    );
  }

  /// Navigate with fade transition (matches landing page navigation)
  static Future<T?> fadeNavigate<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      createFadeRoute<T>(page: page, duration: duration),
    );
  }

  /// Replace current page with fade transition
  static Future<T?> fadeReplace<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      createFadeRoute<T>(page: page, duration: duration),
    );
  }
}

/// Mixin for page entrance animations (like landing page content)
mixin PageEntranceAnimations<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController fadeController;
  late AnimationController slideController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  /// Initialize the entrance animations (call in initState)
  void initializeEntranceAnimations({
    Duration fadeDuration = const Duration(milliseconds: 1000),
    Duration slideDuration = const Duration(milliseconds: 1000),
    Offset slideBegin = const Offset(0, 0.3),
    Curve fadeCurve = Curves.easeInOut,
    Curve slideCurve = Curves.easeOutCubic,
  }) {
    fadeController = AnimationController(
      duration: fadeDuration,
      vsync: this,
    );
    slideController = AnimationController(
      duration: slideDuration,
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: fadeCurve,
    ));

    slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: slideCurve,
    ));
  }

  /// Start the entrance animations
  void startEntranceAnimations() {
    fadeController.forward();
    slideController.forward();
  }

  /// Dispose animation controllers (call in dispose)
  void disposeEntranceAnimations() {
    fadeController.dispose();
    slideController.dispose();
  }

  /// Wrap widget with fade animation
  Widget buildFadeTransition({required Widget child}) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }

  /// Wrap widget with slide and fade animation (for main content)
  Widget buildSlideAndFadeTransition({required Widget child}) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  /// Wrap widget with only slide animation
  Widget buildSlideTransition({required Widget child}) {
    return SlideTransition(
      position: slideAnimation,
      child: child,
    );
  }
}

/// Extension methods for easy navigation
extension NavigationExtensions on BuildContext {
  /// Navigate with fade transition (matches landing page style)
  Future<T?> fadeNavigateTo<T extends Object?>(Widget page) {
    return PageAnimationUtils.fadeNavigate<T>(this, page);
  }

  /// Replace with fade transition
  Future<T?> fadeReplaceTo<T extends Object?, TO extends Object?>(Widget page) {
    return PageAnimationUtils.fadeReplace<T, TO>(this, page);
  }
}
