//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
//widgets
import 'package:foretale_application/ui/widgets/bubble_loading_indicator.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';

/// Helper widgets for the landing page

class LandingWidgets {
  /// Builds the main heading text
  static Widget buildMainHeading(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final headingFontSize = context.responsiveFontSize(20);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.spacing(size: SpacingSize.small),
      ),
      child: Text(
        'Choose a project to continue',
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: headingFontSize,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          height: 1.3,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  /// Builds a circular metric item widget - Modern, elegant styling for execution stats
  static Widget buildCircularMetricItem(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final finalValueColor = valueColor ?? colorScheme.onSurface;
    final finalBackgroundColor = backgroundColor ?? colorScheme.primary;
    
    // Circular container size - compact and elegant for horizontal layout
    final circleSize = 48.0;
    final valueFontSizeCircular = context.responsiveFontSize(14);
    final labelFontSizeCircular = context.responsiveFontSize(7.5);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,

            border: Border.all(
              color: finalBackgroundColor.withValues(alpha: 0.4),
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: valueFontSizeCircular,
                fontWeight: FontWeight.w500,
                color: finalValueColor,
                letterSpacing: -0.4,
                height: 1.0,
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: labelFontSizeCircular,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              letterSpacing: 1.0,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds a metric item widget - Rectangular design for project metrics
  static Widget buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
    double borderRadius,
    double padding,
    double spacing,
    double labelFontSize,
    double valueFontSize, {
    Color? iconColor,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final iconSize = context.iconSize(size: IconSize.small) * 0.9;
    final finalIconColor = iconColor ?? colorScheme.primary.withValues(alpha: 0.8);
    final finalValueColor = valueColor ?? colorScheme.onSurface;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding * 0.85, vertical: padding * 0.65),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.25), 
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: finalIconColor,
          ),
          SizedBox(width: spacing * 0.6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: labelFontSize,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: spacing / 8),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w400,
                    color: finalValueColor,
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the project metrics section
  static Widget buildProjectMetrics(BuildContext context, ProjectDetails project) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 0.6;
    final padding = context.spacing(size: SpacingSize.small) * 0.6;
    final spacing = context.spacing(size: SpacingSize.small) * 0.6;
    final labelFontSize = context.responsiveFontSize(8.5);
    final valueFontSize = context.responsiveFontSize(11);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildMetricItem(
          context,
          "Process",
          project.projectType,
          Icons.work_outline,
          colorScheme,
          borderRadius,
          padding,
          spacing,
          labelFontSize,
          valueFontSize,
        ),
        SizedBox(height: spacing),
        buildMetricItem(
          context,
          "Days into Project",
          "${project.daysIntoProject} days",
          Icons.calendar_today_outlined,
          colorScheme,
          borderRadius,
          padding,
          spacing,
          labelFontSize,
          valueFontSize,
        ),
        if (project.projectScopeStartDate.isNotEmpty && project.projectScopeEndDate.isNotEmpty) ...[
          SizedBox(height: spacing),
          buildMetricItem(
            context,
            "Scope",
            "${project.projectScopeStartDate} - ${project.projectScopeEndDate}",
            Icons.date_range_outlined,
            colorScheme,
            borderRadius,
            padding,
            spacing,
            labelFontSize,
            valueFontSize,
          ),
        ],
      ],
    );
  }

  /// Builds the loading state widget
  static Widget buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = context.iconSize(size: IconSize.medium) * 1.75;
    return Center(
      child: BubbleLoadingIndicator(
        isLoading: true,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHighest,
        size: size,
      ),
    );
  }
}

