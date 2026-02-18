//core
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/ecs/ecs_task_service.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/config/config_s3.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
//utils
import 'package:foretale_application/core/services/database/handling_crud.dart';

class Test {
  int testId;
  String testName;
  String testDescription;
  String topicName;
  String subtopicName;
  String testCriticality;
  String testRunType;
  String testCategory;
  String config;
  bool isSelected;
  String relevantSchemaName;
  String testConfigGenerationStatus;
  String testConfigExecutionStatus;
  String testCode;
  int projectTestId;
  String selectClause;
  String technicalDescription;
  String analysisTableName;
  bool markAsCompleted;
  String testRunProgram;
  String aiFormattedSqlQuery;
  String module;
  String testConfigExecutionMessage;
  String testConfigGenerationMessage;
  String impactStatement;
  String configImpactStatement;
  String feedbackSummary;
  bool showDescription;
  bool showImpact;
  String testConfigImpactGenerationStatus;
  String testConfigImpactGenerationMessage;
  int flaggedTransactionsCount;
  String configImpactStatementResultJson;
  String? lastRunCount;
  String aiImpactFormattedSqlQuery;
  String configImpactStatementResultSummary;
  String identifiedRisks;
  String identifiedRecommendations;
  String riskTopicCodes;
  String riskRecommendationCodes;
  int parentProjectId;
  bool isProjectCreatedTest;

  Test({
    this.testId = 0,
    this.testName = '',
    this.testDescription = '',
    this.topicName = '',
    this.subtopicName = '',
    this.testCriticality = '',
    this.testRunType = '',
    this.testCategory = '',
    this.config = '',
    this.isSelected = false,
    this.relevantSchemaName = '',
    this.testConfigGenerationStatus = '',
    this.testConfigExecutionStatus = '',
    this.testCode = '',
    this.projectTestId = 0,
    this.selectClause = '',
    this.technicalDescription = '',
    this.analysisTableName = '',
    this.markAsCompleted = false,
    this.testRunProgram = '',
    this.aiFormattedSqlQuery = '',
    this.module = '',
    this.testConfigExecutionMessage = '',
    this.testConfigGenerationMessage = '',
    this.impactStatement = '',
    this.configImpactStatement = '',
    this.feedbackSummary = '',
    this.showDescription = true,
    this.showImpact = true,
    this.testConfigImpactGenerationStatus = '',
    this.testConfigImpactGenerationMessage = '',
    this.flaggedTransactionsCount = 0,
    this.configImpactStatementResultJson = '',
    this.lastRunCount,
    this.aiImpactFormattedSqlQuery = '',
    this.configImpactStatementResultSummary = '',
    this.identifiedRisks = '',
    this.identifiedRecommendations = '',
    this.riskTopicCodes = '',
    this.riskRecommendationCodes = '',
    this.parentProjectId = 0,
    this.isProjectCreatedTest = false,
  });

  factory Test.fromJson(Map<String, dynamic> map) {
 
    return Test(
      testId: map['test_id'] ?? 0,
      testName: map['test_name'] ?? '',
      testDescription: map['test_description'] ?? '',
      topicName: map['topic_name'] ?? '',
      subtopicName: map['sub_topic_name'] ?? '',
      testCriticality: map['test_criticality'] ?? '',
      testRunType: map['test_run_type'] ?? '',
      testCategory: map['test_category'] ?? '',
      config: map['config'] ?? '',
      isSelected: bool.tryParse(map['is_selected']) ?? false,
      relevantSchemaName: map['relevant_schema_name'] ?? '',
      testConfigGenerationStatus: map['config_generation_status'] ?? '',
      testConfigExecutionStatus: map['config_execution_status'] ?? '',
      testCode: map['test_code'] ?? '',
      projectTestId: map['project_test_id'] ?? 0,
      selectClause: map['select_clause'] ?? '',
      technicalDescription: map['technical_description'] ?? '',
      analysisTableName: map['analysis_table_name'] ?? '',
      markAsCompleted: bool.tryParse(map['mark_as_completed']) ?? false,
      testRunProgram: map['run_program'] ?? '',
      module: map['module'] ?? '',
      testConfigExecutionMessage: map['config_execution_message'] ?? '',
      testConfigGenerationMessage: map['config_generation_message'] ?? '',
      impactStatement: map['impact_statement'] ?? '',
      configImpactStatement: map['config_impact_statement'] ?? '',
      feedbackSummary: map['feedback_summary'] ?? '',
      testConfigImpactGenerationStatus: map['config_impact_generation_status'] ?? '',
      testConfigImpactGenerationMessage: map['config_impact_generation_message'] ?? '',
      flaggedTransactionsCount: map['flagged_transactions_count'] ?? 0,
      configImpactStatementResultJson: map['config_impact_statement_result'] ?? '',
      lastRunCount: map['last_run_count'],
      configImpactStatementResultSummary: map['config_impact_statement_result_summary'] ?? '',
      identifiedRisks: map['identified_risks'] ?? '',
      identifiedRecommendations: map['identified_recommendations'] ?? '',
      riskTopicCodes: map['risk_topic_codes'] ?? '',
      riskRecommendationCodes: map['risk_recommendation_codes'] ?? '',
      parentProjectId: map['parent_project_id'] ?? 0,
      isProjectCreatedTest: bool.tryParse(map['is_project_created_test'].toString()) ?? false,
    );
  }
}

class TestExecutionStatus {
  int testExecutionLogId;
  int projectId;
  int testId;
  int projectTestId;
  String status;
  String message;

  TestExecutionStatus({
    this.testExecutionLogId = 0,
    this.projectId = 0,
    this.testId = 0,
    this.projectTestId = 0,
    this.status = '',
    this.message = '',
  });

  factory TestExecutionStatus.fromJson(Map<String, dynamic> map) {
    return TestExecutionStatus(
      testExecutionLogId: map['execution_id'] ?? 0,
      projectId: map['project_id'] ?? 0,
      testId: map['test_id'] ?? 0,
      projectTestId: map['project_test_id'] ?? 0,
      status: map['config_execution_status'] ?? '',
      message: map['config_execution_message'] ?? '',
    );
  }
}

class TestsModel with ChangeNotifier implements ChatDrivingModel {
  final CRUD _crudService = CRUD();
  

  
  List<Test> testsList = [];
  List<Test> get getTestsList => testsList;

  List<Test> get getRunningTests => testsList.where((test) => test.testConfigExecutionStatus == 'Running').toList();
  int get getRunningTestsCount => getRunningTests.length;

  List<Test> filteredTestsList = [];
  List<Test> get getFilteredTestList => filteredTestsList;

  int _selectedTestId = 0;
  int get getSelectedTestId => _selectedTestId;

  Test get getSelectedTest {
    return testsList.firstWhere(
      (test) => test.testId == _selectedTestId
      , orElse: () => Test()
    );
  }

  bool _isPageLoading = false;
  bool get getIsPageLoading => _isPageLoading;
  set setIsPageLoading(bool value) {
    _isPageLoading = value;
    notifyListeners();
  }

  bool _isSaveHappening = false;
  bool get getIsSaveHappening => _isSaveHappening;
  set setIsSaveHappening(bool value) {
    _isSaveHappening = value;
    notifyListeners();
  }

  int findTestIndex(int testId) {
    return testsList.indexWhere((test) => test.testId == testId);
  }

  void updateTestIdSelection(int testId, {bool notify = true}) async {
    _selectedTestId = testId;
    if (notify) {
      notifyListeners();
    }
  }

  void _updateTestSelection(int testId, bool isSelected) {
    var index = findTestIndex(testId);
    if (index != -1) {
      testsList[index].isSelected = isSelected;
    }
    notifyListeners();
  }

  Future<void> filterData(String query) async {
    String lowerCaseQuery = query.trim().toLowerCase();

    if (query.isEmpty) {
      filteredTestsList = List.from(testsList);
    } else {
      filteredTestsList = testsList.where((test) {
        return test.testName.toLowerCase().contains(lowerCaseQuery) ||
            test.testDescription.toLowerCase().contains(lowerCaseQuery) ||
            test.testCategory.toLowerCase().contains(lowerCaseQuery) ||
            test.testRunType.toLowerCase().contains(lowerCaseQuery) ||
            test.testCriticality.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchTestsByProject(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'project_type_id': projectDetailsModel.getProjectTypeId,
      'industry_id': projectDetailsModel.getIndustryId,
    };

    testsList = await _crudService.getRecords<Test>(
      context,
      'dbo.sproc_get_tests_by_project',
      params,
      (json) => Test.fromJson(json),
    );

    filteredTestsList = testsList;
    notifyListeners();
  }

  Future<void> updateTestConfigGenerationStatus(int testId, String testConfigGenerationStatus) async {
    var index = findTestIndex(testId);
    if (index != -1) {
      testsList[index].testConfigGenerationStatus = testConfigGenerationStatus;
    }
    notifyListeners();
  }

  Future<void> updateTestExecutionStatusOffline(BuildContext context, Test test, String status, String message) async {
    var index = findTestIndex(test.testId);

    if (index != -1) {
      test.testConfigExecutionStatus = status;
      test.testConfigExecutionMessage = message;

      testsList[index].testConfigExecutionStatus = status;
      testsList[index].testConfigExecutionMessage = message;
    }
    notifyListeners();
  }

  Future<int> insertTestExecutionLog(BuildContext context, Test test, String status, String message) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'is_ai_execution': false,
      'session_id': null,
      'created_by': userDetailsModel.getUserMachineId,
    };

    int updatedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_update_test_execution_log',
      params,
    );

    return updatedId;
  }

  Future<void> executeTest(BuildContext context,Test test, int executionId, String status, String message) async {
    if (!context.mounted) {
      return;
    }

    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'project_test_id': test.projectTestId,
      'execution_id': executionId,
      'created_by': userDetailsModel.getUserMachineId,
      'status': status,
      'message': message,
    };
    unawaited(ECSTaskService().invokeTestExecutionTask(testExecutionPayload: params));
  }

  Future<int> selectTest(BuildContext context, Test test) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'config': test.config,
      'created_by': userDetailsModel.getUserMachineId,
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_test_project',
      params,
    );

    if (insertedId > 0) {
      _updateTestSelection(test.testId, true);
    }

    return insertedId;
  }

  Future<int> removeTest(BuildContext context, Test test) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    int deletedId = await _crudService.deleteRecord(
      context,
      'dbo.sproc_delete_assigned_test',
      params,
    );

    if (deletedId > 0) {
      _updateTestSelection(test.testId, false);
    }

    return deletedId;
  }

  Future<int> deleteTest(BuildContext context, Test test) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    int deletedId = await _crudService.deleteRecord(
      context,
      'dbo.sproc_delete_test',
      params,
    );

    if (deletedId > 0) {
      _updateTestSelection(test.testId, false);
    }

    return deletedId;
  }

  void updateProjectTestConfidOffline(Test test, String firstCode, String secondCode) {
    var index = findTestIndex(test.testId);
    test.config = firstCode;
    test.configImpactStatement = secondCode;
    if (index != -1) {
      testsList[index].config = firstCode;
      testsList[index].configImpactStatement = secondCode;
    }
    notifyListeners();
  }

  Future<int> updateProjectTestConfig(BuildContext context, Test test) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'config': test.config,
      'config_impact_statement': test.configImpactStatement,
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

    int updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_update_test_configs',
      params,
    );

    return updatedId;
  }

  void updatedTestCompletionOffline(Test test, bool status) {
    var index = findTestIndex(test.testId);
    if (index != -1) {
      testsList[index].markAsCompleted = status;
    }
    notifyListeners();
  }

  Future<int> updateTestCompletion(BuildContext context, Test test, bool status) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'status': status,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    int updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_update_mark_test_completion_status',
      params,
    );

    return updatedId;
  }

  void toggleTestDescription(int testId) {
    var index = findTestIndex(testId);
    if (index != -1) {
      testsList[index].showDescription = !testsList[index].showDescription;
      testsList[index].showImpact = !testsList[index].showImpact;
      notifyListeners();
    }
  }

  List<Test> fetchReportableTests(BuildContext context) {
    return testsList
      .where((test) => test.isSelected && test.markAsCompleted)
      .toList();
  }

  Future<void> fetchTestExecutionStatus(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    String commaSeparatedRunningTestIds = 
      testsList
      .where((test) => test.testConfigExecutionStatus == 'Running')
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

    for (var executionStatus in executionStatusList) {
      var index = findTestIndex(executionStatus.testId);
      if (index != -1) {
        testsList[index].testConfigExecutionStatus = executionStatus.status;
        testsList[index].testConfigExecutionMessage = executionStatus.message;
      }
    }

    notifyListeners();
  }

  Future<void> updateFeedbackSummary(BuildContext context, Test test, String feedbackSummary) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var index = findTestIndex(test.testId);
    if (index != -1) {
      testsList[index].feedbackSummary = feedbackSummary;
    }

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'feedback_summary': feedbackSummary,
    };

    await _crudService.updateRecord(
      context,
      'dbo.sproc_update_feedback_summary',
      params,
    );

    notifyListeners();
  }

  @override
  int get selectedId => getSelectedTestId;

  @override
  int getActiveProjectId(BuildContext context) {
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    return projectDetailsModel.getActiveProjectId;
  }

  @override
  Future<void> fetchResponses(BuildContext context) {
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    return inquiryResponseModel.fetchResponsesByReference(
      context,
      getSelectedTestId,
      getDrivingModelName(context),
    );
  }

  @override
  Future<int> insertResponse(BuildContext context, String responseText) {
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    return inquiryResponseModel.insertResponseByReference(
      context,
      getSelectedTestId,
      getDrivingModelName(context),
      responseText,
      getSelectedTestId,
    );
  } 

  @override
  String buildStoragePath({required String projectId, required String responseId}) {
    return '${S3Config.baseResponseTestAttachmentPath}$projectId/$selectedId/$responseId';
  }

  @override
  String getStoragePath(BuildContext context, int responseId) {
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    return buildStoragePath(projectId: projectDetailsModel.getActiveProjectId.toString(), responseId: responseId.toString());
  }

  @override
  int getSelectedId(BuildContext context) => selectedId;

  @override
  String getDrivingModelName(BuildContext context) => 'test';

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