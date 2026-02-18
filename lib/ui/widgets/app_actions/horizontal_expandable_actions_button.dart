import 'package:flutter/material.dart';
import 'base_expandable_actions_button.dart';

class HorizontalExpandableActionsButton extends BaseExpandableActionsButton {
  const HorizontalExpandableActionsButton({
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
  State<HorizontalExpandableActionsButton> createState() => _HorizontalExpandableActionsButtonState();
}

class _HorizontalExpandableActionsButtonState extends BaseExpandableActionsButtonState<HorizontalExpandableActionsButton> {
  @override
  EdgeInsets get actionButtonPadding => const EdgeInsets.symmetric(horizontal: 4.0);

  @override
  IconData get defaultMainIcon => Icons.more_horiz;

  @override
  Widget buildActionsList(List<Widget> actionWidgets) {
    return Row(mainAxisSize: MainAxisSize.min, children: actionWidgets);
  }

  @override
  Widget buildMainLayout(List<Widget> children, bool isExpanded) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        children[0],
        if (isExpanded) const SizedBox(width: 8),
        children[1],
      ],
    );
  }
}
