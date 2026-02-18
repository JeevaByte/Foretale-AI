import 'package:flutter/material.dart';

class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double breakpoint;
  final double? minChildWidth;
  final double? maxChildWidth;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.breakpoint = 600.0,
    this.minChildWidth,
    this.maxChildWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > breakpoint;
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minChildWidth ?? (isWideScreen ? 120 : 80),
                maxWidth: maxChildWidth ?? (isWideScreen ? 200 : 150),
              ),
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}
