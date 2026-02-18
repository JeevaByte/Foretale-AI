import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/ui/widgets/ai_box/state/base_ai_box_provider.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/agent/agent_message_bubble.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/shared/scroll_helper.dart';

/// Message list widget for agent mode
class AgentMessageList extends StatelessWidget {
  final ScrollController scrollController;

  const AgentMessageList({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BaseAIBoxProvider>(
      builder: (context, provider, child) {
        // Only auto-scroll when streaming chunks are coming in
        final hasStreamingMessage = provider.messages.any((msg) => msg.isStreaming);
        
        if (hasStreamingMessage) {
          // Check if user is at bottom before scrolling
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!scrollController.hasClients) return;
            
            final position = scrollController.position;
            final maxScroll = position.maxScrollExtent;
            final currentScroll = position.pixels;
            final threshold = 100.0;
            
            // Only scroll if user is already at or near the bottom
            if ((maxScroll - currentScroll) <= threshold) {
              ScrollHelper.scrollToBottom(
                scrollController: scrollController,
                reversed: false,
              );
            }
          });
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: provider.messages.length,
          padding: const EdgeInsets.all(12),
          // Performance optimizations for large messages
          cacheExtent: 500, // Cache 500 pixels worth of off-screen items
          addAutomaticKeepAlives: true, // Don't keep items alive when off-screen
          addRepaintBoundaries: true, // Isolate repaints to individual items
          addSemanticIndexes: false, // Disable semantic indexes for better performance
          itemBuilder: (context, index) {
            final message = provider.messages[index];
            return AgentMessageBubble(
              key: ValueKey('message_${index}_${message.content.hashCode}_${message.isUser}'),
              message: message,
            );
          },
        );
      },
    );
  }
}

