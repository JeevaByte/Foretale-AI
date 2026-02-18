//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/client_contacts_model.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:provider/provider.dart';

//widgets
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_client_contacts.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/core/utils/message_helper.dart';

class ClientContactsScreen extends StatefulWidget {
  final bool isNew;
  final TabController tabController;

  const ClientContactsScreen(
    {super.key, required this.isNew, 
    required this.tabController
  });

  @override
  State<ClientContactsScreen> createState() => _ClientContactsScreenState();
}

class _ClientContactsScreenState extends State<ClientContactsScreen> {
  final String _currentFileName = "client_contacts.dart";
  final _formKey = GlobalKey<FormState>();

  // Controllers for Client Contact Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late ClientContactsModel _clientContactsModel;

  @override
  void initState() {
    super.initState();
    _clientContactsModel = Provider.of<ClientContactsModel>(context, listen: false);

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
      child: Consumer<ClientContactsModel>(
        builder: (context, clientContactsModel, child) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildClientContactsWidget(context, clientContactsModel),
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

  Widget _buildAddButton(BuildContext context, ClientContactsModel clientContactsModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 1.25;
    return CustomIconButton(
      icon: Icons.add,
      iconSize: iconSize,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      iconColor: colorScheme.primary,
      onPressed: () {
        _saveClientContact(context);
      },
      tooltip: 'Add client contact',
      isProcessing: clientContactsModel.getIsSaveHappening,
    );
  }

  Widget _buildClientContactsWidget(BuildContext context, ClientContactsModel clientContactsModel) {
    return CustomContainer(
      title: 'Client Contacts',
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form fields for adding new client contact
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
                        _buildAddButton(context, clientContactsModel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const ClientContactsDataGrid(),
        ],
      ),
    );
  }

  Widget _buildActionButtonsWidget(BuildContext context) {
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
            widget.tabController.animateTo(2);
          },
          tooltip: 'Previous',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        ),
        SizedBox(width: spacing),
        CustomIconButton(
          icon: Icons.arrow_forward,
          iconSize: iconSize,
          onPressed: () {
            widget.tabController.animateTo(4);
          },
          tooltip: 'Next',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Future<void> _saveClientContact(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        _clientContactsModel.setIsSaveHappening = true;
        int resultId = await _clientContactsModel.addUpdateContact(
            context,
            ClientContact(
                name: _nameController.text.trim(),
                position: _jobTitleController.text.trim(),
                function: _departmentController.text.trim(),
                email: _emailController.text.trim(),
                phone: '',
                isClient: 'Yes'));

        if (resultId > 0) {
          SnackbarMessage.showSuccessMessage(context,
              '"${_nameController.text.trim()}" has been added to the project.');
          _nameController.clear();
          _jobTitleController.clear();
          _departmentController.clear();
          _emailController.clear();
        }
      } catch (e, errorStackTrace) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: errorStackTrace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveClientContact");
      } finally {
        _clientContactsModel.setIsSaveHappening = false;
      }
    }
  }

  Future<void> _fetchClientContacts(BuildContext context) async {
    await _clientContactsModel.fetchClientsByProjectId(context);
  }

  Future<void> _loadPage() async {
    try {
      _clientContactsModel.setIsPageLoading = true;
      await _fetchClientContacts(context);
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, 'Something went wrong!',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage");
    } finally {
      _clientContactsModel.setIsPageLoading = false;
    }
  }
}

