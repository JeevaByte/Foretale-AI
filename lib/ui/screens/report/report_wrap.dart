//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_tab_bar.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_tab_header.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
//constants
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/ui/screens/projects/project_modules.dart';
//ui
import 'package:foretale_application/ui/screens/report/report_overview_tab.dart';
import 'package:foretale_application/ui/screens/report/report_test_summary_tab.dart';
import 'package:foretale_application/ui/screens/report/report_detailed_findings_tab.dart';
import 'package:foretale_application/ui/screens/report/report_business_risks_tab.dart';
import 'package:foretale_application/ui/screens/report/report_recommendations_tab.dart';
//styles
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';
import 'package:provider/provider.dart';

class RiskReportPage extends StatefulWidget {
  const RiskReportPage({super.key});

  @override
  State<RiskReportPage> createState() => _RiskReportPageState();
}

class _RiskReportPageState extends State<RiskReportPage> with TickerProviderStateMixin<RiskReportPage>, PageEntranceAnimations {
  late TabController _tabController;
  late ProjectDetailsModel _projectDetailsModel;

  @override
  void initState() {
    super.initState();
    initializeEntranceAnimations();
    startEntranceAnimations();
    _tabController = TabController(length: 5, vsync: this);
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
  }

  @override
  void dispose() {
    disposeEntranceAnimations();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget content = buildSlideAndFadeTransition(
      child: Column(
        children: [
          _buildTopSection(context),
          const SizedBox(height: 50),
          Expanded(
            child: _buildMainContent(context, size),
          ),
        ])
    );

    return CustomPageWrapper(
      size: size,
      onBackPressed: () => Navigator.pop(context),
      onHomePressed: () => context.fadeNavigateTo(const ProjectModules()),
      child: Center(child: content),
    );
  }

  Widget _buildMainContent(BuildContext context, Size size) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left side - Main content (70%)
            Expanded(
              flex: 7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTab(
                    context,
                    tabController: _tabController,
                    tabs: [
                      buildTabHeader(context, icon: Icons.assessment, label: 'Project Overview'),
                      buildTabHeader(context, icon: Icons.table_chart, label: 'Test Overview'),
                      buildTabHeader(context, icon: Icons.warning_amber, label: 'Risk-Criticality Matrix'),
                      buildTabHeader(context, icon: Icons.lightbulb_outline, label: 'Recommendations'),
                      buildTabHeader(context, icon: Icons.find_in_page, label: 'Consolidated Findings'),
                    ],
                    onTap: (index, isActivateTabs) => (index, isActivateTabs){},
                    isActivateTabs: true,
                  ),
                  const SizedBox(height: 25),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        // Overview Tab
                        ReportOverviewTab(),
                        // Test Results Summary Tab
                        ReportTestResultsTab(),
                        // Business Risks Tab
                        ReportBusinessRisksTab(),
                        // Recommendations Tab
                        ReportRecommendationsTab(),
                        // Detailed Findings Tab
                        ReportDetailedFindingsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return ProjectHeaderSection(
      projectName: _projectDetailsModel.getName,
      sectionTitle: 'Findings & Insights',
    );
  }
}
