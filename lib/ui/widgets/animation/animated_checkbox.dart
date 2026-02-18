import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class AnimatedCheckbox extends StatelessWidget {
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;
  final bool isEnabled;

  const AnimatedCheckbox({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = context.iconSize(size: IconSize.small) * 1.5; // 18px
    final borderRadius = context.borderRadius * 0.5; // 6px
    final iconSize = context.iconSize(size: IconSize.small) * 0.625; // 10px
    
    return GestureDetector(
      onTap: isLoading || !isEnabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? colorScheme.secondary : colorScheme.primary,
            width: 1,
          ),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onSecondary),
                  strokeWidth: 2,
                )
              : isSelected
                  ? Icon(
                      Icons.check,
                      size: iconSize,
                      color: colorScheme.onSecondary,
                    )
                  : null,
        ),
      ),
    );
  }
}
