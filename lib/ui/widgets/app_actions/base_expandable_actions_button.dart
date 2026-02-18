import 'package:flutter/material.dart';
import 'expandable_actions_button.dart';

abstract class BaseExpandableActionsButton extends StatefulWidget {
  final List<ActionItem> actions;
  final IconData? mainIcon;
  final String? mainTooltip;
  final double iconSize;
  final double actionIconSize;
  final Duration animationDuration;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final double? buttonSize;

  const BaseExpandableActionsButton({
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
    this.buttonSize,
  });
}

abstract class BaseExpandableActionsButtonState<T extends BaseExpandableActionsButton> extends State<T> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // Abstract methods for direction-specific behavior
  EdgeInsets get actionButtonPadding;
  IconData get defaultMainIcon;
  Widget buildActionsList(List<Widget> actionWidgets);
  Widget buildMainLayout(List<Widget> children, bool isExpanded);

  Widget _buildActionButton(ActionItem action, double buttonSize, Color activeColor, Color inactiveColor, Color backgroundColor) {
    return Padding(
      padding: actionButtonPadding,
      child: SizedBox(
        width: buttonSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tooltip(
              message: action.tooltip,
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: Material(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(buttonSize / 2),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(buttonSize / 2),
                    onTap: action.onPressed,
                    hoverColor: backgroundColor.withValues(alpha: 0.2),
                    splashColor: activeColor.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        action.icon,
                        color: action.isActive ? activeColor : inactiveColor,
                        size: widget.actionIconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (action.showLabel) ...[
              const SizedBox(height: 4),
              Text(
                action.tooltip,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(double buttonSize, Color activeColor, Color inactiveColor, Color backgroundColor) {
    final tooltip = widget.mainTooltip ?? "Menu";
    return SizedBox(
      width: buttonSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Tooltip(
            message: tooltip,
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Material(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(buttonSize / 2),
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(buttonSize / 2),
                  onTap: _toggleExpanded,
                  hoverColor: backgroundColor.withValues(alpha: 0.2),
                  splashColor: activeColor.withValues(alpha: 0.1),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _isExpanded ? 0.125 : 0,
                      duration: widget.animationDuration,
                      child: Icon(
                        widget.mainIcon ?? defaultMainIcon,
                        color: _isExpanded ? activeColor : inactiveColor,
                        size: widget.iconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tooltip.isEmpty ? ' ' : tooltip,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedActions(double buttonSize, Color activeColor, Color inactiveColor, Color backgroundColor) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        if (_animationController.value == 0.0) {
          return const SizedBox.shrink();
        }
        
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildActionsList(buttonSize, activeColor, inactiveColor, backgroundColor),
          ),
        );
      },
    );
  }

  Widget _buildActionsList(double buttonSize, Color activeColor, Color inactiveColor, Color backgroundColor) {
    final visibleActions = widget.actions.where((action) => action.showCondition).toList();
    final actionWidgets = visibleActions.map((action) => 
      _buildActionButton(action, buttonSize, activeColor, inactiveColor, backgroundColor)
    ).toList();
    
    return buildActionsList(actionWidgets);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = widget.activeColor ?? colorScheme.onSurface;
    final inactiveColor = widget.inactiveColor ?? colorScheme.onSurface;
    final backgroundColor = widget.backgroundColor ?? colorScheme.primary.withValues(alpha: 0.2);
    final buttonSize = widget.buttonSize ?? 56.0;

    final children = [
      _buildAnimatedActions(buttonSize, activeColor, inactiveColor, backgroundColor),
      _buildMainButton(buttonSize, activeColor, inactiveColor, backgroundColor),
    ];

    return buildMainLayout(children, _isExpanded);
  }
}
