import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';

import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/models/ai_assistant_model.dart';
import 'package:foretale_application/models/ai_session_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/ui/widgets/ai_box/model/message_event_model.dart';
import 'package:foretale_application/ui/widgets/ai_box/business/message_service.dart';
import 'package:foretale_application/ui/widgets/ai_box/business/agent/agent_service.dart';
import 'package:foretale_application/ui/widgets/ai_box/business/chat/chat_service.dart';

class BaseAIBoxProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isConnected = false;
  StreamSubscription<MessageEvent>? _subscription;
  MessageService? _service;

  final List<Message> _messages = [];
  Message? _currentStreamingMessage;
  final String _sessionId;

  bool _isSessionSaved = false;

  final BuildContext context;
  final ChatDrivingModel drivingModel;

  BaseAIBoxProvider({
    required this.context,
    required this.drivingModel,
  }) : _sessionId = DateTime.now().millisecondsSinceEpoch.toString() {
    _initializeService();
  }

  List<Message> get messages => _messages;
  void addMessage(
    Message message) => _messages.add(message
  );
  void clearMessages() => _messages.clear();

  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isConnected => _isConnected;
  set isConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  void _initializeService() {
    _disposeService();
    _service = _createService();
    _listenToService();
    
    final aiAssistantModel = Provider.of<AIAssistantModel>(context, listen: false);
    final sessionId = aiAssistantModel.getSelectedSessionId;
    
    _service?.connect(sessionId: sessionId);
  }

  MessageService _createService() {
    if (drivingModel.isAgentMode) {
      return AgentService();
    } else {
      return ChatService(context: context, drivingModel: drivingModel);
    }
  }

  void _listenToService() {
    _subscription?.cancel();
    _subscription = _service?.messageStream.listen(_handleMessageEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onServiceInitialized();
    });
  }

  void _onServiceInitialized() {
    if (drivingModel.isAgentMode) {
      final aiAssistantModel = Provider.of<AIAssistantModel>(context, listen: false);
      aiAssistantModel.updateMetricsPartial(
        latencyMs: 0,
        isSynced: false,
        isGuardrailActivated: false,
        isExplainableAIEnabled: false,
        isConnected: false,
      );
    } else {
      final inquiryModel = Provider.of<InquiryResponseModel>(context, listen: false);
      isConnected = true;
      isLoading = inquiryModel.getIsPageLoading;
    }
  }

  void _handleMessageEvent(MessageEvent event) {
    switch (event.type) {
      case MessageEventType.streamingChunk:
        if (_currentStreamingMessage == null) {
          _currentStreamingMessage = Message('', false, isStreaming: true, startTime: DateTime.now());
          _messages.add(_currentStreamingMessage!);
        }
        _currentStreamingMessage!.content += event.content ?? '';
        notifyListeners();
        break;
        
      case MessageEventType.agentStep:
        if (_currentStreamingMessage == null) {
          _currentStreamingMessage = Message('', false, isStreaming: true, startTime: DateTime.now());
          _messages.add(_currentStreamingMessage!);
        }
        
        if (event.data != null && event.data!['agent_steps'] != null) {
          final agentSteps = event.data!['agent_steps'] as List;
          for (final stepData in agentSteps) {
            if (stepData is Map<String, dynamic>) {
              final toolMessage = stepData['tool_message'] as String? ?? '';
              final status = stepData['status'] as String? ?? 'started';
              final runId = stepData['run_id'] as String? ?? '';
              
              if (runId.isNotEmpty) {
                final existingStepIndex = _currentStreamingMessage!.agentSteps.indexWhere((step) => step.runId == runId);
                
                if (existingStepIndex >= 0) {
                  _currentStreamingMessage!.agentSteps[existingStepIndex].status = status;
                } else {
                  _currentStreamingMessage!.agentSteps.add(AgentStep(
                    toolMessage: toolMessage,
                    status: status,
                    runId: runId,
                  ));
                }
              }
            }
          }
          notifyListeners();
        }
        break;
        
      case MessageEventType.streamingComplete:
        if (_currentStreamingMessage != null) {
          _currentStreamingMessage!.isStreaming = false;
          _currentStreamingMessage = null;
        }
        isLoading = false;
        break;
        
      case MessageEventType.historyMessage:
        if (event.data != null && event.data!['content'] != null) {
          final content = event.data!['content'] as Map<String, dynamic>;
          final text = content['text'] as String? ?? '';
          final messageType = content['type'] as String? ?? 'ai';
          final isUser = messageType == 'human';
          final agentSteps = event.data!['agent_steps'] as List? ?? [];

          final tokens = content['tokens'] as Map<String, dynamic>?;
          final totalTokens = tokens?['total_tokens'] as int? ?? 0;
          final aiAssistantModel = Provider.of<AIAssistantModel>(context, listen: false);
          aiAssistantModel.updateTokenUsage(totalTokens);
          
          final historyMessage = Message(
            text,
            isUser,
            isStreaming: false,
            agentSteps: agentSteps.map((step) {
              if (step is Map<String, dynamic>) {
                return AgentStep(
                  toolMessage: step['tool_message'] as String? ?? '',
                  status: step['status'] as String? ?? 'completed',
                  runId: step['run_id'] as String? ?? '',
                );
              }
              return AgentStep(toolMessage: '', status: 'completed', runId: '');
            }).toList(),
          );
          
          _messages.add(historyMessage);
          notifyListeners();
        }
        break;
        
      case MessageEventType.error:
        isLoading = false;
        _messages.add(Message(event.content ?? 'Error occurred. Please try again.', false));
        notifyListeners();
        break;

      case MessageEventType.metrics:
        if (event.content != null) {
          try {
            final content = jsonDecode(event.content!) as Map<String, dynamic>;
            final latency = content['latency'] as int? ?? 0;
            final tokens = content['tokens'] as Map<String, dynamic>?;
            final totalTokens = tokens?['total_tokens'] as int? ?? 0;
            
            final aiAssistantModel = Provider.of<AIAssistantModel>(context, listen: false);
            aiAssistantModel.setLatencyMs(latency);
            if (totalTokens > 0) {
              aiAssistantModel.updateTokenUsage(totalTokens);
            }
          } catch (e) {
            SnackbarMessage.showErrorMessage(
              context, 
              'Error parsing metrics: $e', 
              showUserMessage: false,
              logError: true, errorMessage: 'Error parsing metrics: $e', 
              errorStackTrace: e.toString(), 
              errorSource: '_handleMessageEvent', 
              severityLevel: 'Critical', 
              requestPath: 'metrics');
          }
        }
        break;
        
      case MessageEventType.connected:
        isConnected = true;
        _onConnected();
        break;
        
      case MessageEventType.disconnected:
        isConnected = false;
        _messages.add(Message('Connection lost. Please refresh.', false));
        notifyListeners();
        _onDisconnected();
        break;
    }
  }

  void _onConnected() {
    if (drivingModel.isAgentMode) {
      addMessage(Message(
        'You\'re connected to AI assistant! Ready to tackle risks and strengthen controls together! 🚀 ',
        false,
      ));

      final aiAssistantModel = Provider.of<AIAssistantModel>(context, listen: false);
      aiAssistantModel.updateMetricsPartial(
        latencyMs: 0,
        isSynced: true,
        isGuardrailActivated: true,
        isExplainableAIEnabled: true,
        isConnected: true,
      );
    }
  }

  void _onDisconnected() {
    if (drivingModel.isAgentMode) {
      final aiAssistantModel = Provider.of<AIAssistantModel>(context, listen: false);
      aiAssistantModel.updateMetricsPartial(
        latencyMs: 0,
        isSynced: false,
        isGuardrailActivated: false,
        isExplainableAIEnabled: false,
        isConnected: false,
      );
    }
  }

  Future<void> sendMessage(String message, {FilePickerResult? filePickerResult}) async {
    if (message.trim().isEmpty || _isLoading) return;

    final projectModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    final userModel = Provider.of<UserDetailsModel>(context, listen: false);
    final aiAssistantModel = Provider.of<AIAssistantModel>(context, listen: false);

    final String sessionIdToUse = aiAssistantModel.getSelectedSessionId ?? _sessionId;
    final bool isUsingSelectedSession = aiAssistantModel.getSelectedSessionId != null;

    if (!_isSessionSaved && !isUsingSelectedSession) {
      await _saveSession(message);
      _isSessionSaved = true;
    }

    final String? userId = userModel.getUserMachineId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is not available. Please ensure the user is properly initialized.');
    }

    if (drivingModel.isAgentMode) {
      addMessage(Message(message, true));
      isLoading = true;
    }

    final metadata = {
      'session_id': sessionIdToUse,
      'project_id': projectModel.getActiveProjectId,
      'user_id': userId,
      'file_picker_result': filePickerResult,
      'send_history': aiAssistantModel.getSelectedSessionId!=null?true:false,
    };

    try {
      await _service?.sendMessage(message, metadata);
      if (!drivingModel.isAgentMode) {
        isLoading = false;
      }
    } catch (e) {
      isLoading = false;
      _messages.add(Message('Error: $e', false));
      notifyListeners();
    }
  }

  Future<void> _saveSession(String promptDescription) async {
    try {
      final aiAssistantModel = Provider.of<AIAssistantModel>(context, listen: false);
      int insertedId = await aiAssistantModel.saveSession(context, _sessionId, promptDescription);

      if(insertedId > 0) {
        // Add new session to the list and highlight it
        final newSession = AISession(
          sessionId: _sessionId,
          promptDescription: promptDescription,
          timestamp: DateTime.now(),
          differenceInDays: 0,
        );

        aiAssistantModel.addSession(newSession);
      }
      //aiAssistantModel.setSelectedSessionId(_sessionId);
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context, 
        'Error saving session: $e', 
        showUserMessage: false,
        logError: true, errorMessage: 'Error saving session: $e', 
        errorStackTrace: e.toString(), 
        errorSource: '_saveSession', 
        severityLevel: 'Critical', 
        requestPath: 'saveSession');
    }
  }

  void _disposeService() {
    _subscription?.cancel();
    _subscription = null;
    _service?.disconnect();
    _service = null;
    isConnected = false;
    if (drivingModel.isAgentMode) {
      clearMessages();
    }
  }

  @override
  void dispose() {
    _disposeService();
    super.dispose();
  }
}

