import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/custom_selectable_list.dart';

class CategoryListWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final List<String> categories;
  final int Function(String) getCount;

  const CategoryListWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
    required this.getCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader(context),
        Expanded(
          child: _buildCategoryList(context, categories, selectedCategory, onCategorySelected),
        ),
      ],
    );
  }

  Widget _buildCategoryHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = context.spacing(size: SpacingSize.small);
    final borderRadius = context.borderRadius * 1.5;
    final iconSize = context.iconSize(size: IconSize.small) * 1.25;
    final fontSize = context.responsiveFontSize(14);
    
    return Container(
      margin: EdgeInsets.fromLTRB(spacing, 0, spacing, spacing * 0.5),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing * 2,
          vertical: spacing * 0.5,
        ),
        child: Row(
          children: [
            Icon(
              Icons.category_rounded,
              color: colorScheme.primary,
              size: iconSize,
            ),
            SizedBox(width: spacing * 1.5),
            Flexible(
              child: Text(
                "Categories",
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  fontSize: fontSize,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<String> categories,
    String selectedCategory,
    Function(String) onCategorySelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing(size: SpacingSize.small);
    final borderRadius = context.borderRadius * 1.5;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SelectableAnimatedList<String>(
          items: categories,
          selectedItem: selectedCategory,
          getLabel: (cat) => cat,
          getCount: getCount,
          onItemSelected: onCategorySelected,
          selectedColor: colorScheme.primary,
        ),
      ),
    );
  }
}
