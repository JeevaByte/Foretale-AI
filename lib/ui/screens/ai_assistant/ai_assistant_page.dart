//core
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/mixins/polling_mixin.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/ui/screens/projects/project_modules.dart';
import 'package:provider/provider.dart';
//model
import 'package:foretale_application/models/ai_assistant_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
//ui
import 'package:foretale_application/ui/screens/ai_assistant/layouts/ai_assistant_wide_layout.dart';
import 'package:foretale_application/ui/screens/ai_assistant/widgets/conversation_panel.dart';
import 'package:foretale_application/ui/screens/ai_assistant/widgets/side_panel.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class AIAssistantPollingController extends ChangeNotifier with PollingMixin {}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final String _currentFileName = "ai_assistant_page.dart";
  late ProjectDetailsModel _projectDetailsModel;
  late AIAssistantModel _aiAssistantModel;
  late AIAssistantPollingController _pollingController;

  @override
  void initState() {
    super.initState();
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    _aiAssistantModel = Provider.of<AIAssistantModel>(context, listen: false);
    _pollingController = AIAssistantPollingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _aiAssistantModel.fetchTestsByProject(context);

      if (!mounted) return;
      unawaited(_fetchSessions(context));
      unawaited(_fetchTestExecutionStatus(context));

      if (!mounted) return;
      
      _aiAssistantModel.setPollingInterval(const Duration(seconds: 5));    
      _pollingController.setPollingInterval(const Duration(seconds: 5));
      _aiAssistantModel.setIsPolling = true;
      _pollingController.startPollingMultiple(context, [
        _syncAndFetchTestExecutionStatus,
      ]);
    });
  }

  @override
  void dispose() {
    _pollingController.stopPolling();
    _pollingController.dispose();
    // Use silent method to avoid notifyListeners during disposal
    _aiAssistantModel.setIsPollingSilent(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return CustomPageWrapper(
      size: size,
      onBackPressed: () => Navigator.pop(context),
      onHomePressed: () => context.fadeNavigateTo(const ProjectModules()),
      enableGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopSection(context),
          const SizedBox(height: 32),
          Expanded(
            child: _buildMainContent(context, size),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return ProjectHeaderSection(
      projectName: _projectDetailsModel.getName,
      sectionTitle: 'foretale.ai',
    );
  }

  Widget _buildMainContent(BuildContext context, Size size) {
    final conversation = ConversationPanel();

    final sidePanel = const SidePanel();

    return AIAssistantWideLayout(
      conversationPanel: conversation,
      sidePanel: sidePanel,
      sidePanelFlex: 1,
      conversationPanelFlex: 3,
    );
  }

  Future<void> _syncAndFetchTestExecutionStatus(BuildContext context) async {
    if (!mounted) return;
    
    try {
      await _aiAssistantModel.fetchTestsByProject(context);
      await _aiAssistantModel.fetchTestExecutionStatus(context);
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
        requestPath: "_syncAndFetchTestExecutionStatus",
      );
    }
  }

  Future<void> _fetchTestExecutionStatus(BuildContext context) async {
    if (!mounted) return;
    
    try {
      await _aiAssistantModel.fetchTestExecutionStatus(context);
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
        requestPath: "_fetchTestExecutionStatus",
      );
    }
  }

  Future<void> _fetchSessions(BuildContext context) async {
    if (!mounted) return;
    
    try {
      await _aiAssistantModel.fetchSessions(context);
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
        requestPath: "_fetchSessions",
      );
    }
  }
}
