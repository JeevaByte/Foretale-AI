import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/bubble_loading_indicator.dart';

Widget buildLoadingState(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  // Responsive size based on screen type
  final double size = switch (context.screenSize) {
    ScreenSize.desktop => 40,
    ScreenSize.tablet => 32,
    ScreenSize.mobile => 28,
  };

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BubbleLoadingIndicator(
          isLoading: true,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surfaceContainerHighest,
          size: size,
        ),
      ],
    ),
  );
}