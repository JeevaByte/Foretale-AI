import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class SelectableAnimatedList<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final String Function(T) getLabel;
  final int Function(T) getCount;
  final void Function(T) onItemSelected;
  final Color selectedColor;

  const SelectableAnimatedList({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.getLabel,
    required this.getCount,
    required this.onItemSelected,
    this.selectedColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final bool isSelected = item == selectedItem;
        final String label = getLabel(item);
        final int count = getCount(item);
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        final labelFontSize = context.responsiveFontSize(14);
        final countFontSize = context.responsiveFontSize(10);
        final padding = context.spacing(size: SpacingSize.small);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: selectedColor.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onItemSelected(item),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selection indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 3,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected ? selectedColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Category label
                    Flexible(
                      flex: 5,
                      child: Text(
                        label,
                        style: textTheme.labelMedium?.copyWith(
                          fontSize: labelFontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: padding,
                          vertical: padding / 2,
                        ),
                        child: Text(
                          "(${count.toString()})",
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: countFontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
