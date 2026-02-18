import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_reporting_section.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/report_model.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_columns.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

//change to statefule widget
class ReportTestResultsTab extends StatefulWidget {
  const ReportTestResultsTab({super.key});

  @override
  State<ReportTestResultsTab> createState() => _ReportTestResultsTabState();
}

class _ReportTestResultsTabState extends State<ReportTestResultsTab> {
  late ExecutionStatsModel executionStatsModel;
  final String _currentFileName = "ReportTestResultsTab";

  @override
  void initState() {
    super.initState();
    executionStatsModel = Provider.of<ExecutionStatsModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadPage();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { 
    return Selector<ExecutionStatsModel, bool>(
      selector: (context, executionStatsModel) => executionStatsModel.getIsPageLoading,
      builder: (context, getIsPageLoading, child) {
        if (getIsPageLoading) {
          return buildLoadingState(context);
        } else {
          return  buildReportingSection(
            title: "SUMMARY BY TEST",
            icon: Icons.assessment,
            context,
            child: Selector<ExecutionStatsModel, List<TestResultSummary>>(
                  selector: (context, executionStatsModel) => executionStatsModel.testResultSummaryList,
                  builder: (context, testResultSummaryList, child) {
                    return buildTestSummaryTable(context, testResultSummaryList);
                  },
                )
            );
        }
      });
  }

  Future<void> _loadPage() async {
    try {
      //avoid reloading
      executionStatsModel.setIsPageLoading = true;
      executionStatsModel.getTestResultSummary(context);

    } catch (e) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: StackTrace.current.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage"
          );
      }
    } finally {
      executionStatsModel.setIsPageLoading = false;
    }
  }
} 

List<CustomGridColumn> _getCustomGridColumns() {
  return [
    CustomGridColumn(
      columnName: 'testCode',
      width: 180,
      label: 'Test Code',
      cellType: CustomCellType.text,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.start,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
    CustomGridColumn(
      columnName: 'testName',
      width: 250,
      label: 'Name',
      cellType: CustomCellType.text,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.start,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
    CustomGridColumn(
      columnName: 'testDescription',
      width: 350,
      label: 'Description',
      cellType: CustomCellType.text,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.start,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
    CustomGridColumn(
      columnName: 'testStatus',
      width: 150,
      label: 'Status',
      cellType: CustomCellType.categorical,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.center,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
    CustomGridColumn(
      columnName: 'totalFindings',
      width: 120,
      label: 'Total Findings',
      cellType: CustomCellType.number,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.center,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
    CustomGridColumn(
      columnName: 'acceptedFindings',
      width: 124,
      label: 'Accepted Findings',
      cellType: CustomCellType.number,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.center,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
    CustomGridColumn(
      columnName: 'otherFindings',
      width: 124,
      label: 'Other Findings',
      cellType: CustomCellType.number,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.center,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
    CustomGridColumn(
      columnName: 'peopleError',
      width: 124,
      label: 'People Error',
      cellType: CustomCellType.number,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.center,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
    CustomGridColumn(
      columnName: 'processError',
      width: 124,
      label: 'Process Error',
      cellType: CustomCellType.number,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.center,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
    CustomGridColumn(
      columnName: 'systemError',
      width: 124,
      label: 'System Error',
      cellType: CustomCellType.number,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.center,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
    CustomGridColumn(
      columnName: 'dataError',
      width: 124,
      label: 'Data Error',
      cellType: CustomCellType.number,
      allowSorting: true,
      allowFiltering: true,
      textAlign: TextAlign.center,
      checkboxUpdateCallback: const {},
      dropdownUpdateCallback: const {},
    ),
  ];
}


List<Map<String, dynamic>> _convertToCustomGridData(List<TestResultSummary> testResultSummaryList) {
  return testResultSummaryList.map((test) => {
    'testCode': test.testCode,
    'testName': test.testName,
    'testDescription': test.testDescription,
    'testStatus': test.testStatus,
    'totalFindings': test.totalFindings,
    'acceptedFindings': test.acceptedFindings,
    'otherFindings': test.otherFindings,
    'peopleError': test.peopleError,
    'processError': test.processError,
    'systemError': test.systemError,
    'dataError': test.dataError,
  }).toList();
}

Widget  buildTestSummaryTable(BuildContext context, List<TestResultSummary> testResultSummaryList) {
  if (testResultSummaryList.isNotEmpty) {
    final columns = _getCustomGridColumns();
    final data = _convertToCustomGridData(testResultSummaryList);

    return SizedBox(
      //i want the grid to occupy full width of the parent widget
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      child: CustomGrid(
        columns: columns,
        data: data,
        gridAllowSorting: true,
        gridAllowFiltering: true,
        gridAllowPagination: false,
        gridAllowSelection: true,
        gridAllowMultiSelection: false,
        columnWidthMode: ColumnWidthMode.fitByCellValue,
        headerRowHeight: 55,
        rowHeight: 36,
        gridOnRowTap: (rowData, rowIndex) {
        },
      ),
    );
  }
  return const Center(
    child: EmptyState(
      title: 'No Results',
      subtitle: 'Please ensure the test has been run and configured correctly.',
      icon: Icons.table_view_outlined,
    )
  );
}