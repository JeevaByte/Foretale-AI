import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CustomSlider extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final Function(int)? onChanged;
  final bool isEnabled;
  final String? bottomLabel;

  const CustomSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
    required this.isEnabled,
    this.bottomLabel,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = value.clamp(min, max);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 1.125;
    final fontSize = context.responsiveFontSize(14);
    final labelFontSize = context.responsiveFontSize(10);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            IconButton(
              icon: Icon(Icons.remove, size: iconSize),
              color: colorScheme.primary,
              onPressed: isEnabled && currentValue > min
                  ? () {
                      final newValue = (currentValue - 1).clamp(min, max);
                      onChanged?.call(newValue);
                    }
                  : null,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: iconSize * 1.33,
                minHeight: iconSize * 2.11,
              ),
              iconSize: iconSize,
            ),
            SizedBox(
              width: context.spacing(size: SpacingSize.medium) * 1.875,
              child: Text(
                currentValue.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add, size: iconSize),
              color: colorScheme.primary,
              onPressed: isEnabled && currentValue < max
                  ? () {
                      final newValue = (currentValue + 1).clamp(min, max);
                      onChanged?.call(newValue);
                    }
                  : null,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: iconSize * 1.33,
                minHeight: iconSize * 2.11,
              ),
              iconSize: iconSize,
            ),
            ],
          ),
        ),
        if (bottomLabel != null) ...[
          SizedBox(height: context.spacing(size: SpacingSize.small) / 4),
          Center(
            child: Text(
              bottomLabel!,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: labelFontSize),
            ),
          ),
        ],
      ],
    );
  }
}
