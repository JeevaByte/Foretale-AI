import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/create_test_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/topic_list_model.dart';
import 'package:foretale_application/ui/screens/create_test/create_test_service.dart';
import 'package:foretale_application/ui/widgets/dropdowns/custom_dropdown_search.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:provider/provider.dart';

class BasicInformationSection extends StatefulWidget {
  final bool isNew;
  final TabController tabController;

  const BasicInformationSection({
    super.key,
    required this.isNew,
    required this.tabController,
  });

  @override
  State<BasicInformationSection> createState() => _BasicInformationSectionState();
}

class _BasicInformationSectionState extends State<BasicInformationSection> {
  late CreateTestModel _createTestModel;
  late ProjectDetailsModel _projectDetailsModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late TextEditingController _industryController;
  late TextEditingController _topicController;
  late TextEditingController _projectTypeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _technicalDescriptionController;
  late TextEditingController _potentialImpactController;

  @override
  void initState() {
    super.initState();
    _createTestModel = Provider.of<CreateTestModel>(context, listen: false);
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    
    // Initialize controllers
    _industryController = TextEditingController();
    _topicController = TextEditingController();
    _projectTypeController = TextEditingController();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _technicalDescriptionController = TextEditingController();
    _potentialImpactController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
    });
  }

  @override
  void dispose() {
    _industryController.dispose();
    _topicController.dispose();
    _projectTypeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _technicalDescriptionController.dispose();
    _potentialImpactController.dispose();
    super.dispose();
  }

  Future<void> _loadPage() async {
    try {
      _createTestModel.setProjectType(_projectDetailsModel.getProjectType);
      _createTestModel.setIndustry(_projectDetailsModel.getIndustry);
      await _fetchTopics();
    } catch (e) {
      SnackbarMessage.showErrorMessage(context, 'Error loading page: $e');
    }
  }

  Future<void> _fetchTopics() async {
    if (_createTestModel.getTopicList.isNotEmpty) return;
    final lkpList = await TopicList().fetchAllActiveTopics(context);
    _createTestModel.setTopicList = lkpList;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTestModel>(
      builder: (context, createTestModel, child) {
        _industryController.text = createTestModel.getIndustry;
        _topicController.text = createTestModel.getTopic;
        _projectTypeController.text = createTestModel.getProjectType;
        _nameController.text = createTestModel.getTestName;
        _descriptionController.text = createTestModel.getTestDescription;
        _technicalDescriptionController.text = createTestModel.getTechnicalDescription;
        _potentialImpactController.text = createTestModel.getPotentialImpact;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildFirstRow(context, createTestModel),
                      const SizedBox(height: 20),
                      _buildAiMagicRow(createTestModel),
                      const SizedBox(height: 15),
                      _buildThirdRow(context, createTestModel),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _buildActionButtons(context, createTestModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFirstRow(BuildContext context, CreateTestModel createTestModel) {
    return CustomContainer(title: "Choose a module", 
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Industry
        Expanded(
          flex: 1,
          child: CustomTextField(
            controller: _industryController,
            label: 'Industry',
            isEnabled: false,
          ),
        ),
        const SizedBox(width: 20),
        // Project Type
        Expanded(
          flex: 1,
          child: CustomTextField(
            controller: _projectTypeController,
            label: 'Project Type',
            isEnabled: false,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: CustomDropdownSearch(
            items: createTestModel.getTopicList.map((topic) => topic.name).toList(),
            title: 'Topic',
            hintText: 'Choose Topic',
            isEnabled: widget.isNew,
            selectedItem: createTestModel.getTopic,
            onChanged: (value) {  
              createTestModel.setTopic(value??'');
            },
          ),
        ),
      ],
    ));
  }

  Widget _buildAiMagicRow(CreateTestModel createTestModel) {
    return CustomContainer(title: "Ask AI", 
    child: Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: _nameController,
            label: 'Test Name',
            validator: (value) => CreateTestService.validateRequiredField(value, 'Test name'),
            isEnabled: widget.isNew,
            onChanged: (value) {
              createTestModel.setTestName(value, notify: false);
            },
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
      ],
    ));
  }

  Widget _buildThirdRow(BuildContext context, CreateTestModel createTestModel){
    return CustomContainer(title: "Test details", 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: 
        CustomTextField(
          controller: _descriptionController,
          label: 'Test Description',
          maxLines: 16,
          validator: (value) => CreateTestService.validateRequiredField(value, 'Description'),
          isEnabled: widget.isNew,
          onChanged: (value) {
            createTestModel.setTestDescription(value, notify: false);
          },
        )),
        const SizedBox(width: 15),
        Expanded(child: CustomTextField(
          controller: _technicalDescriptionController,
          label: 'Technical Description',
          maxLines: 16,
          validator: (value) => CreateTestService.validateRequiredField(value, 'Technical description'),
          isEnabled: widget.isNew,
          onChanged: (value) {
            createTestModel.setTechnicalDescription(value, notify: false);
          },
        )),
        const SizedBox(width: 15),
        Expanded(child: CustomTextField(
          controller: _potentialImpactController,
          label: 'Potential Impact Statement',
          maxLines: 16,
          validator: (value) => CreateTestService.validateRequiredField(value, 'Potential impact'),
          isEnabled: widget.isNew,
          onChanged: (value) {
            createTestModel.setPotentialImpact(value, notify: false);
          },
        ))
      ],
    ));
  }

  Widget _buildActionButtons(BuildContext context, CreateTestModel createTestModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.medium) * 2;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconButton(
          icon: Icons.arrow_forward,
          iconSize: iconSize,
          onPressed: () {
            if(_formKey.currentState!.validate()) {
              widget.tabController.animateTo(1);
            }
          },
          tooltip: 'Next',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}