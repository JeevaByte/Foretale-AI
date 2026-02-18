import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';

class ReportService {
  static Color getCriticalityColor(String criticality) {
    switch (criticality.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.blue;
      case 'medium':
        return Colors.yellow.shade700;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static Widget buildTableHeader(BuildContext context, String firstColumnTitle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 0.5; // 6px
    final padding = context.spacing(size: SpacingSize.small);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _TableHeaderText(context, firstColumnTitle, colorScheme.primary),
          ),
          Expanded(
            child: _TableHeaderText(context, "Critical", getCriticalityColor("Critical")),
          ),
          Expanded(
            child: _TableHeaderText(context, "High", getCriticalityColor("High")),
          ),
          Expanded(
            child: _TableHeaderText(context, "Medium", getCriticalityColor("Medium")),
          ),
          Expanded(
            child: _TableHeaderText(context, "Low", getCriticalityColor("Low")),
          ),
        ],
      ),
    );
  }

  static Widget buildCriticalityCell(
    BuildContext context,
    String itemName,
    String columnCriticality,
    int count,
    Map<String, bool> expandedCells,
    VoidCallback onTap,
  ) {
    final hasData = count > 0;
    final cellColor = hasData ? getCriticalityColor(columnCriticality) : Colors.grey.shade100;
    final textColor = hasData ? Colors.white : Colors.grey.shade500;
    final cellKey = '${itemName}_$columnCriticality';
    final isExpanded = expandedCells[cellKey] ?? false;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: cellColor,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: textColor,
                fontSize: context.responsiveFontSize(10),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasData)
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: textColor,
                size: 8,
              ),
          ],
        ),
      ),
    );
  }

  static Widget buildExpandedDetails(
    BuildContext context,
    String itemName,
    Map<String, bool> expandedCells,
    Widget Function(String) buildDetailsForCriticality,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(14);
    
    final expandedCellsForItem = expandedCells.entries
        .where((entry) => entry.key.startsWith('${itemName}_') && entry.value)
        .map((entry) => entry.key.split('_').last)
        .toList();

    if (expandedCellsForItem.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.borderRadius * 0.5),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The classification is based on the analytical results of the following tests:',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              fontSize: fontSize,
            ),
          ),
          const SizedBox(height: 6),
          ...expandedCellsForItem.map((criticality) => buildDetailsForCriticality(criticality)),
        ],
      ),
    );
  }

  static Widget buildCriticalityDetails(
    BuildContext context,
    String criticality,
    List<Widget> detailsWidgets,
  ) {
    if (detailsWidgets.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomChip(
                label: "Criticality: $criticality",
                backgroundColor: getCriticalityColor(criticality).withValues(alpha: 0.1),
                textColor: getCriticalityColor(criticality),
                border: Border.all(color: getCriticalityColor(criticality).withValues(alpha: 0.3), width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                height: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...detailsWidgets,
        ],
      ),
    );
  }

  static Widget buildSimpleItemCard(
    BuildContext context,
    String title,
    List<String> details,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final titleFontSize = context.responsiveFontSize(12);
    final detailFontSize = context.responsiveFontSize(11);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(context.borderRadius * 0.5),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize,
            ),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...details.map((detail) => 
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  '• $detail',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: detailFontSize,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildFilterColumn({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String selectedItem,
    required Function(String) onItemSelected,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(12);
    final itemFontSize = context.responsiveFontSize(11);
    final iconSize = context.iconSize(size: IconSize.small) * 0.875;
    final borderRadius = context.borderRadius * 0.5;
    final spacing = context.spacing(size: SpacingSize.small);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: spacing * 0.75),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedItem == item;
              
              return InkWell(
                onTap: () => onItemSelected(item),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing * 0.75),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2), width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: itemFontSize,
                            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: iconSize,
                          color: colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget buildFilterColumnWithCounts({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> itemsWithCounts,
    required String selectedItem,
    required Function(String) onItemSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(12);
    final itemFontSize = context.responsiveFontSize(11);
    final countFontSize = context.responsiveFontSize(10);
    final iconSize = context.iconSize(size: IconSize.small) * 0.875;
    final borderRadius = context.borderRadius * 0.5;
    final spacing = context.spacing(size: SpacingSize.small);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: spacing * 0.75),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: ListView.builder(
            itemCount: itemsWithCounts.length,
            itemBuilder: (context, index) {
              final item = itemsWithCounts[index];
              final itemName = item['name'] as String;
              final testCount = item['count'] as int;
              final isSelected = selectedItem == itemName;
              
              return InkWell(
                onTap: () => onItemSelected(itemName),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing * 0.75),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2), width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          itemName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: itemFontSize,
                            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (itemName != 'All')
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: spacing * 0.75, vertical: spacing / 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(context.borderRadius * 1.25),
                          ),
                          child: Text(
                            testCount.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: countFontSize,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (isSelected) ...[
                        SizedBox(width: spacing / 2),
                        Icon(
                          Icons.check,
                          size: iconSize,
                          color: colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  const _TableHeaderText(this.context, this.text, this.color);
  
  final BuildContext context;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = this.context.responsiveFontSize(14);
    
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      textAlign: text == "Risk" || text == "Recommendation" ? TextAlign.start : TextAlign.center,
    );
  }
}
