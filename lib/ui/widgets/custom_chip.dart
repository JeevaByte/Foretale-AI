import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final IconData? leadingIcon;
  final double height;
  final bool useShadow;
  final Border? border;

  const CustomChip({
    super.key,
    required this.label,
    this.backgroundColor = Colors.transparent,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
    this.leadingIcon,
    this.height = 28,
    this.useShadow = false,
    this.border,
  });

  Widget _buildChipText(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(12);
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        height: 1,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: textColor,
        fontSize: fontSize,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: const BoxConstraints(minWidth: 40),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: border,

      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 14,
                color: textColor,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: _buildChipText(context),
            ),
          ],
        ),
      ),
    );
  }
}