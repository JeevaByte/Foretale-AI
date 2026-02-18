//core
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:highlight/languages/sql.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/screens/test_case/custom_code_formatter.dart';
import 'package:foretale_application/ui/screens/test_case/test_service.dart';
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';

class SqlQueryDialogWidget extends StatefulWidget {
  final Test test;

  const SqlQueryDialogWidget({
    super.key,
    required this.test,
  });

  @override
  State<SqlQueryDialogWidget> createState() => _SqlQueryDialogWidgetState();
}

class _SqlQueryDialogWidgetState extends State<SqlQueryDialogWidget> with TickerProviderStateMixin, PageEntranceAnimations {
  static const String _defaultQueryText = '-- No SQL query available --';
  static const String _currentFileName = "sql_query_dialog_widget";
  static const EdgeInsets _tabPadding = EdgeInsets.all(8);
  
  late final TabController _tabController;
  late final InquiryResponseModel _inquiryResponseModel;
  late final TestsModel _testsModel;
  
  String _firstCode = "";
  CodeController? _firstTabCodeController;

  String _secondCode = "";
  CodeController? _secondTabCodeController;

  @override
  void initState() {
    super.initState();
    initializeEntranceAnimations();
    startEntranceAnimations();
    _testsModel = Provider.of<TestsModel>(context, listen: false);
    _inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this);

    _initializeTabContent();

  }

  @override
  void dispose() {
    disposeEntranceAnimations();
    
    _tabController.dispose();
    _firstTabCodeController?.dispose();
    _secondTabCodeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    Widget content = buildSlideAndFadeTransition(
      child: Column(
        children: [
          _buildTopSection(context),
          const SizedBox(height: 20),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabHeader(context),
                  const SizedBox(height: 30),
                  _buildTabContent(context),
                  _buildSaveAndRunButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return CustomPageWrapper(
      size: size,
      onBackPressed: () => Navigator.pop(context),
      enableGradient: true,
      child: Center(child: content),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return buildFadeTransition(
      child: ProjectHeaderSection(
        projectName: 'CONFIGURATION',
        sectionTitle: widget.test.testName,
      ),
    );
  }

  Widget buildTab(BuildContext context, {required IconData icon, required String label}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 1.25;
    final fontSize = context.responsiveFontSize(16);
    final spacing = context.spacing(size: SpacingSize.small);
    
    return Tab(
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary, size: iconSize),
            SizedBox(width: spacing),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //build tab header
  Widget _buildTabHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(14);
    final indicatorWidth = context.indicatorWidth;
    
    return TabBar(
      controller: _tabController,
      indicatorColor: colorScheme.primary,
      indicatorWeight: indicatorWidth,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
      ),
      unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
      ),
      tabs: [
        buildTab(context, icon: Icons.settings, label: 'Test Configuration'),
        buildTab(context, icon: Icons.assessment, label: 'Impact Configuration'),
      ],
      onTap: (index) async {
        await _handleTabChange(index);
      },
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return Expanded(
      child: Consumer<TestsModel>(
        builder: (context, testsModel, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildFirstTab(testsModel),
              _buildSecondTab(testsModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSaveAndRunButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 1.125;
    final spacing = context.spacing(size: SpacingSize.medium);
    
    return Selector<TestsModel, bool>(
      selector: (context, testsModel) => testsModel.getIsSaveHappening,
      builder: (context, isSaveHappening, child) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomIconButton(
                icon: Icons.save,
                onPressed: () => TestService.saveSqlQuery(context, widget.test, _firstCode, _secondCode),
                tooltip: 'Save Query',
                iconSize: iconSize,
                isEnabled: widget.test.testConfigExecutionStatus.trim() != "Running" && !isSaveHappening,
                iconColor: colorScheme.primary,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
              ),
              SizedBox(width: spacing),
              CustomIconButton(
                icon: Icons.play_arrow,
                onPressed: () => TestService.saveAndRunSqlQuery(context, widget.test, _firstCode, _secondCode),
                tooltip: 'Save & Run Query',
                iconSize: iconSize,
                isEnabled: widget.test.testConfigExecutionStatus.trim() != "Running",
                iconColor: colorScheme.primary,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
                isProcessing: isSaveHappening,
              ),
            ],
          );
      },
    ); 
  }

  // Tab Building Methods
  Widget _buildFirstTab(TestsModel testsModel) {
    final firstQueryText = _resolveQueryText(testsModel.getSelectedTest.config);
    if (_firstCode != firstQueryText) {
      _firstCode = firstQueryText;
      _firstTabCodeController?.text = firstQueryText;
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Left section - 60% of width
            Expanded(
              flex: 60,
              child: _buildCodeFormatter(
                testsModel.getSelectedTest,
                _firstCode,
                constraints.maxWidth * 0.6,
                (code) => _updateCodeController(_firstTabCodeController, code),
                tabIndex: 0,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecondTab(TestsModel testsModel) {
    // Update _secondCode when configImpactStatement changes
    final secondQueryText = _resolveQueryText(testsModel.getSelectedTest.configImpactStatement);
    if (_secondCode != secondQueryText) {
      _secondCode = secondQueryText;
      _secondTabCodeController?.text = secondQueryText;
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Left section - 60% of width
            Expanded(
              flex: 60,
              child: _buildCodeFormatter(
                testsModel.getSelectedTest,
                _secondCode,
                constraints.maxWidth * 0.6,
                (code) => _updateCodeController(_secondTabCodeController, code),
                tabIndex: 1,
              ),
            )
          ],
        );
      },
    );
  }

  // Code Formatter and Handler Methods
  Widget _buildCodeFormatter(
    Test test,
    String queryText,
    double width,
    void Function(String) onCodeChanged,
    {int tabIndex = 0}
  ) {
    return Container(
      width: width,
      padding: _tabPadding,
      child: CustomCodeFormatter(
        key: ValueKey('${test.testId}_tab_${tabIndex}_${test.testConfigExecutionStatus}'),
        isCodeRunning: test.testConfigExecutionStatus.trim() == "Running",
        initialCode: queryText,
        onCodeChanged: onCodeChanged,
        width: width,
        showSaveRunButtons: false, // We're handling buttons in the Actions section
        onSaveQuery: () => TestService.saveSqlQuery(context, test, _firstCode, _secondCode),
        onRunQuery: () => TestService.saveAndRunSqlQuery(context, test, _firstCode, _secondCode),
      ),
    );
  }

  void _initializeTabContent() {
    try{
      // Initialize first tab content
      final firstQueryText = _resolveQueryText(widget.test.config);
      _firstCode = firstQueryText;
      _firstTabCodeController = CodeController(
        text: firstQueryText,
        language: sql,
      );

      // Initialize second tab content
      final secondQueryText = _resolveQueryText(widget.test.configImpactStatement);
      _secondCode = secondQueryText;
      _secondTabCodeController = CodeController(
        text: secondQueryText,
        language: sql,
      );
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context, 
        "Error initializing tab content: $e",
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_initializeTabContent");
    }
  }

  String _resolveQueryText(String? rawQuery) {
    final normalized = (rawQuery ?? '').replaceAll('\\n', '\n').trim();
    return normalized.isNotEmpty ? normalized : _defaultQueryText;
  }

  void _updateCodeController(CodeController? controller, String code) {
    if (controller == null) return;

    try {
      if (controller == _firstTabCodeController) {
        _firstCode = code;
      } else if (controller == _secondTabCodeController) {
        _secondCode = code;
      }
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context, 
        "Error updating code controller: $e",
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_updateCodeController");
    }
  }

  Future<void> _handleTabChange(int index) async {
    try{
      _inquiryResponseModel.setIsPageLoading(true);
      await _testsModel.fetchResponses(context);
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context, 
        "Error loading responses: $e",
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_handleTabChange");
    }
    finally{
      _inquiryResponseModel.setIsPageLoading(false);
    }
  }


}