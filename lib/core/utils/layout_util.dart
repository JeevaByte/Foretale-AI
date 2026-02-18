import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Common layout helpers for deriving responsive container bounds.
double calculateMaxContentWidth(
  Size size, {
  double horizontalPadding = 48,
  double? widthCap,
}) {
  final double paddedWidth = math.max(0.0, size.width - horizontalPadding);
  if (widthCap == null) return paddedWidth;
  return math.min(paddedWidth, widthCap).toDouble();
}

double calculateAvailableContentHeight(
  Size size, {
  double minHeight = 520,
  double verticalOffset = 150,
}) {
  return math.max(minHeight, size.height - verticalOffset);
}

//getter for compact size
bool isCompactSize(Size size) {
  return size.width < 1180;
}

double resolveConversationPanelHeight(
  Size screenSize, {
  double? availableHeight,
  double minHeight = 360,
  double fallbackMin = 460,
  double fallbackMax = 640,
}) {
  final double fallbackHeight = math.max(fallbackMin, math.min(screenSize.height * 0.58, fallbackMax));
  return math.max(
    minHeight, 
    availableHeight ?? fallbackHeight);
}

