//core
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/core/utils/image_display_util.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/logo_text.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/constants/colors/app_colors_v2.dart';
//screen
import 'package:foretale_application/ui/screens/help/resource_page.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/app_actions/expandable_actions_button.dart';
import 'package:foretale_application/ui/widgets/responsive_wrap.dart';
//screen
import 'package:foretale_application/ui/screens/create_project/create_project.dart';
import 'package:foretale_application/ui/screens/data_upload/upload_screen_wizard.dart';
import 'package:foretale_application/ui/screens/inquiry/inquiry.dart';
import 'package:foretale_application/ui/screens/test_case/test_config.dart';
import 'package:foretale_application/ui/screens/report/report_wrap.dart';
import 'package:foretale_application/ui/screens/ai_assistant/ai_assistant_page.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/report_model.dart';
//helpers
import 'package:foretale_application/ui/screens/landing/landing_widgets.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> with TickerProviderStateMixin<LandingPage>, PageEntranceAnimations {
  final String _currentFileName = "landing.dart";
  final TextEditingController _searchController = TextEditingController();
  late ProjectDetailsModel _projectDetailsModel;
  late ExecutionStatsModel _executionStatsModel;
  String _searchQuery = '';
  bool _hasLoaded = false;
  Map<int, ExecutionStats> _executionStatsCache = {};

  @override
  void initState() {
    super.initState();
    initializeEntranceAnimations(fadeDuration: const Duration(milliseconds: 800), slideDuration: const Duration(milliseconds: 600));
    startEntranceAnimations();
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    _executionStatsModel = Provider.of<ExecutionStatsModel>(context, listen: false);
  }

  @override
  void dispose() {
    disposeEntranceAnimations();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return CustomPageWrapper(
      size: size,
      workloadTheme: false,
      showBackButton: true,
      showHomeButton: true,
      onBackPressed: () => Navigator.pop(context),
      onHomePressed: () => context.fadeNavigateTo(const LandingPage()),
      onReady: () {
        // This callback is called when CustomPageWrapper's FutureBuilder completes
        // ensuring all Providers are ready before loading projects
        if (mounted && !_hasLoaded && _projectDetailsModel.projectListByUser.isEmpty) {
          _hasLoaded = true;
          _loadPage();
        }
      },
      additionalActions: [
        ActionItem(
          icon: Icons.add_circle_outline,
          onPressed: () => _navigateToCreateProject(context),
          tooltip: 'New Project',
        ),
        ActionItem(
          icon: Icons.tips_and_updates_rounded,
          onPressed: () => _navigateToResourcePage(context),
          tooltip: 'Resources',
        ),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Top section with welcome message
          _buildTopSection(context),
          const SizedBox(height: 32),
          // Center content with welcome screen or project selection
          Expanded(
            child: _buildCenterContent(context, size),
          ),
        ],
      ),
    );
  }


  Widget _buildTopSection(BuildContext context) {
    return buildFadeTransition(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo section
            Row(
              children: [
                ImageDisplayUtil.companyLogo(),
                const SizedBox(width: 10),
                const LogoText(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterContent(BuildContext context, Size size) {
    return buildSlideAndFadeTransition(
      child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
          LandingWidgets.buildMainHeading(context),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: _buildProjectSelectionSection(context, size),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSelectionSection(BuildContext context, Size size) {
    final maxWidth = (size.width * 0.9).clamp(800.0, 1400.0);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.borderRadius * 1.5),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildSearchBar(context),
          ),
          Expanded(
            child: Consumer<ProjectDetailsModel>(
              builder: (context, model, child) {
                List<ProjectDetails> projects = model.getFilteredProjectsList;
                
                if (model.getIsPageLoading) {
                  return LandingWidgets.buildLoadingState(context);
                }
                
                return projects.isEmpty
                    ? EmptyState(
                        title: "No Projects Found",
                        subtitle: "Start by creating a new project",
                        icon: Icons.folder_outlined,
                        onActionPressed: () => _navigateToCreateProject(context),
                        actionText: "Create Project",
                      )
                    : _buildProjectGrid(context, projects, size);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid(BuildContext context, List<ProjectDetails> projects, Size size) {
    return SingleChildScrollView(
      key: ValueKey<String>(_searchQuery),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ResponsiveWrap(
        spacing: 64.0,
        runSpacing: 32.0,
        breakpoint: 900.0,
        minChildWidth: 300.0,
        maxChildWidth: 350.0,
        children: projects.map((project) {
          return _buildProjectCard(context, project);
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return CustomTextField(
      controller: _searchController,
      label: "Search projects...",
      isEnabled: true,
      onChanged: (value) {
        _searchQuery = value.trim();
        _projectDetailsModel.filterData(_searchQuery);
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectDetails project) {
    final isSelected = (project.activeProjectId == _projectDetailsModel.getActiveProjectId);
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = context.borderRadius * 1.2;
    
    return Hero(
      tag: 'project-${project.activeProjectId}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onProjectSelection(context, project),
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        colorScheme.surface.withValues(alpha: 0.5),
                        colorScheme.surface.withValues(alpha: 0.9),
                      ]
                    : [
                        colorScheme.surface.withValues(alpha: 0.95),
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isSelected 
                    ? colorScheme.onSecondaryFixed
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2.0 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? colorScheme.secondary.withValues(alpha: 0.3)
                      : colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: isSelected ? 8 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildCardContent(context, project, isSelected),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, ProjectDetails project, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Title and Modules menu
                _buildCardHeader(context, project, isSelected),
                const SizedBox(height: 20),
                // Project metrics section
                _buildCardMetricsSection(context, project, isSelected),
                const SizedBox(height: 16),
                // Execution stats section
                _buildCardStatsSection(context, project, isSelected),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildModuleMenuButton(context, project),
        ],
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, ProjectDetails project, bool isSelected) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final titleFontSize = context.responsiveFontSize(16);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.folder_special_rounded,
                    size: 20,
                    color: isSelected 
                        ? colorScheme.primary 
                        : colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.name.toUpperCase(),
                      style: textTheme.titleLarge?.copyWith(
                        color: isSelected 
                            ? colorScheme.primary 
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: titleFontSize,
                        letterSpacing: 1.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isSelected ? 'ACTIVE' : ' ',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 28),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardMetricsSection(BuildContext context, ProjectDetails project, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(context.borderRadius * 0.8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: LandingWidgets.buildProjectMetrics(context, project),
    );
  }

  Widget _buildCardStatsSection(BuildContext context, ProjectDetails project, bool isSelected) {
    final executionStats = _executionStatsCache[project.activeProjectId];
    final colorScheme = Theme.of(context).colorScheme;
    
    final metrics = [
      {
        'label': "Tested",
        'value': executionStats?.executedTests.toString() ?? '0',
        'color': BrandColors.success,
        'icon': Icons.check_circle_outline,
      },
      {
        'label': executionStats != null ? "Issues" : "Failed",
        'value': executionStats?.withObservations.toString() ?? '0',
        'color': BrandColors.warning,
        'icon': Icons.warning_amber_rounded,
      },
      {
        'label': "Accepted",
        'value': executionStats?.acceptedFindings.toString() ?? '0',
        'color': BrandColors.danger,
        'icon': Icons.assignment_turned_in_outlined,
      },
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(context.borderRadius * 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: metrics.map((metric) {
          return Expanded(
            child: _buildCompactStatItem(
              context,
              metric['label'] as String,
              metric['value'] as String,
              metric['icon'] as IconData,
              metric['color'] as Color,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: context.responsiveFontSize(16),
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: context.responsiveFontSize(8),
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _navigateToCreateProject(BuildContext context) {
    context.fadeNavigateTo(const CreateProject(isNew: true));
  }

  void _onProjectSelection(BuildContext context, ProjectDetails projectDetails) async {
    try {
      await _projectDetailsModel.updateProjectDetails(context, projectDetails);
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context,
        "Invalid project selection.",
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_onProjectSelection",
      );
    }
  }

  Future<void> _loadPage() async {
    try {
      _projectDetailsModel.setIsPageLoading = true;
      await _projectDetailsModel.fetchProjectsByUserMachineId(context);
      
      // Fetch execution stats for all projects
      if (mounted) {
        await _fetchExecutionStatsForProjects(context);
      }
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
      if (mounted) {
        _projectDetailsModel.setIsPageLoading = false;
      }
    }
  }

  Future<void> _fetchExecutionStatsForProjects(BuildContext context) async {
    try {
      _executionStatsCache.clear();
      
      // Fetch all execution stats for all projects at once
      final statsMap = await _executionStatsModel.getLandingExecutionStats(context);
      _executionStatsCache = statsMap;
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Silently fail - stats are optional
      if (mounted) {
        setState(() {});
      }
    }
  }


  void _navigateToResourcePage(BuildContext context) {
    context.fadeNavigateTo(const ResourcePage());
  }

  Widget _buildModuleMenuButton(BuildContext context, ProjectDetails project) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ExpandableActionsButton(
      actions: [
        ActionItem(
          icon: Icons.smart_toy_outlined,
          onPressed: () => _navigateToModule(context, project, _navigateToAgenticAI),
          tooltip: 'Autonomous AI',
          isActive: true,
          showLabel: false,
        ),
        ActionItem(
          icon: Icons.cloud_upload_outlined,
          onPressed: () => _navigateToModule(context, project, _navigateToDataUpload),
          tooltip: 'Upload Wizard',
          isActive: true,
          showLabel: false,
        ),
        ActionItem(
          icon: Icons.library_books_outlined,
          onPressed: () => _navigateToModule(context, project, _navigateToGather),
          tooltip: 'Knowledge Base',
          isActive: true,
          showLabel: false,
        ),
        ActionItem(
          icon: Icons.assignment_outlined,
          onPressed: () => _navigateToModule(context, project, _navigateToRiskLibrary),
          tooltip: 'Controls Register',
          isActive: true,
          showLabel: false,
        ),
        ActionItem(
          icon: Icons.description_outlined,
          onPressed: () => _navigateToModule(context, project, _navigateToFindings),
          tooltip: 'Reports',
          isActive: true,
          showLabel: false,
        ),
        ActionItem(
          icon: Icons.edit_outlined,
          onPressed: () => _navigateToModule(context, project, _navigateToEditProject),
          tooltip: 'Edit Project',
          isActive: true,
          showLabel: false,
        ),
      ],
      backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.primary.withValues(alpha: 0.7),
      expansionDirection: Axis.vertical,
      iconSize: context.iconSize(size: IconSize.small),
      actionIconSize: context.iconSize(size: IconSize.small),
      buttonSize: context.iconSize(size: IconSize.small) * 1.5,
      mainIcon: Icons.more_horiz,
      mainTooltip: '',
    );
  }

  Future<void> _navigateToModule(
    BuildContext context,
    ProjectDetails project,
    Future<void> Function(BuildContext) navigateFunction,
  ) async {
    try {
      // First set the project as active
      await _projectDetailsModel.updateProjectDetails(context, project);
      // Then navigate to the module
      await navigateFunction(context);
    } catch (e) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context,
          "Failed to navigate to module.",
          logError: true,
          errorMessage: e.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_navigateToModule",
        );
      }
    }
  }

  Future<void> _navigateToDataUpload(BuildContext context) async {
    context.fadeNavigateTo(const UploadScreenWizard());
  }

  Future<void> _navigateToGather(BuildContext context) async {
    context.fadeNavigateTo(const InquiryPage());
  }

  Future<void> _navigateToRiskLibrary(BuildContext context) async {
    context.fadeNavigateTo(const TestConfigPage());
  }

  Future<void> _navigateToFindings(BuildContext context) async {
    context.fadeNavigateTo(const RiskReportPage());
  }

  Future<void> _navigateToAgenticAI(BuildContext context) async {
    context.fadeNavigateTo(const AIAssistantPage());
  }

  Future<void> _navigateToEditProject(BuildContext context) async {
    context.fadeNavigateTo(const CreateProject(isNew: false));
  }
}

