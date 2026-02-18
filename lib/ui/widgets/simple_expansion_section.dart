import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/custom_icon.dart';

class SimpleExpansionSection extends StatefulWidget {
  final String title;
  final List<Widget> items;
  final bool? isExpanded;
  final VoidCallback? onToggle;

  const SimpleExpansionSection({
    super.key,
    required this.title,
    required this.items,
    this.isExpanded,
    this.onToggle,
  });

  @override
  State<SimpleExpansionSection> createState() => _SimpleExpansionSectionState();
}

class _SimpleExpansionSectionState extends State<SimpleExpansionSection> {
  bool _isExpanded = false;
  bool _lastExternalState = false;

  bool get _currentExpanded {
    // If external state is provided, use it
    if (widget.isExpanded != null) {
      _lastExternalState = widget.isExpanded!;
      return widget.isExpanded!;
    }
    // Otherwise use internal state
    return _isExpanded;
  }

  @override
  void didUpdateWidget(SimpleExpansionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If external state changed, update internal state to match
    if (widget.isExpanded != null && widget.isExpanded != _lastExternalState) {
      _isExpanded = widget.isExpanded!;
      _lastExternalState = widget.isExpanded!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 1.5;
    final padding = context.spacing(size: SpacingSize.medium);
    final fontSize = context.responsiveFontSize(14);
    final iconSize = context.iconSize(size: IconSize.small) * 1.25;
    
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing(size: SpacingSize.small) / 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header with custom icon
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (widget.onToggle != null) {
                widget.onToggle!();
              }
            },
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                        letterSpacing: 0.5,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                  CustomIcon(
                    icon: _currentExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: iconSize,
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (_currentExpanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: padding,
                right: padding,
                bottom: padding * 0.75,
                top: padding * 0.75,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.items.isEmpty)
                    EmptyState(
                      title: "No ${widget.title.toLowerCase()} available",
                      subtitle: "Select an option from the list",
                      icon: Icons.list_alt,
                    )
                  else
                    ...widget.items,
                ],
              ),
            ),
        ],
      ),
    );
  }
}
