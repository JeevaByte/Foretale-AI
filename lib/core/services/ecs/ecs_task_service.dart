import 'dart:convert';

import 'package:foretale_application/config/config_ecs.dart';
import 'package:foretale_application/core/services/api/api_service.dart';

class ECSTaskService {
  Future<Map<String, dynamic>> invokeECSTask({
    required String url,
    required String clusterName,
    required String taskDefinition,
    required String containerName,
    required List<String> command,
  }) async {
    try {
      final payload = {
        'action': 'run_task',
        'command': command,
        'cluster_name': clusterName,
        'task_definition': taskDefinition,
        'container_name': containerName,
      };

      final response = await ApiService.post(
        url: url,
        payload: payload,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error invoking ECS task: $e');
    }
  }

  Future<Map<String, dynamic>> invokeCSVUploadTask({required Map<String, dynamic> csvUploadPayload}) async {
    // Validate required keys
    if (!csvUploadPayload.containsKey('file_upload_id')) {
      throw Exception('csvUploadPayload must contain "file_upload_id" key');
    }
    if (!csvUploadPayload.containsKey('user_id')) {
      throw Exception('csvUploadPayload must contain "user_id" key');
    }
    
    // Extract user_id and file_upload_id as separate command arguments
    final userId = csvUploadPayload['user_id'].toString();
    final fileUploadId = csvUploadPayload['file_upload_id'].toString();
    
    // Add the payload as command arguments - pass user_id and file_upload_id as separate arguments
    final command = [
      CsvUploadECS.pythonPath, 
      CsvUploadECS.appPath,
      fileUploadId,
      userId,
    ];
    
    return await invokeECSTask(
      url: CsvUploadECS.url,
      clusterName: CsvUploadECS.clusterName,
      taskDefinition: CsvUploadECS.taskDefinition,
      containerName: CsvUploadECS.containerName,
      command: command,
    );
  }

  Future<Map<String, dynamic>> invokeTestExecutionTask({required Map<String, dynamic> testExecutionPayload}) async {
    // Validate required keys
    if (!testExecutionPayload.containsKey('project_id')) {
      throw Exception('testExecutionPayload must contain "project_id" key');
    }
    if (!testExecutionPayload.containsKey('test_id')) {
      throw Exception('testExecutionPayload must contain "test_id" key');
    }

    if (!testExecutionPayload.containsKey('project_test_id')) {
      throw Exception('testExecutionPayload must contain "project_test_id" key');
    }
    if (!testExecutionPayload.containsKey('execution_id')) {
      throw Exception('testExecutionPayload must contain "execution_id" key');
    }
    if (!testExecutionPayload.containsKey('created_by')) {
      throw Exception('testExecutionPayload must contain "created_by" key');
    }
    if (!testExecutionPayload.containsKey('status')) {
      throw Exception('testExecutionPayload must contain "status" key');
    }
    if (!testExecutionPayload.containsKey('message')) {
      throw Exception('testExecutionPayload must contain "message" key');
    }

    // Extract project_id and test_id as separate command arguments
    final sprocName = 'sproc_execute_config_sql';
    final projectId = testExecutionPayload['project_id'].toString();
    final testId = testExecutionPayload['test_id'].toString();
    final projectTestId = testExecutionPayload['project_test_id'].toString();
    final executionId = testExecutionPayload['execution_id'].toString();
    final createdBy = testExecutionPayload['created_by'].toString();
    final status = testExecutionPayload['status'].toString();
    final message = testExecutionPayload['message'].toString();
    
    // Add the payload as command arguments - pass project_id and test_id as separate arguments
    final command = [
      TestExecutionECS.pythonPath, 
      TestExecutionECS.appPath,
      sprocName,
      jsonEncode({
        'project_id': projectId,
        'test_id': testId,
        'project_test_id': projectTestId,
        'execution_id': executionId,
        'created_by': createdBy,
        'status': status,
        'message': message,
      }),
    ];

    return await invokeECSTask(
      url: TestExecutionECS.url,
      clusterName: TestExecutionECS.clusterName,
      taskDefinition: TestExecutionECS.taskDefinition,
      containerName: TestExecutionECS.containerName,
      command: command,
    );
  }
}