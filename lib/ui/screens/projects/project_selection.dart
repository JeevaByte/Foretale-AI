//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/core/utils/responsive.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/ui/screens/create_project/create_project.dart';
import 'package:foretale_application/ui/screens/landing/landing.dart';
import 'package:foretale_application/ui/screens/projects/project_modules.dart';
//screen
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/ui/widgets/bubble_loading_indicator.dart';
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/app_actions/expandable_actions_button.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin<WelcomePage>, PageEntranceAnimations {
  final String _currentFileName = "welcome.dart";

  final TextEditingController _searchController = TextEditingController();
  late ProjectDetailsModel _projectDetailsModel;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Reduced duration for better UX - 3 seconds was too long
    initializeEntranceAnimations();
    startEntranceAnimations();
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
    });
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
    
    Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Ensure left alignment for top section
        children: [
          _buildTopSection(context),
          const SizedBox(height: 20),
          Expanded(
            child: _buildlist(context, size),
          ),
        ],
      );
    

    return CustomPageWrapper(
      size: size,
      additionalActions: [
        ActionItem(
          icon: Icons.add,
          onPressed: () => _navigateToCreateProject(context),
          tooltip: 'Create Project',
        ),
      ],
      onBackPressed: () => Navigator.pop(context),
      onHomePressed: () => context.fadeNavigateTo(const LandingPage()),
      enableGradient: true,
      child: buildSlideAndFadeTransition(child: content),
    );
  }

  void _navigateToCreateProject(BuildContext context) {
    context.fadeNavigateTo(const CreateProject(isNew: true));
  }

  void _navigateToProjectModules(BuildContext context) {
    context.fadeNavigateTo(const ProjectModules());
  }

  Widget _buildlist(BuildContext context, Size size) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSearchBar(),
            Expanded(
              child: Consumer<ProjectDetailsModel>(
                builder: (context, model, child) {
                  List<ProjectDetails> projects = model.getFilteredProjectsList;
                  
                  if (model.getIsPageLoading) {
                    return _buildLoadingState(context);
                  }
                  
                  return projects.isEmpty
                  ? EmptyState(
                    title: "No Projects Found",
                    subtitle: "Start by creating a new project",
                    icon: Icons.folder_outlined,
                    onActionPressed: () => _navigateToCreateProject(context),
                    actionText: "Create Project",
                  )
                  : ListView.builder(
                      key: ValueKey<String>(_searchQuery),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        ProjectDetails project = projects[index];
                        return _buildProjectCard(context, project);
                      },
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: CustomTextField(
        controller: _searchController,
        label: "Search...",
        isEnabled: true,
        onChanged: (value) {
          _searchQuery = value.trim();
          _projectDetailsModel.filterData(_searchQuery);
        },
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return const ProjectHeaderSection(
      projectName: "",
      sectionTitle: 'Choose a project',
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectDetails project) {
    final isSelected = (project.activeProjectId == _projectDetailsModel.getActiveProjectId);

    return Hero(
      tag: 'project-${project.activeProjectId}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.grey.shade500, width: 0.5),
          borderRadius: BorderRadius.circular(12),

        ),
        child: _buildCardContent(context, project, isSelected),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, ProjectDetails project, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = context.borderRadius;
    final padding = context.spacing(size: SpacingSize.medium) * 1.25;
    final spacing = context.spacing(size: SpacingSize.medium) * 1.25;
    
    return Material(
      color: colorScheme.surface.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: () => _onProjectSelection(context, project),
        splashColor: colorScheme.secondary.withValues(alpha: 0.25),
        splashFactory: InkRipple.splashFactory,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeftSideOfCard(context, project, isSelected),
              SizedBox(width: spacing),
              _buildRightSideOfCard(context, project, isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSideOfCard(BuildContext context, ProjectDetails project, bool isSelected) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final titleFontSize = context.responsiveFontSize(18);
    final descFontSize = context.responsiveFontSize(14);
    final spacing = context.spacing(size: SpacingSize.small) * 1.5;
    final chipSpacing = context.spacing(size: SpacingSize.small);
    
    return Expanded(
      flex: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project name
          Text(
            project.name,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: spacing),
          Text(
            project.description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: descFontSize,
              height: 1.4,
            ),
          ),
          SizedBox(height: spacing * 1.67),
          // Project metadata chips with modern styling
          Wrap(
            spacing: chipSpacing,
            runSpacing: chipSpacing * 0.75,
            children: [
              CustomChip(
                label: project.industry, 
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1), 
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
              ),
              CustomChip(
                label: project.projectType, 
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1), 
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
              ),
              CustomChip(
                label: "Started: ${project.createdDate.toString()}", 
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1), 
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightSideOfCard(BuildContext context, ProjectDetails project, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isSelected)
            CustomChip(
              label: "Active", 
              backgroundColor: colorScheme.secondary, 
              textColor: colorScheme.onSecondary,
              border: Border.all(
                color: colorScheme.surface,
                width: 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = context.iconSize(size: IconSize.medium) * 1.75;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BubbleLoadingIndicator(
            isLoading: true,
            color: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerHighest,
            size: size,
          )
        ],
      ),
    );
  }

  void _onProjectSelection(BuildContext context, ProjectDetails projectDetails) async{
    try {
      await _projectDetailsModel.updateProjectDetails(context, projectDetails);
      _navigateToProjectModules(context);
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
      // Check if data is already loaded to prevent unnecessary API calls
      _projectDetailsModel.setIsPageLoading = true;
      await _projectDetailsModel.fetchProjectsByUserMachineId(context);
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
      _projectDetailsModel.setIsPageLoading = false;
    }
  }


}
