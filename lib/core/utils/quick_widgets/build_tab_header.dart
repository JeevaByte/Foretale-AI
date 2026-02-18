import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

Widget buildTabHeader(
  BuildContext context, {
  required IconData icon,
  required String label,
}) {
  final theme = Theme.of(context);

  final double iconSize = context.iconSize(size: IconSize.small);
  final double spacing = context.spacing(size: SpacingSize.small);
  final double fontSize = context.responsiveFontSize(14);

  return Tooltip(
    message: label,
    child: Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
          ),
          SizedBox(width: spacing),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ),
  );
}
