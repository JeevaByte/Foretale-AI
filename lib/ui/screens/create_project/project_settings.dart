//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/project_settings_model.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
//widgets
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';

class ProjectSettingsScreen extends StatefulWidget {
  final bool isNew;
  final TabController tabController;

  const ProjectSettingsScreen({
    super.key, 
    required this.isNew,
    required this.tabController
  });

  @override
  State<ProjectSettingsScreen> createState() => _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends State<ProjectSettingsScreen> {
  final String _currentFileName = "project_settings.dart";
  final _formKey = GlobalKey<FormState>();

  // Controllers for each text field
  final TextEditingController _sqlHostController = TextEditingController();
  final TextEditingController _sqlPortController = TextEditingController();
  final TextEditingController _sqlDatabaseController = TextEditingController();
  final TextEditingController _sqlUsernameController = TextEditingController();
  final TextEditingController _sqlPasswordController = TextEditingController();
  final TextEditingController _s3UrlController = TextEditingController();
  final TextEditingController _s3UsernameController = TextEditingController();
  final TextEditingController _s3PasswordController = TextEditingController();

  late ProjectSettingsModel _projectSettingsModel;

  @override
  void initState() {
    super.initState();
    _projectSettingsModel = Provider.of<ProjectSettingsModel>(context, listen: false);

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
      child: Consumer<ProjectSettingsModel>(
        builder: (context, projectSettingsModel, child) {
          return projectSettingsModel.getIsPageLoading
            ? buildLoadingState(context)
            : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildDatabaseConfigurationWidget(context, projectSettingsModel),
                          const SizedBox(height: 25),
                          _buildS3ConfigurationWidget(context, projectSettingsModel),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildActionButtonsWidget(context, projectSettingsModel),
                ],
              ),
            );
        },
      ),
    );
  }

  Widget _buildDatabaseConfigurationWidget(BuildContext context, ProjectSettingsModel projectSettingsModel) {
    _sqlHostController.text = projectSettingsModel.getSqlHost;
    _sqlPortController.text = projectSettingsModel.getSqlPort.toString();
    _sqlDatabaseController.text = projectSettingsModel.getSqlDatabase;
    _sqlUsernameController.text = projectSettingsModel.getSqlUsername;
    _sqlPasswordController.text = projectSettingsModel.getSqlPassword;

    return CustomContainer(
      title: 'Database Details (Optional)',
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Row 1: SQL Server Host and Port
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  isEnabled: true,
                  controller: _sqlHostController,
                  label: 'SQL Server Host',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Server name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 1,
                child: CustomTextField(
                  isEnabled: true,
                  controller: _sqlPortController,
                  label: 'Port',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Port is required';
                    }
                    // Check if the value is a valid integer
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number for Port';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Row 2: Database name
          CustomTextField(
            isEnabled: true,
            controller: _sqlDatabaseController,
            label: 'Database',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Database name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          // Row 3: Username and Password
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  isEnabled: true,
                  controller: _sqlUsernameController,
                  label: 'Username (Leave blank for Windows Authentication)',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: CustomTextField(
                  isEnabled: true,
                  controller: _sqlPasswordController,
                  label: 'Password (Leave blank for Windows Authentication)',
                  obscureText: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildS3ConfigurationWidget(BuildContext context, ProjectSettingsModel projectSettingsModel) {
    _s3UrlController.text = projectSettingsModel.getS3Url;
    _s3UsernameController.text = projectSettingsModel.getS3Username;
    _s3PasswordController.text = projectSettingsModel.getS3Password;

    return CustomContainer(
      title: 'Storage Details (Optional)',
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          CustomTextField(
            isEnabled: true,
            controller: _s3UrlController,
            label: 'Amazon S3 File Storage URL',
          ),
          const SizedBox(height: 15),
          // Row: S3 Username and Password
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  isEnabled: true,
                  controller: _s3UsernameController,
                  label: 'S3 Username',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: CustomTextField(
                  isEnabled: true,
                  controller: _s3PasswordController,
                  label: 'S3 Password',
                  obscureText: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsWidget(BuildContext context, ProjectSettingsModel projectSettingsModel) {
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
            widget.tabController.animateTo(1);
          },
          tooltip: 'Previous',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          isEnabled: !projectSettingsModel.getIsSaveHappening ,
        ),
        SizedBox(width: spacing),
        CustomIconButton(
          icon: Icons.save,
          iconSize: iconSize,
          onPressed: () {
            _saveProjectSettings(context);
          },
          tooltip: 'Save',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          isProcessing: projectSettingsModel.getIsSaveHappening,
        ),
        SizedBox(width: spacing),
        CustomIconButton(
          icon: Icons.arrow_forward,
          iconSize: iconSize,
          onPressed: () {
            widget.tabController.animateTo(3);
          },
          tooltip: 'Next',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          isEnabled: !projectSettingsModel.getIsSaveHappening ,
        ),
      ],
    );
  }

  Future<void> _saveProjectSettings(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        _projectSettingsModel.setIsSaveHappening = true;
        _projectSettingsModel.projectSettings = ProjectSettings(
            sqlHost: _sqlHostController.text.trim(),
            sqlPort: int.parse(_sqlPortController.text.trim()),
            sqlDatabase: _sqlDatabaseController.text.trim(),
            sqlUsername: _sqlUsernameController.text.trim(),
            sqlPassword: _sqlPasswordController.text.trim(),
            s3Url: _s3UrlController.text.trim(),
            s3Username: _s3UsernameController.text.trim(),
            s3Password: _s3PasswordController.text.trim());

        int projectSettingId = await _projectSettingsModel.saveProjectSettings(context);
        if (projectSettingId > 0) {
          SnackbarMessage.showSuccessMessage(context, 'Project settings saved successfully.');
        }
      } catch (e, errorStackTrace) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: 'Something went wrong! Please contact support for assistance.',
            errorStackTrace: errorStackTrace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveProjectSettings");
      } finally {
        _projectSettingsModel.setIsSaveHappening = false;
      } 
    }
  }

  Future<void> _fetchProjectSettings(BuildContext context) async {
    await _projectSettingsModel.fetchProjectSettingsByUserMachineId(context);
  }

  Future<void> _loadPage() async {
    try {
      if (!widget.isNew) {
        await _fetchProjectSettings(context);
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
