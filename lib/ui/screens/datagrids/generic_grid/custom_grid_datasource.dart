import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/core/utils/util_date.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_columns.dart';
import 'package:foretale_application/ui/widgets/dropdowns/custom_dropdown_lite.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomGridDataSource extends DataGridSource {

  final BuildContext context;
  final List<CustomGridColumn> columns; //list of column definitions to be displayed in the grid.
  final List<Map<String, dynamic>> data; //list of data to be displayed in the grid. This is raw data from the backend.
  List<DataGridRow> dataGridRows = []; //list of data grid rows to be displayed in the grid. This is the raw data converted to a list of data grid rows compatible with the syncfusion datagrid.

  //selected row index
  int _selectedRowIndex = -1;
  int get selectedRowIndex => _selectedRowIndex;
  set selectedRowIndex(int value) {
    _selectedRowIndex = value;
    notifyListeners();
  }

  CustomGridDataSource({
    required this.context,
    required this.columns,
    required this.data,
  }) {
    _buildRows(); //prepare the data grid rows to be displayed in the grid.
  }

  @override
  List<DataGridRow> get rows => dataGridRows; //returns the list of data grid rows to be displayed in the grid.

  @override //builds the UI widget for each row in the grid.
  DataGridRowAdapter buildRow(DataGridRow row) {
    //get the row index
    final rowIndex = dataGridRows.indexOf(row);
    final colorScheme = Theme.of(context).colorScheme;

    return DataGridRowAdapter(
      color: rowIndex == selectedRowIndex 
          ? colorScheme.primary.withValues(alpha: 0.1) 
          : null,
      cells: row.getCells().map<Widget>((cell) {
        //get the cell type from the column definition
        final columnDef = columns.firstWhere(
          (col) => col.columnName == cell.columnName
        );
        //build the cell
        return _buildCell(row, rowIndex, columnDef, cell.value);
      }).toList(),
    );
  }

  void _buildRows() {
    dataGridRows = data.map<DataGridRow>((rowData) {
      return DataGridRow(
        cells: columns.map<DataGridCell>((column) {
          return DataGridCell<String>(
            columnName: column.columnName,
            value: rowData[column.columnName]?.toString() ?? '',
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildCell(DataGridRow row, int rowIndex, CustomGridColumn columnDef, dynamic value) {
    final cellType = columnDef.cellType;
    final columnName = columnDef.columnName;
    final allowedValues = columnDef.allowedValues;
    final checkboxUpdateCallback = columnDef.checkboxUpdateCallback;
    final dropdownUpdateCallback = columnDef.dropdownUpdateCallback;

    Widget cellWidget;
    
    switch (cellType) {
      case CustomCellType.number:
        cellWidget = _buildNumberCell(value);
        break;
      case CustomCellType.currency:
        cellWidget = _buildCurrencyCell(value);
        break;
      case CustomCellType.percentage:
        cellWidget = _buildPercentageCell(value);
        break;
      case CustomCellType.date:
        cellWidget = _buildDateCell(value);
        break;
      case CustomCellType.categorical:
        cellWidget = _buildCategoricalCell(value);
        break;
      case CustomCellType.text:
        cellWidget = _buildTextCell(value);
        break;
      case CustomCellType.checkbox:
        cellWidget = _buildCheckboxCell(row, rowIndex, columnName, checkboxUpdateCallback, value);
        break;
      case CustomCellType.dropdown:
        cellWidget = _buildDropdownCell(row, rowIndex, columnName, allowedValues, dropdownUpdateCallback, value);
        break;
      default:
        cellWidget = _buildTextCell(value);
        break;
    }

    final padding = context.spacing(size: SpacingSize.small) / 2;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      alignment: Alignment.center,
      child: cellWidget,
    );
  }

  Widget _buildTextCell(dynamic value) {
    final theme = Theme.of(context);
    return Text(
      '${value ?? ''}',
      style: theme.textTheme.bodySmall,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNumberCell(dynamic value) {
    final theme = Theme.of(context);
    return Text(
      '${value ?? ''}',
      style: theme.textTheme.bodySmall,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCurrencyCell(dynamic value) {
    final theme = Theme.of(context);
    return Text(
      '${value ?? ''}',
      style: theme.textTheme.bodySmall,
    );
  }

  Widget _buildPercentageCell(dynamic value) {
    final theme = Theme.of(context);
    return Text(
      '${value ?? ''}%',
      style: theme.textTheme.bodySmall,
    );
  }

  Widget _buildDateCell(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      DateTime dateTime;

      if (value is DateTime) {
        dateTime = value;
      } else if (value is String) {
        try {
          dateTime = DateTime.parse(value); //parse the string as a date time
        } catch (_) {
          final converted = convertToDateString(value);
          if (converted.isEmpty) {
            throw const FormatException('Unrecognized format');
          }
          dateTime = DateTime.parse(converted); //parse the string as a date time
        }
      } else {
        dateTime = DateTime.parse(value.toString()); //parse the string as a date time
      }

      final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);

      return _buildTextCell(formattedDate);
    } catch (e) {
      return _buildTextCell(value); // fallback to plain text
    }
  }


  Widget _buildCategoricalCell(dynamic value) {
    if (value == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final padding = context.spacing(size: SpacingSize.small);
    final borderRadius = context.borderRadius * 0.5;
    final fontSize = context.responsiveFontSize(10);
    
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: padding * 0.75,
          vertical: padding / 4,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          '$value',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// *********************************CHECKBOX CELL*********************************
  Widget _buildCheckboxCell(DataGridRow row, int rowIndex, String columnName, Map<String, Function(String, bool)> checkboxUpdateCallback, dynamic value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Transform.scale(
        scale: 0.9,
        child: Checkbox(
          value: _convertToBoolean(value),
          onChanged: (_) {
            //update the value in the grid
            _updateCheckboxCellValue(row, rowIndex, columnName, value);

            //update the value in the database
            if(checkboxUpdateCallback.containsKey(columnName)){
              String hashKey = row.getCells().firstWhere((cell) => cell.columnName == "hash_key").value.toString();
              unawaited(checkboxUpdateCallback[columnName]?.call(hashKey, !_convertToBoolean(value)));
            }
          },
          activeColor: colorScheme.primary,
          checkColor: colorScheme.onPrimary,
          side: BorderSide(color: colorScheme.primary, width: 1),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  bool _convertToBoolean(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  void _updateCheckboxCellValue(DataGridRow row, int rowIndex, String columnName, dynamic value) {
    //toggle the checkbox state based on the value
    final newState = !_convertToBoolean(value);
    //update the value in the row
    final cells = dataGridRows[rowIndex].getCells();
    //update the value in the row
    for (var cell in cells) {
      if (cell.columnName == columnName) {
        // Create new cell with updated value since value is final
        final newCell = DataGridCell<String>(
          columnName: cell.columnName,
          value: newState.toString()
        );
        // Replace old cell with new one
        cells[cells.indexOf(cell)] = newCell;
      }
    }
    //notify the data source to update the row
    notifyListeners();
  }

  /// *********************************DROPDOWN CELL*********************************
  Widget _buildDropdownCell(DataGridRow row, int rowIndex, String columnName, List<String> allowedValues, Map<String, Function(String, String)> dropdownUpdateCallback, dynamic value) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 28,
        width: double.infinity,
        child: CustomDropdownLite(
          items: allowedValues,
          hintText: 'Select',
          selectedItem: (value == null || value.toString().trim().isEmpty) ? 'Select' : value,
          onChanged: (String? newValue) {
            if(newValue != null && newValue.toString().trim().isNotEmpty && newValue.toLowerCase() != 'select'){
              _updateDropdownCellValue(row, rowIndex, columnName, dropdownUpdateCallback, newValue);
            }
          },
          title: columnName,
      )));
  }

  void _updateDropdownCellValue(DataGridRow row, int rowIndex, String columnName, Map<String, Function(String, String)> dropdownUpdateCallback, dynamic value) {
    // Handle dropdown selection
    if(dropdownUpdateCallback.containsKey(columnName)){
      String hashKey = row.getCells().firstWhere((cell) => cell.columnName == "hash_key").value.toString();
      unawaited(dropdownUpdateCallback[columnName]?.call(hashKey, value ?? ''));
    }
  }
}