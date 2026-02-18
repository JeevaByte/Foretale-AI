import 'package:flutter/material.dart';
import 'horizontal_expandable_actions_button.dart';
import 'vertical_expandable_actions_button.dart';

class ActionItem {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isActive;
  final bool showCondition;
  final bool showLabel;

  const ActionItem({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isActive = false,
    this.showCondition = true,
    this.showLabel = true,
  });
}

class ExpandableActionsButton extends StatelessWidget {
  final List<ActionItem> actions;
  final IconData? mainIcon;
  final String? mainTooltip;
  final double iconSize;
  final double actionIconSize;
  final Duration animationDuration;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final Axis expansionDirection;
  final double? buttonSize;

  const ExpandableActionsButton({
    super.key,
    required this.actions,
    this.mainIcon,
    this.mainTooltip,
    this.iconSize = 20.0,
    this.actionIconSize = 18.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.expansionDirection = Axis.horizontal,
    this.buttonSize,
  });

  @override
  Widget build(BuildContext context) {
    if (expansionDirection == Axis.horizontal) {
      return HorizontalExpandableActionsButton(
        key: key,
        actions: actions,
        mainIcon: mainIcon,
        mainTooltip: mainTooltip,
        iconSize: iconSize,
        actionIconSize: actionIconSize,
        animationDuration: animationDuration,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        backgroundColor: backgroundColor,
        buttonSize: buttonSize,
      );
    } else {
      return VerticalExpandableActionsButton(
        key: key,
        actions: actions,
        mainIcon: mainIcon,
        mainTooltip: mainTooltip,
        iconSize: iconSize,
        actionIconSize: actionIconSize,
        animationDuration: animationDuration,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        backgroundColor: backgroundColor,
        buttonSize: buttonSize,
      );
    }
  }
}
