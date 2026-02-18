//core
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/ui/screens/projects/project_modules.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/core/services/mixins/polling_mixin.dart';
//utils
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
//ui
import 'package:foretale_application/ui/screens/create_test/create_test.dart';
import 'package:foretale_application/ui/screens/test_case/test_card_widgets.dart';
//model
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
//listviews
//widgets
import 'package:foretale_application/ui/widgets/ai_box/ai_box.dart';
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';
import 'package:foretale_application/ui/widgets/app_actions/expandable_actions_button.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';

class TestConfigPage extends StatefulWidget {
  const TestConfigPage({super.key});

  @override
  State<TestConfigPage> createState() => _TestConfigPageState();
}

class TestConfigPollingController extends ChangeNotifier with PollingMixin {}

class _TestConfigPageState extends State<TestConfigPage> {
  final String _currentFileName = "test_config.dart";
  String loadText = 'Loading...';

  final TextEditingController _searchController = TextEditingController();
  FilePickerResult? filePickerResult;

  late TestsModel _testsModel;
  late ProjectDetailsModel _projectDetailsModel;
  late InquiryResponseModel _inquiryResponseModel;
  late TestConfigPollingController _pollingController;

  @override
  void initState() {
    super.initState();
    _testsModel = Provider.of<TestsModel>(context, listen: false);
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    _inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    _pollingController = TestConfigPollingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {          
      await _loadPage();
      
      if (mounted) {
        //check if there are any running tests
        _pollingController.setPollingInterval(const Duration(seconds: 120));
        _pollingController.startPollingMultiple(context, [
          _fetchTestExecutionStatus,
          _fetchResponsesByTest,
        ]);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pollingController.stopPolling();
    _pollingController.dispose();

    _testsModel.updateTestIdSelection(0, notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopSection(context),
        const SizedBox(height: 4),
        Expanded(
          child: _buildMainContent(context, size),
        ),
      ],
    );

    return CustomPageWrapper(
      size: size,
      onBackPressed: () => Navigator.pop(context),
      onHomePressed: () => context.fadeNavigateTo(const ProjectModules()),
      additionalActions: [
        ActionItem(
          icon: Icons.add,
          onPressed: () => _navigateToCreateTest(context),
          tooltip: 'Create Control',
        ),
        //refresh action
        ActionItem(
          icon: Icons.refresh,
          onPressed: () => _loadPage(),
          tooltip: 'Refresh',
        ),
      ],
      enableGradient: true,
      child: content,
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return ProjectHeaderSection(
      projectName: _projectDetailsModel.getName,
      sectionTitle: 'Controls Register',
    );
  }

  Widget _buildMainContent(BuildContext context, Size size) {
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Main content
          Expanded(
            child: Row(
              children: [
                // Tests list
                Flexible(
                  flex: 6,
                  child: CustomContainer(
                    title: "Choose a control",
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _searchController,
                                  label: "Search controls...",
                                  isEnabled: true,
                                  onChanged: (value) async =>
                                      await _testsModel.filterData(value.trim()),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Consumer<TestsModel>(
                            builder: (context, model, __) {
                              final filteredTests = model.getFilteredTestList;
                              
                              if(model.getIsPageLoading) {
                                return buildLoadingState(context);
                              }
                              
                              if (filteredTests.isEmpty) {
                                return EmptyState(
                                  title: "Controls register is empty",
                                  subtitle: "Start by creating a new control",
                                  icon: Icons.search_off,
                                  onActionPressed: () => _navigateToCreateTest(context),
                                  actionText: "Create Control",
                                );
                              }
                              return const TestsListView();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Test details and chat
                Consumer<TestsModel>(
                  builder: (context, model, child) {
                    return Flexible(
                      flex: 2,
                      child: CustomContainer(
                        title: "AI assistant",
                        padding: const EdgeInsets.all(2),
                        child: AIBox(
                          key: ValueKey('test_chat_${model.getSelectedTest.testId}'),
                          drivingModel: model,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  //navigate to create test
  void _navigateToCreateTest(BuildContext context) async{
    _testsModel.updateTestIdSelection(0);
    await context.fadeNavigateTo(const CreateTest(isNew: true));
    _testsModel.fetchTestsByProject(context);
  }

  Future<void> _loadPage() async {
    try {
      _testsModel.setIsPageLoading = true;
      await _testsModel.fetchTestsByProject(context);
      if (_testsModel.getSelectedTestId > 0) {
        await _loadResponses();
      }
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage");
    } finally {
      _testsModel.setIsPageLoading = false;
    }
  }

  Future<void> _loadResponses() async {
    await _inquiryResponseModel.fetchResponsesByReference(context, _testsModel.getSelectedTestId, 'test');
  }

  Future<void> _fetchTestExecutionStatus(BuildContext context) async {
    if (!mounted) return;
    
    try{
      await _testsModel.fetchTestExecutionStatus(context);
    } catch (e, errorStackTrace) {
      if (!mounted) return;
      SnackbarMessage.showErrorMessage(
          context, 
          e.toString(),
          showUserMessage: false,
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_fetchTestExecutionStatus");
    }
  }

  Future<void> _fetchResponsesByTest(BuildContext context) async {
    if (!mounted) return;
    try{
      if(_testsModel.getSelectedTestId == 0 || !_testsModel.getSelectedTest.markAsCompleted) return;
      await _inquiryResponseModel.fetchResponsesByReference(context, _testsModel.getSelectedTestId, 'test');
    } catch (e, errorStackTrace) {
      if (!mounted) return;
      SnackbarMessage.showErrorMessage(
          context, 
          e.toString(),
          showUserMessage: false,
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_fetchResponsesByTest");
    }
  }
}
