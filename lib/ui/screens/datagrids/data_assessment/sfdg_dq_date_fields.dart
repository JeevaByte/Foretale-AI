import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/data_assessment_model.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';

class DateFieldsDataGrid extends StatelessWidget {
  final List<DataQualityProfile> profiles;

  const DateFieldsDataGrid({super.key, required this.profiles});

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
        allowFiltering: true,
        allowSorting: true,
        isScrollbarAlwaysShown: true,
        columnWidthMode: ColumnWidthMode.fill,
        selectionMode: SelectionMode.multiple,
        headerRowHeight: 30,
        source: DateFieldsDataSource(context, profiles),
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
            label: _buildColumnLabel(context, 'Min Date'),
          ),
          GridColumn(
            columnName: 'max',
            label: _buildColumnLabel(context, 'Max Date'),
          ),
        ],
      ),
    );
  }
}

class DateFieldsDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];

  DateFieldsDataSource(this.context, List<DataQualityProfile> profiles) {
    dataGridRows = profiles.map<DataGridRow>((profile) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'columnName', value: profile.columnName),
        DataGridCell<String>(columnName: 'dataType', value: profile.dataType),
        DataGridCell<String>(columnName: 'min', value: profile.minValue.toString()),
        DataGridCell<String>(columnName: 'max', value: profile.maxValue.toString()),
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