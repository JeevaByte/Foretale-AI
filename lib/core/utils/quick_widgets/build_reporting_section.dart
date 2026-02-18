import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

Widget buildReportingSection(
  BuildContext context, {
  required Widget child,
  required String title,
  required IconData icon,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  final double borderRadius = context.borderRadius;
  final double padding = context.cardPadding;
  final double iconSize = context.iconSize(size: IconSize.small);
  final double iconSpacing = context.spacing(size: SpacingSize.medium);
  final double fontSize = context.responsiveFontSize(14);

  return Card(
    elevation: isDark ? 0 : 1,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ColoredBox(
          color: colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: colorScheme.primary,
                  size: iconSize,
                ),
                SizedBox(width: iconSpacing),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(padding),
          child: child,
        ),
      ],
    ),
  );
}
