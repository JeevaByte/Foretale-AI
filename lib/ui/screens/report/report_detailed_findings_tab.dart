import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_reporting_section.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/core/utils/pdf_export_util.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/report_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/ui/screens/analysis/result.dart';
import 'package:foretale_application/ui/screens/report/report_matrix_service.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/chat/response_text_widget.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/agent/message_parser.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/responsive_wrap.dart';
import 'package:provider/provider.dart';

class ReportDetailedFindingsTab extends StatefulWidget {
  const ReportDetailedFindingsTab({super.key});

  @override
  State<ReportDetailedFindingsTab> createState() => _ReportDetailedFindingsTabState();
}

class _ReportDetailedFindingsTabState extends State<ReportDetailedFindingsTab> {
  late TestsModel _testsModel;
  final String _currentFileName = "report_detailed_findings_tab.dart";
  Test? _selectedTest;
  String _selectedCriticality = 'All';

  @override
  void initState() {
    super.initState();
    _testsModel = Provider.of<TestsModel>(context, listen: false);

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
    return Consumer<TestsModel>(
      builder: (context, testsModel, child) {
        if (testsModel.getIsPageLoading) {
          return buildLoadingState(context);
        }
        
        final completedTests = testsModel.fetchReportableTests(context);
        
        if (completedTests.isEmpty) {
          return const EmptyState(
            title: "No completed tests found",
            subtitle: "Complete tests to see detailed findings",
            icon: Icons.search_off,
          );
        }
                    
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: buildReportingSection(
                    title: "COMPLETED TESTS",
                    icon: Icons.list_alt,
                    context,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: _buildTestList(completedTests),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: buildReportingSection(
                    title: "DETAILED FINDINGS",
                    icon: Icons.analytics_outlined,
                    context,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: _selectedTest != null 
                          ? _buildTestDetails(_selectedTest!)
                          : _buildNoSelectionState(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildTestList(List<Test> tests) {
    List<Test> filteredTests = _selectedCriticality == 'All' 
        ? tests 
        : tests.where((test) => test.testCriticality.toLowerCase() == _selectedCriticality.toLowerCase()).toList();

    return Column(
      children: [
        _buildCriticalityFilters(context, tests),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            key: ValueKey<String>('test_list_$_selectedCriticality'),
            itemCount: filteredTests.length,
            itemBuilder: (context, index) {
              final test = filteredTests[index];
              Color severityColor = ReportService.getCriticalityColor(test.testCriticality);
              return _buildTestListItem(context, test, severityColor);
            },
          ),
        ),
      ],
    );
  }


  Widget _buildCriticalityLabel(BuildContext context, String criticality, int count, Color severityColor) {
    final theme = Theme.of(context);
    final labelFontSize = context.responsiveFontSize(10);
    final countFontSize = context.responsiveFontSize(14);
    return Column(
      children: [
        Text(
          criticality.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: severityColor,
            fontWeight: FontWeight.w600,
            fontSize: labelFontSize,
          ),
        ),
        SizedBox(height: context.spacing(size: SpacingSize.small) / 4),
        Text(
          count.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: severityColor,
            fontWeight: FontWeight.w700,
            fontSize: countFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildTestListItemText(BuildContext context, Test test) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(14);
    final codeFontSize = context.responsiveFontSize(12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          test.testName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: fontSize,
          ),
        ),
        SizedBox(height: context.spacing(size: SpacingSize.small) / 2),
        Text(
          test.testCode,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: codeFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalityFilters(BuildContext context, List<Test> tests) {
    final groupedTests = <String, List<Test>>{};
    for (var test in tests) {
      final criticality = test.testCriticality.toLowerCase();
      groupedTests[criticality] = (groupedTests[criticality] ?? [])..add(test);
    }

    const criticalityOrder = ['critical', 'high', 'medium', 'low'];
    final criticalities = <String>['All'];
    
    for (final criticality in criticalityOrder) {
      if (groupedTests.containsKey(criticality)) {
        criticalities.add(criticality);
      }
    }
    
    return ResponsiveWrap(
      spacing: 8.0,
      runSpacing: 0.0,
      breakpoint: 0.0, // Always use wide screen mode
      minChildWidth: 60.0,
      maxChildWidth: 120.0,
      children: criticalities.map((criticality) {
        final count = criticality == 'All' 
            ? groupedTests.values.fold(0, (sum, list) => sum + list.length)
            : groupedTests[criticality]?.length ?? 0;
        
        final isSelected = _selectedCriticality == criticality;
        final severityColor = criticality == 'All' 
            ? Colors.grey.shade600
            : ReportService.getCriticalityColor(criticality);
        
        return Material(
          color: isSelected ? severityColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedCriticality = criticality;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? severityColor : Colors.grey.shade400,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  _buildCriticalityLabel(context, criticality, count, severityColor),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTestListItem(BuildContext context, Test test, Color severityColor) {
    final isSelected = _selectedTest?.testCode == test.testCode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? severityColor : Colors.grey.shade400,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedTest = test),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTestListItemText(context, test),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestDetails(Test test) {
    final severityColor = ReportService.getCriticalityColor(test.testCriticality);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTestHeader(context, test, severityColor),
          const SizedBox(height: 20),
          ..._buildDetailSections(test),
        ],
      ),
    );
  }

  Widget _buildTestHeaderText(BuildContext context, String testName) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(18);
    return Text(
      testName,
      style: theme.textTheme.titleLarge?.copyWith(
        fontSize: fontSize,
      ),
    );
  }

  Widget _buildTestHeader(BuildContext context, Test test, Color severityColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test name as main title with view results icon
          Row(
            children: [
              Expanded(
                child: _buildTestHeaderText(context, test.testName),
              ),
              const SizedBox(width: 8),
              CustomIconButton(
                icon: Icons.table_view_sharp,
                onPressed: () {
                  context.fadeNavigateTo(ResultScreen(test: test));
                },
                iconSize: 20,
                backgroundColor: Colors.grey.shade600,
                iconColor: Colors.white,
                padding: 8,
                isEnabled: true,
                tooltip: "View Test Results",
              ),
              const SizedBox(width: 8),
              CustomIconButton(
                icon: Icons.download_rounded,
                onPressed: () {
                  _downloadAnalysisReport(test);
                },
                iconSize: 20,
                backgroundColor: Colors.grey.shade600,
                iconColor: Colors.white,
                padding: 8,
                isEnabled: true,
                tooltip: "Download Analysis Report",
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Compact chips row for test code and criticality
          Row(
            children: [
              CustomChip(
                label: test.testCode,
                border: Border.all(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                height: 24,
              ),
              const SizedBox(width: 8),
              CustomChip(
                label: test.testCriticality.toUpperCase(),
                border: Border.all(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                height: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _downloadAnalysisReport(Test test) async {
    try {
      if (!mounted) return;

      // Show loading message
      SnackbarMessage.showSuccessMessage(
        context, 
        "Generating PDF report...",
      );

      // Prepare report data
      final reportData = await _prepareReportData(test);

      // Generate PDF filename
      final fileName = 'analysis_report_${test.testCode}_${DateTime.now().millisecondsSinceEpoch}';

      // Export to PDF
      await PdfExportUtil.exportAnalysisReportToPdf(
        context: context,
        reportData: reportData,
        fileName: fileName,
      );

      if (mounted) {
        SnackbarMessage.showSuccessMessage(
          context, 
          "Analysis report PDF generated successfully.",
        );
      }
    } catch (e, errorStackTrace) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context, 
          "Error generating analysis report PDF: ${e.toString()}",
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_downloadAnalysisReport"
        );
      }
    }
  }

  Future<Map<String, dynamic>> _prepareReportData(Test test) async {
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    final executionStatsModel = Provider.of<ExecutionStatsModel>(context, listen: false);
    
    // Get risk topics and recommendations for this test
    final riskTopics = executionStatsModel.riskTopicList
        .where((topic) => topic.testId == test.testId)
        .toList();
    
    final riskRecommendations = executionStatsModel.riskRecommendationList
        .where((rec) => rec.testId == test.testId)
        .toList();

    return {
      "slides": [
        {
          "slide_number": 1,
          "slide_type": "project_details",
          "title": "Project Details",
          "content": {
            "project_name": projectDetailsModel.getName,
            "project_description": projectDetailsModel.getDescription,
            "date_of_creation": projectDetailsModel.getProjectStartDate,
            "scope": "${projectDetailsModel.getProjectScopeStartDate} to ${projectDetailsModel.getProjectScopeEndDate}",
            "industry": projectDetailsModel.getIndustry,
            "company": projectDetailsModel.getOrganization,
            "system": projectDetailsModel.getSystemName
          }
        },
        {
          "slide_number": 2,
          "slide_type": "test_overview",
          "title": "Test Overview",
          "content": {
            "test_name": test.testName,
            "test_code": test.testCode,
            "criticality": test.testCriticality,
            "category": test.testCategory,
            "module": test.module,
            "description": test.testDescription,
            "potential_risks": test.identifiedRisks,
            "recommendations": test.identifiedRecommendations
          }
        },
        {
          "slide_number": 3,
          "slide_type": "test_results",
          "title": "Test Results",
          "content": {
            "test_result": _buildResultSummary(test),
            "potential_impact": test.configImpactStatementResultSummary,
            "feedback_summary": test.feedbackSummary
          }
        },
        {
          "slide_number": 4,
          "slide_type": "risks_and_recommendations",
          "title": "Identified Risks and Recommendations",
          "content": {
            "identified_risks": riskTopics.map((topic) => {
              "code": topic.code,
              "broad_category": topic.broadCategory,
              "category": topic.category,
              "risk_topic": topic.riskTopic,
              "reason": topic.reason,
              "test_id": topic.testId,
              "test_name": topic.testName,
              "criticality": topic.testCriticality,
              "test_code": topic.testCode
            }).toList(),
            "risk_recommendations": riskRecommendations.map((rec) => {
              "code": rec.code,
              "broad_category": rec.broadCategory,
              "category": rec.category,
              "recommendation": rec.recommendation,
              "reason": rec.reason,
              "test_id": rec.testId,
              "test_name": rec.testName,
              "criticality": rec.testCriticality,
              "test_code": rec.testCode
            }).toList()
          }
        }
      ]
    };
  }


  List<Widget> _buildDetailSections(Test test) {
    return [
      // Group 1: Description, Potential Risks, and Recommendations
      CustomContainer(
        title: "Information entered at the time of test creation",
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection(context, "Description", test.testDescription, Icons.description_outlined),
            _buildDetailSection(context, "Possible Risks", test.identifiedRisks, Icons.warning_outlined),
            _buildDetailSection(context, "Possible Recommendations", test.identifiedRecommendations, Icons.recommend_outlined),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // Group 2: Test Result, Potential Impact, Feedback Summary, and Risk Topics
      CustomContainer(
        title: "Test execution results",
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection(context, "Test Result", _buildResultSummary(test), Icons.check_circle_outline),
            _buildDetailSectionWithMarkdown(context, "Potential Impact", test.configImpactStatementResultSummary, Icons.warning_outlined),
            _buildDetailSectionWithMarkdown(context, "Feedback Summary", test.feedbackSummary, Icons.feedback_outlined),
            _buildRiskTopicsSection(context, test),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // Group 3: Risk Recommendations
      CustomContainer(
        title: "Recommendations",
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRiskRecommendationsSection(context, test)
          ],
        ),
      ),
    ];
  }

  Widget _buildDetailSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(14);
    return Text(
      title,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: fontSize,
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, String title, String content, IconData icon) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(14);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: context.iconSize(size: IconSize.small), color: colorScheme.onSurface.withValues(alpha: 0.6)),
              SizedBox(width: context.spacing(size: SpacingSize.small)),
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(size: SpacingSize.small)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.spacing(size: SpacingSize.small)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.borderRadius * 0.5),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
            ),
            child: ResponseTextWidget(responseText: content)
          ),
        ],
      ),
    );
  }

  Widget _buildMessageParser(BuildContext context, String content) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(14);
    return MessageParser(
      content: content,
      isUser: false,
      baseTextStyle: theme.textTheme.bodyMedium?.copyWith(
        fontSize: fontSize,
      ) ?? const TextStyle(),
    );
  }

  Widget _buildDetailSectionWithMarkdown(BuildContext context, String title, String content, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: context.iconSize(size: IconSize.small), color: colorScheme.onSurface.withValues(alpha: 0.6)),
              SizedBox(width: context.spacing(size: SpacingSize.small)),
              _buildDetailSectionTitle(context, title),
            ],
          ),
          SizedBox(height: context.spacing(size: SpacingSize.small)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.spacing(size: SpacingSize.small)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.borderRadius * 0.5),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
            ),
            child: _buildMessageParser(context, content),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentifiedRisksTitle(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(12);
    return Text(
      "Identified Risks",
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRiskTopicChips(BuildContext context, String broadCategory, String category) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing(size: SpacingSize.small) / 2;
    final chipHeight = context.iconSize(size: IconSize.small) * 1.5;
    return Row(
      children: [
        CustomChip(
          label: broadCategory,
          padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing / 2),
          textColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
          height: chipHeight,
        ),
        SizedBox(width: spacing),
        CustomChip(
          label: category,
          padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing / 2),
          textColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
          height: chipHeight,
        ),
      ],
    );
  }

  Widget _buildRiskTopicContent(BuildContext context, String riskTopic, String reason) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleFontSize = context.responsiveFontSize(16);
    final reasonFontSize = context.responsiveFontSize(12);
    final spacing = context.spacing(size: SpacingSize.small) / 2;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          riskTopic,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: titleFontSize,
            height: 1.4,
          ),
        ),
        if (reason.isNotEmpty) ...[
          SizedBox(height: spacing),
          Text(
            reason,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: reasonFontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRiskTopicsSection(BuildContext context, Test test) {
    return Consumer<ExecutionStatsModel>(
      builder: (context, executionStatsModel, child) {
        final riskTopics = executionStatsModel.riskTopicList
            .where((topic) => topic.testId == test.testId)
            .toList();

        if (riskTopics.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  _buildIdentifiedRisksTitle(context),
                ],
              ),
              const SizedBox(height: 12),
              
              // Cards Layout
              ...riskTopics.map((topic) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: _buildCardDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category and Code Row
                      Row(
                        children: [
                          _buildRiskTopicChips(context, topic.broadCategory, topic.category),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildRiskTopicContent(context, topic.riskTopic, topic.reason),
                    ],
                  ),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiskRecommendationsSection(BuildContext context, Test test) {
    return Consumer<ExecutionStatsModel>(
      builder: (context, executionStatsModel, child) {
        final riskRecommendations = executionStatsModel.riskRecommendationList
            .where((rec) => rec.testId == test.testId)
            .toList();

        if (riskRecommendations.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 12),
              
              // Cards Layout
              ...riskRecommendations.map((rec) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: _buildCardDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category and Code Row
                      Row(
                        children: [
                          CustomChip(
                            label: rec.broadCategory,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            textColor: Colors.black,
                            backgroundColor: Colors.green.shade100,
                            border: Border.all(color: Colors.green.shade400),
                            height: 24,
                          ),
                          const SizedBox(width: 4),
                          CustomChip(
                            label: rec.category,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            textColor: Colors.black,
                            backgroundColor: Colors.green.shade100,
                            border: Border.all(color: Colors.green.shade400),
                            height: 24,
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildRiskTopicContent(context, rec.recommendation, rec.reason),
                    ],
                  ),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoSelectionState() {
    return EmptyState(
      title: "Select a test to view details",
      subtitle: "No test selected",
      icon: Icons.touch_app,
    );
  }


  String _buildResultSummary(Test test) {
    return test.flaggedTransactionsCount > 0 
        ? "${test.flaggedTransactionsCount} findings."
        : "Test completed successfully.";
  }

  // Reusable decoration for cards
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade100,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }


  Future<void> _loadPage() async {
    try {
      _testsModel.setIsPageLoading = true;
      
      // Load tests and execution stats in parallel
      await Future.wait([
        _testsModel.fetchTestsByProject(context),
        Provider.of<ExecutionStatsModel>(context, listen: false).getRiskRecommendation(context),
        Provider.of<ExecutionStatsModel>(context, listen: false).getRiskTopic(context),
      ]);
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
          requestPath: "_loadPage"
        );
      }
    } finally {
      if (mounted) {
        _testsModel.setIsPageLoading = false;
      }
    }
  }
}
