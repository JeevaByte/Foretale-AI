//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_tab_bar.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_tab_header.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
//constants
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/create_test_model.dart';
//ui
import 'package:foretale_application/ui/screens/create_test/test_details.dart';
import 'package:foretale_application/ui/screens/create_test/risks_section.dart';
import 'package:foretale_application/ui/screens/create_test/actions_section.dart';
import 'package:foretale_application/ui/screens/create_test/test_settings.dart';
import 'package:foretale_application/ui/screens/landing/landing.dart';
//styles
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';
import 'package:provider/provider.dart';

class CreateTest extends StatefulWidget {
  final bool isNew;

  const CreateTest({super.key, required this.isNew});

  @override
  State<CreateTest> createState() => _CreateTestState();
}

class _CreateTestState extends State<CreateTest> with TickerProviderStateMixin<CreateTest>, PageEntranceAnimations {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    initializeEntranceAnimations();
    startEntranceAnimations();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    disposeEntranceAnimations();
    _tabController.dispose();
    super.dispose();
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
        ],
      ),
    );

    return CustomPageWrapper(
      size: size,
      onBackPressed: () => Navigator.pop(context),
      onHomePressed: () => context.fadeNavigateTo(const LandingPage()),
      enableGradient: true,
      child: Center(child: content),
    );
  }

  Widget _buildTopSection(BuildContext context){
    return Selector<ProjectDetailsModel, (int, String)>(
      selector: (context, projectDetailsModel) => (projectDetailsModel.getActiveProjectId, projectDetailsModel.getName),
      builder: (context, data, child) => ProjectHeaderSection(
        projectName: data.$2,
        sectionTitle: (widget.isNew) ? 'Create a new test' : 'Test management',
      ));
  }

  Widget _buildMainContent(BuildContext context, Size size) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Selector<CreateTestModel, int>(
              selector: (context, createTestModel) => createTestModel.getActiveTestId,
              builder: (context, activeTestId, child) {
                bool isActivateTabs = (activeTestId > 0);
                return buildTab(
                    context,
                    tabController: _tabController,
                    tabs: [
                      buildTabHeader(context, icon: Icons.info, label: 'Test Details'),
                      buildTabHeader(context, icon: Icons.warning_outlined, label: 'Risks'),
                      buildTabHeader(context, icon: Icons.work_outline, label: 'Actions'),
                      buildTabHeader(context, icon: Icons.settings, label: 'Test Settings'),
                    ],
                    onTap: (index, isActivateTabs) => _handleTabChange(index, isActivateTabs),
                    isActivateTabs: isActivateTabs,
                  );
                },
            ),
            const SizedBox(height: 10),
            Selector<CreateTestModel, int>(
              selector: (context, createTestModel) => createTestModel.getActiveTestId,
              builder: (context, activeTestId, child) {
                bool isEnabled = widget.isNew && (activeTestId == 0);
                return Expanded(
                child: TabBarView(
                controller: _tabController,
                children: [
                      BasicInformationSection(isNew: isEnabled, tabController: _tabController),
                      RisksSection(isNew: isEnabled, tabController: _tabController),
                      ActionsSection(isNew: isEnabled, tabController: _tabController),
                      TestConfigurationSection(isNew: isEnabled, tabController: _tabController),
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
} 