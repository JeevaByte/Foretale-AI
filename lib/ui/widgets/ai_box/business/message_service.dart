import 'package:foretale_application/ui/widgets/ai_box/model/message_event_model.dart';

/// Abstract interface for message services
/// Both agent and chat modes implement this interface
abstract class MessageService {
  /// Send a message
  Future<void> sendMessage(String message, Map<String, dynamic> metadata);
  
  /// Connect/Initialize the service
  /// sessionId is optional and only used when connecting to an existing session
  Future<void> connect({String? sessionId});
  
  /// Disconnect/Cleanup the service
  void disconnect();
  
  /// Check if service is connected/ready
  bool get isConnected;
  
  /// Stream of messages from the service
  Stream<MessageEvent> get messageStream;
}

