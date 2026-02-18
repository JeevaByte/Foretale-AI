import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database/handling_crud.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:provider/provider.dart';

class ExecutionStats {
  final int projectId;
  final int totalTests;
  final int executedTests;
  final int pendingTests;
  final int reviewCompleted;
  final int reviewPending;
  final int withObservations;
  final int withoutObservations;
  final int acceptedFindings;
  final int otherFindings;

  ExecutionStats({
    this.projectId = 0,
    this.totalTests = 0,
    this.executedTests = 0,
    this.pendingTests = 0,
    this.reviewCompleted = 0,
    this.reviewPending = 0,
    this.withObservations = 0,
    this.withoutObservations = 0,
    this.acceptedFindings = 0,
    this.otherFindings = 0,
  });

  factory ExecutionStats.fromJson(Map<String, dynamic> json) {
    return ExecutionStats(
      projectId: json['project_id'] ?? 0,
      totalTests: json['total_tests_selected'] ?? 0,
      executedTests: json['tests_executed'] ?? 0,
      pendingTests: json['tests_pending'] ?? 0,
      reviewCompleted: json['tests_reviewed'] ?? 0,
      reviewPending: json['tests_pending_review'] ?? 0,
      withObservations: json['tests_with_observations'] ?? 0,
      withoutObservations: json['tests_without_observations'] ?? 0,
      acceptedFindings: json['tests_with_accepted_findings'] ?? 0,
      otherFindings: json['tests_with_other_findings'] ?? 0,
    );
  }
}

class TestResultSummary {
  final int projectId;
  final int testId;
  final String testName;
  final String testCode;
  final String testDescription;
  final String testStatus;
  final int totalFindings;
  final int acceptedFindings;
  final int otherFindings;
  final int peopleError;
  final int processError;
  final int systemError;
  final int dataError;

  TestResultSummary({
    this.projectId = 0,
    this.testId = 0,
    this.testName = '',
    this.testCode = '',
    this.testDescription = '',
    this.testStatus = '',
    this.totalFindings = 0,
    this.acceptedFindings = 0,
    this.otherFindings = 0,
    this.peopleError = 0,
    this.processError = 0,
    this.systemError = 0,
    this.dataError = 0,
  });

  factory TestResultSummary.fromJson(Map<String, dynamic> json) {

    return TestResultSummary(
      projectId: json['project_id'] ?? 0,
      testId: json['test_id'] ?? 0,
      testName: json['test_name'] ?? '',
      testCode: json['test_code'] ?? '',
      testDescription: json['test_description'] ?? '',
      testStatus: json['test_status'] ?? '',
      totalFindings: json['total_findings'] ?? 0,
      acceptedFindings: json['accepted_findings'] ?? 0,
      otherFindings: json['other_findings'] ?? 0,
      peopleError: json['people_error'] ?? 0,
      processError: json['process_error'] ?? 0,
      systemError: json['system_error'] ?? 0,
      dataError: json['data_error'] ?? 0,
    );
  }

}

class RiskTopic{
  final String code;
  final String broadCategory;
  final String category;
  final String riskTopic;
  final String reason;
  final int testId;
  final String testName;
  final String testCriticality;
  final String testCode;

  RiskTopic({
    this.code = '',
    this.broadCategory = '',
    this.category = '',
    this.riskTopic = '',
    this.reason = '',
    this.testId = 0,
    this.testName = '',
    this.testCriticality = '',
    this.testCode = '',
  });

  factory RiskTopic.fromJson(Map<String, dynamic> json) {
    return RiskTopic(
      code: json['code'] ?? '',
      broadCategory: json['broad_category'] ?? '',
      category: json['category'] ?? '',
      riskTopic: json['risk_topic'] ?? '',
      reason: json['reason'] ?? '',
      testId: json['test_id'] ?? 0,
      testName: json['test_name'] ?? '',
      testCriticality: json['criticality'] ?? '',
      testCode: json['test_code'] ?? '',
    );
  }
}

class RiskRecommendation{
  final String code;
  final String broadCategory;
  final String category;
  final String recommendation;
  final String reason;
  final int testId;
  final String testName;
  final String testCriticality;
  final String testCode;

  RiskRecommendation({
    this.code = '',
    this.broadCategory = '',
    this.category = '',
    this.recommendation = '',
    this.reason = '',
    this.testId = 0,
    this.testName = '',
    this.testCriticality = '',
    this.testCode = '',
  });

  factory RiskRecommendation.fromJson(Map<String, dynamic> json) {
    return RiskRecommendation(
      code: json['code'] ?? '',
      broadCategory: json['broad_category'] ?? '',
      category: json['category'] ?? '',
      recommendation: json['recommendation'] ?? '',
      reason: json['reason'] ?? '',
      testId: json['test_id'] ?? 0,
      testName: json['test_name'] ?? '',
      testCriticality: json['criticality'] ?? '',
      testCode: json['test_code'] ?? '',
    );
  }
}

class ExecutionStatsModel with ChangeNotifier  {
  final CRUD _crudService = CRUD();

  ExecutionStats executionStats = ExecutionStats();
  List<ExecutionStats> executionStatsList = [];
  List<TestResultSummary> testResultSummaryList = [];

  List<RiskTopic> riskTopicList = [];
  List<RiskRecommendation> riskRecommendationList = [];

  bool isPageLoading = false;
  bool get getIsPageLoading => isPageLoading;
  set setIsPageLoading(bool value) {
    isPageLoading = value;
    notifyListeners();
  }

  //Get execution stats at project level
  Future<void> getExecutionStats(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
    };

    final result = await _crudService.getRecords<ExecutionStats>(
      context,
      'dbo.sproc_get_report_execution_statistics',
      params,
      (json) => ExecutionStats.fromJson(json),
    );

    if (result.isNotEmpty) {
      executionStats = result.first;
      notifyListeners();
    }
  }

  //Get execution stats for all projects (landing page)
  Future<Map<int, ExecutionStats>> getLandingExecutionStats(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    final params = {
      'user_machine_id': userDetailsModel.getUserMachineId,
    };

    final result = await _crudService.getRecords<ExecutionStats>(
      context,
      'dbo.sproc_get_landing_execution_statistics',
      params,
      (json) => ExecutionStats.fromJson(json),
    );

    // Convert list to map keyed by projectId
    final Map<int, ExecutionStats> executionStatsMap = {};
    for (var stats in result) {
      if (stats.projectId > 0) {
        executionStatsMap[stats.projectId] = stats;
      }
    }

    notifyListeners();
    return executionStatsMap;
  }

  //Get test result summary
  Future<void> getTestResultSummary(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
    };

    final result = await _crudService.getRecords<TestResultSummary>(
      context,
      'dbo.sproc_get_report_test_summary',
      params,
      (json) => TestResultSummary.fromJson(json),
    );

    if (result.isNotEmpty) {
      testResultSummaryList = result;
      notifyListeners();
    }
  }

  //Get risk topic
  Future<void> getRiskTopic(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
    };

    final result = await _crudService.getRecords<RiskTopic>(
      context,
      'dbo.sproc_get_risk_topics_by_project',
      params,
      (json) => RiskTopic.fromJson(json),
    );

    if (result.isNotEmpty) {
      riskTopicList = result;
      notifyListeners();
    }
  }

  //Get risk recommendation
  Future<void> getRiskRecommendation(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
    };

    final result = await _crudService.getRecords<RiskRecommendation>(
      context,
      'dbo.sproc_get_risk_recommendations_by_project',
      params,
      (json) => RiskRecommendation.fromJson(json),
    );
    
    if (result.isNotEmpty) {
      riskRecommendationList = result;
      notifyListeners();
    }
  }
}