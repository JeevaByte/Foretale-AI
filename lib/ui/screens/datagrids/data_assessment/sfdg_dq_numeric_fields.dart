import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/models/data_assessment_model.dart';

class NumericFieldsDataGrid extends StatelessWidget {
  final List<DataQualityProfile> profiles;

  const NumericFieldsDataGrid({super.key, required this.profiles});

  Widget _buildColumnLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    final padding = context.spacing(size: SpacingSize.small) / 2;
    return Container(
      padding: EdgeInsets.all(padding),
      alignment: Alignment.center,
      child: Text(text, style: theme.textTheme.labelMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme(context),
      child: SfDataGrid(
        allowSorting: true,
        allowFiltering: true,
        isScrollbarAlwaysShown: true,
        columnWidthMode: ColumnWidthMode.fill,
        selectionMode: SelectionMode.multiple,
        headerRowHeight: 30,
        source: NumericFieldsDataSource(context, profiles),
        columns: <GridColumn>[
          GridColumn(
            columnName: 'columnName',
            label: _buildColumnLabel(context, 'Column Name'),
          ),
          GridColumn(
            columnName: 'dataType',
            label: _buildColumnLabel(context, 'Data Type'),
          ),
          GridColumn(
            columnName: 'min',
            label: _buildColumnLabel(context, 'Min'),
          ),
          GridColumn(
            columnName: 'max',
            label: _buildColumnLabel(context, 'Max'),
          ),
          GridColumn(
            columnName: 'average',
            label: _buildColumnLabel(context, 'Average'),
          ),
          GridColumn(
            columnName: 'stddev',
            label: _buildColumnLabel(context, 'Std Dev'),
          ),
        ],
      ),
    );
  }
}

class NumericFieldsDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];

  NumericFieldsDataSource(this.context, List<DataQualityProfile> profiles) {
    dataGridRows = profiles.map<DataGridRow>((profile) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'columnName', value: profile.columnName),
        DataGridCell<String>(columnName: 'dataType', value: profile.dataType),
        DataGridCell<String>(columnName: 'min', value: profile.minValue),
        DataGridCell<String>(columnName: 'max', value: profile.maxValue),
        DataGridCell<num>(columnName: 'average', value: profile.avgValue),
        DataGridCell<num>(columnName: 'stddev', value: profile.stdDev),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        final theme = Theme.of(context);
        final padding = context.spacing(size: SpacingSize.small);
        return Container(
          padding: EdgeInsets.all(padding),
          alignment: Alignment.center,
          child: Text(
            dataGridCell.value.toString(),
            style: theme.textTheme.bodySmall,
          ),
        );
      }).toList(),
    );
  }
}
