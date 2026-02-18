//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/models/inquiry_attachment_model.dart';
//utils
import 'package:foretale_application/core/services/database/handling_crud.dart';
import 'dart:async';

class InquiryResponse {
  int responseId;
  int projectId;
  int referenceId;
  String referenceType;
  int isAiMagicResponse;
  String responseText;
  String responseBy;
  String responseDate;
  String responseByMachineId;
  List<InquiryAttachment> attachments; 
  bool isEmbeddingCompleted;
  bool isResponseDeleteAvailable;

  InquiryResponse({
    this.responseId = 0,
    this.projectId = 0,
    this.referenceId = 0,
    this.referenceType = '',
    this.isAiMagicResponse = 0,
    this.responseText = '',
    this.responseBy = '',
    this.responseDate = '',
    this.responseByMachineId = '',
    this.attachments = const [], // Initialize with an empty list
    this.isEmbeddingCompleted = false,
    this.isResponseDeleteAvailable = true,
  });

  factory InquiryResponse.fromJson(Map<String, dynamic> map) {
    return InquiryResponse(
      responseId: map['response_id'] ?? 0,
      projectId: map['project_id'] ?? 0,
      referenceId: map['reference_id'] ?? 0,
      referenceType: map['reference_type'] ?? '',
      isAiMagicResponse: map['is_ai_magic_response'] ?? 0,
      responseText: map['response_text'] ?? '',
      responseBy: map['response_by'] ?? '',
      responseDate: map['response_date'] ?? '',
      responseByMachineId: map['response_by_machine_id'] ?? '',
      attachments: map.containsKey('attachments')
          ? List<InquiryAttachment>.from((map['attachments'] as List)
              .map((x) => InquiryAttachment.fromJson(x)))
          : [],
      isEmbeddingCompleted: map['is_embedding_complete'] ?? false,
      isResponseDeleteAvailable: map['is_response_delete_available'] ?? true,
    );
  }

  @override
  String toString() {
    return 'InquiryResponse(responseId: $responseId, '
        'projectId: $projectId, '
        'referenceId: $referenceId, '
        'referenceType: $referenceType, '
        'isAiMagicResponse: $isAiMagicResponse, '
        'responseText: "$responseText", '
        'responseBy: "$responseBy", '
        'responseDate: "$responseDate", '
        'responseByMachineId: "$responseByMachineId", '
        'attachments: ${attachments.map((a) => a.toString()).toList()})';
  }
}

class InquiryResponseModel with ChangeNotifier {
  final CRUD _crudService = CRUD();
  List<InquiryResponse> responseList = [];
  List<InquiryResponse> get getResponseList => responseList;
 
  int _selectedInquiryResponseId = 0;
  int get getSelectedInquiryResponseId => _selectedInquiryResponseId;

  bool _isPageLoading = false;
  bool get getIsPageLoading => _isPageLoading;

  void setIsPageLoading(bool value) {
    if (_isPageLoading != value) {
      _isPageLoading = value;
      notifyListeners();
    }
  }

  List<String> get getSortedResponseTexts {
    return responseList
        .where((response) => response.isAiMagicResponse == 0)
        .map((e) => e.responseText)
        .toList()
      ..sort((a, b) => a.compareTo(b));
  }

  void clearResponseList({bool notify = true}) {
    responseList.clear();
    if (notify) {
      notifyListeners();
    }
  }

  /// Removes the last offline response (used for error handling)
  void removeLastOfflineResponse() {
    if (responseList.isNotEmpty) {
      final firstResponse = responseList.first;
      if (firstResponse.responseId < 0) { // Check if it's an offline response
        responseList.removeAt(0);
        notifyListeners();
      }
    }
  }

  /// Updates the response ID from offline to real database ID
  void updateOfflineResponseId(int oldId, int newId) {
    final index = responseList.indexWhere((response) => response.responseId == oldId);
    if (index != -1) {
      responseList[index].responseId = newId;
      // Update attachment IDs as well
      for (final attachment in responseList[index].attachments) {
        if (attachment.responseId == oldId) {
          attachment.responseId = newId;
        }
      }
      notifyListeners();
    }
  }

  void updateResponseIdSelection(int responseId) {
    _selectedInquiryResponseId = responseId;
    notifyListeners();
  }

  Future<void> fetchResponsesByReference(BuildContext context,int referenceId, String referenceType) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'reference_id': referenceId, //questionModel.getSelectedInquiryQuestionId
      'reference_type': referenceType,
    };

    responseList = await _crudService.getJsonRecords<InquiryResponse>(
      context,
      'dbo.sproc_get_responses_with_attachments',
      params,
      (json) => InquiryResponse.fromJson(json),
    );

    notifyListeners();
  }

  Future<int> insertResponseByReference(BuildContext context, int referenceId, String referenceType, String? responseText, int? testId) async {
    var userDetailsModel =  Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'reference_id': referenceId, //questionModel.getSelectedInquiryQuestionId,
      'reference_type': referenceType,
      'response_text': responseText ?? '',
      'last_updated_by': userDetailsModel.getUserMachineId,
      'test_id': testId ?? 0,
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_response_by_reference',
      params,
    );

    /*if (insertedId > 0) {
      await fetchResponsesByReference(context, referenceId, referenceType);
      notifyListeners();
    }*/

    return insertedId;
  }

  Future<int> insertAttachmentByResponse(
      BuildContext context,
      String? s3FilePath,
      String fileName,
      String fileType,
      int fileSize) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'response_id': _selectedInquiryResponseId,
      'file_path': s3FilePath,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'created_by': userDetailsModel.getUserMachineId
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_attachments_by_response_id',
      params,
    );

    return insertedId;
  }

  Future<int> deleteResponse(BuildContext context, int responseId) async {
    var userDetailsModel =
        Provider.of<UserDetailsModel>(context, listen: false);

    var params = {
      'response_id': responseId,
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

    int deletedId = await _crudService.deleteRecord(
      context,
      'dbo.sproc_delete_response',
      params,
    );

    return deletedId;
  }

  Future<void> deleteResponseOffline(BuildContext context, int responseId) async {
    responseList.removeWhere((response) => response.responseId == responseId);
    notifyListeners();
  }

  Future<void> insertResponseOffline(
      BuildContext context, 
      int projectId,
      String responseText, 
      int referenceId,
      String referenceType,
      List<InquiryAttachment> attachments
    ) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    
    // Generate a unique negative ID for offline responses to avoid conflicts
    // Use negative numbers since database IDs are always positive
    int responseId = -(responseList.length + 1);
    
    final newResponse = InquiryResponse(
      projectId: projectId,
      responseId: responseId, 
      responseText: responseText,
      referenceId: referenceId,
      referenceType: referenceType,
      responseBy: userDetailsModel.getName ?? '',
      responseDate:  "Sending...", 
      responseByMachineId: userDetailsModel.getUserMachineId ?? '',
      attachments: [], // Initialize empty list
      isResponseDeleteAvailable: false,
    );

    // Add attachments to the response
    for (int i = 0; i < attachments.length; i++) {
      newResponse.attachments.add(
        InquiryAttachment(
          attachmentId: -(i + 1), // Use negative IDs for offline attachments
          responseId: responseId,
          filePath: attachments[i].filePath,
          fileName: attachments[i].fileName,
          fileSize: attachments[i].fileSize,
          fileType: attachments[i].fileType,
          isDownloadAvailable: false,
        )
      );
    }

    // Add to the beginning of the list for immediate visibility
    responseList.insert(0, newResponse);

    notifyListeners();
  }
}
