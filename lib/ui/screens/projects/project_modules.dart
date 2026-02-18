//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/core/utils/image_display_util.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/ui/screens/create_project/create_project.dart';
import 'package:foretale_application/ui/screens/data_upload/upload_screen_wizard.dart';
import 'package:foretale_application/ui/screens/inquiry/inquiry.dart';
import 'package:foretale_application/ui/screens/report/report_wrap.dart';
import 'package:foretale_application/ui/screens/test_case/test_config.dart';
import 'package:foretale_application/ui/screens/ai_assistant/ai_assistant_page.dart';
//screen
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';
import 'package:foretale_application/ui/widgets/app_actions/expandable_actions_button.dart';
import 'package:provider/provider.dart';

class ProjectModules extends StatefulWidget {
  const ProjectModules({super.key});

  @override
  State<ProjectModules> createState() => _ProjectModulesState();
}

class _ProjectModulesState extends State<ProjectModules> with TickerProviderStateMixin<ProjectModules>, PageEntranceAnimations {
  late ProjectDetailsModel _projectDetailsModel;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    initializeEntranceAnimations();
    startEntranceAnimations();
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    
    // Initialize rotation animation for foretale.ai border
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    disposeEntranceAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    Widget content = buildSlideAndFadeTransition(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopSection(context),
          const SizedBox(height: 40),
          _buildModulesGrid(context, size),
        ],
      )
    );

    return CustomPageWrapper(
      size: size,
      onBackPressed: () => Navigator.pop(context),
      additionalActions: [
        ActionItem(
          icon: Icons.edit,
          onPressed: () => _navigateToEditProject(context),
          tooltip: 'Edit Project',
        ),
      ],
      enableGradient: true,
      child: content,
    );
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

  Future<void> _navigateToEditProject(BuildContext context) async {
    context.fadeNavigateTo(const CreateProject(isNew: false));
  }

  Future<void> _navigateToAgenticAI(BuildContext context) async {
    context.fadeNavigateTo(const AIAssistantPage());
  }

  Widget _buildTopSection(BuildContext context) {
    return buildFadeTransition(
      child: ProjectHeaderSection(
        projectName: _projectDetailsModel.getName,
        sectionTitle: 'Home',
      )
    );
  }

  Widget _buildModulesGrid(BuildContext context, Size size) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: size.height * 0.6,
        maxWidth: size.width * 0.9,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildForetaleAIModule(context),
          const SizedBox(height: 50),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 40,
            runSpacing: 30,
            children: [
              _buildModuleOption(context, 'Upload Wizard', ImageDisplayUtil.uploadWizardIcon(size: 100), () => _navigateToDataUpload(context)),
              const SizedBox(width: 10),
              _buildModuleOption(context, 'Knowledge Base', ImageDisplayUtil.knowledgeBaseIcon(size: 100), () => _navigateToGather(context)),
              const SizedBox(width: 10),
              _buildModuleOption(context, 'Controls Register', ImageDisplayUtil.controlsRegisterIcon(size: 100), () => _navigateToRiskLibrary(context)),
              const SizedBox(width: 10),
              _buildModuleOption(context, 'Reports', ImageDisplayUtil.reportsIcon(size: 100), () => _navigateToFindings(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForetaleAIModule(BuildContext context) {
    const double borderSize = 140.0;
    const double contentSize = 138.0;
    const double iconSize = 100.0;
    
    return Column(
      children: [
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Rotating gradient border
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: borderSize,
                    height: borderSize,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Colors.cyan,
                          Colors.blue,
                          Colors.purple,
                          Colors.pink,
                          Colors.orange,
                          Colors.cyan,
                        ],
                        stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                // Main content
                _buildAgenticAIContent(context, contentSize, iconSize),
              ],
            );
          },
        ),
        SizedBox(height: context.spacing(size: SpacingSize.small) * 1.5),
        _buildAgenticAILabel(context),
      ],
    );
  }

  Widget _buildAgenticAIContent(BuildContext context, double contentSize, double iconSize) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _navigateToAgenticAI(context),
      customBorder: const CircleBorder(),
      hoverColor: colorScheme.primary.withValues(alpha: 0.15),
      splashColor: colorScheme.primary.withValues(alpha: 0.25),
      highlightColor: colorScheme.primary.withValues(alpha: 0.1),
      child: Container(
        width: contentSize,
        height: contentSize,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface.withValues(alpha: 0.9),
        ),
        child: ImageDisplayUtil.agenticAIIcon(size: iconSize),
      ),
    );
  }

  Widget _buildAgenticAILabel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(14);
    return Text(
      'Autonomous AI Assistant',
      style: theme.textTheme.titleMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        height: 1.2,
        letterSpacing: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildModuleOption(BuildContext context, String title, Widget widget, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final padding = context.spacing(size: SpacingSize.medium);
    final fontSize = context.responsiveFontSize(14);
    final spacing = context.spacing(size: SpacingSize.small) * 1.5;
    
    return Column(
      children: [
        Material(
          color: colorScheme.surface.withValues(alpha: 0.2),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            hoverColor: colorScheme.primary.withValues(alpha: 0.1),
            splashColor: colorScheme.primary.withValues(alpha: 0.15),
            splashFactory: InkRipple.splashFactory,
            highlightColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: widget,
            ),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}