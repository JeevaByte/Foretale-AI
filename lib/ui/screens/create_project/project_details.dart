// Flutter
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:provider/provider.dart';

// Core
import 'package:foretale_application/core/constants/values.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';

// Models
import 'package:foretale_application/models/industry_list_model.dart';
import 'package:foretale_application/models/organization_list_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/project_type_list_model.dart';

// UI
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/dropdowns/custom_dropdown_search.dart';
import 'package:foretale_application/ui/widgets/custom_grid_menu.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final bool isNew;
  final TabController tabController;

  const ProjectDetailsScreen({
    super.key, 
    required this.isNew, 
    required this.tabController
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final String _currentFileName = "project_details.dart";
  final _formKey = GlobalKey<FormState>();

  late ProjectDetailsModel _projectDetailsModel;

  @override
  void initState() {
    super.initState();
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Consumer<ProjectDetailsModel>(
        builder: (context, projectDetailsModel, child) {
          if (projectDetailsModel.getIsPageLoading) {
            return buildLoadingState(context);
          }
          return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildProjectClassificationWidget(context, projectDetailsModel),
                          const SizedBox(height: 25),
                          _buildProjectTypeWidget(context, projectDetailsModel),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildActionButtonsWidget(context, projectDetailsModel),
                ],
              ),
            );
        },
      ),
    );
  }

  Widget _buildProjectClassificationWidget(BuildContext context, ProjectDetailsModel projectDetailsModel) {
    return CustomContainer(
        title: 'Classify Project',
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              child: CustomDropdownSearch(
                items: projectDetailsModel.getOrganizationsList,
                isEnabled: widget.isNew,
                hintText: 'Choose Organization',
                title: "Organization",
                selectedItem: projectDetailsModel.getSelectedOrganization,
                onChanged: (String? selectedItem) {
                  projectDetailsModel.setSelectedOrganization(selectedItem);
                },
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: CustomDropdownSearch(
                items: projectDetailsModel.getIndustriesList,
                isEnabled: widget.isNew,
                hintText: 'Choose Industry',
                title: "Industry",
                selectedItem: projectDetailsModel.getSelectedIndustry,
                onChanged: (String? selectedItem) {
                  _handleIndustryChanged(selectedItem ?? '');
                },
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: CustomDropdownSearch(
                items: systemNames,
                isEnabled: widget.isNew,
                hintText: 'Choose System',
                title: "System Name",
                selectedItem: projectDetailsModel.getSelectedSystemName,
                onChanged: (String? selectedItem) {
                  projectDetailsModel.setSelectedSystemName(selectedItem);
                },
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildProjectTypeWidget(BuildContext context, ProjectDetailsModel projectDetailsModel) {
    return CustomContainer(
      title: 'Choose Type',
      padding: const EdgeInsets.all(30),
      child: _buildProjectTypeContent(projectDetailsModel),
    );
  }

  Widget _buildProjectTypeContent(ProjectDetailsModel projectDetailsModel) {


    if (projectDetailsModel.getProjectTypesList.isEmpty) {
      return EmptyState(
        icon: Icons.warning,
        title: "No modules available",
        subtitle: "Choose an industry to view modules",
      );
    }

    return SingleChildScrollView(
      child: CustomGridMenu(
        isEnabled: widget.isNew,
        items: projectDetailsModel.getProjectTypesList,
        labelText: "Project Type",
        selectedItem: projectDetailsModel.getSelectedProjectType,
        onItemSelected: (String selectedItem) {
          projectDetailsModel.setSelectedProjectType(selectedItem);
        },
      ),
    );
  }

  Widget _buildActionButtonsWidget(BuildContext context, ProjectDetailsModel projectDetailsModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.medium) * 1;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconButton(
          icon: Icons.arrow_forward,
          iconSize: iconSize,
          onPressed: () => _handleNextButton(projectDetailsModel),
          tooltip: 'Next',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  void _handleIndustryChanged(String selectedIndustry) {
    try{
      _projectDetailsModel.setSelectedIndustry(selectedIndustry);
      _fetchProjectTypes(selectedIndustry);
    } catch (e) {
      SnackbarMessage.showErrorMessage(context, 'Choose a project type');
      return;
    } 
  }

  void _handleNextButton(ProjectDetailsModel projectDetailsModel) {
    try {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }

      if (projectDetailsModel.getSelectedProjectType == null) {
        SnackbarMessage.showErrorMessage(context, 'Choose a project type');
        return;
      }

      widget.tabController.animateTo(1);
    } catch (e) {
      SnackbarMessage.showErrorMessage(context, 'Choose a project type');
      return;
    }
  }

  Future<void> _fetchOrganizations() async {
    if (_projectDetailsModel.getOrganizationsList.isNotEmpty) return;
    final lkpList = await OrganizationList().fetchAllActiveOrganizations(context);
    _projectDetailsModel.setOrganizationsList(lkpList.map((obj) => obj.name).toList());
  }

  Future<void> _fetchIndustries() async {
    if (_projectDetailsModel.getIndustriesList.isNotEmpty) return;
    final lkpList = await IndustryList().fetchAllActiveIndustries(context);
    _projectDetailsModel.setIndustriesList(lkpList.map((obj) => obj.name).toList());
  }

  Future<void> _fetchProjectTypes(String selectedIndustry) async {
    if (selectedIndustry.isEmpty) {
      _projectDetailsModel.clearProjectTypesList();
      return;
    }

    _projectDetailsModel.setIsLoadingProjectTypes = true;

    try {
      final lkpList = await ProjectTypeList().fetchAllActiveProjectTypes(context, selectedIndustry);
      _projectDetailsModel.setProjectTypesList(lkpList);
    } catch (e) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context, 
          'Failed to load project types',
          errorMessage: e.toString(),
          errorSource: _currentFileName,
        );
      }
    } finally {
      _projectDetailsModel.setIsLoadingProjectTypes = false;
    }
  }

  Future<void> _fetchProjectDetails(BuildContext context) async {
    unawaited(_fetchProjectTypes(_projectDetailsModel.getIndustry));
    await _projectDetailsModel.fetchProjectDetailsById(context, _projectDetailsModel.getActiveProjectId);
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchOrganizations(),
      _fetchIndustries(),
    ]);
  }

  Future<void> _loadPage() async {
    try {
      await _loadInitialData();
      if (!widget.isNew) {
        await _fetchProjectDetails(context);
      }
    } catch (e, errorStackTrace) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context, 
          'Failed to load project details',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage",
        );
      }
    }
  }
}
