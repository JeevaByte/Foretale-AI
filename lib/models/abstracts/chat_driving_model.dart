import 'package:flutter/material.dart';


abstract class ChatDrivingModel {
  int get selectedId;
  
  String get mode;
  set mode(String value);
  bool get isAgentMode;

  //default is false
  bool get enableAgentMode;

  Future<void> fetchResponses(BuildContext context);

  Future<int> insertResponse(BuildContext context, String responseText);

  String buildStoragePath({
    required String projectId,
    required String responseId,
  });

  String getStoragePath(BuildContext context, int responseId);

  int getActiveProjectId(BuildContext context);

  int getSelectedId(BuildContext context);

  String getDrivingModelName(BuildContext context);

}
