import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_columns.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// A simple, generic table widget for displaying data using CustomGrid
class SimpleTableGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SimpleTableGridWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return EmptyState(
        title: 'No data available',
        subtitle: 'No data available',
        icon: Icons.data_object,
      );
    }

    // Convert data to CustomGrid format
    final columns = _buildColumns();
    
    return CustomGrid(
      columns: columns,
      data: data,
      gridAllowSorting: true,
      gridAllowFiltering: true,
      gridAllowPagination: false,
      gridAllowSelection: false,
      gridAllowMultiSelection: false,
      enablePagination: false,
      columnWidthMode: ColumnWidthMode.fitByColumnName,
    );
  }

  List<CustomGridColumn> _buildColumns() {
    // Get all unique keys from all data entries, preserving order
    final allKeys = <String>[];
    final seenKeys = <String>{};
    
    for (final item in data) {
      for (final key in item.keys) {
        if (!seenKeys.contains(key)) {
          allKeys.add(key);
          seenKeys.add(key);
        }
      }
    }

    return allKeys.map((key) {
      return CustomGridColumn(
        columnName: key,
        label: key,
        cellType: _determineCellType(key),
        allowSorting: true,
        allowFiltering: true,
        visible: true,
        textAlign: TextAlign.center,
        isFeedbackColumn: false,
        allowedValues: const [],
        checkboxUpdateCallback: const {},
        dropdownUpdateCallback: const {},
      );
    }).toList();
  }

  CustomCellType _determineCellType(String key) {
    // Sample a few values to determine the most appropriate cell type
    final sampleValues = data.take(5).map((item) => item[key]).where((value) => value != null).toList();
    
    if (sampleValues.isEmpty) {
      return CustomCellType.text;
    }

    // Check if all values are numbers
    final allNumbers = sampleValues.every((value) => 
        value is num || (value is String && double.tryParse(value.toString()) != null));
    
    if (allNumbers) {
      // Check if it looks like currency (contains $ or currency symbols)
      final hasCurrencySymbols = sampleValues.any((value) => 
          value.toString().contains('\$') || value.toString().contains('€') || value.toString().contains('£'));
      
      if (hasCurrencySymbols) {
        return CustomCellType.currency;
      }
      
      // Check if it looks like percentage (contains %)
      final hasPercentageSymbols = sampleValues.any((value) => 
          value.toString().contains('%'));
      
      if (hasPercentageSymbols) {
        return CustomCellType.percentage;
      }
      
      return CustomCellType.number;
    }

    // Check if all values are dates
    final allDates = sampleValues.every((value) => 
        value is DateTime || (value is String && DateTime.tryParse(value.toString()) != null));
    
    if (allDates) {
      return CustomCellType.date;
    }

    // Default to text
    return CustomCellType.text;
  }
}
