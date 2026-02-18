import 'package:flutter/material.dart';
import 'package:foretale_application/ui/widgets/app_actions/expandable_actions_button.dart';

class EnhancedFloatingActionButton extends StatelessWidget {
  final List<ActionItem> additionalActions;
  final VoidCallback? onHomePressed;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final double iconSize;
  final bool showBackButton;
  final bool showHomeButton;

  const EnhancedFloatingActionButton({
    super.key,
    this.additionalActions = const [],
    this.onHomePressed,
    this.onBackPressed,
    this.backgroundColor,
    this.iconSize = 20.0,
    this.showBackButton = true,
    this.showHomeButton = true,
  });

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required String heroTag,
    required Color backgroundColor,
    required Color hoverSplashColor,
    required Color iconColor,
  }) {
    const double buttonSize = 48.0;
    return SizedBox(
      width: buttonSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: label,
            child: Hero(
              tag: heroTag,
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: Material(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(buttonSize / 2),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(buttonSize / 2),
                    onTap: onPressed,
                    hoverColor: hoverSplashColor,
                    splashColor: hoverSplashColor,
                    child: Center(
                      child: Icon(icon, size: iconSize, color: iconColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = this.backgroundColor ?? colorScheme.primary.withValues(alpha: 0.2);
    final hoverSplashColor = colorScheme.primary.withValues(alpha: 0.1);
    final iconColor = colorScheme.onSurface;
    const double spacing = 6.0;
    const double buttonMargin = 6.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (additionalActions.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.all(buttonMargin),
            child: ExpandableActionsButton(
              actions: additionalActions,
              mainIcon: Icons.more_horiz,
              mainTooltip: "Menu",
              activeColor: iconColor,
              inactiveColor: iconColor,
              backgroundColor: backgroundColor,
              buttonSize: 48.0,
            ),
          ),
          const SizedBox(width: spacing),
        ],
        if (showBackButton) ...[
          Container(
            margin: const EdgeInsets.all(buttonMargin),
            child: _buildActionButton(
              context: context,
              icon: Icons.arrow_back,
              label: 'Back',
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              heroTag: 'back_button',
              backgroundColor: backgroundColor,
              hoverSplashColor: hoverSplashColor,
              iconColor: iconColor,
            ),
          ),
          const SizedBox(width: spacing),
        ],
        if (showHomeButton) ...[
          Container(
            margin: const EdgeInsets.all(buttonMargin),
            child: _buildActionButton(
              context: context,
              icon: Icons.home,
              label: 'Home',
              onPressed: onHomePressed ?? () {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              heroTag: 'home_button',
              backgroundColor: backgroundColor,
              hoverSplashColor: hoverSplashColor,
              iconColor: iconColor,
            ),
          ),
        ],
      ],
    );
  }
}
