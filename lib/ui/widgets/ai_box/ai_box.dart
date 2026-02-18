//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
//widgets
import 'package:foretale_application/ui/widgets/ai_box/state/base_ai_box_provider.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/agent/agent_message_list.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/chat/chat_message_list.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/agent/agent_input_area.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/chat/chat_input_area.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/agent/agent_steps_widget.dart';
import 'package:foretale_application/ui/widgets/ai_box/model/message_event_model.dart';

class AIBox extends StatefulWidget {
  final ChatDrivingModel drivingModel;

  const AIBox({
    super.key,
    required this.drivingModel
  });

  @override
  State<AIBox> createState() => _AIBoxState();
}

class _AIBoxState extends State<AIBox> {
  final ScrollController _scrollController = ScrollController();
  late BaseAIBoxProvider _provider;
  bool _previousMode = false;

  @override
  void initState() {
    super.initState();
    _provider = BaseAIBoxProvider(context: context, drivingModel: widget.drivingModel);
    _previousMode = widget.drivingModel.isAgentMode;
    
    // Listen for mode changes (agent ↔ chat toggle)
    if (widget.drivingModel is ChangeNotifier) {
      (widget.drivingModel as ChangeNotifier).addListener(_onModeChanged);
    }
  }

  void _onModeChanged() {
    if (!mounted || _previousMode == widget.drivingModel.isAgentMode) return;
    
    setState(() {
      _previousMode = widget.drivingModel.isAgentMode;
      _provider.dispose();
      _provider = BaseAIBoxProvider(context: context, drivingModel: widget.drivingModel);
    });
  }

  @override
  void dispose() {
    if (widget.drivingModel is ChangeNotifier) {
      (widget.drivingModel as ChangeNotifier).removeListener(_onModeChanged);
    }
    _scrollController.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Column(
        children: [
          if (widget.drivingModel.isAgentMode) 
          _buildAgentSteps(),
          Expanded(
            child: widget.drivingModel.isAgentMode
                ? AgentMessageList(scrollController: _scrollController)
                : ChatMessageList(
                    scrollController: _scrollController,
                    drivingModel: widget.drivingModel,
                  ),
          ),
          widget.drivingModel.isAgentMode
              ? AgentInputArea(drivingModel: widget.drivingModel)
              : ChatInputArea(drivingModel: widget.drivingModel),
        ],
      ),
    );
  }

  Widget _buildAgentSteps() {
    return Consumer<BaseAIBoxProvider>(
      builder: (context, provider, _) {
        final messageWithSteps = _findMessageWithAgentSteps(provider);
        if (messageWithSteps == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: AgentStepsWidget(message: messageWithSteps),
        );
      },
    );
  }

  /// Finds the most recent AI message that has agent execution steps to display
  Message? _findMessageWithAgentSteps(BaseAIBoxProvider provider) {
    if (provider.messages.isEmpty) return null;
    
    final lastMessage = provider.messages.last;
    // Only show steps for AI messages (not user messages) that have steps
    if (lastMessage.isUser || lastMessage.agentSteps.isEmpty) return null;
    
    return lastMessage;
  }
}

