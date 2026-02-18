//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//utils
import 'package:foretale_application/core/utils/responsive.dart';
//model
import 'package:foretale_application/models/ai_assistant_model.dart';
//widgets
import 'package:foretale_application/ui/widgets/ai_box/ai_box.dart';

class ConversationPanel extends StatelessWidget {
  const ConversationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final double outerPadding = context.spacing(size: SpacingSize.small);
    final double outerBorderRadius = context.borderRadius * 2;
    final double innerPadding = context.spacing(size: SpacingSize.small) * 0.67;
    final double innerBorderRadius = context.borderRadius * 1.67;
    final double clipBorderRadius = context.borderRadius * 1.33;
    final double innerContainerPadding = context.spacing(size: SpacingSize.small) * 0.5;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(outerPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(outerBorderRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          innerPadding,
          innerPadding * 1.5,
          innerPadding,
          innerPadding * 0.67,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(innerBorderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : colorScheme.outline.withValues(alpha: 0.1),
            ),
            color: Colors.transparent,
          ),
          padding: EdgeInsets.all(innerContainerPadding),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(clipBorderRadius),
            child: Consumer<AIAssistantModel>(
              builder: (context, aiModel, _) {
                final String? selectedSessionId = aiModel.getSelectedSessionId;
                final String keyValue = selectedSessionId != null
                    ? 'session_chat_$selectedSessionId'
                    : 'test_chat_${aiModel.getActiveProjectId}';
                return AIBox(
                  key: ValueKey(keyValue),
                  drivingModel: aiModel,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

