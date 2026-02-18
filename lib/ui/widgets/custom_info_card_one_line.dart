import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CustomOneLineInfoCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CustomOneLineInfoCard({
    super.key,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = context.spacing(size: SpacingSize.medium);
    final borderRadius = context.borderRadius * 1.5;
    final fontSize = context.responsiveFontSize(14);
    
    return Container(
      margin: EdgeInsets.only(bottom: spacing * 0.75),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing,
              vertical: spacing * 0.875,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: spacing),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 