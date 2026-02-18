import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database/database_connect.dart';
import 'package:foretale_application/core/utils/message_helper.dart';

class CRUD {
  Future<int> addRecord(BuildContext context, String storedProcedure,
      Map<String, dynamic> params) async {
    try {
      var jsonResponse = await DatabaseApiService().insertRecord(storedProcedure, params);
      int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());

      return insertedId;
    } catch (e, errorStackTrace) {
      _handleError(context, e, errorStackTrace, storedProcedure, 'insertRecord', params);
      return 0;
    }
  }

  Future<int> updateRecord(BuildContext context, String storedProcedure, Map<String, dynamic> params) async {
    try {
      var jsonResponse = await DatabaseApiService().updateRecord(storedProcedure, params);
      int updatedId = int.parse(jsonResponse['data'][0]['updated_id'].toString());

      return updatedId;
    } catch (e, errorStackTrace) {
      _handleError(context, e, errorStackTrace, storedProcedure, 'updateRecord', params);
      return 0;
    }
  }

  Future<int> deleteRecord(BuildContext context, String storedProcedure,
      Map<String, dynamic> params) async {
    try {
      var jsonResponse = await DatabaseApiService().deleteRecord(storedProcedure, params);
      int deletedId = int.parse(jsonResponse['data'][0]['deleted_id'].toString());
      return deletedId;
    } catch (e, errorStackTrace) {
      _handleError(context, e, errorStackTrace, storedProcedure, 'deleteRecord', params);
      return 0;
    }
  }

  Future<List<T>> getRecords<T>(
      BuildContext context,
      String storedProcedure,
      Map<String, dynamic> params,
      T Function(Map<String, dynamic>) fromJson) async {
    try {
      var jsonResponse = await DatabaseApiService().readRecord(storedProcedure, params);

      if (jsonResponse != null && jsonResponse['data'] != null) {
        var data = jsonResponse['data'];

        if (data is! List) {
          return [];
        }

        return data
            .map<T?>((json) {
              try {
                return fromJson(json)!;
              } catch (e) {
                return null;
              }
            })
            .whereType<T>()
            .toList();
      } else {
        return [];
      }
    } catch (e, errorStackTrace) {
      _handleError(context, e, errorStackTrace, storedProcedure, 'readRecord', params);
      return [];
    }
  }

  Future<List<T>> getJsonRecords<T>(
    BuildContext context, 
    String storedProcedure, 
    Map<String, dynamic> params, 
    T Function(Map<String, dynamic>) fromJson) async {

    try {
      var jsonResponse = await DatabaseApiService().readJsonRecord(storedProcedure, params);

      if (jsonResponse != null && jsonResponse['data'] != null) {
        var data = jsonResponse['data'];

        if (data is! List) {
          return [];
        }

        return data.map<T?>((json) {
              try {
                return fromJson(json)!;
              } catch (e) {
                return null;
              }
            })
            .whereType<T>()
            .toList();
      } else {
        return [];
      }
    } catch (e, errorStackTrace) {
      _handleError(context, e, errorStackTrace, storedProcedure, 'readJsonRecord', params);
      return [];
    }
  }

  // Handle errors and show messages to users
  void _handleError(BuildContext context, dynamic error, StackTrace stackTrace, String storedProcedure, String action, Map<String, dynamic> params) {
    // Check if context is still mounted before using it
    try {
      if (!context.mounted) {
        return;
      }
    } catch (e) {
      // Widget has been disposed, context is no longer valid
      return;
    }
    
    try {
      SnackbarMessage.showErrorMessage(
        context,
        'Unable to complete the action. Please contact support for assistance.',
        logError: true,
        errorMessage: error.toString(),
        errorStackTrace: stackTrace.toString(),
        errorSource: '$storedProcedure $params',
        severityLevel: 'Critical',
        requestPath: action,
      );
    } catch (e) {
      // Context became invalid while showing error message, just return
      return;
    }
  }
}
