import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/file_picker.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_attachment_model.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/core/services/s3/s3_activites.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';

class InputAreaService {
  static const String _currentFileName = 'InputAreaService.dart';

  Future<void> handleSend({
    required BuildContext context,
    required ChatDrivingModel drivingModel,
    required String responseText,
    required String userId,
    required FilePickerResult? filePickerResult,
    required VoidCallback clearInputAndFiles,
    required String requestPath,
  }) async {
    try {
      await addResponse(
        context: context,
        responseText: responseText,
        drivingModel: drivingModel,
        userId: userId,
        filePickerResult: filePickerResult,
        clearInputAndFiles: clearInputAndFiles,
      );
    } catch (e, stackTrace) {
      SnackbarMessage.showErrorMessage(
        context,
        "Error adding response.",
        logError: true,
        errorMessage: "Error adding response: $e",
        errorStackTrace: stackTrace.toString(),
        severityLevel: "Critical",
        requestPath: requestPath,
      );
    }
  }

  /// Service method for handling chat response operations
  Future<void> addResponse({
    required BuildContext context,
    required String responseText,
    required ChatDrivingModel drivingModel,
    required String userId,
    required FilePickerResult? filePickerResult,
    required VoidCallback clearInputAndFiles,
  }) async {
    int insertedId = 0;
    try {
      final inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
      final referenceType = drivingModel.getDrivingModelName(context);
      
      await _insertResponseOffline(context, responseText, filePickerResult, drivingModel, referenceType);

      clearInputAndFiles();

      //update database response
      insertedId = await _insertResponse(context, responseText, drivingModel);
      if (insertedId <= 0) {
        throw Exception("Error adding response. Inserted id is 0.");
      }

      inquiryResponseModel.updateResponseIdSelection(insertedId);

      if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
        await _processAttachments(context, insertedId, drivingModel, filePickerResult);
      }

      await drivingModel.fetchResponses(context);

    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context, 
        "Error adding response. Please contact support for assistance.",
        logError: true,
        errorMessage: "Error adding response: $e",
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "addResponse"
      );
    }
  }

  //Create a separate function for offline update
  Future<void> _insertResponseOffline(
    BuildContext context,
    String responseText,
    FilePickerResult? filePickerResult,
    ChatDrivingModel drivingModel,
    String referenceType,
  ) async {
    List<InquiryAttachment> dummyAttachments = [];
    final inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);

    if(filePickerResult != null && filePickerResult.files.isNotEmpty){
      dummyAttachments = filePickerResult.files.map((file) => InquiryAttachment(
        attachmentId: 0,
        responseId: 0,
        filePath: '',
        fileName: file.name,
        fileSize: file.size,
        fileType: file.extension ?? '',
      )).toList();
    } 

    await inquiryResponseModel.insertResponseOffline(
      context, 
      drivingModel.getActiveProjectId(context),
      responseText,
      drivingModel.getSelectedId(context),
      referenceType,
      dummyAttachments,
    );
  }

  /// Inserts the response into the database
  Future<int> _insertResponse(BuildContext context, String responseText, ChatDrivingModel drivingModel) async {
    return await drivingModel.insertResponse(context, responseText);
  }

  /// Processes file attachments
  Future<int> _processAttachments(BuildContext context, int insertedId, ChatDrivingModel drivingModel, FilePickerResult filePickerResult) async {
    final inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    final storagePath = drivingModel.getStoragePath(context, insertedId);

    int insertedAttachmentId = 0;

    for (final file in filePickerResult.files) {
      await S3Service().uploadFile(file, storagePath);
      insertedAttachmentId = await inquiryResponseModel.insertAttachmentByResponse(
        context,
        storagePath,
        file.name,
        file.extension ?? "",
        (file.size / (1024 * 1024)).round(),
      );
    }

    if(insertedAttachmentId <= 0) {
      throw Exception("Error adding attachments. Inserted attachment id is 0.");
    }

    return insertedAttachmentId;
  }

  static Future<void> handleDownload(BuildContext context, InquiryAttachment attachment) async {
    try {
      final s3Service = S3Service();
      final filePath = '${attachment.filePath}/${attachment.fileName}';
      final fileUrl = await s3Service.getFileUrl(filePath);

      if (fileUrl == null) {
        SnackbarMessage.showErrorMessage(context, "File not found or access denied.");
      } 

      await s3Service.downloadFile(filePath);
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context, 
        "Error downloading file.",
        logError: true,
        errorMessage: "Error downloading file: $e",
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "handleDownload"
      );
    }
  }

  static Future<void> deleteResponse(BuildContext context, int responseId, ChatDrivingModel drivingModel) async {
    try {
        //then confirm the user if they want to delete the response
        final inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);

        final confirmed = await showConfirmDialog(
          context: context,
          title: 'Delete Response',
          content: 'Are you sure you want to delete this response?',
          confirmText: 'Delete',
          cancelText: 'Cancel',
          confirmTextColor: Colors.green,
        );

        if (confirmed == true) {
          await inquiryResponseModel.deleteResponseOffline(context, responseId);
          int deletedId = await inquiryResponseModel.deleteResponse(context, responseId);
          if (deletedId == 0) {
            await drivingModel.fetchResponses(context);
            throw Exception("Failed to delete response. Deleted id is 0.");
          }
        }
      } catch (e, errorStackTrace) {
        SnackbarMessage.showErrorMessage(
          context,
          'Error deleting response.',
          logError: true,
          errorMessage: "Error deleting response: $e",
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "deleteResponse",
        );
      }
  }

  FilePickerResult? removeFile(FilePickerResult? currentResult, PlatformFile file) {
    if (currentResult == null) {
      return null;
    }

    final files = List<PlatformFile>.from(currentResult.files)..removeWhere((f) => f.name == file.name);

    if (files.isEmpty) {
      return null;
    }

    return FilePickerResult(files);
  }

  Future<FilePickerResult?> pickFile({
    required BuildContext context,
    required FilePickerResult? currentResult,
    required String requestPath,
  }) async {
    try {
      final result = await pickFileForChat();

      if (result == null) {
        return currentResult;
      }

      if (currentResult == null) {
        return result;
      }

      final files = List<PlatformFile>.from(currentResult.files)..addAll(result.files);
      return FilePickerResult(files);
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context,
        "Error picking file.",
        logError: true,
        errorMessage: "Error picking file: $e",
        errorStackTrace: "$e",
        severityLevel: "Critical",
        requestPath: requestPath,
      );
      return currentResult;
    }
  }
}
