//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/user_details_model.dart';
//widgets
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/util_date.dart';

class ProjectInformationScreen extends StatefulWidget {
  final bool isNew;
  final TabController tabController;

  const ProjectInformationScreen(
    {super.key, required this.isNew, 
    required this.tabController
  });

  @override
  State<ProjectInformationScreen> createState() => _ProjectInformationScreenState();
}

class _ProjectInformationScreenState extends State<ProjectInformationScreen> {
  final String _currentFileName = "project_information.dart";
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController = TextEditingController();
  final TextEditingController _projectScopeStartDateController = TextEditingController();
  final TextEditingController _projectScopeEndDateController = TextEditingController();

  late UserDetailsModel _userDetailsModel;
  late ProjectDetailsModel _projectDetailsModel;

  @override
  void initState() {
    super.initState();
    _userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
    });
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    _projectScopeStartDateController.dispose();
    _projectScopeEndDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Consumer<ProjectDetailsModel>(
        builder: (context, projectDetailsModel, child) {
          bool isEnabled = widget.isNew && (projectDetailsModel.getActiveProjectId == 0);

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildProjectInformationWidget(context, projectDetailsModel, isEnabled),
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

  Widget _buildProjectInformationWidget(BuildContext context, ProjectDetailsModel projectDetailsModel, bool isEnabled) {
    _projectNameController.text = projectDetailsModel.getName;
    _projectDescriptionController.text = projectDetailsModel.getDescription;
    _projectScopeStartDateController.text = projectDetailsModel.getProjectScopeStartDate;
    _projectScopeEndDateController.text = projectDetailsModel.getProjectScopeEndDate;
        
    return CustomContainer(
      title: 'Project Information',
      padding: const EdgeInsets.all(30),
      child: projectDetailsModel.getIsPageLoading
        ? buildLoadingState(context)
        : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextField(
            isEnabled: isEnabled,
            controller: _projectNameController,
            label: 'Project Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Project name is required';
              }
              return null;
            },
            onChanged: (value) {
              if (value.isNotEmpty) {
                _projectDetailsModel.projectDetails.name = value;
              }
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            isEnabled: true,
            controller: _projectDescriptionController,
            label: 'Project Description',
            maxLines: 10,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Project description is required';
              }
              return null;
            },
            onChanged: (value) {
              if (value.isNotEmpty) {
                _projectDetailsModel.projectDetails.description = value;
              }
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  isEnabled: isEnabled,
                  controller: _projectScopeStartDateController,
                  label: 'Project Scope Start Date (yyyy-mm-dd)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Start date is required';
                    }
                    // Validate date format
                    if (!isValidDateFormat(value)) {
                      return 'Please enter date in yyyy-mm-dd format';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _projectDetailsModel.projectDetails.projectScopeStartDate = value;
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  isEnabled: isEnabled,
                  controller: _projectScopeEndDateController,
                  label: 'Project Scope End Date (yyyy-mm-dd)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'End date is required';
                    }
                    // Validate date format
                    if (!isValidDateFormat(value)) {
                      return 'Please enter date in yyyy-mm-dd format';
                    }
                    // Validate that end date is after start date
                    if (_projectScopeStartDateController.text.isNotEmpty) {
                      if (!isEndDateAfterStartDate(_projectScopeStartDateController.text, value)) {
                        return 'End date must be after start date';
                      }
                    }
                    return null;
                  },
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _projectDetailsModel.projectDetails.projectScopeEndDate = value;
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsWidget(BuildContext context, ProjectDetailsModel projectDetailsModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.medium) * 1;
    final spacing = context.spacing(size: SpacingSize.medium);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconButton(
          icon: Icons.arrow_back,
          iconSize: iconSize,
          onPressed: () {
            widget.tabController.animateTo(0);
          },
          tooltip: 'Previous',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          isEnabled: !projectDetailsModel.getIsSaveHappening ,
        ),
        SizedBox(width: spacing),
        CustomIconButton(
          icon: Icons.save,
          iconSize: iconSize,
          onPressed: () async{
            await _saveProjectInformation(context);
          },
          tooltip: 'Save',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          isProcessing: projectDetailsModel.getIsSaveHappening,
        ),
        SizedBox(width: spacing),
        CustomIconButton(
          icon: Icons.arrow_forward,
          iconSize: iconSize,
          onPressed: () {
            widget.tabController.animateTo(2);
          },
          tooltip: 'Next',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          isEnabled: !projectDetailsModel.getIsSaveHappening && projectDetailsModel.getActiveProjectId > 0,
        ),
      ],
    );
  }

  Future<void> _saveProjectInformation(BuildContext context) async {
    // Additional validation for form fields
    if (_formKey.currentState?.validate() ?? false) {
      try {
        _projectDetailsModel.setIsSaveHappening = true;
        ProjectDetails projectDetails = ProjectDetails(
            name: _projectNameController.text.trim(),
            description: _projectDescriptionController.text.trim(),
            organization: _projectDetailsModel.getOrganization,
            recordStatus: 'A',
            createdBy: _userDetailsModel.getUserMachineId!,
            activeProjectId: widget.isNew ? 0 : _projectDetailsModel.getActiveProjectId,
            projectType: _projectDetailsModel.getProjectType,
            createdByName: _userDetailsModel.getName!,
            createdByEmail: _userDetailsModel.getEmail!,
            industry: _projectDetailsModel.getIndustry,
            systemName: _projectDetailsModel.getSystemName,
            projectScopeStartDate: _projectScopeStartDateController.text.trim(),
            projectScopeEndDate: _projectScopeEndDateController.text.trim()
        );

        int resultId = await _projectDetailsModel.saveProjectDetails(context, projectDetails);

        if (resultId > 0) {
          await _projectDetailsModel.fetchProjectDetailsById(context, resultId);
          SnackbarMessage.showSuccessMessage(
            context, 
            '"${_projectDetailsModel.getName.trim()}" has been saved successfully.'
          );
        }
      } catch (e, errorStackTrace) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: 'Something went wrong! Please contact support for assistance.',
            errorStackTrace: errorStackTrace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveProjectInformation");
      } finally {
        _projectDetailsModel.setIsSaveHappening = false;
      }
    }
  }

  Future<void> _loadPage() async {
    try {
      if (!widget.isNew) {
        await _projectDetailsModel.fetchProjectDetailsById(context, _projectDetailsModel.getActiveProjectId);
      }
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: 'Something went wrong! Please contact support for assistance.',
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage");
    }
  }
}
