import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CustomIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const CustomIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = context.spacing(size: SpacingSize.small);
    final borderRadius = context.borderRadius;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        icon, 
        size: size, 
        color: color ?? colorScheme.primary,
      ),
    );
  }
}
