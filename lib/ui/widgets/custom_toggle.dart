import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final String? bottomLabel;

  const CustomToggle({
    super.key,
    required this.value,
    required this.onChanged,
    Color? activeColor,
    Color? inactiveColor,
    this.bottomLabel,
  }) : activeColor = activeColor ?? const Color(0xFF6750A4),
       inactiveColor = inactiveColor ?? const Color(0xFF79747E);

  Widget _buildLabel(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(10);
    return Text(
      bottomLabel!,
      style: theme.textTheme.bodySmall?.copyWith(
        fontSize: fontSize,
        height: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 0.7, // Scale to size 18 (default Switch height ~30, so 18/30 = 0.6)
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: activeColor,
            inactiveTrackColor: inactiveColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        if (bottomLabel != null)
          _buildLabel(context),
      ],
    );
  }
}
