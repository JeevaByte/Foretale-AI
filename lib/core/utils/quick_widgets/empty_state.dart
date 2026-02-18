import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyState({
    super.key,
    this.title = "No Data",
    this.subtitle = "There's nothing to show right now",
    this.icon = Icons.folder_outlined,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final double maxWidth = context.emptyStateMaxWidth;
    final double iconPadding = context.cardPadding;
    final double iconSize = context.iconSize(size: IconSize.medium);
    final double titleSpacing = context.emptyStateSpacing(type: EmptyStateSpacingType.title);
    final double subtitleSpacing = context.emptyStateSpacing(type: EmptyStateSpacingType.subtitle);
    final double buttonSpacing = context.emptyStateSpacing(type: EmptyStateSpacingType.button);
    final double titleFontSize = context.responsiveFontSize(16);
    final double subtitleFontSize = context.responsiveFontSize(11);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: titleSpacing),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: titleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: subtitleSpacing),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.65),
                fontSize: subtitleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionText != null) ...[
              SizedBox(height: buttonSpacing),
              CustomElevatedButton(
                onPressed: onActionPressed ?? () {},
                text: actionText!,
                textSize: context.responsiveFontSize(16),
                isEnabled: true,
                isLoading: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
