import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/team_contacts_model.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TeamContactsDataGrid extends StatelessWidget {
  const TeamContactsDataGrid({super.key});

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
      child: Consumer<TeamContactsModel>(builder: (context, model, child) {
        return SfDataGrid(
          allowEditing: true,
          allowSorting: true,
          allowFiltering: true,
          isScrollbarAlwaysShown: true,
          columnWidthMode: ColumnWidthMode.fill, // Expands columns to fill the grid width
          selectionMode: SelectionMode.multiple,
          headerRowHeight: 30,
          rowHeight: 32,
          source: TeamContactDataSource(context, model, model.getTeamContacts),
          columns: <GridColumn>[
              GridColumn(
                columnName: 'name',
                label: _buildColumnLabel(context, 'Name'),
              ),
              GridColumn(
                columnName: 'position',
                label: _buildColumnLabel(context, 'Position'),
              ),
              GridColumn(
                columnName: 'function',
                label: _buildColumnLabel(context, 'Function'),
              ),
              GridColumn(
                columnName: 'email',
                label: _buildColumnLabel(context, 'Email'),
              ),
              // New delete column
            GridColumn(
              allowSorting: false,
              allowFiltering: false,
              width:50.0,
              columnName: 'delete',
              label: _buildColumnLabel(context, ''),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TeamContactDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];
  List<TeamContact> teamContacts;
  TeamContactsModel teamContactsModel;
  final String _currentFileName = "sfdg_team_contacts.dart";

  TeamContactDataSource(
    this.context,
    this.teamContactsModel, 
    this.teamContacts,
    ) {

    buildDataGridRows();

  }

  // This method is used to build the DataGridRow for each team contact
  void buildDataGridRows() {
    dataGridRows = teamContacts.map<DataGridRow>((teamContact) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: teamContact.name),
        DataGridCell<String>(columnName: 'position', value: teamContact.position),
        DataGridCell<String>(columnName: 'function', value: teamContact.function),
        DataGridCell<String>(columnName: 'email', value: teamContact.email),
        // Add delete icon to each row
        DataGridCell<Widget>(columnName: 'delete', 
        value: _buildDeleteButton(teamContact)),
      ]);
    }).toList();
  }

  Widget _buildDeleteButton(TeamContact teamContact) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 0.8;
    return CustomIconButton(
      icon: Icons.delete,
      iconSize: iconSize,
      padding: 0.0,
      backgroundColor: Colors.transparent,
      iconColor: colorScheme.primary,
      onPressed: () => _removeContact(teamContact),
    );
  }

  void _removeContact(TeamContact teamContact) {
    try
    {
      teamContacts.removeWhere((t) => t.id == teamContact.id);
      teamContactsModel.removeContact(context, teamContact);
      buildDataGridRows();
      notifyListeners();
    } catch(e, errorStackTrace){
      SnackbarMessage.showErrorMessage(
        context, 
        'Failed to remove team contact',
        logError: true,
        errorMessage: e.toString(),
        errorStackTrace: errorStackTrace.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_removeContact",
      );
    }
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.value is Widget) {
          // For the delete button, return the widget (the icon button)
          final padding = context.spacing(size: SpacingSize.small);
          return Container(
            padding: EdgeInsets.all(padding),
            alignment: Alignment.center,
            child: dataGridCell.value as Widget,
          );
        }
        // For other cells, return the text value as usual
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

