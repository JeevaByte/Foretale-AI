import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/ai_box/model/message_event_model.dart';

/// Widget to display agent execution steps
class AgentStepsWidget extends StatelessWidget {
  final Message message;

  const AgentStepsWidget({
    super.key,
    required this.message,
  });

  Widget _buildStepIcon(BuildContext context, AgentStep step) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small);
    return Icon(
      step.isCompleted
          ? Icons.check_circle
          : step.isInProgress
              ? Icons.hourglass_empty
              : Icons.circle_outlined,
      size: iconSize,
      color: step.isCompleted
          ? Colors.green
          : step.isInProgress
              ? colorScheme.secondary
              : colorScheme.onSurface.withValues(alpha: 0.4),
    );
  }

  Widget _buildStepText(BuildContext context, AgentStep step) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(12);
    return Text(
      step.toolMessage,
      style: step.isCompleted
          ? theme.textTheme.bodySmall?.copyWith(
              fontSize: fontSize,
              decoration: TextDecoration.lineThrough,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            )
          : theme.textTheme.bodySmall?.copyWith(
              fontSize: fontSize,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (message.agentSteps.isEmpty) return const SizedBox.shrink();

    final duration = message.totalDuration;
    final durationText = duration != null 
        ? '${duration.inSeconds}s' 
        : '';

    final stepWidgets = message.agentSteps.asMap().entries.map((entry) {
      final step = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStepIcon(context, step),
            const SizedBox(width: 6),
              Expanded(
                child: _buildStepText(context, step),
              ),
          ],
        ),
      );
    }).toList();

    return _buildStepsContainer(context, durationText, stepWidgets);
  }

  Widget _buildStepsContainer(BuildContext context, String durationText, List<Widget> stepWidgets) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = context.borderRadius * 0.5;
    final padding = context.spacing(size: SpacingSize.small);
    final margin = context.spacing(size: SpacingSize.small) / 2;
    final topMargin = context.spacing(size: SpacingSize.medium) * 1.25;
    
    return Container(
      margin: EdgeInsets.only(bottom: margin, top: topMargin),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 1.5),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepsHeader(context, durationText),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 90),
            child: Scrollbar(
              thumbVisibility: stepWidgets.length > 3,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: stepWidgets,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsHeader(BuildContext context, String durationText) {
    final theme = Theme.of(context);
    final headerFontSize = context.responsiveFontSize(11);
    final durationFontSize = context.responsiveFontSize(10);
    final spacing = context.spacing(size: SpacingSize.small) * 0.75;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'STEPS [${message.agentSteps.length}]',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: headerFontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        if (durationText.isNotEmpty) ...[
          SizedBox(width: spacing),
          Text(
            '• $durationText',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: durationFontSize,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}

