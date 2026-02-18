//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/core/utils/responsive.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/question_model.dart';
//screen
import 'package:foretale_application/ui/screens/datagrids/sfdg_questions.dart';
import 'package:foretale_application/ui/screens/landing/landing.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/dropdowns/custom_dropdown_search.dart';
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:provider/provider.dart';

class QuestionsScreen extends StatefulWidget {
  final bool isNew;

  const QuestionsScreen({super.key, required this.isNew});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> with TickerProviderStateMixin<QuestionsScreen>, PageEntranceAnimations {
  final String _currentFileName = "project_questions.dart";
  late ProjectDetailsModel _projectDetailsModel;
  late QuestionsModel _questionModel;
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _industryTextController = TextEditingController();
  final TextEditingController _projectTypeTextController = TextEditingController();
  final TextEditingController _questionTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    _questionModel = Provider.of<QuestionsModel>(context, listen: false);
    initializeEntranceAnimations();
    startEntranceAnimations();
    
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await _loadPage()
    );
  }

  @override
  void dispose() {
    disposeEntranceAnimations();
    _industryTextController.dispose();
    _projectTypeTextController.dispose();
    _questionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    _industryTextController.text = _projectDetailsModel.getIndustry;
    _projectTypeTextController.text = _projectDetailsModel.getProjectType;

    Widget content = buildSlideAndFadeTransition(
      child: Consumer<QuestionsModel>(
        builder: (context, questionModel, child) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopSection(context),
                const SizedBox(height: 20),
                _buildMainContent(context),
              ],
            ),
          );
        },
      )
    );

    return CustomPageWrapper(
      size: size,
      onBackPressed: () => Navigator.pop(context),
      onHomePressed: () => context.fadeNavigateTo(const LandingPage()),
      enableGradient: true,
      child: content,
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return ProjectHeaderSection(
      projectName: _projectDetailsModel.getName,
      sectionTitle: 'Add a new question',
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return 
    Consumer<QuestionsModel>(
      builder: (context, questionModel, child) {
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProjectInformationWidget(context, questionModel),
                const SizedBox(height: 25),
                _buildQuestionsGridWidget(context, questionModel)
              ],
            )
          )
        );
      },
    );
  }

  Widget _buildProjectInformationWidget(BuildContext context, QuestionsModel questionModel) {
    return CustomContainer(
      title: 'Project Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  isEnabled: false,
                  controller: _industryTextController,
                  label: 'Industry',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  isEnabled: false,
                  controller: _projectTypeTextController,
                  label: 'Project Type',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTopicDropdown(context, questionModel),
              ),
            ],
          ),
          const SizedBox(height: 15), 
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: CustomTextField(
                  isEnabled: true,
                  controller: _questionTextController,
                  label: 'Type your question',
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Question is required';
                    } else if (value.length < 10) {
                      return 'Question should be at least 10 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 20),
              _buildAddButton(context, questionModel),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuestionsGridWidget(BuildContext context, QuestionsModel questionModel) {
    return CustomContainer(
      title: 'Project Questions',
      child: (questionModel.getIsPageLoading) ? buildLoadingState(context) : QuestionsDataGrid(),
    );
  }

  Widget _buildTopicDropdown(BuildContext context, QuestionsModel questionModel) {
    return CustomDropdownSearch(
      items: questionModel.getTopicsList,
      isEnabled: widget.isNew,
      hintText: 'Select a topic',
      title: 'Topic',
      selectedItem: questionModel.getSelectedTopic,
      onChanged: (String? selectedItem) {
        questionModel.setSelectedTopic(selectedItem ?? '');
      },
    );
  }

  Widget _buildAddButton(BuildContext context, QuestionsModel questionModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 1.25;
    
    return CustomIconButton(
      icon: Icons.add,
      iconSize: iconSize,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      iconColor: colorScheme.primary,
      onPressed: () => _saveQuestion(context, questionModel),
      tooltip: 'Add',
      isProcessing: questionModel.getIsSaving,
      isEnabled: !questionModel.getIsSaving,
    );
  }

  Future<void> _saveQuestion(BuildContext context, QuestionsModel questionModel) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        questionModel.setIsSaving = true;
        int resultId = await _questionModel.addNewQuestionByProjectId(
          context,
          _questionTextController.text.trim(),
          questionModel.getSelectedTopic,
        );

        if (resultId > 0) {
          questionModel.fetchQuestionsByProject(context);
          _questionTextController.text = '';
          questionModel.setSelectedTopic('');
          SnackbarMessage.showSuccessMessage(context, 'Question added successfully!');
        }
      } catch (e) {
        SnackbarMessage.showErrorMessage(
          context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: '_saveQuestion',
        );
      } finally {
        questionModel.setIsSaving = false;
      }
    }
  }


  Future<void> _loadPage() async {
    try {
      await Future.wait([
        _questionModel.fetchQuestionsByProject(context),
        _questionModel.fetchTopics(context),
      ]);
    } catch (e, errorStackTrace) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context,
          'Something went wrong! Please contact support for assistance.',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: '_loadPage',
        );
      }
    }
  }
}
