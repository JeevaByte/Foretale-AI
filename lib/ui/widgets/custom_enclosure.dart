import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CustomContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets padding;
  final double? height;
  final BoxBorder? border;

  const CustomContainer({
    super.key, 
    required this.title, 
    required this.child,
    this.padding = const EdgeInsets.all(15),
    this.height,
    this.border,
    });

  Widget _buildTitleLabel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final padding = context.spacing(size: SpacingSize.small);
    final borderRadius = context.borderRadius * 0.33;
    final fontSize = context.responsiveFontSize(11);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 0.625,
        vertical: padding / 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimary,
          fontSize: fontSize,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: border ?? Border.all(color: Colors.grey.shade500, width: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          height: height,
          // Allow horizontal overflow for proper scrolling
          clipBehavior: Clip.none,
          child: child,
        ),
        Positioned(
          top: -10,
          left: 12,
          child: _buildTitleLabel(context),
        ),
      ],
    );
  }
}
