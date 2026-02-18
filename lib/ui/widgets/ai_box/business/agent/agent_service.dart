//core
import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
//screens
import 'package:foretale_application/ui/widgets/ai_box/config/config.dart';
//models
import 'package:foretale_application/ui/widgets/ai_box/model/message_event_model.dart';
//widgets
import 'package:foretale_application/ui/widgets/ai_box/business/message_service.dart';

/// Agent mode service using WebSocket
/// Handles WebSocket connection and converts protocol messages to MessageEvent stream
class AgentService implements MessageService {
  // ============================================================================
  // Properties
  // ============================================================================

  // WebSocket connection state
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;

  // Message event stream
  final _messageController = StreamController<MessageEvent>.broadcast();

  // ============================================================================
  // Public Interface (MessageService)
  // ============================================================================

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<MessageEvent> get messageStream => _messageController.stream;

  // ============================================================================
  // Connection Lifecycle
  // ============================================================================

  @override
  Future<void> connect({String? sessionId}) async {
    if (_channel != null) return; // Already connected or connecting

    await Future.delayed(AgenticAIConfig.connectionDelay);

    try {
      _establishConnection(sessionId);
      _setupMessageListener();
    } catch (e) {
      _handleConnectionError('Failed to connect: $e');
    }
  }

  void _establishConnection(String? sessionId) {
    final wsUrlString = AgenticAIConfig.getWebSocketUrl(sessionId: sessionId);
    final wsUrl = Uri.parse(wsUrlString);
    _channel = WebSocketChannel.connect(wsUrl);

    // Optimistically set as connected - will be corrected if connection fails
    _setConnected(true);
  }

  void _setupMessageListener() {
    _subscription = _channel!.stream.listen(
      _onWebSocketData,
      onError: _onWebSocketError,
      onDone: _onWebSocketDone,
      cancelOnError: false,
    );
  }

  void _onWebSocketData(dynamic data) {
    // Handle reconnection case
    if (!_isConnected) {
      _setConnected(true);
    }

    try {
      final jsonData = jsonDecode(data) as Map<String, dynamic>;
      _processWebSocketMessage(jsonData);
    } catch (e) {
      _emitError('Error parsing message: $e');
    }
  }

  void _onWebSocketError(dynamic error) {
    _setConnected(false);
    _emitError('Connection error: $error');
    _emitDisconnected();
  }

  void _onWebSocketDone() {
    _setConnected(false);
    _emitDisconnected();
  }

  // ============================================================================
  // Message Processing
  // ============================================================================

  void _processWebSocketMessage(Map<String, dynamic> data) {
    final messageType = data['type'] as String?;

    switch (messageType) {
      case 'streaming_chunk':
        _emitMessage(MessageEvent(
          type: MessageEventType.streamingChunk,
          content: data['content'] as String?,
        ));
        break;

      case 'streaming_complete':
        _emitMessage(MessageEvent(
          type: MessageEventType.streamingComplete
          ));
        break;

      case 'tool_status':
        _processToolStatus(data);
        break;

      case 'history_message':
        _processHistoryMessage(data);
        break;

      case 'error':
        _emitMessage(MessageEvent(
          type: MessageEventType.error,
          content: data['content'] as String? ?? 'An error occurred',
        ));
        break;

      case 'metrics':
        _processMetrics(data);
        break;

      default:
        // Unknown message type - ignore or log
        break;
    }
  }

  void _processToolStatus(Map<String, dynamic> data) {
    try {
      final agentSteps = data['agent_steps'] as List?;
      if (agentSteps != null && agentSteps.isNotEmpty) {
        _emitMessage(MessageEvent(
          type: MessageEventType.agentStep,
          data: {
            'agent_steps': agentSteps,
            'run_id': data['run_id'] as String?,
          },
        ));
      }
    } catch (e) {
      // Silently ignore parsing errors for tool status
      // They don't need to be shown to the user
    }
  }

  void _processHistoryMessage(Map<String, dynamic> data) {
    try {
      final content = data['content'] as Map<String, dynamic>?;
      final agentSteps = data['agent_steps'] as List?;
      
      if (content != null) {
        _emitMessage(MessageEvent(
          type: MessageEventType.historyMessage,
          data: {
            'content': content,
            'agent_steps': agentSteps ?? [],
          },
        ));
      }
    } catch (e) {
      // Silently ignore parsing errors for history messages
    }
  }

  void _processMetrics(Map<String, dynamic> data) {
    try {
      // The content is a JSON string containing metrics
      final content = data['content'] as String?;
      if (content != null) {
        _emitMessage(MessageEvent(
          type: MessageEventType.metrics,
          content: content,
        ));
      }
    } catch (e) {
      // Silently ignore parsing errors for metrics
    }
  }


  // ============================================================================
  // Message Sending
  // ============================================================================

  @override
  Future<void> sendMessage(String message, Map<String, dynamic> metadata) async {
    _ensureConnected();

    final appMessage = {
      'session_id': metadata['session_id'],
      'project_id': metadata['project_id'],
      'user_id': metadata['user_id'],
      'message':  message,
    };

    try {
      _channel!.sink.add(jsonEncode(appMessage));
    } catch (e) {
      _handleSendError(e);
      rethrow;
    }
  }

  void _ensureConnected() {
    if (!_isConnected || _channel == null) {
      throw Exception('Not connected');
    }
  }

  void _handleSendError(dynamic error) {
    _setConnected(false);
    _emitError('Error sending message: $error');
    _emitDisconnected();
  }

  // ============================================================================
  // Disconnection
  // ============================================================================

  @override
  void disconnect() {
    _cancelSubscription();
    _closeChannel();
    _cleanup();
  }

  void _cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _closeChannel() {
    if (_channel == null) return;

    try {
      if (_isConnected) {
        _channel!.sink.close();
      }
    } catch (e) {
      // Ignore errors during cleanup
    } finally {
      _channel = null;
    }
  }

  void _cleanup() {
    _isConnected = false; // Set directly without emitting events
    if (!_messageController.isClosed) {
      _messageController.close();
    }
  }

  // ============================================================================
  // Helper Methods (State & Events)
  // ============================================================================
  void _setConnected(bool connected) {
    _isConnected = connected;
    if (connected) {
      _emitMessage(MessageEvent(type: MessageEventType.connected));
    }
  }

  void _emitMessage(MessageEvent event) {
    if (!_messageController.isClosed) {
      _messageController.add(event);
    }
  }

  void _emitError(String error) {
    _emitMessage(MessageEvent(
      type: MessageEventType.error,
      content: error,
    ));
  }

  void _emitDisconnected() {
    _emitMessage(MessageEvent(type: MessageEventType.disconnected));
  }

  void _handleConnectionError(String error) {
    _setConnected(false);
    _emitError(error);
  }
}

