import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }
enum IconSize { small, medium, large }
enum SpacingSize { small, medium, large }
enum EmptyStateSpacingType { title, subtitle, button }

class Responsive {
  static ScreenSize sizeOf(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return ScreenSize.desktop;
    if (width >= 600) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  static bool isMobile(BuildContext context) =>
      sizeOf(context) == ScreenSize.mobile;
  static bool isTablet(BuildContext context) =>
      sizeOf(context) == ScreenSize.tablet;
  static bool isDesktop(BuildContext context) =>
      sizeOf(context) == ScreenSize.desktop;

  /// Scale font size based on screen type
  static double fontSize(BuildContext context, double base) {
    switch (sizeOf(context)) {
      case ScreenSize.desktop:
        return base * 1.2;
      case ScreenSize.tablet:
        return base * 1.1;
      case ScreenSize.mobile:
        return base;
    }
  }

  /// Global horizontal padding (for pages)
  static EdgeInsets pagePadding(BuildContext context) {
    switch (sizeOf(context)) {
      case ScreenSize.desktop:
        return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
      case ScreenSize.tablet:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
      case ScreenSize.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
  }

  /// Max width for main content / cards on wide screens
  static double maxContentWidth(BuildContext context) {
    switch (sizeOf(context)) {
      case ScreenSize.desktop:
        return 1200;
      case ScreenSize.tablet:
        return 800;
      case ScreenSize.mobile:
        return double.infinity;
    }
  }

  /// Standard border radius for cards
  static double borderRadius(BuildContext context) {
    switch (sizeOf(context)) {
      case ScreenSize.desktop:
        return 12;
      case ScreenSize.tablet:
        return 12;
      case ScreenSize.mobile:
        return 8;
    }
  }

  /// Standard padding for cards
  static double cardPadding(BuildContext context) {
    switch (sizeOf(context)) {
      case ScreenSize.desktop:
        return 16;
      case ScreenSize.tablet:
        return 14;
      case ScreenSize.mobile:
        return 12;
    }
  }

  /// Icon sizes (small, medium, large)
  static double iconSize(BuildContext context, {IconSize size = IconSize.medium}) {
    switch (size) {
      case IconSize.small:
        switch (sizeOf(context)) {
          case ScreenSize.desktop:
            return 20;
          case ScreenSize.tablet:
            return 18;
          case ScreenSize.mobile:
            return 18;
        }
      case IconSize.medium:
        switch (sizeOf(context)) {
          case ScreenSize.desktop:
            return 32;
          case ScreenSize.tablet:
            return 28;
          case ScreenSize.mobile:
            return 24;
        }
      case IconSize.large:
        switch (sizeOf(context)) {
          case ScreenSize.desktop:
            return 48;
          case ScreenSize.tablet:
            return 40;
          case ScreenSize.mobile:
            return 32;
        }
    }
  }

  /// Spacing between elements (small, medium, large)
  static double spacing(BuildContext context, {SpacingSize size = SpacingSize.medium}) {
    switch (size) {
      case SpacingSize.small:
        switch (sizeOf(context)) {
          case ScreenSize.desktop:
            return 8;
          case ScreenSize.tablet:
            return 6;
          case ScreenSize.mobile:
            return 6;
        }
      case SpacingSize.medium:
        switch (sizeOf(context)) {
          case ScreenSize.desktop:
            return 12;
          case ScreenSize.tablet:
            return 10;
          case ScreenSize.mobile:
            return 8;
        }
      case SpacingSize.large:
        switch (sizeOf(context)) {
          case ScreenSize.desktop:
            return 20;
          case ScreenSize.tablet:
            return 16;
          case ScreenSize.mobile:
            return 12;
        }
    }
  }

  /// Tab indicator width
  static double indicatorWidth(BuildContext context) {
    switch (sizeOf(context)) {
      case ScreenSize.desktop:
        return 3;
      case ScreenSize.tablet:
        return 3;
      case ScreenSize.mobile:
        return 2.5;
    }
  }

  /// Empty state max width
  static double emptyStateMaxWidth(BuildContext context) {
    switch (sizeOf(context)) {
      case ScreenSize.desktop:
        return 400;
      case ScreenSize.tablet:
        return 350;
      case ScreenSize.mobile:
        return double.infinity;
    }
  }

  /// Vertical spacing for empty state elements
  static double emptyStateSpacing(BuildContext context, {EmptyStateSpacingType type = EmptyStateSpacingType.title}) {
    switch (type) {
      case EmptyStateSpacingType.title:
        switch (sizeOf(context)) {
          case ScreenSize.desktop:
            return 20;
          case ScreenSize.tablet:
            return 16;
          case ScreenSize.mobile:
            return 12;
        }
      case EmptyStateSpacingType.subtitle:
        switch (sizeOf(context)) {
          case ScreenSize.desktop:
            return 8;
          case ScreenSize.tablet:
            return 8;
          case ScreenSize.mobile:
            return 6;
        }
      case EmptyStateSpacingType.button:
        switch (sizeOf(context)) {
          case ScreenSize.desktop:
            return 28;
          case ScreenSize.tablet:
            return 24;
          case ScreenSize.mobile:
            return 20;
        }
    }
  }
}

/// Extension methods on BuildContext for cleaner responsive syntax
extension ResponsiveContext on BuildContext {
  /// Get current screen size
  ScreenSize get screenSize => Responsive.sizeOf(this);

  /// Check if mobile screen
  bool get isMobile => Responsive.isMobile(this);

  /// Check if tablet screen
  bool get isTablet => Responsive.isTablet(this);

  /// Check if desktop screen
  bool get isDesktop => Responsive.isDesktop(this);

  /// Scale font size based on screen type
  double responsiveFontSize(double base) => Responsive.fontSize(this, base);

  /// Global horizontal padding (for pages)
  EdgeInsets get pagePadding => Responsive.pagePadding(this);

  /// Max width for main content / cards on wide screens
  double get maxContentWidth => Responsive.maxContentWidth(this);

  /// Standard border radius for cards
  double get borderRadius => Responsive.borderRadius(this);

  /// Standard padding for cards
  double get cardPadding => Responsive.cardPadding(this);

  /// Icon sizes (small, medium, large)
  double iconSize({IconSize size = IconSize.medium}) =>
      Responsive.iconSize(this, size: size);

  /// Spacing between elements (small, medium, large)
  double spacing({SpacingSize size = SpacingSize.medium}) =>
      Responsive.spacing(this, size: size);

  /// Tab indicator width
  double get indicatorWidth => Responsive.indicatorWidth(this);

  /// Empty state max width
  double get emptyStateMaxWidth => Responsive.emptyStateMaxWidth(this);

  /// Vertical spacing for empty state elements
  double emptyStateSpacing({EmptyStateSpacingType type = EmptyStateSpacingType.title}) =>
      Responsive.emptyStateSpacing(this, type: type);
}

