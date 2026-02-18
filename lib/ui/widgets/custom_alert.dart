import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  String cancelText = 'Cancel',
  String confirmText = 'Delete',
  Color? confirmTextColor,
}) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final spacing = context.spacing(size: SpacingSize.medium);
  final borderRadius = context.borderRadius * 2;
  final titleFontSize = context.responsiveFontSize(18);
  final contentFontSize = context.responsiveFontSize(14);
  final buttonFontSize = context.responsiveFontSize(14);
  
  final result = await showDialog<bool>(
    barrierColor: Colors.black.withValues(alpha: 0.5),
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (context) => AlertDialog(
      backgroundColor: colorScheme.surface,
      contentPadding: EdgeInsets.all(spacing * 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      content: Container(
        constraints: BoxConstraints(
          minWidth: context.responsiveFontSize(300),
          maxWidth: context.responsiveFontSize(400),
          minHeight: context.responsiveFontSize(150),
          maxHeight: context.responsiveFontSize(250),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: titleFontSize,
              ),
            ),
            SizedBox(height: spacing),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: contentFontSize,
              ),
              textAlign: TextAlign.left,
              softWrap: true,
              maxLines: 10,
              textWidthBasis: TextWidthBasis.parent
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            cancelText,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontSize: buttonFontSize,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(
            confirmText,
            style: theme.textTheme.labelLarge?.copyWith(
              color: confirmTextColor ?? colorScheme.error,
              fontSize: buttonFontSize,
            ),
          ),
        ),
      ],
    ),
  );
  
  final finalResult = result ?? false;
  return finalResult;
}
