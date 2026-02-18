//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_tab_header.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';
import 'package:foretale_application/ui/widgets/custom_slider.dart';
import 'package:foretale_application/ui/widgets/simple_table_grid_widget.dart';
import 'package:provider/provider.dart';

//models
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/models/tests_model.dart';

//ui
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_columns.dart';
import 'package:foretale_application/ui/screens/landing/landing.dart';
import 'package:foretale_application/ui/screens/storyboard/story.dart';

//utils
import 'package:foretale_application/core/utils/responsive.dart';

//widgets
import 'package:foretale_application/ui/widgets/ai_box/ai_box.dart';
import 'package:foretale_application/ui/widgets/custom_toggle.dart';
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';

//utils
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/excel_export_util.dart';
import 'package:foretale_application/core/utils/json_table_parser.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ResultScreen extends StatefulWidget {
  final Test test;

  const ResultScreen({
    super.key, 
    required this.test
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin, PageEntranceAnimations {
  final String _currentFileName = "result.dart";

  late TabController _tabController;

  late InquiryResponseModel _inquiryResponseModel;
  late ResultModel _resultModel;

  // Freeze columns controller (UI only)
  final TextEditingController _freezeColumnsController = TextEditingController();
  
  // Horizontal scroll controller for the grid - can be controlled from other widgets
  final ScrollController _gridHorizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeEntranceAnimations();
    startEntranceAnimations();
    _tabController = TabController(length: 3, vsync: this);
    
    // Add listener to clear analysis selections when Analysis tab is selected
    _tabController.addListener(() {
      if (_tabController.index == 2 && _tabController.indexIsChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _resultModel.clearAnalysisSelections();
        });
      }
    });
    
    _resultModel = Provider.of<ResultModel>(context, listen: false);
    _inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);

    _freezeColumnsController.value = TextEditingValue(text: _resultModel.getFrozenColumnsCount.toString());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadPage();
    });
  }

  @override
  void dispose() {
    _freezeColumnsController.dispose();
    _gridHorizontalScrollController.dispose();
    disposeEntranceAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return CustomPageWrapper(
      size: size,
      onBackPressed: () => Navigator.pop(context),
      onHomePressed: () => context.fadeNavigateTo(const LandingPage()),
      child: Column(
        children: [
          ProjectHeaderSection(
            projectName: 'TEST FINDINGS',
            sectionTitle: widget.test.testName,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildMainContent(context, size),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer<ResultModel>(
        builder: (context, resultModel, child) {
          return Column(
            children: [
              _buildTabBar(context),
              const SizedBox(height: 10),
              if (resultModel.getIsPageLoading)
                buildLoadingState(context)
              else if (resultModel.genericGridColumns.isEmpty || resultModel.tableData.isEmpty)
                const EmptyState(
                  title: "No Results Found",
                  subtitle: "Please ensure the test has been run and configured correctly.",
                  icon: Icons.table_view_outlined,
                )
              else
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSnapshotSection(context, resultModel),
                      _buildDataGridSection(context, resultModel),
                      _buildAnalysisSection(context, resultModel),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(14);
    final indicatorWidth = context.indicatorWidth;
    
    return TabBar(
      controller: _tabController,
      indicatorColor: colorScheme.primary,
      indicatorWeight: indicatorWidth,
      labelStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
      ),
      unselectedLabelStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
      ),
      tabs: [
        buildTabHeader(context, icon: Icons.analytics_outlined, label: 'Summary'),
        buildTabHeader(context, icon: Icons.table_view_outlined, label: 'Flagged Transactions'),
        buildTabHeader(context, icon: Icons.analytics_outlined, label: 'Analysis'),
      ],
    );
  }

  Widget _buildSamplesToggle(BuildContext context, ResultModel resultModel) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomToggle(
      value: resultModel.getShowSamplesOnly,
      onChanged: (value) {
        resultModel.updateSelectedTransactions(value);
      },
      activeColor: colorScheme.primary,
      inactiveColor: Colors.transparent,
      bottomLabel: 'Samples',
    );
  }

  Widget _buildActionButtons(BuildContext context, List<CustomGridColumn> columns, List<Map<String, dynamic>> data) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconPadding = context.spacing(size: SpacingSize.small);
    final spacing = context.spacing(size: SpacingSize.small) * 1.25;
    
    return Row(
      children: [
        CustomIconButton(
          icon: Icons.download, 
          onPressed: () => _exportToExcel(columns, data),
          tooltip: 'Download to Excel',
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
          padding: iconPadding,
          isEnabled: true,
        ),
        SizedBox(width: spacing),
        // Horizontal scroll control buttons
        CustomIconButton(
          icon: Icons.arrow_back_ios, 
          onPressed: () {
            // Scroll left
            _gridHorizontalScrollController.animateTo(
              _gridHorizontalScrollController.offset - 200,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          tooltip: 'Scroll Left',
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
          padding: iconPadding,
          isEnabled: true,
        ),
        SizedBox(width: spacing),
        CustomIconButton(
          icon: Icons.arrow_forward_ios, 
          onPressed: () {
            // Scroll right
            _gridHorizontalScrollController.animateTo(
              _gridHorizontalScrollController.offset + 200,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          tooltip: 'Scroll Right',
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
          padding: iconPadding,
          isEnabled: true,
        ),
      ],
    );
  }

  Widget _buildSnapshotSection(BuildContext context, ResultModel resultModel) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CustomContainer(
            title: 'Potential Impact',

            child: _buildPotentialImpactSection(context, resultModel),
          ),
        ],
      );
  }

  Widget _buildDataGridSection(BuildContext context, ResultModel resultModel) {
    final columns = resultModel.genericGridColumns;
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: _buildFlaggedTransactionsLeftSection(context, resultModel, resultModel.filteredTableData, columns),
        ),
        const SizedBox(width: 5),
        if (resultModel.getSelectedId(context) > 0)
          Expanded(
            flex: 2,
            child: _buildFlaggedTransactionsRightSection(context, resultModel),
          ),
      ],
    );
  }

  Widget _buildPotentialImpactSection(BuildContext context, ResultModel resultModel) {
    const emptyState = Center(
      child: EmptyState(
        title: "No Impact Data Available",
        subtitle: "Impact analysis has not been generated for this test.",
        icon: Icons.warning_outlined,
      ),
    );

    final jsonString = widget.test.configImpactStatementResultJson.trim();
    print(jsonString);
    if (jsonString.isEmpty || !_isLikelyJson(jsonString)) {
      return emptyState;
    }

    List<Map<String, dynamic>> tableData;
    try {
      tableData = JsonTableParser.parseJsonToTableData(jsonString);
    } catch (_) {
      return emptyState;
    }

    if (tableData.isEmpty) {
      return emptyState;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: SimpleTableGridWidget(data: tableData),
        ),
      ],
    );
  }

  bool _isLikelyJson(String value) => value.startsWith('{') || value.startsWith('[');

  Widget _buildAnalysisSection(BuildContext context, ResultModel resultModel) {
    return const StoryPage();
  }

  Widget _buildFlaggedTransactionsLeftSection(
    BuildContext context,
    ResultModel resultModel,
    List<Map<String, dynamic>> data,
    List<CustomGridColumn> columns,
  ) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              // Left side: Freeze Columns and Samples
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: CustomSlider(
                      value: _resultModel.getFrozenColumnsCount,
                      min: 0,
                      max: columns.length,
                      bottomLabel:'Freeze Columns',
                      isEnabled: true,
                      onChanged: (value) {
                        resultModel.updateFrozenColumnsCount(value.toInt(), columns.length);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildSamplesToggle(context, resultModel),
                ],
              ),
              Spacer(),
              // Right side: Download and Scroll buttons
              _buildActionButtons(context, columns, data),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomContainer(
                title: 'Flagged Transactions',
                child: CustomGrid(
                  key: ValueKey('custom_grid_${data.length}_${resultModel.getShowSamplesOnly}'),
                  columns: columns,
                  data: data,
                  firstColumnName: 'is_selected',
                  enablePagination: false,
                  gridOnRowTap: (rowData, rowIndex) {
                      _updateSelectedResultId(rowData['feedback_id'].toString());
                  },
                  frozenColumnsCount: resultModel.getFrozenColumnsCount,
                  columnWidthMode: ColumnWidthMode.fitByCellValue,
                  horizontalScrollController: _gridHorizontalScrollController,
                )
              ),
          ),
        ],
      )
    );
  }

  Widget _buildFlaggedTransactionsRightSection(BuildContext context, ResultModel resultModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Selector<ResultModel, int>(
        selector: (context, model) => model.getSelectedId(context),
        builder: (context, selectedId, __) {
          return CustomContainer(
            title: 'Chat',
            child: AIBox(
              key: ValueKey('result_chat_$selectedId'),
              drivingModel: resultModel,
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateSelectedResultId(String selectedId) async {
    try
    {
      _inquiryResponseModel.setIsPageLoading(true);

      final feedbackId = int.tryParse(selectedId)??0;

      if (_resultModel.getSelectedId(context) == feedbackId) {
        _resultModel.updateSelectedFeedback(0);
      } else {
        _resultModel.updateSelectedFeedback(feedbackId);
      }

      await _inquiryResponseModel.fetchResponsesByReference(context, feedbackId, 'feedback');
    } catch (e, errorStackTrace) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context,
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_updateSelectedResultId",
        );
      }
    } finally {
      _inquiryResponseModel.setIsPageLoading(false);
    } 
  }

  void _exportToExcel(List<CustomGridColumn> columns, List<Map<String, dynamic>> data) {
    try{
      const excludedColumns = {'project_id', 'test_id', 'table_reference', 'hash_key', 'record_status', 'created_date', 'created_by'};
      
      final filteredColumns = columns.where((col) => !excludedColumns.contains(col.columnName)).toList();

      final columnsMap = filteredColumns.map((col) => {
        'columnName': col.columnName,
        'label': (col.columnName == 'is_selected') ? 'SAMPLE' : col.label.toUpperCase().replaceAll('_', ' '),
      }).toList();
      
      ExcelExportUtil.exportGridToExcel(
        context,
        columns: columnsMap,
        data: data,
        fileName: 'result_${widget.test.testCode}_${DateTime.now().millisecondsSinceEpoch}'
      );
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context,
        e.toString(),
        logError: true,
        errorMessage: e.toString(),
        errorStackTrace: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_exportToExcel",
      );
    } 
  }

  Future<void> _loadPage() async {
    if (!mounted) return;
    _resultModel.setSelectedTestId = widget.test.testId;

    try {
      _resultModel.setIsPageLoading = true;
      
      if(widget.test.flaggedTransactionsCount > 0){
        _resultModel.totalRows = widget.test.flaggedTransactionsCount;
      } else {
        _resultModel.totalRows = 500;
      }

      await _resultModel.updateDataGrid(context, widget.test);
    } catch (e, errorStackTrace) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context,
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage",
        );
      }
    } finally {
      _resultModel.setSelectedTestId = widget.test.testId;
      _resultModel.setIsPageLoading = false;
    }
  }
}

