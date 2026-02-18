import 'package:flutter/material.dart';
import 'package:foretale_application/models/question_model.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class QuestionsDataGrid extends StatelessWidget {
  const QuestionsDataGrid({super.key});

  Widget _buildColumnLabel(BuildContext context, String text, {double paddingFactor = 0.5}) {
    final theme = Theme.of(context);
    final padding = context.spacing(size: SpacingSize.small) * paddingFactor;
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
      child: Consumer<QuestionsModel>(builder: (context, model, child) {
        return SfDataGrid(
          allowEditing: true,
          allowSorting: true,
          allowFiltering: true,
          isScrollbarAlwaysShown: true,
          columnWidthMode: ColumnWidthMode.fill, // Expands columns to fill the grid width
          selectionMode: SelectionMode.single,
          source: QuestionsDataSource(context, model, model.getQuestionsList),
          headerRowHeight: 30,
          rowHeight: 32,
          columns: <GridColumn>[
              GridColumn(
                width: 50,
                allowSorting: false,
                allowFiltering: false,
                columnName: 'isSelected',
                label: _buildColumnLabel(context, ''),
              ),
              GridColumn(
                width: MediaQuery.of(context).size.width * 0.20,
                columnName: 'questionText',
                label: _buildColumnLabel(context, 'Question', paddingFactor: 0.25),
              ),
              GridColumn(
                columnWidthMode: ColumnWidthMode.auto,
                visible: false,
                columnName: 'industry',
                label: _buildColumnLabel(context, 'Industry', paddingFactor: 0.25),
              ),
              GridColumn(
                columnWidthMode: ColumnWidthMode.auto,
                visible: false,
                columnName: 'projectType',
                label: _buildColumnLabel(context, 'Project Type', paddingFactor: 0.25),
              ),
              GridColumn(
                columnWidthMode: ColumnWidthMode.fitByCellValue,
                visible: true,
                columnName: 'topic',
                label: _buildColumnLabel(context, 'Topic', paddingFactor: 0.25),
              ),
              GridColumn(
                columnWidthMode: ColumnWidthMode.fitByColumnName,
                columnName: 'createdDate',
                label: _buildColumnLabel(context, 'Created Date', paddingFactor: 0.25),
              ),
              GridColumn(
                columnName: 'createdBy',
                label: _buildColumnLabel(context, 'Created By', paddingFactor: 0.25),
              ),
              GridColumn(
                visible: false,
                columnName: 'questionId',
                label: _buildColumnLabel(context, 'question_id'),
              ),
              // New delete column
              GridColumn(
                allowSorting: false,
                allowFiltering: false,
                width: 50.0,
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

class QuestionsDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];
  List<Question> questionsList;
  QuestionsModel questionsModel;
  final String _currentFileName = "sfdg_questions.dart";

  QuestionsDataSource(this.context, this.questionsModel, this.questionsList) {
    buildDataGridRows();
  }

  // This method is used to build the DataGridRow for each question
  void buildDataGridRows() {
    dataGridRows = questionsList.map<DataGridRow>((row) {
      return DataGridRow(cells: [
        _buildCheckboxCell(row),
        DataGridCell<String>(columnName: 'questionText', value: row.questionText),
        DataGridCell<String>(columnName: 'industry', value: row.industry),
        DataGridCell<String>(columnName: 'projectType', value: row.projectType),
        DataGridCell<String>(columnName: 'topic', value: row.topic),
        DataGridCell<String>(columnName: 'createdDate', value: row.createdDate),
        DataGridCell<String>(columnName: 'createdBy', value: row.createdBy),
        DataGridCell<int>(columnName: 'questionId', value: row.questionId),
        // Add delete button to each row
        DataGridCell<Widget>(columnName: 'delete', 
        value: _buildDeleteButton(row)),
      ]);
    }).toList();
  }

  // Helper method to create checkbox cell with consolidated logic
  DataGridCell<Widget> _buildCheckboxCell(Question row) {
    return DataGridCell<Widget>(
      columnName: 'isSelected',
      value: IconButton(
        icon: Icon(
          size: 16,
          row.isSelected ? Icons.check_box : Icons.check_box_outline_blank,
          color: Colors.red,
        ),
        onPressed: () => _handleQuestionToggle(row),
      ),
    );
  }

  // Helper method to handle question selection/deselection
  Future<void> _handleQuestionToggle(Question row) async {
    try {
      final resultId = row.isSelected
          ? await questionsModel.unselectQuestion(context, row)
          : await questionsModel.selectQuestion(context, row);
      
      if (resultId > 0) {
        buildDataGridRows();
        notifyListeners();
      }
    } catch (e) {
      SnackbarMessage.showErrorMessage(context, e.toString());
    }
  }

  Widget _buildDeleteButton(Question question) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 0.8;
    return CustomIconButton(
      icon: Icons.delete,
      iconSize: iconSize,
      padding: 0.0,
      backgroundColor: Colors.transparent,
      iconColor: colorScheme.primary,
      onPressed: () => _removeQuestion(question),
    );
  }

  // Helper method to handle question deletion
  Future<void> _removeQuestion(Question question) async {
    try {
      questionsList.removeWhere((q) => q.questionId == question.questionId);
      questionsModel.removeQuestion(context, question);
      buildDataGridRows();
      notifyListeners();
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(
        context, 
        'Failed to remove question',
        logError: true,
        errorMessage: e.toString(),
        errorStackTrace: errorStackTrace.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_removeQuestion",

      );
    }
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        // For the widget column (checkbox and delete button)
        if (dataGridCell.value is Widget) {
          final padding = context.spacing(size: SpacingSize.small) / 8;
          return Container(
            padding: EdgeInsets.all(padding),
            alignment: Alignment.center,
            child: dataGridCell.value as Widget,
          );
        }
        // Check if the column is "questionText" and apply center-left alignment
        Alignment alignment = dataGridCell.columnName == "questionText"
            ? Alignment.centerLeft
            : Alignment.center;

        final theme = Theme.of(context);
        final padding = context.spacing(size: SpacingSize.small) / 8;
        
        // For "questionText" column, display it with a max of 3 lines
        if (dataGridCell.columnName == "questionText") {
          return Container(
            padding: EdgeInsets.all(padding),
            alignment: alignment,
            child: Text(
              dataGridCell.value.toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(padding),
          alignment: alignment,
          child: Text(
            dataGridCell.value.toString(),
            style: theme.textTheme.bodySmall,
          ),
        );
      }).toList(),
    );
  }
}
