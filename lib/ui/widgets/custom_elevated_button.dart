import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? width;
  final double? height;
  final String text;
  final double textSize;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;

  const CustomElevatedButton({
    super.key,
    this.width,
    this.height,
    required this.text,
    required this.textSize,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final padding = context.spacing(size: SpacingSize.medium);
    
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (!isEnabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: padding * 1.5,
            vertical: padding * 0.75,
          ),
        ),
        child: isLoading
            ? _buildLoadingContent(context)
            : _buildContent(context),
      ),
    );
  }


  Widget _buildLoadingContent(BuildContext context) {
    return SizedBox(
      width: textSize + 2,
      height: textSize + 2,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = !isEnabled 
        ? colorScheme.onSurface.withValues(alpha: 0.38)
        : colorScheme.onPrimary;

    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        fontSize: textSize,
        color: textColor,
      ),
    );
  }
}
