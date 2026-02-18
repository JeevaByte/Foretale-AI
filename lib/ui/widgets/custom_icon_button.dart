import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final String? tooltip;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? padding;
  final bool isProcessing;
  final bool isEnabled;
  final double borderWidth;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onDoubleTap,
    this.onLongPress,
    this.tooltip,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
    this.padding,
    this.isProcessing = false,
    this.isEnabled = true,
    this.borderWidth = 0.5,

  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer;
    final fg = iconColor ?? Theme.of(context).colorScheme.secondary;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (isProcessing || !isEnabled) ? null : onPressed,
            onDoubleTap: (isProcessing || !isEnabled) ? null : onDoubleTap,
            onLongPress: (isProcessing || !isEnabled) ? null : onLongPress,
            borderRadius: BorderRadius.circular(12),
            splashColor: fg.withValues(alpha: 0.2),
            highlightColor: fg.withValues(alpha: 0.1),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: fg.withValues(alpha: 0.5), width: borderWidth),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding ?? 8.0),
                child: isProcessing
                    ? SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(fg),
                          backgroundColor: bg,
                          strokeCap: StrokeCap.round,
                        ),
                      )
                    : Icon(
                        icon,
                        size: iconSize,
                        color: fg,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
