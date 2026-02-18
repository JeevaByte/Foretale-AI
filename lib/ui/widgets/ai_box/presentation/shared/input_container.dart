import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class InputContainer extends StatelessWidget {
  final bool isAgentMode;
  final Widget? filePreview;
  final Widget responseField;
  final List<Widget> actionRowChildren;

  const InputContainer({
    super.key,
    required this.isAgentMode,
    this.filePreview,
    required this.responseField,
    required this.actionRowChildren,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = context.borderRadius * 0.67; // 8px
    final padding = context.spacing(size: SpacingSize.small);
    final margin = context.spacing(size: SpacingSize.small) / 2;
    final borderWidth = context.spacing(size: SpacingSize.small) / 2;
    
    return Container(
      padding: EdgeInsets.fromLTRB(padding, margin, padding, margin / 2),
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isAgentMode
              ? colorScheme.secondary
              : colorScheme.primary.withValues(alpha: 0.3),
          width: borderWidth,
        ),
        boxShadow: isAgentMode
            ? [
                BoxShadow(
                  color: colorScheme.secondary.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filePreview != null) filePreview!,
          Flexible(
            fit: FlexFit.loose,
            child: responseField,
          ),
          SizedBox(height: margin / 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: actionRowChildren,
          ),
        ],
      ),
    );
  }
}

