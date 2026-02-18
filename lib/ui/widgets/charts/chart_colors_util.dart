import 'package:flutter/material.dart';

class ChartColorsUtil {
  // Private constructor to prevent instantiation
  ChartColorsUtil._();

  /// Base color palette used across all charts
  static const List<Color> _baseColors = [
    Color(0xFFEE4266), // Primary color
    Color(0xFF6C63FF), // Modern purple
    Color(0xFF00D4AA), // Modern teal
    Color(0xFFFF6B6B), // Modern coral
    Color(0xFF4ECDC4), // Light teal
    Color(0xFF45B7D1), // Light blue
    Color(0xFF96CEB4), // Light green
    Color(0xFFFECA57), // Light yellow
    Color(0xFFFF9FF3), // Light pink
    Color(0xFF54A0FF), // Light indigo
  ];

  /// Get a single color by index (for charts that use one color per element)
  /// Uses modulo to cycle through colors if index exceeds available colors
  static Color getColorByIndex(int index) {
    return _baseColors[index % _baseColors.length];
  }

  /// Get a list of colors for charts that need multiple colors (like pie charts)
  /// Generates the requested number of colors cycling through the base palette
  static List<Color> getColors(int count) {
    return List.generate(count, (index) => getColorByIndex(index));
  }

  /// Get a single color with primary color as the first color
  /// This is used by bar charts that prefer the app's primary color
  /// Note: This method now uses a default primary color. For theme-aware colors,
  /// use getColorWithPrimaryFromTheme instead.
  static Color getColorWithPrimary(int index) {
    if (index == 0) {
      return _baseColors[1]; // Use second color as primary substitute
    }
    return _baseColors[(index - 1) % _baseColors.length];
  }

  /// Get a list of colors with primary color as the first color
  static List<Color> getColorsWithPrimary(int count) {
    return List.generate(count, (index) => getColorWithPrimary(index));
  }

  /// Get a single color with theme primary color as the first color
  /// This is used by bar charts that prefer the app's primary color from theme
  static Color getColorWithPrimaryFromTheme(int index, BuildContext context) {
    if (index == 0) {
      return Theme.of(context).colorScheme.primary;
    }
    return _baseColors[(index - 1) % _baseColors.length];
  }

  /// Get a list of colors with theme primary color as the first color
  static List<Color> getColorsWithPrimaryFromTheme(int count, BuildContext context) {
    return List.generate(count, (index) => getColorWithPrimaryFromTheme(index, context));
  }

  /// Get a single color for scatter plots (uses base colors)
  static Color getScatterColor(int index) {
    return getColorByIndex(index);
  }
}
