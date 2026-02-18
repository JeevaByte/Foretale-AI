//core
import 'package:flutter/material.dart';
//utils
import 'package:foretale_application/core/utils/responsive.dart';
//constants
import 'package:foretale_application/core/constants/colors/app_colors_v2.dart';

class InsightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? titleWidget;
  final bool expanded;

  const InsightCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.titleWidget,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final double padding = context.cardPadding;
    final double borderRadius = context.borderRadius * 1.08;
    final double fontSize = context.responsiveFontSize(9);

    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? BrandColors.surfaceElevatedDark.withValues(alpha: 0.6)
            : BrandColors.surfaceLight.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark 
              ? BrandColors.borderDark.withValues(alpha: 0.35) 
              : BrandColors.borderLight.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: isDark ? 12 : 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          if (isDark)
            BoxShadow(
              color: BrandColors.accent.withValues(alpha: 0.02),
              blurRadius: 16,
              offset: const Offset(0, 0),
              spreadRadius: -2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? BrandColors.surfaceDark.withValues(alpha: 0.4)
                    : BrandColors.backgroundDim.withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? BrandColors.borderDark.withValues(alpha: 0.2)
                        : BrandColors.borderLight.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding * 0.9,
                  vertical: padding * 0.65,
                ),
                child: titleWidget ?? SizedBox(
                  width: double.infinity,
                  child: Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark 
                          ? BrandColors.textSecondaryDark.withValues(alpha: 0.85)
                          : BrandColors.textSecondaryLight.withValues(alpha: 0.75),
                      letterSpacing: 0.9,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
            if (expanded)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding * 0.9,
                    vertical: padding * 0.85,
                  ),
                  child: child,
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding * 0.9,
                  vertical: padding * 0.85,
                ),
                child: child,
              ),
          ],
        ),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final double padding = context.cardPadding * 0.8;
    final double borderRadius = context.borderRadius * 0.92;
    final double labelFontSize = context.responsiveFontSize(9);
    final double valueSpacing = context.spacing(size: SpacingSize.small);
    final double valueFontSize = context.responsiveFontSize(24);

    final Widget content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 0.85,
        vertical: padding * 0.75,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.06 : 0.05),
            blurRadius: isDark ? 6 : 4,
            offset: const Offset(0, 1.5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.85,
              color: isDark 
                  ? BrandColors.textSecondaryDark.withValues(alpha: 0.8)
                  : BrandColors.textSecondaryLight.withValues(alpha: 0.7),
              fontSize: labelFontSize,
              height: 1.2,
            ),
          ),
          SizedBox(height: valueSpacing * 0.7),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color.withValues(alpha: 0.95),
              fontSize: valueFontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}

class AutomationTile extends StatelessWidget {
  final String title;
  final String timestamp;
  final bool isSelected;
  final VoidCallback? onTap;

  const AutomationTile({
    super.key,
    required this.title,
    required this.timestamp,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final double borderRadius = context.borderRadius * 0.92;
    final double margin = context.spacing(size: SpacingSize.small);
    final double padding = context.cardPadding * 0.8;
    final double indicatorSize = context.iconSize(size: IconSize.small) * 0.35;
    final double indicatorMargin = context.spacing(size: SpacingSize.medium);
    final double indicatorRadius = borderRadius * 0.5;
    final double titleSpacing = context.spacing(size: SpacingSize.small) / 2;
    final double titleFontSize = context.responsiveFontSize(12);
    final double timestampFontSize = context.responsiveFontSize(9);

    final tileColor = isSelected
        ? (isDark ? BrandColors.accentDark : BrandColors.accent).withValues(alpha: isDark ? 0.18 : 0.12)
        : (isDark ? BrandColors.surfaceDark : BrandColors.backgroundDim).withValues(alpha: isDark ? 0.3 : 0.25);
    
    final borderColor = isSelected
        ? (isDark ? BrandColors.accent : BrandColors.primary).withValues(alpha: isDark ? 0.5 : 0.4)
        : (isDark ? BrandColors.borderDark : BrandColors.borderLight).withValues(alpha: isDark ? 0.25 : 0.2);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        margin: EdgeInsets.only(bottom: margin * 0.7),
        padding: EdgeInsets.symmetric(
          horizontal: padding * 0.9,
          vertical: padding * 0.75,
        ),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? BrandColors.accent : BrandColors.primary)
                        .withValues(alpha: isDark ? 0.12 : 0.1),
                    blurRadius: isDark ? 8 : 6,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: indicatorSize,
              height: indicatorSize,
              margin: EdgeInsets.only(right: indicatorMargin * 0.8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isDark ? BrandColors.accent : BrandColors.primary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(indicatorRadius),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isDark ? BrandColors.accent : BrandColors.primary)
                              .withValues(alpha: isDark ? 0.35 : 0.3),
                          blurRadius: isDark ? 5 : 4,
                          offset: const Offset(0, 1.5),
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: titleFontSize,
                      color: isSelected
                          ? (isDark ? BrandColors.accent : BrandColors.primary).withValues(alpha: 0.95)
                          : (isDark ? BrandColors.textPrimaryDark : BrandColors.textPrimaryLight).withValues(alpha: 0.9),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: titleSpacing * 0.7),
                  Text(
                    timestamp,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? (isDark ? BrandColors.accent : BrandColors.primary)
                              .withValues(alpha: isDark ? 0.75 : 0.7)
                          : (isDark ? BrandColors.textSecondaryDark : BrandColors.textSecondaryLight).withValues(alpha: isDark ? 0.7 : 0.65),
                      fontSize: timestampFontSize,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.25,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final double padding = context.cardPadding;
    final double borderRadius = context.borderRadius * 1.08;
    final double iconSize = context.iconSize(size: IconSize.medium);
    final double iconSpacing = context.spacing(size: SpacingSize.medium);
    final double subtitleSpacing = context.spacing(size: SpacingSize.small) / 2;
    final double titleFontSize = context.responsiveFontSize(12);
    final double subtitleFontSize = context.responsiveFontSize(10);

    final emptyStateColor = isDark ? BrandColors.accent : BrandColors.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: padding * 1.0,
        horizontal: padding * 0.9,
      ),
      decoration: BoxDecoration(
        color: emptyStateColor.withValues(alpha: isDark ? 0.06 : 0.05),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: emptyStateColor.withValues(alpha: isDark ? 0.15 : 0.12),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: emptyStateColor.withValues(alpha: isDark ? 0.04 : 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: emptyStateColor.withValues(alpha: isDark ? 0.12 : 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: emptyStateColor.withValues(alpha: isDark ? 0.08 : 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: iconSize * 0.65,
                color: emptyStateColor.withValues(alpha: isDark ? 0.65 : 0.6),
              ),
            ),
            SizedBox(height: iconSpacing * 0.7),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark 
                    ? BrandColors.textPrimaryDark.withValues(alpha: 0.85)
                    : BrandColors.textPrimaryLight.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
                fontSize: titleFontSize,
                overflow: TextOverflow.ellipsis,
                height: 1.3,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: subtitleSpacing * 0.7),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark 
                      ? BrandColors.textSecondaryDark.withValues(alpha: 0.7)
                      : BrandColors.textSecondaryLight.withValues(alpha: 0.65),
                  fontSize: subtitleFontSize,
                  overflow: TextOverflow.ellipsis,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

