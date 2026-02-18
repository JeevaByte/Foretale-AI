import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/core/constants/colors/app_colors_v2.dart';

/// Reusable logo text widget with gradient effect
class LogoText extends StatelessWidget {
  const LogoText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final logoFontSize = context.responsiveFontSize(28);
    final subtitleFontSize = context.responsiveFontSize(9);
    final spacing = context.spacing(size: SpacingSize.small) / 6;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              colorScheme.primary,
              BrandColors.primaryLight,
            ],
          ).createShader(bounds),
          child: Text(
            'foretale.ai',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: logoFontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.1,
            ),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          'BY HEXANGO',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: subtitleFontSize,
            letterSpacing: 1.5,
            color: colorScheme.onSurface.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
