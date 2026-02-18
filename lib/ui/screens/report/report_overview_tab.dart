import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_reporting_section.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/report_model.dart';
import 'package:provider/provider.dart';

class ReportOverviewTab extends StatefulWidget {
  const ReportOverviewTab({super.key});

  @override
  State<ReportOverviewTab> createState() => _ReportOverviewTabState();
}

class _ReportOverviewTabState extends State<ReportOverviewTab> {
  late ProjectDetailsModel _projectDetailsModel;
  late ExecutionStatsModel _executionStatsModel;

  final String _currentFileName = "report_overview_tab.dart";

  @override
  void initState() {
    super.initState();
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    _executionStatsModel = Provider.of<ExecutionStatsModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.87,
        width: MediaQuery.of(context).size.width * 0.95,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: buildReportingSection(
                    title: "PROJECT DETAILS",
                    icon: Icons.assessment,
                    context,
                    child: _buildReportHeader(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: buildReportingSection(
                    title: "EXECUTION SUMMARY",
                    icon: Icons.assessment,
                    context,
                    child: buildStatisticsCard(context),
                  ),
                ),
              ],
            ),
          ),
        )
      );
  }

  Widget _buildReportHeader(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                "Industry",
                _projectDetailsModel.getIndustry,
                Icons.business,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                context,
                "System",
                _projectDetailsModel.getSystemName,
                Icons.computer,
              ),
            ),]),
          const SizedBox(height: 24),
          Row(
            children:[
            Expanded(
              child: _buildDetailItem(
                context,
                "Project Start Date",
                _projectDetailsModel.getProjectStartDate,
                Icons.calendar_today,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                context,
                "Process",
                _projectDetailsModel.getProjectType,
                Icons.work,
              ),
            ),]),
          const SizedBox(height: 24),
          Row(
            children:[
            Expanded(
              child: _buildDetailItem(
                context,
                "Project Scope",
                "${_projectDetailsModel.getProjectScopeStartDate} - ${_projectDetailsModel.getProjectScopeEndDate}",
                Icons.calendar_today,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                context,
                "Days into project",
                "${_projectDetailsModel.getDaysIntoProject} days",
                Icons.calendar_month,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 0.67; // 8px
    final padding = context.spacing(size: SpacingSize.small);
    final iconSize = context.iconSize(size: IconSize.small) * 1.5;
    final spacing = context.spacing(size: SpacingSize.small);
    final labelFontSize = context.responsiveFontSize(10);
    final valueFontSize = context.responsiveFontSize(16);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5)
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: colorScheme.secondary,
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: labelFontSize,
                    color: colorScheme.onSurface,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: spacing / 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatisticsCard(BuildContext context) {
    return Consumer<ExecutionStatsModel>(
      builder: (context, executionStatsModel, child) {
        return _buildTestFlowDiagram(context, executionStatsModel);
      }
    );
  }

  Widget _buildTestFlowDiagram(BuildContext context, ExecutionStatsModel executionStatsModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Level 1: Total Tests
            _buildFlowNode(
              context,
              "Total Tests",
              executionStatsModel.executionStats.totalTests.toString(),
              "All selected tests in the project",
              Icons.assessment,
              colorScheme.secondary,
              true,
            ),
            
            // Arrow down from Total Tests
            _buildFlowArrow(context, colorScheme.primary),
            
            // Level 2: Executed Tests and Pending Execution
            _buildLevelRow(
              context,
              executionStatsModel,
              leftNode: _buildNodeWithBranch(
                context,
                "Executed Tests",
                executionStatsModel.executionStats.executedTests.toString(),
                "Tests that have been configured and executed",
                Icons.play_circle,
                colorScheme.secondary,
                true,
                child: _buildExecutedTestsBranch(context, executionStatsModel),
              ),
              rightNode: _buildFlowNode(
                context,
                "Pending Execution",
                executionStatsModel.executionStats.pendingTests.toString(),
                "Tests waiting to be configured and executed",
                Icons.schedule,
                colorScheme.primary.withValues(alpha: 0.5),
                false,
                isCompact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutedTestsBranch(BuildContext context, ExecutionStatsModel executionStatsModel) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFlowArrow(context, colorScheme.primary),
        // Level 3: Review Completed and Review Pending
        _buildLevelRow(
          context,
          executionStatsModel,
          leftNode: _buildNodeWithBranch(
            context,
            "Review Completed",
            executionStatsModel.executionStats.reviewCompleted.toString(),
            "Tests that have been reviewed",
            Icons.visibility,
            colorScheme.secondary,
            true,
            child: _buildReviewCompletedBranch(context, executionStatsModel),
          ),
          rightNode: _buildFlowNode(
            context,
            "Review Pending",
            executionStatsModel.executionStats.reviewPending.toString(),
            "Tests waiting for review",
            Icons.pending,
            colorScheme.primary.withValues(alpha: 0.5),
            false,
            isCompact: true,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCompletedBranch(BuildContext context, ExecutionStatsModel executionStatsModel) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFlowArrow(context, colorScheme.primary),
        // Level 4: With Observations and Without Observations
        _buildLevelRow(
          context,
          executionStatsModel,
          leftNode: _buildNodeWithBranch(
            context,
            "With Observations",
            executionStatsModel.executionStats.withObservations.toString(),
            "One or more issues were found",
            Icons.insights,
            colorScheme.secondary,
            true,
            child: _buildWithObservationsBranch(context, executionStatsModel),
          ),
          rightNode: _buildFlowNode(
            context,
            "No Observations",
            executionStatsModel.executionStats.withoutObservations.toString(),
            "Passed clean",
            Icons.visibility_off,
            colorScheme.primary.withValues(alpha: 0.5),
            false,
            isCompact: true,
          ),
        ),
      ],
    );
  }

  Widget _buildWithObservationsBranch(BuildContext context, ExecutionStatsModel executionStatsModel) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFlowArrow(context, colorScheme.primary),
        // Level 5: Accepted Findings and Other Findings
        _buildLevelRow(
          context,
          executionStatsModel,
          leftNode: _buildFlowNode(
            context,
            "Accepted Issues",
            executionStatsModel.executionStats.acceptedFindings.toString(),
            "Valid issues accepted by business",
            Icons.warning,
            colorScheme.error,
            true,
          ),
            rightNode: _buildFlowNode(
              context,
              "Others",
              executionStatsModel.executionStats.otherFindings.toString(),
              "Explainable exceptions",
              Icons.info,
              colorScheme.primary.withValues(alpha: 0.5),
              false,
              isCompact: true,
            ),
        ),
      ],
    );
  }

  Widget _buildLevelRow(
    BuildContext context,
    ExecutionStatsModel executionStatsModel, {
    required Widget leftNode,
    required Widget rightNode,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: leftNode,
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: 2,
          child: rightNode,
        ),
      ],
    );
  }

  Widget _buildNodeWithBranch(
    BuildContext context,
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
    bool isHighlighted, {
    required Widget child,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFlowNode(
          context,
          title,
          value,
          description,
          icon,
          color,
          isHighlighted,
        ),
        child,
      ],
    );
  }

  Widget _buildFlowNode(
    BuildContext context,
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
    bool isHighlighted, {
    bool isCompact = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 0.67; // 8px
    final padding = context.spacing(size: SpacingSize.small);
    final iconSize = context.iconSize(size: IconSize.small) * 1.5;
    final spacing = context.spacing(size: SpacingSize.small);
    final titleFontSize = context.responsiveFontSize(10);
    final descriptionFontSize = context.responsiveFontSize(9);
    final compactValueFontSize = context.responsiveFontSize(20);
    final largeValueFontSize = context.responsiveFontSize(32);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.8), width: 0.5,),
      ),
      child: isCompact
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    letterSpacing: 0.5,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing / 2),
                // Value (Small)
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: compactValueFontSize,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  icon,
                  color: color,
                  size: iconSize,
                ),
                SizedBox(width: spacing),
                // Title and Description in Column
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                          letterSpacing: 0.5,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing / 4),
                      // Description
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: descriptionFontSize,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing),
                // Value (Big)
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: largeValueFontSize,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFlowArrow(BuildContext context, Color color) {
    return Container(
      height: 3,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  Future<void> _loadPage() async{
    try{
      _executionStatsModel.setIsPageLoading = true;
      
      await _executionStatsModel.getExecutionStats(context);
      
    } catch (e){
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
    finally{
      _executionStatsModel.setIsPageLoading = false;
    }

  }
} 
