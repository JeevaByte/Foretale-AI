import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CopyrightFooter extends StatelessWidget {
  final String companyName;
  final int? startYear;

  const CopyrightFooter({
    super.key,
    this.companyName = 'HEXANGO',
    this.startYear,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final yearRange = startYear != null && startYear != currentYear 
        ? '$startYear-$currentYear' 
        : currentYear.toString();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(12);
    
    return SizedBox(
      width: double.infinity,
      child: Text(
        '© $yearRange $companyName. All rights reserved.',
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: fontSize,
          color: colorScheme.primary.withValues(alpha: 0.7),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
