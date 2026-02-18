import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/project_type_list_model.dart';

class CustomGridMenu extends StatelessWidget {
  final List<ProjectType> items;
  final String? selectedItem;
  final ValueChanged<String> onItemSelected;
  final bool isEnabled;
  final String labelText;

  const CustomGridMenu({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.isEnabled,
    required this.labelText,
  });

  String _getIconForType(ProjectType type) {
    if(type.abbreviation.isNotEmpty){
      return type.abbreviation.toUpperCase().trim();
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = context.spacing(size: SpacingSize.small);
    final borderRadius = context.borderRadius;
    final iconFontSize = context.responsiveFontSize(16);
    final textFontSize = context.responsiveFontSize(12);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: context.responsiveFontSize(200),
        childAspectRatio: 2.2,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item.name == selectedItem;
        
        return InkWell(
          onTap: isEnabled ? () => onItemSelected(item.name) : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? colorScheme.primary.withValues(alpha: 0.1) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: colorScheme.primary,
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(spacing * 0.75),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getIconForType(item),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: iconFontSize,
                    color: isSelected 
                        ? colorScheme.primary 
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  item.longName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: textFontSize,
                    color: isSelected 
                        ? colorScheme.primary 
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
