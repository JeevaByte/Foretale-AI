//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_tab_bar.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_tab_header.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
//constants
import 'package:foretale_application/models/project_details_model.dart';
//ui
import 'package:foretale_application/ui/screens/create_project/client_contacts.dart';
import 'package:foretale_application/ui/screens/create_project/project_details.dart';
import 'package:foretale_application/ui/screens/create_project/project_information.dart';
import 'package:foretale_application/ui/screens/create_project/project_settings.dart';
import 'package:foretale_application/ui/screens/create_project/team_contacts.dart';
import 'package:foretale_application/ui/screens/landing/landing.dart';
//styles
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';
import 'package:provider/provider.dart';



class CreateProject extends StatefulWidget {
  final bool isNew;

  const CreateProject({super.key, required this.isNew});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> with TickerProviderStateMixin<CreateProject>, PageEntranceAnimations {
  late TabController _tabController;
  late ProjectDetailsModel _projectDetailsModel;

  @override
  void initState() {
    super.initState();
    initializeEntranceAnimations();
    startEntranceAnimations();
    _tabController = TabController(length: 5, vsync: this);
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    if (widget.isNew) {
      _projectDetailsModel.clearAllState();
    }
  }

  @override
  void dispose() {
    disposeEntranceAnimations();
    _tabController.dispose();

    if (widget.isNew) {
      _projectDetailsModel.clearAllState();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget content = buildSlideAndFadeTransition(
      child: Column(
        children: [
          _buildTopSection(context),
          const SizedBox(height: 10),
          Expanded(
            child: _buildMainContent(context, size)
          ),
        ])
    );

    return CustomPageWrapper(
      size: size,
      onBackPressed: () => Navigator.pop(context),
      onHomePressed: () => context.fadeNavigateTo(const LandingPage()),
      enableGradient: true,
      child: Center(child: content),
    );
  }

  void _handleTabChange(int index, bool isActivateTabs){
    if (_tabController.indexIsChanging) {
      if (isActivateTabs) {
        _tabController.animateTo(index);
        return;
      }
      _tabController.animateTo(_tabController.previousIndex);
    }
  }

  Widget _buildMainContent(BuildContext context, Size size) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Selector<ProjectDetailsModel, int>(
              selector: (context, projectDetailsModel) => projectDetailsModel.getActiveProjectId,
              builder: (context, activeProjectId, child) {
                bool isActivateTabs = (activeProjectId > 0);
                return buildTab(
                  context,
                  tabController: _tabController,
                  tabs: [
                    buildTabHeader(context, icon: Icons.public, label: 'Scope'),
                    buildTabHeader(context, icon: Icons.info, label: 'Details'),
                    buildTabHeader(context, icon: Icons.settings, label: 'Settings'),
                    buildTabHeader(context, icon: Icons.people_outline, label: 'Client'),
                    buildTabHeader(context, icon: Icons.group, label: 'Team'),
                  ],
                  onTap: (index, isActivateTabs) => _handleTabChange(index, isActivateTabs),
                  isActivateTabs: isActivateTabs,
                );
              },
            ),
            const SizedBox(height: 10),
            Selector<ProjectDetailsModel, int>(
              selector: (context, projectDetailsModel) => projectDetailsModel.getActiveProjectId,
              builder: (context, activeProjectId, child) {
                //single source of truth
                bool isEnabled = widget.isNew && (activeProjectId == 0);
                return Expanded(
                  child: TabBarView(
                      controller: _tabController,
                      children: [
                        ProjectDetailsScreen(isNew: isEnabled, tabController: _tabController),
                        ProjectInformationScreen(isNew: isEnabled, tabController: _tabController),
                        ProjectSettingsScreen(isNew: isEnabled, tabController: _tabController),
                        ClientContactsScreen(isNew: isEnabled, tabController: _tabController),
                        TeamContactsScreen(isNew: isEnabled, tabController: _tabController)
                      ],
                  )
                );
              }
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context){
    return Selector<ProjectDetailsModel, (int, String)>(
      selector: (context, projectDetailsModel) => (projectDetailsModel.getActiveProjectId, projectDetailsModel.getName),
      builder: (context, data, child) => ProjectHeaderSection(
        projectName: data.$2,
        sectionTitle: (widget.isNew && data.$1 == 0) ? 'Create a new project' : 'Project management',
      ));
  }
}
