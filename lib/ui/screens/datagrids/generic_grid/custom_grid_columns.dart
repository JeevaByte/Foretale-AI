import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomGridColumn {
  final String columnName; //technical name of the column
  final String label; //display name of the column
  final CustomCellType cellType; //type of the cell (text, checkbox, dropdown, etc.)
  final double? width; //width of the column
  final bool allowSorting; //whether the column can be sorted
  final bool allowFiltering; //whether the column can be filtered
  final bool visible; //whether the column is visible
  final TextAlign textAlign; //alignment of the text (left, right, center, justify, start, end)
  final bool isFeedbackColumn; //whether the column is a feedback column
  final List<String> allowedValues; //allowed values for the column
  final Map<String, Function(String, bool)> checkboxUpdateCallback; //callback function for final update
  final Map<String, Function(String, String)> dropdownUpdateCallback; //callback function for dropdown update

  CustomGridColumn({
    required this.columnName,
    required this.label,
    required this.cellType,
    this.width,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.visible = true,
    this.textAlign = TextAlign.start,
    this.isFeedbackColumn = false,
    this.allowedValues = const [],
    required this.checkboxUpdateCallback,
    required this.dropdownUpdateCallback,
  });

  GridColumn toGridColumn(BuildContext context){
    // Always set a width to enable horizontal scrolling
    // If width is -1 or null, use calculated optimal width
    final columnWidth = (width == null || width == -1) 
        ? _calculateOptimalWidth(label: label, cellType: cellType)
        : width!;
    
    return GridColumn(
      columnName: columnName,
      width: columnWidth,
      allowSorting: allowSorting,
      allowFiltering: allowFiltering,
      visible: visible,
      label: _buildConsistentHeader(context, label, isFeedbackColumn),
      autoFitPadding: EdgeInsets.all(2),
      sortIconPosition: ColumnHeaderIconPosition.start,
    );
  }

  double _calculateOptimalWidth({required String label, required CustomCellType cellType}) {
    double baseWidth = (label.length * 10) + 48; //increased character width for better header visibility

    return baseWidth.clamp(100.0, 300.0); //minimum and maximum width constraints
  }

  Widget _buildConsistentHeader(BuildContext context, String label, bool isFeedbackColumn) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final padding = context.spacing(size: SpacingSize.small) / 4;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
      child: Center(
        child: Text(
          label.toUpperCase().replaceAll("_", " "),
          style: theme.textTheme.labelMedium?.copyWith(
            height: 1.2,
            color: isFeedbackColumn 
                ? colorScheme.error 
                : null,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}