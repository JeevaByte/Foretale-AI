import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/test_case/sql_query_dialog_widget.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/widgets/ai_box/business/agent/agent_service.dart';

class TestService {
  static const String _currentFileName = "test_service";

  // Test Selection Methods
  static Future<void> handleTestSelection(BuildContext context, dynamic test) async {
    int resultId;
    try {
      final testsModel = Provider.of<TestsModel>(context, listen: false);
      testsModel.updateTestIdSelection(test.testId);

      if (test.isSelected) {
        final colorScheme = Theme.of(context).colorScheme;
        final confirmed = await showConfirmDialog(
          context: context,
          title: 'Remove Test',
          content: 'Are you sure you want to remove this test? This action will reset the test configurations.',
          cancelText: 'Cancel',
          confirmText: 'Remove',
          confirmTextColor: colorScheme.primary,
        );
        resultId = confirmed ? await testsModel.removeTest(context, test) : -1;

      } else {
        resultId = await testsModel.selectTest(context, test);
      }

      if (resultId > 0) {
        testsModel.fetchTestsByProject(context);
      }
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context, 
        e.toString(),
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_handleTestSelection");
    }
  }

  // Public methods for SQL operations
  static Future<int> saveSqlQuery(BuildContext context, Test test, String code, String secondCode) async {
    try {
      final testsModel = Provider.of<TestsModel>(context, listen: false);
      const content = "The result of the query will replace the existing analysis. Would you like to continue with the execution?";
      //Show the confirmation dialog
      final confirmed = await showConfirmDialog(
        context: context,
        title: "Execute SQL Query",
        cancelText: "NO",
        confirmText: "YES",
        confirmTextColor: Colors.green,
        content: content,
      );

      int updatedId = 0;
      if (confirmed == true) {
        final firstQuery = _prepareQueryForSave(code);
        final secondQuery = _prepareQueryForSave(secondCode);

        testsModel.updateProjectTestConfidOffline(
          test, 
          firstQuery, 
          secondQuery
        );
        
        updatedId = await testsModel.updateProjectTestConfig(context, test);

        if(updatedId > 0){
          SnackbarMessage.showSuccessMessage(context, "SQL query saved successfully");
        }
      }
      
      return updatedId;
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context, 
        e.toString(),
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "saveSqlQuery");
    }
    return 0;
  }

  static Future<void> saveAndRunSqlQuery(BuildContext context, Test test, String code, String secondCode) async {
    final testsModel = Provider.of<TestsModel>(context, listen: false);
    try {
      testsModel.setIsSaveHappening = true;
      
      int updatedId = await saveSqlQuery(context, test, code, secondCode);

      if(updatedId > 0){
        try{
            int executionId = 0;
            String status = 'Running';
            String message = 'Test is running in the background.';
            
            executionId = await testsModel.insertTestExecutionLog(context, test, status, message); 

            if(executionId > 0){
              testsModel.executeTest(context, test, executionId, status, message);
              await testsModel.updateTestExecutionStatusOffline(context, test, status, message);
              SnackbarMessage.showSuccessMessage(context, "Test is running in the background.");
            } else{
              throw Exception("Unable to update the test execution log.");
            }
        } catch (e) {
          throw Exception(e);
        }
      }
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context, 
        "Unable to save and execute the test. Please try again later.",
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_saveAndRunSqlQuery");
    } finally {
      testsModel.setIsSaveHappening = false;
    }
  }

  static Future<void> onTestTap(BuildContext context, InquiryResponseModel inquiryResponseModel, TestsModel testsModel, Test test) async {
    try{
      if(test.testId == testsModel.getSelectedTestId){
        testsModel.updateTestIdSelection(0);
        return;
      }
      inquiryResponseModel.setIsPageLoading(true);
      testsModel.updateTestIdSelection(test.testId);
      await inquiryResponseModel.fetchResponsesByReference(context, test.testId, 'test');
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_onTestTap");
    } finally{
      inquiryResponseModel.setIsPageLoading(false);
    }
  }

  static Future<void> onTestTapShowResults(BuildContext context, InquiryResponseModel inquiryResponseModel, TestsModel testsModel, Test test) async {
    try{
      testsModel.updateTestIdSelection(test.testId);
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_onTestTapShowResults");
    }
  }

  static Future<void> onTestSelection(BuildContext context, Test test) async {
    try{
      await TestService.handleTestSelection(context, test);
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_onTestSelection");
    }
  }

  static Future<void> _sendMessageToAgent(BuildContext context, Test test) async {
    try {
      final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
      final userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
      
      final agentService = AgentService();
      await agentService.connect();
      
      // Wait a bit for connection to establish
      await Future.delayed(const Duration(milliseconds: 500));
      
      final message = "Summarize and update feedback and potential impact for test: ${test.testName} (ID: ${test.testId})";
      
      final metadata = {
        'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'project_id': projectDetailsModel.getActiveProjectId,
        'user_id': userDetailsModel.getUserMachineId,
      };
      
      await agentService.sendMessage(message, metadata);
    } catch (e) {
      // Silently handle errors - don't interrupt the user flow
      print('Error sending message to agent: $e');
    }
  }

  static Future<void> onMarkAsCompletedTap(BuildContext context, Test test, TestsModel testsModel) async {
    try{
      testsModel.updatedTestCompletionOffline(test, !test.markAsCompleted);

      await testsModel.updateTestCompletion(
        context, 
        test, 
        test.markAsCompleted
      ); 

      /*if(test.markAsCompleted){
        unawaited(_sendMessageToAgent(context, test));
        SnackbarMessage.showSuccessMessage(context, "Summarizing the feedback provided on findings.");
      }*/
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_onMarkAsCompletedTap");
    }
  }

  static Future<void> onViewConfigurationTap(BuildContext context, Test test, TestsModel testsModel) async {
    try{
      //Open the view configuration dialog
      if(test.testId == testsModel.getSelectedTestId){
        testsModel.updateTestIdSelection(0);
        return;
      }
      testsModel.updateTestIdSelection(test.testId);
      context.fadeNavigateTo(SqlQueryDialogWidget(test: test));
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_onViewConfigurationTap");
    }   
  }

  static Future<void> onDeleteTestTap(BuildContext context, Test test, TestsModel testsModel) async {
    try{
      if(await showConfirmDialog(
        context: context,
        title: "Delete Test",
        content: "This action will delete the test permanently. Are you sure you want to delete this test?",
        confirmText: "Delete",
        cancelText: "Cancel",
      )){
        int deletedId = await testsModel.deleteTest(context, test);
        if(deletedId > 0){
          SnackbarMessage.showSuccessMessage(context, "Test deleted permanently");
          testsModel.fetchTestsByProject(context);
        } else {
          throw Exception("Failed to delete test");
        }
      }
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_onDeleteTestTap");
    }
  }

  static String _prepareQueryForSave(String value) {
    final sanitized = value.replaceAll('\r\n', '\n');
    return sanitized.trim().isEmpty ? '' : sanitized;
  }
}