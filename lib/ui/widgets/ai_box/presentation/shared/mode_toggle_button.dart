import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';

class ModeToggleButton extends StatelessWidget {
  final ChatDrivingModel drivingModel;

  const ModeToggleButton({
    super.key,
    required this.drivingModel,
  });

  @override
  Widget build(BuildContext context) {
    final isAgentMode = drivingModel.isAgentMode;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isAgentMode 
        ? colorScheme.secondary 
        : colorScheme.surface;
    final textColor = isAgentMode 
        ? colorScheme.onSecondary 
        : colorScheme.primary;
    final borderColor = isAgentMode 
        ? colorScheme.secondary 
        : colorScheme.primary.withValues(alpha: 0.4);
    
    final borderRadius = context.borderRadius * 0.5; // 6px
    final height = context.spacing(size: SpacingSize.medium) * 2.63; // 26px
    final padding = context.spacing(size: SpacingSize.small) * 1.25; // 10px
    final iconSize = context.iconSize(size: IconSize.small);
    final fontSize = context.responsiveFontSize(12);
    final spacing = context.spacing(size: SpacingSize.small) / 2;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: drivingModel.enableAgentMode ? () {drivingModel.mode = isAgentMode ? 'chat' : 'agent';} : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: spacing),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAgentMode ? Icons.auto_awesome : Icons.chat_bubble_outline,
                  size: iconSize,
                  color: textColor,
                ),
                SizedBox(width: spacing),
                Text(
                  drivingModel.mode,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

