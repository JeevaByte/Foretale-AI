import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/create_test_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/widgets/dropdowns/custom_dropdown_search.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/core/constants/values.dart';

class TestConfigurationSection extends StatefulWidget {
  final bool isNew;
  final TabController tabController;

  const TestConfigurationSection({
    super.key,
    required this.isNew,
    required this.tabController,
  });

  @override
  State<TestConfigurationSection> createState() => _TestConfigurationSectionState();
}

class _TestConfigurationSectionState extends State<TestConfigurationSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _currentFileName = "test_settings.dart";

  late CreateTestModel _createTestModel;
  
  // Data for dropdowns
  final List<String> runTypes = runTypesList;
  final List<String> criticalityLevels = criticalityLevelsList;
  final Map<String, List<String>> runPrograms = runProgramsList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _createTestModel = Provider.of<CreateTestModel>(context, listen: false);
      await _loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTestModel>(
      builder: (context, createTestModel, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildTestConfigurationWidget(context, createTestModel),
                      const SizedBox(height: 25),
                      _buildTestClassificationWidget(context, createTestModel),
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

  Widget _buildTestConfigurationWidget(BuildContext context, CreateTestModel createTestModel) {
    return CustomContainer(
      title: 'Test Configuration',
      padding: const EdgeInsets.all(30),
      child: Row(
        children: [
          Expanded(
            child: CustomDropdownSearch(
              items: runTypes,
              isEnabled: widget.isNew,
              hintText: 'Choose Run Type',
              title: "Run Type",
              selectedItem: createTestModel.getRunType,
              onChanged: (String? selectedItem) {
                createTestModel.setRunProgram(null);
                createTestModel.setRunType(selectedItem);
              },
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: CustomDropdownSearch(
              items: runPrograms[createTestModel.getRunType] ?? [],
              isEnabled: widget.isNew,
              hintText: 'Choose Run Program',
              title: "Run Program",
              selectedItem: createTestModel.getRunProgram,
              onChanged: (String? selectedItem) {
                createTestModel.setRunProgram(selectedItem);
              },
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: CustomDropdownSearch(
              items: criticalityLevels,
              isEnabled: widget.isNew,
              hintText: 'Choose Criticality',
              title: "Criticality",
              selectedItem: createTestModel.getCriticality,
              onChanged: (String? selectedItem) {
                createTestModel.setCriticality(selectedItem);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestClassificationWidget(BuildContext context, CreateTestModel createTestModel) {
    return CustomContainer(
      title: 'Test Classification',
      padding: const EdgeInsets.all(30),
      child: Row(
        children: [
          Expanded(
            child: CustomDropdownSearch(
              items: createTestModel.getCategoriesList,
              isEnabled: widget.isNew,
              hintText: 'Choose Category',
              title: "Category",
              selectedItem: createTestModel.getCategory,
              onChanged: (String? selectedItem) {
                _handleCategoryChanged(selectedItem ?? '', createTestModel);
              },
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: CustomDropdownSearch(
              items: createTestModel.getModulesList,
              isEnabled: widget.isNew,
              hintText: 'Choose Module',
              title: "Module",
              selectedItem: createTestModel.getModule,
              onChanged: (String? selectedItem) {
                createTestModel.setModule(selectedItem);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CreateTestModel createTestModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.medium) * 2;
    final spacing = context.spacing(size: SpacingSize.medium);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        CustomIconButton(
          icon: Icons.arrow_back,
          iconSize: iconSize,
          onPressed: () => _handlePreviousButton(),
          tooltip: 'Previous',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        ),
        SizedBox(width: spacing),
        // Save button
        CustomIconButton(
          icon: Icons.save,
          iconSize: iconSize,
          onPressed: () => _handleSaveTest(context, createTestModel),
          tooltip: 'Save',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          isProcessing: createTestModel.getIsSaveHappening,
        ),
      ],
    );
  }

  void _handleCategoryChanged(String selectedCategory, CreateTestModel createTestModel) {
    try {
      createTestModel.setCategory(selectedCategory);
      createTestModel.fetchModules(context, selectedCategory);
    } catch (e) {
      SnackbarMessage.showErrorMessage(context, 'Failed to load modules for selected category');
    }
  }

  void _handlePreviousButton() {
    widget.tabController.animateTo(widget.tabController.index - 1);
  }

  void _handleSaveTest(BuildContext context, CreateTestModel createTestModel) async {
    try {
      createTestModel.setIsSaveHappening = true;
      if (_formKey.currentState!.validate()) {
        int testId = await createTestModel.saveTest(context);

        if (testId > 0) {
          SnackbarMessage.showSuccessMessage(context, 'Test saved successfully!');
          _createTestModel.clearAllState();
          await TestsModel().fetchTestsByProject(context);
          Navigator.pop(context);
        }
      } 
    } catch (e, stackTrace) {
      SnackbarMessage.showErrorMessage(
        context, 
        'Something went wrong! Please contact support for assistance.', 
        logError: true, 
        errorMessage: e.toString(), 
        errorStackTrace: stackTrace.toString(), 
        errorSource: "CreateTestService", 
        severityLevel: 'Critical', 
        requestPath: "handleSaveTest",
      );
    } finally {
      createTestModel.setIsSaveHappening = false;
    }
  }

  Future<void> _loadInitialData() async {
    try {
      await _createTestModel.fetchCategories(context);
    } catch (e) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context, 
          'Failed to load initial data',
          logError: true,
          errorMessage: e.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadInitialData",
        );
      }
    }
  }
} 