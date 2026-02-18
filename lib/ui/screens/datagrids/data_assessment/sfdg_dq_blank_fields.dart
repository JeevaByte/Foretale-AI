import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/data_assessment_model.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';

class NullFieldsDataGrid extends StatelessWidget {
  final List<DataQualityProfile> profiles;
  const NullFieldsDataGrid({super.key, required this.profiles});

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
        source: NullFieldsDataSource(context, profiles),
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
            columnName: 'nulls',
            label: _buildColumnLabel(context, 'Nulls'),
          ),
        ],
      ),
    );
  }
}

class NullFieldsDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];

  NullFieldsDataSource(this.context, List<DataQualityProfile> profiles) {
    dataGridRows = profiles.map<DataGridRow>((profile) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'columnName', value: profile.columnName),
        DataGridCell<String>(columnName: 'dataType', value: profile.dataType),
        DataGridCell<int>(columnName: 'nulls', value: profile.nullCount),
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