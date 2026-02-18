import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/ai_box/model/message_event_model.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/agent/message_parser.dart';

/// Agent mode message bubble
class AgentMessageBubble extends StatelessWidget {
  final Message message;

  const AgentMessageBubble({
    super.key,
    required this.message,
  });

  Widget _buildUserMessage(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius;
    final padding = context.spacing(size: SpacingSize.small);
    final margin = context.spacing(size: SpacingSize.small);
    final smallRadius = context.borderRadius * 0.13; // 2px
    
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: margin),
        padding: EdgeInsets.symmetric(horizontal: padding * 1.13, vertical: padding * 0.88),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.secondary, colorScheme.secondary],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius * 0.94),
            topRight: Radius.circular(borderRadius * 1.13),
            bottomLeft: Radius.circular(borderRadius * 1.13),
            bottomRight: Radius.circular(smallRadius),
          ),
        ),
        child: message.content.isNotEmpty
            ? MessageParser(
                content: message.content,
                isUser: true,
                baseTextStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSecondary,
                ) ?? const TextStyle(),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildNotUserMessage(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 0.56; // 9px
    final padding = context.spacing(size: SpacingSize.small);
    final margin = context.spacing(size: SpacingSize.small);
    final iconSize = context.iconSize(size: IconSize.small) * 0.6;
    final iconPadding = context.spacing(size: SpacingSize.small) / 2;
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: margin),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding * 4.13, vertical: padding * 0.88),
              child: message.content.isNotEmpty
                  ? MessageParser(
                      content: message.content,
                      isUser: false,
                      baseTextStyle: textTheme.bodyMedium ?? const TextStyle(),
                    )
                  : const SizedBox.shrink(),
            ),
            Positioned(
              top: iconPadding,
              right: iconPadding,
              child: IconButton(
                icon: Icon(Icons.content_copy, size: iconSize),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return message.isUser ? _buildUserMessage(context) : _buildNotUserMessage(context);
  }
}

