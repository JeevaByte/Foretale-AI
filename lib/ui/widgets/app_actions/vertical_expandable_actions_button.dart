import 'package:flutter/material.dart';
import 'base_expandable_actions_button.dart';

class VerticalExpandableActionsButton extends BaseExpandableActionsButton {
  const VerticalExpandableActionsButton({
    super.key,
    required super.actions,
    super.mainIcon,
    super.mainTooltip,
    super.iconSize,
    super.actionIconSize,
    super.animationDuration,
    super.activeColor,
    super.inactiveColor,
    super.backgroundColor,
    super.buttonSize,
  });

  @override
  State<VerticalExpandableActionsButton> createState() => _VerticalExpandableActionsButtonState();
}

class _VerticalExpandableActionsButtonState extends BaseExpandableActionsButtonState<VerticalExpandableActionsButton> {
  @override
  EdgeInsets get actionButtonPadding => const EdgeInsets.symmetric(vertical: 4.0);

  @override
  IconData get defaultMainIcon => Icons.more_vert;

  @override
  Widget buildActionsList(List<Widget> actionWidgets) {
    // Create a compact vertical layout with minimal spacing
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: actionWidgets,
    );
  }

  @override
  Widget buildMainLayout(List<Widget> children, bool isExpanded) {
    // For vertical layout: main button first (stays fixed), actions expand below
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        children[1], // Main button first
        children[0], // Actions below
      ],
    );
  }
}
