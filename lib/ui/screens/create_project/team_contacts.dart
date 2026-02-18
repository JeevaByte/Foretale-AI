//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/team_contacts_model.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:provider/provider.dart';
//widgets
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_team_contacts.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/core/utils/message_helper.dart';

class TeamContactsScreen extends StatefulWidget {
  final bool isNew;
  final TabController tabController;

  const TeamContactsScreen(
    {super.key, required this.isNew, 
    required this.tabController
  });

  @override
  State<TeamContactsScreen> createState() => _TeamContactsScreenState();
}

class _TeamContactsScreenState extends State<TeamContactsScreen> {
  final String _currentFileName = "team_contacts.dart";
  final _formKey = GlobalKey<FormState>();

  // Controllers for Team Contact Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late TeamContactsModel _teamContactsModel;

  @override
  void initState() {
    super.initState();
    _teamContactsModel = Provider.of<TeamContactsModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Consumer<TeamContactsModel>(
        builder: (context, teamContactsModel, child) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTeamContactsWidget(context, teamContactsModel),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildActionButtonsWidget(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, TeamContactsModel teamContactsModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 1.25;
    return CustomIconButton(
      icon: Icons.add,
      iconSize: iconSize,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      iconColor: colorScheme.primary,
      onPressed: () {
        _saveTeamContact(context);
      },
      tooltip: 'Add team contact',
      isProcessing: teamContactsModel.getIsSaveHappening,
    );
  }

  Widget _buildTeamContactsWidget(BuildContext context, TeamContactsModel teamContactsModel) {
    return CustomContainer(
      title: 'Team Members',
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form fields for adding new team contact
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: Name and Function
              Expanded(
                child: Column(
                  children: [
                    CustomTextField(
                      isEnabled: true,
                      controller: _nameController,
                      label: 'Name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      isEnabled: true,
                      controller: _departmentController,
                      label: 'Function',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right column: Email, Position, and Add button
              Expanded(
                child: Column(
                  children: [
                    CustomTextField(
                      isEnabled: true,
                      controller: _emailController,
                      label: 'Email',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            isEnabled: true,
                            controller: _jobTitleController,
                            label: 'Position',
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildAddButton(context, teamContactsModel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const TeamContactsDataGrid(),
        ],
      ),
    );
  }

  Widget _buildActionButtonsWidget(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.medium) * 1;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconButton(
          icon: Icons.arrow_back,
          iconSize: iconSize,
          onPressed: () {
            widget.tabController.animateTo(3);
          },
          tooltip: 'Previous',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Future<void> _saveTeamContact(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        _teamContactsModel.setIsSaveHappening = true;
        int resultId = await _teamContactsModel.addUpdateContact(
            context,
            TeamContact(
                name: _nameController.text.trim(),
                position: _jobTitleController.text.trim(),
                function: _departmentController.text.trim(),
                email: _emailController.text.trim(),
                phone: '',
                isClient: 'No'));

        if (resultId > 0) {
          SnackbarMessage.showSuccessMessage(context,'"${_nameController.text.trim()}" has been added to the project.');
          _nameController.clear();
          _jobTitleController.clear();
          _departmentController.clear();
          _emailController.clear();
        }
      } catch (e, errorStackTrace) {
        SnackbarMessage.showErrorMessage(context, 
            "Something went wrong! Please contact support for assistance.",
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: errorStackTrace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveTeamContact");
      } finally {
        _teamContactsModel.setIsSaveHappening = false;
      }
    }
  }

  Future<void> _fetchTeamContacts(BuildContext context) async {
    await _teamContactsModel.fetchTeamByProjectId(context);
  }

  Future<void> _loadPage() async {
    try {
      _teamContactsModel.setIsPageLoading = true;
      await _fetchTeamContacts(context);
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, 'Something went wrong!',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage");
    } finally {
      _teamContactsModel.setIsPageLoading = false;
    }
  }
}
