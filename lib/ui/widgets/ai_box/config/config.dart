class AgenticAIConfig {
  // WebSocket Configuration
  static const String wsPath = '/ws';
  static const String defaultHost = '54.209.170.16:8002';
  
  // Connection Timing
  static const Duration connectionDelay = Duration(milliseconds: 100);
  
  // Section Title
  static const String sectionTitle = 'foretale.ai';
  
  // Connection Messages
  static const String connectedMessage = 'Connected to AI assistant!';
  static const String connectionLostMessage = 'Connection lost. Please refresh.';
  
  // WebSocket URL Helper
  /// [sessionId] is optional and only included when connecting to an existing session
  static String getWebSocketUrl({String? sessionId}) {
    if (sessionId != null && sessionId.isNotEmpty) {
      return 'ws://$defaultHost$wsPath?session_id=$sessionId';
    }
    return 'ws://$defaultHost$wsPath';
  }
}

