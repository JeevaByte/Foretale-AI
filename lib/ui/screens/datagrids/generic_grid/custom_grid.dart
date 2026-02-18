import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_columns.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_datasource.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_helper.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomGrid extends StatefulWidget {
  List<CustomGridColumn> columns = []; //list of columns to be displayed in the grid
  List<Map<String, dynamic>> data = []; //list of data to be displayed in the grid
  bool gridAllowSorting = true; //whether the grid allows sorting
  bool gridAllowFiltering = true; //whether the grid allows filtering
  bool gridAllowPagination = true; //whether the grid allows pagination
  bool gridAllowSelection = true; //whether the grid allows selection
  bool gridAllowMultiSelection = true; //whether the grid allows multi-selection
  ColumnWidthMode columnWidthMode = ColumnWidthMode.none; //the mode to use for the column width
  double headerRowHeight = 38; //the height of the header row
  double rowHeight = 36; //the height of the row


  final void Function(Map<String, dynamic> rowData, int rowIndex)? gridOnRowTap; //callback for row tap

  bool enablePagination = false; //whether the grid allows pagination

  String? firstColumnName; //the name of the column that should be displayed first in the grid
  
  int frozenColumnsCount = 0; //number of columns to freeze

  final ScrollController? horizontalScrollController; //optional external scroll controller for horizontal scrolling

  CustomGrid({
    super.key, 
    required this.columns, 
    required this.data,
    this.gridAllowSorting = true,
    this.gridAllowFiltering = true,
    this.gridAllowPagination = true,
    this.gridAllowSelection = true,
    this.gridAllowMultiSelection = true,
    this.gridOnRowTap,
    this.enablePagination = false,
    this.firstColumnName,
    this.columnWidthMode = ColumnWidthMode.none,
    this.frozenColumnsCount = 0,
    this.horizontalScrollController,
    this.headerRowHeight = 38,
    this.rowHeight = 36,

    });

  @override
  State<CustomGrid> createState() => _CustomGridState();
}

class _CustomGridState extends State<CustomGrid> {
  final String _currentFileName = 'custom_grid.dart';
  final GlobalKey<SfDataGridState> _dataGridKey = GlobalKey<SfDataGridState>(); //key for the syncfusion datagrid. This will help in re-rendering the grid when the data changes.
  late CustomGridDataSource sfDataSource; //data source for the syncfusion datagrid.
  late ScrollController _horizontalScrollController; //internal scroll controller if not provided externally

  @override
  void initState() {
    super.initState();
    // Use external controller if provided, otherwise create internal one
    _horizontalScrollController = widget.horizontalScrollController ?? ScrollController();
    
    try{
      //a custom grid data source is created to be used by the syncfusion datagrid.
      sfDataSource = CustomGridDataSource(
        context: context,
        columns: widget.columns,//getColumnsOrderedByFirstColumnName(widget.columns, widget.firstColumnName),
        data: widget.data,
      );
    } catch (e, errorStackTrace) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: errorStackTrace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_initState");
      }
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the controller internally
    if (widget.horizontalScrollController == null) {
      _horizontalScrollController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if data or columns have changed and recreate data source
    if (widget.data != oldWidget.data || widget.columns != oldWidget.columns) {
      try {
        sfDataSource = CustomGridDataSource(
          context: context,
          columns: getColumnsOrderedByFirstColumnName(widget.columns, widget.firstColumnName),
          data: widget.data,
        );
      } catch (e, errorStackTrace) {
        if (mounted) {
          SnackbarMessage.showErrorMessage(context, e.toString(),
              logError: true,
              errorMessage: e.toString(),
              errorStackTrace: errorStackTrace.toString(),
              errorSource: _currentFileName,
              severityLevel: 'Critical',
              requestPath: "didUpdateWidget");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    try{
      if (sfDataSource.rows.isEmpty) {
        return _buildNoDataState(); //if there is no data, show the no data state
      }

      return _buildDataGrid();
    } catch (e, errorStackTrace) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: errorStackTrace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_buildDataGrid");
      }
      return const SizedBox.shrink();
    } 
  }

  Widget _buildNoDataState() {
    return const EmptyState(
      title: "No Data Available",
      subtitle: "Please ensure the test has been run and configured correctly.",
        icon: Icons.table_view_outlined,
    );
  }

  Widget _buildDataGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SfDataGridTheme(
          data: SFDataGridTheme.sfCustomDataGridTheme(context),
          child: SfDataGrid(
            key: _dataGridKey,
            source: sfDataSource,
            columns: sfDataSource.columns.map((column) => column.toGridColumn(context)).toList(),
            allowSorting: widget.gridAllowSorting,
            allowFiltering: widget.gridAllowFiltering,
            gridLinesVisibility: GridLinesVisibility.horizontal,
            headerGridLinesVisibility: GridLinesVisibility.both,
            rowHeight: widget.rowHeight,
            headerRowHeight: widget.headerRowHeight,
            isScrollbarAlwaysShown: true,
            frozenColumnsCount: widget.frozenColumnsCount,
            onCellTap: (details) => _onCellTap(details),
            columnWidthMode: widget.columnWidthMode,
            horizontalScrollController: _horizontalScrollController,
          ),
        );
      },
    );
  }

  // Getter to access the scroll controller from outside
  ScrollController get horizontalScrollController => _horizontalScrollController; 

  void _onCellTap(DataGridCellTapDetails details) {
    // Only handle taps on data rows (not header row)
    if (details.rowColumnIndex.rowIndex > 0) {
      final rowIndex = details.rowColumnIndex.rowIndex - 1; // Adjust for header row
      
      if (rowIndex < widget.data.length) {
        // Update the selected row index in the data source
        sfDataSource.selectedRowIndex = rowIndex;
        // Call the onRowTap callback if provided 
        if (widget.gridOnRowTap != null) {
          //get the row data
          final rowData = widget.data[rowIndex];
          //call the onRowTap callback with the row data and index
          widget.gridOnRowTap!(rowData, rowIndex);
        }
      }
    }
  }
}