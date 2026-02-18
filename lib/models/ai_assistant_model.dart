//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/models/ai_session_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
//utils
import 'package:foretale_application/core/services/database/handling_crud.dart';
import 'package:foretale_application/config/config_s3.dart';

class AIAssistantMetrics with ChangeNotifier {
  int latencyMs;
  bool isSynced;
  bool isGuardrailActivated;
  bool isExplainableAIEnabled;
  bool isConnected;
  Duration pollingInterval;
  DateTime lastSyncTime;
  int totalMessages;
  int totalTokensUsed;

  AIAssistantMetrics({
    this.latencyMs = 0,
    this.isSynced = false,
    this.isGuardrailActivated = false,
    this.isExplainableAIEnabled = false,
    this.isConnected = false,
    this.pollingInterval = const Duration(seconds: 5),
    DateTime? lastSyncTime,
    this.totalMessages = 0,
    this.totalTokensUsed = 0,
  }) : lastSyncTime = lastSyncTime ?? DateTime.now();

  factory AIAssistantMetrics.fromJson(Map<String, dynamic> map) {
    return AIAssistantMetrics(
      latencyMs: map['latency_ms'] ?? 0,
      isSynced: map['is_synced'] ?? false,
      isGuardrailActivated: map['is_guardrail_activated'] ?? false,
      isExplainableAIEnabled: map['is_explainable_ai_enabled'] ?? false,
      isConnected: map['is_connected'] ?? false,
      pollingInterval: Duration(seconds: map['polling_interval_seconds'] ?? 5),
      lastSyncTime: map['last_sync_time'] != null 
          ? DateTime.parse(map['last_sync_time']) 
          : DateTime.now(),
      totalMessages: map['total_messages'] ?? 0,
      totalTokensUsed: map['total_tokens_used'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latency_ms': latencyMs,
      'is_synced': isSynced,
      'is_guardrail_activated': isGuardrailActivated,
      'is_explainable_ai_enabled': isExplainableAIEnabled,
      'is_connected': isConnected,
      'polling_interval_seconds': pollingInterval.inSeconds,
      'last_sync_time': lastSyncTime.toIso8601String(),
      'total_messages': totalMessages,
      'total_tokens_used': totalTokensUsed,
    };
  }
}

class AIAssistantModel with ChangeNotifier implements ChatDrivingModel {
  AIAssistantMetrics _metrics = AIAssistantMetrics();
  AIAssistantMetrics get metrics => _metrics;
  List<AISession> _sessions = [];
  List<AISession> get getSessions => _sessions;
  final CRUD _crudService = CRUD();
  
  // Running tests logic (copied from TestsModel)
  List<Test> _runningTests = [];
  List<Test> get getRunningTests => _runningTests;
  int get getRunningTestsCount => _runningTests.length;
  
  List<Test> _allTests = [];
  List<Test> get getAllTests => _allTests;
  
  int get getActiveControlsCount => _allTests.where((test) => test.isSelected).length;
  int get getTotalControlsCount {
    final activeControls = getActiveControlsCount;
    return activeControls > 0 ? activeControls : _allTests.length;
  }
  
  double get getExecutionProgress {
    final totalControls = getTotalControlsCount;
    return totalControls == 0 ? 0.0 : (getRunningTestsCount / totalControls).clamp(0.0, 1.0);
  }

  bool _isPageLoading = false;
  bool get getIsPageLoading => _isPageLoading;
  set setIsPageLoading(bool value) {
    _isPageLoading = value;
    notifyListeners();
  }

  bool _isPolling = false;
  bool get getIsPolling => _isPolling;
  set setIsPolling(bool value) {
    if (_isPolling != value) {
      _isPolling = value;
      notifyListeners();
    }
  }
  
  // Method to set polling state without notifying (for use during disposal)
  void setIsPollingSilent(bool value) {
    _isPolling = value;
  }

  String? _selectedSessionId;
  String? get getSelectedSessionId => _selectedSessionId;
  void setSelectedSessionId(String? sessionId) {
    _selectedSessionId = sessionId;
    notifyListeners();
  }

  // Getters for individual metrics
  int get getLatencyMs => _metrics.latencyMs;
  String get getLatencyDisplay => '${_metrics.latencyMs} ms';
  
  bool get getIsSynced => _metrics.isSynced;
  bool get getIsGuardrailActivated => _metrics.isGuardrailActivated;
  bool get getIsExplainableAIEnabled => _metrics.isExplainableAIEnabled;
  bool get getIsConnected => _metrics.isConnected;
  
  Duration get getPollingInterval => _metrics.pollingInterval;
  DateTime get getLastSyncTime => _metrics.lastSyncTime;
  
  int get getTotalMessages => _metrics.totalMessages;
  int get getTotalTokensUsed => _metrics.totalTokensUsed;

  // Setters for individual metrics
  void setLatencyMs(int value) {
    _metrics.latencyMs = value;
    notifyListeners();
  }

  void setPollingInterval(Duration value) {
    _metrics.pollingInterval = value;
    notifyListeners();
  }

  // Update specific metric fields
  void updateMetricsPartial({
    int? latencyMs,
    bool? isSynced,
    bool? isGuardrailActivated,
    bool? isExplainableAIEnabled,
    bool? isConnected,
    Duration? pollingInterval,
    int? totalMessages,
    int? totalTokensUsed,
  }) {
    if (latencyMs != null) _metrics.latencyMs = latencyMs;
    if (isSynced != null) {
      _metrics.isSynced = isSynced;
      if (isSynced) {
        _metrics.lastSyncTime = DateTime.now();
      }
    }
    if (isGuardrailActivated != null) {
      _metrics.isGuardrailActivated = isGuardrailActivated;
    }
    if (isExplainableAIEnabled != null) {
      _metrics.isExplainableAIEnabled = isExplainableAIEnabled;
    }
    if (isConnected != null) _metrics.isConnected = isConnected;
    if (pollingInterval != null) _metrics.pollingInterval = pollingInterval;
    if (totalMessages != null) _metrics.totalMessages = totalMessages;
    if (totalTokensUsed != null) _metrics.totalTokensUsed = totalTokensUsed;
    notifyListeners();
  }

  // Reset metrics to default values
  void resetMetrics() {
    _metrics = AIAssistantMetrics();
    notifyListeners();
  }

  // Update token usage
  void updateTokenUsage(int tokensUsed) {
    _metrics.totalTokensUsed = tokensUsed;
    notifyListeners();
  }

  // Fetch tests by project (copied from TestsModel)
  Future<void> fetchTestsByProject(BuildContext context) async {
    try {
      if (!context.mounted) return;
    } catch (e) {
      // Widget has been disposed, context is no longer valid
      return;
    }
    
    try {
      var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

      final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'project_type_id': projectDetailsModel.getProjectTypeId,
        'industry_id': projectDetailsModel.getIndustryId,
      };

      _allTests = await _crudService.getRecords<Test>(
        context,
        'dbo.sproc_get_tests_by_project',
        params,
        (json) => Test.fromJson(json),
      );

      try {
        if (!context.mounted) return;
      } catch (e) {
        // Widget has been disposed, context is no longer valid
        return;
      }
      
      _runningTests = _allTests.where((test) => test.testConfigExecutionStatus == 'Running').toList();
      notifyListeners();
    } catch (e) {
      // If context becomes invalid during the operation, just return
      // The error will be handled by the calling code if needed
      return;
    }
  }

  // Fetch test execution status (copied from TestsModel)
  Future<void> fetchTestExecutionStatus(BuildContext context) async {
    try {
      if (!context.mounted) return;
    } catch (e) {
      // Widget has been disposed, context is no longer valid
      return;
    }
    
    try {
      var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

      String commaSeparatedRunningTestIds = 
        _runningTests
        .map((test) => test.testId.toString())
        .join(',');

      if(commaSeparatedRunningTestIds.isEmpty){
        return;
      }
      
      final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id_list': commaSeparatedRunningTestIds,
      };

      List<TestExecutionStatus> executionStatusList = await _crudService.getRecords<TestExecutionStatus>(
        context,
        'dbo.sproc_get_test_status_by_project',
        params,
        (json) => TestExecutionStatus.fromJson(json),
      );

      try {
        if (!context.mounted) return;
      } catch (e) {
        // Widget has been disposed, context is no longer valid
        return;
      }

      for (var executionStatus in executionStatusList) {
        var index = _allTests.indexWhere((test) => test.testId == executionStatus.testId);
        if (index != -1) {
          _allTests[index].testConfigExecutionStatus = executionStatus.status;
          _allTests[index].testConfigExecutionMessage = executionStatus.message;
        }
      }

      // Update running tests list after status update
      _runningTests = _allTests.where((test) => test.testConfigExecutionStatus == 'Running').toList();
      notifyListeners();
    } catch (e) {
      // If context becomes invalid during the operation, just return
      // The error will be handled by the calling code if needed
      return;
    }
  }

  /// Save a new AI assistant session
  Future<int> saveSession(BuildContext context, String sessionId, String firstPromptDescription) async {
    try {
      if (!context.mounted) return 0;
    } catch (e) {
      // Widget has been disposed, context is no longer valid
      return 0;
    }
    
    try {
      var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
      var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

      final params = {
        'unique_session_id': sessionId,
        'project_id': projectDetailsModel.getActiveProjectId,
        'prompt_description': firstPromptDescription,
        'created_by': userDetailsModel.getUserMachineId,
      };

      int insertedId = await _crudService.addRecord(
        context,
        'dbo.sproc_agent_insert_session',
        params,
      );

      return insertedId;
    } catch (e) {
      // If context becomes invalid during the operation, just return 0
      return 0;
    }
  }

  /// Get all sessions for the current project
  Future<void> fetchSessions(BuildContext context) async {
    try {
      if (!context.mounted) return;
    } catch (e) {
      // Widget has been disposed, context is no longer valid
      return;
    }
    
    try {
      var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
      var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

      final params = {
        'session_user_id': userDetailsModel.getUserMachineId,
        'project_id': projectDetailsModel.getActiveProjectId,
      };

      _sessions = await _crudService.getRecords<AISession>(
        context,
        'dbo.sproc_agent_get_sessions',
        params,
        (json) => AISession.fromJson(json),
      );

      try {
        if (!context.mounted) return;
      } catch (e) {
        // Widget has been disposed, context is no longer valid
        return;
      }
      
      notifyListeners();
    } catch (e) {
      // If context becomes invalid during the operation, just return
      // The error will be handled by the calling code if needed
      return;
    }
  }

  /// Add a new session to the list
  void addSession(AISession session) {
    _sessions.add(session);
    notifyListeners();
  }

  @override
  int get selectedId => 0;

  @override
  int getActiveProjectId(BuildContext context) {
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    return projectDetailsModel.getActiveProjectId;
  }

  @override
  Future<void> fetchResponses(BuildContext context) async {
    try {
      if (!context.mounted) return;
    } catch (e) {
      // Widget has been disposed, context is no longer valid
      return;
    }
    
    try {
      var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
      return inquiryResponseModel.fetchResponsesByReference(
        context,
        getActiveProjectId(context),
        getDrivingModelName(context),
      );
    } catch (e) {
      // If context becomes invalid during the operation, just return
      return;
    }
  }

  @override
  Future<int> insertResponse(BuildContext context, String responseText) async {
    try {
      if (!context.mounted) return 0;
    } catch (e) {
      // Widget has been disposed, context is no longer valid
      return 0;
    }
    
    try {
      var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
      return inquiryResponseModel.insertResponseByReference(
        context,
        getActiveProjectId(context),
        getDrivingModelName(context),
        responseText,
        0,
      );
    } catch (e) {
      // If context becomes invalid during the operation, just return 0
      return 0;
    }
  }

  @override
  String buildStoragePath({required String projectId, required String responseId}) {
    return '${S3Config.baseResponseQuestionAttachmentPath}$projectId/$responseId';
  }

  @override
  String getStoragePath(BuildContext context, int responseId) {
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    return buildStoragePath(projectId: projectDetailsModel.getActiveProjectId.toString(), responseId: responseId.toString());
  }

  @override
  int getSelectedId(BuildContext context) => getActiveProjectId(context);

  @override
  String getDrivingModelName(BuildContext context) => 'assistant';

  String _mode = 'agent';

  @override
  String get mode => _mode;

  @override
  set mode(String value) {
    _mode = value;
    notifyListeners();
  }

  @override
  bool get isAgentMode => _mode == 'agent';

  @override
  bool get enableAgentMode => true;

}

