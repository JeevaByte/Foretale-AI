import 'package:flutter/material.dart';

/// A modern, lightweight container with customizable properties
class ModernContainer extends StatelessWidget {
  final Widget child;
  final double? width, height;
  final EdgeInsetsGeometry margin, padding;
  final Color? backgroundColor;
  final Color shadowColor;
  final double borderRadius, elevation;
  final bool isClickable, isLoading;
  final VoidCallback? onTap;
  final Widget? badge;

  const ModernContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    this.backgroundColor,
    this.borderRadius = 8,
    this.elevation = 1,
    this.shadowColor = Colors.black54,
    this.isClickable = false,
    this.onTap,
    this.badge,
    this.isLoading = false,
  }) : margin = margin ?? const EdgeInsets.all(8),
       padding = padding ?? const EdgeInsets.all(16);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: isLoading ? _buildLoadingEffect(context) : child,
    );

    final containerWithBadge = badge != null
        ? Stack(clipBehavior: Clip.none, children: [container, Positioned(top: -8, right: -8, child: badge!)])
        : container;

    return isClickable
        ? GestureDetector(
            onTap: onTap,
            child: containerWithBadge,
          )
        : containerWithBadge;
  }

  Widget _buildLoadingEffect(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(
          colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
