//core
import 'package:flutter/material.dart';
//models
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/ui/widgets/ai_box/model/message_event_model.dart';
//widgets
import 'package:foretale_application/ui/widgets/ai_box/business/message_service.dart';
import 'package:foretale_application/ui/widgets/ai_box/business/chat/input_area_service.dart';
import 'package:file_picker/file_picker.dart';

/// Chat mode service using HTTP API
class ChatService implements MessageService {
  final BuildContext context;
  final ChatDrivingModel drivingModel;
  bool _isConnected = true; // Chat is always "connected" (HTTP)

  ChatService({
    required this.context,
    required this.drivingModel,
  });

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<MessageEvent> get messageStream => const Stream.empty(); 

  @override
  Future<void> connect({String? sessionId}) async {
    // Chat mode doesn't need connection, just fetch existing messages
    // sessionId parameter is ignored for chat mode
    await drivingModel.fetchResponses(context);
    _isConnected = true;
  }

  @override
  Future<void> sendMessage(String message, Map<String, dynamic> metadata) async {
    final filePickerResult = metadata['file_picker_result'] as FilePickerResult?;
    
    await InputAreaService().addResponse(
      context: context,
      responseText: message,
      drivingModel: drivingModel,
      userId: metadata['user_id'] as String,
      filePickerResult: filePickerResult,
      clearInputAndFiles: () {}, // Handled by input area
    );
  }

  @override
  void disconnect() {
    // Chat doesn't need cleanup
    _isConnected = false;
  }
}

