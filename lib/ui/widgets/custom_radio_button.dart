import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CustomRadioButton<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T> onChanged;
  final List<RadioOption<T>> options;
  final Color activeColor;
  final Color inactiveColor;
  final Axis direction;

  const CustomRadioButton({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.options,
    Color? activeColor,
    Color? inactiveColor,
    this.direction = Axis.vertical,
  }) : activeColor = activeColor ?? const Color(0xFF6750A4),
       inactiveColor = inactiveColor ?? const Color(0xFF79747E);

  Widget _buildOptionLabel(BuildContext context, String label, bool isSelected, Color activeColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(12);
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: isSelected 
            ? activeColor 
            : colorScheme.onSurface.withValues(alpha: 0.7),
        fontSize: fontSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = options.map((option) {
      final isSelected = groupValue == option.value;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(option.value),
            child: Transform.scale(
              scale: 0.8,
              child: Radio<T>(
                value: option.value,
                groupValue: groupValue,
                onChanged: (T? newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
                activeColor: activeColor,
                fillColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return activeColor;
                    }
                    return inactiveColor;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          _buildOptionLabel(context, option.label, isSelected, activeColor),
        ],
      );
    }).toList();

    if (direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < children.length - 1 ? 8 : 0,
            ),
            child: child,
          );
        }).toList(),
      );
    } else {
      return Row(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              right: index < children.length - 1 ? 16 : 0,
            ),
            child: child,
          );
        }).toList(),
      );
    }
  }
}

class RadioOption<T> {
  final T value;
  final String label;

  const RadioOption({
    required this.value,
    required this.label,
  });
}

