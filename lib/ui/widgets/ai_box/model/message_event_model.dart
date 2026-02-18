/// Message events from services
/// Used to communicate between message services and providers
class MessageEvent {
  final MessageEventType type;
  final String? content;
  final Map<String, dynamic>? data;

  MessageEvent({
    required this.type,
    this.content,
    this.data,
  });
}

/// Types of message events that can occur in the message service
enum MessageEventType {
  streamingChunk,
  streamingComplete,
  historyMessage,
  error,
  connected,
  disconnected,
  agentStep,
  metrics
}

/// Agent step with status tracking
class AgentStep {
  final String toolMessage;
  String status; // 'started', 'completed', etc.
  final String runId;

  AgentStep({
    required this.toolMessage,
    required this.status,
    required this.runId,
  });

  bool get isCompleted => status == 'completed' || status == 'done';
  bool get isInProgress => status == 'started' || status == 'running';
}

class Message {
  String content;
  final bool isUser;
  bool isStreaming;
  final List<AgentStep> agentSteps;
  DateTime? startTime;

  Message(
    this.content,
    this.isUser, {
    this.isStreaming = false,
    List<AgentStep>? agentSteps,
    this.startTime,
  }) : agentSteps = agentSteps ?? [];

  Duration? get totalDuration {
    if (startTime != null && !isStreaming) {
      return DateTime.now().difference(startTime!);
    }
    return null;
  }

  /// Update agent step status by run_id
  void updateAgentStepStatus(String runId, String status) {
    for (var step in agentSteps) {
      if (step.runId == runId) {
        step.status = status;
        return;
      }
    }
  }
}