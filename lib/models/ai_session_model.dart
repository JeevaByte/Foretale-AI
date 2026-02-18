/// Model for AI Assistant Session
/// Stores session information: first prompt description, timestamp, and user_id
class AISession {
  final String sessionId;
  final String promptDescription;
  final DateTime timestamp;
  final int differenceInDays;

  AISession({
    required this.sessionId,
    required this.promptDescription,
    required this.timestamp,
    required this.differenceInDays,
  });

  /// Create from JSON (database response)
  factory AISession.fromJson(Map<String, dynamic> json) {
    return AISession(
      sessionId: json['unique_session_id'].toString(),
      promptDescription: json['prompt_description'] ?? '',
      timestamp: DateTime.parse(json['created_date'].toString()),
      differenceInDays: json['days_difference'] ?? 0,
    );
  }
}

