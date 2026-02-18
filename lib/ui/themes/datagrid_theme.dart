import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class SFDataGridTheme {
  static SfDataGridThemeData sfCustomDataGridTheme(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return SfDataGridThemeData( 
      headerColor: colorScheme.primary.withValues(alpha: 0.5),
      headerHoverColor: colorScheme.primary.withValues(alpha: 0.4),
      selectionColor: colorScheme.primary.withValues(alpha: 0.15),
      gridLineColor: colorScheme.outline.withValues(alpha: 0.3),
      gridLineStrokeWidth: 1.0,
      rowHoverColor: colorScheme.primary.withValues(alpha: 0.3),
      sortIcon: Icon(
        Icons.keyboard_arrow_up,
        size: Responsive.iconSize(context, size: IconSize.small),
        color: colorScheme.primary,
      ),
      filterIcon: Icon(
        Icons.filter_list,
        size: Responsive.iconSize(context, size: IconSize.small),
        color: colorScheme.primary,
      ),

      filterPopupTextStyle: textTheme.bodyMedium?.copyWith(
        fontSize: context.responsiveFontSize(12.0),
      ) ?? TextStyle(fontSize: context.responsiveFontSize(12.0)),
      filterPopupDisabledTextStyle: textTheme.bodyMedium?.copyWith(
        fontSize: context.responsiveFontSize(12.0),
        color: colorScheme.onSurface.withValues(alpha: 0.38),
      ) ?? TextStyle(
        fontSize: context.responsiveFontSize(12.0),
        color: colorScheme.onSurface.withValues(alpha: 0.38),
      ),

      filterPopupBackgroundColor: colorScheme.surface,
      filterPopupTopDividerColor: colorScheme.primary,
      filterPopupBottomDividerColor: colorScheme.primary,

      // "Apply/OK" and "Reset/Cancel" buttons
      okFilteringLabelButtonColor: colorScheme.primaryContainer,
      okFilteringLabelColor: colorScheme.onPrimaryContainer,
      cancelFilteringLabelButtonColor: colorScheme.surfaceContainerHighest,
      cancelFilteringLabelColor: colorScheme.onSurface,

      // text & icons inside the popup
      filterPopupIconColor: colorScheme.onSurface,
      filterPopupDisabledIconColor: colorScheme.onSurface.withValues(alpha: 0.38),

      // text field (search/input) styling
      filterPopupInputBorderColor: colorScheme.outline.withValues(alpha: 0.5),
      searchAreaFocusedBorderColor: colorScheme.primary,
      searchAreaCursorColor: colorScheme.onSurface,

      // optional: calendar icon in date filter
      calendarIconColor: colorScheme.onSurface,

      filterPopupCheckColor: colorScheme.onPrimaryContainer,
      filterPopupCheckboxFillColor: WidgetStateProperty.all(
        colorScheme.primary.withValues(alpha: 0.5),
      ),
    );  
  }
}
