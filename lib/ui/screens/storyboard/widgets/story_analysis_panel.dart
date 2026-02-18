import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/ui/widgets/simple_expansion_section.dart';

class StoryAnalysisPanel extends StatefulWidget {
  const StoryAnalysisPanel({
    super.key,
    required this.resultModel,
  });

  final ResultModel resultModel;

  @override
  State<StoryAnalysisPanel> createState() => _StoryAnalysisPanelState();
}

class _StoryAnalysisPanelState extends State<StoryAnalysisPanel> {
  static const List<String> _aggregationOptions = [
    "Sum",
    "Count",
    "Average",
    "Min",
    "Max",
    "Median",
    "Mode",
    "Count Distinct",
  ];

  static const List<String> _chartOptions = [
    "Bar Chart",
    "Column Chart",
    "Line Chart",
    "Pie Chart",
    "Scatter Plot",
    "Pareto Chart",
  ];

  bool _allExpanded = false;
  bool _useGlobalState = false;

  @override
  Widget build(BuildContext context) {
    final sections = _buildExpansionSections(widget.resultModel);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildExpandCollapseButton(context),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildSectionWidgets(sections),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionWidgets(List<_ExpansionSectionConfig> sections) {
    final widgets = <Widget>[];

    for (final section in sections) {
      widgets.add(
        SimpleExpansionSection(
          title: section.title,
          isExpanded: _useGlobalState ? _allExpanded : null,
          onToggle: _handleSectionToggle,
          items: section.items,
        ),
      );
      widgets.add(const SizedBox(height: 20));
    }

    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }

    return widgets;
  }

  void _handleSectionToggle() {
    setState(() {
      _useGlobalState = false;
    });
  }

  List<_ExpansionSectionConfig> _buildExpansionSections(ResultModel resultModel) {
    final sections = <_ExpansionSectionConfig>[];
    
    // Add saved configs section at the top if there are any
    if (resultModel.savedChartConfigs.isNotEmpty) {
      sections.add(
        _ExpansionSectionConfig(
          title: "Saved Views",
          items: _buildTwoColumnItems(
            resultModel.savedChartConfigs
                .map(
                  (config) => _buildSavedConfigItem(
                    config.name.isNotEmpty ? config.name : 'Unnamed Config',
                    config,
                    resultModel,
                  ),
                ).toList(),
          ),
        ),
      );
    }
    
    // Add other sections
    sections.addAll([
      _ExpansionSectionConfig(
        title: "Attributes",
        items: _buildTwoColumnItems(
          resultModel.tableColumnsList
              .where((column) => !column.isFeedbackColumn && column.cellType == 'text')
              .map(
                (column) => _buildSelectableOptionItem(
                  column.columnLabel,
                  resultModel.selectedDimension,
                  (value) => resultModel.selectDimension(value),
                ),
              )
              .toList(),
        ),
      ),
      _ExpansionSectionConfig(
        title: "Values",
        items: _buildTwoColumnItems(
          resultModel.tableColumnsList
              .where((column) => !column.isFeedbackColumn && column.cellType == 'number')
              .map(
                (column) => _buildSelectableOptionItem(
                  column.columnLabel,
                  resultModel.selectedFact,
                  (value) => resultModel.selectFact(value),
                ),
              )
              .toList(),
        ),
      ),
      _ExpansionSectionConfig(
        title: "Aggregation",
        items: _buildTwoColumnItems(
          _aggregationOptions
              .map(
                (agg) => _buildSelectableOptionItem(
                  agg,
                  resultModel.selectedAggregation,
                  (value) => resultModel.selectAggregation(value),
                ),
              )
              .toList(),
        ),
      ),
      _ExpansionSectionConfig(
        title: "Charts",
        items: _buildTwoColumnItems(
          _chartOptions
              .map(
                (chart) => _buildSelectableOptionItem(
                  chart,
                  resultModel.selectedGraph,
                  (value) => resultModel.selectGraph(value),
                ),
              )
              .toList(),
        ),
      ),
    ]);
    
    return sections;
  }

  List<Widget> _buildTwoColumnItems(List<Widget> items) {
    if (items.isEmpty) return [];

    final twoColumnItems = <Widget>[];

    for (int i = 0; i < items.length; i += 2) {
      final leftItem = items[i];
      final Widget? rightItem = i + 1 < items.length ? items[i + 1] : null;

      twoColumnItems.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: leftItem),
            if (rightItem != null) ...[
              const SizedBox(width: 8),
              Expanded(child: rightItem),
            ],
          ],
        ),
      );

      if (i + 2 < items.length) {
        twoColumnItems.add(const SizedBox(height: 4));
      }
    }

    return twoColumnItems;
  }

  Widget _buildExpandCollapseButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconSize = context.iconSize(size: IconSize.small);
    final fontSize = context.responsiveFontSize(12);
    final padding = context.spacing(size: SpacingSize.small);
    
    return TextButton.icon(
      onPressed: () {
        setState(() {
          _useGlobalState = true;
          _allExpanded = !_allExpanded;
        });
      },
      icon: Icon(
        _allExpanded ? Icons.unfold_less : Icons.unfold_more,
        size: iconSize,
        color: colorScheme.primary,
      ),
      label: Text(
        _allExpanded ? 'Collapse All' : 'Expand All',
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildSelectableOptionItemContent(BuildContext context, String label, bool isSelected, Function(String) onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 0.67; // 8px
    final padding = context.spacing(size: SpacingSize.small);
    final fontSize = context.responsiveFontSize(10);
    final iconSize = context.iconSize(size: IconSize.small);
    final spacing = context.spacing(size: SpacingSize.small) / 2;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(label),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          margin: EdgeInsets.only(bottom: spacing),
          padding: EdgeInsets.symmetric(horizontal: padding * 1.5, vertical: padding),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase().replaceAll("_", " "),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.87),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: iconSize,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedConfigItemContent(BuildContext context, String label, bool isSelected, SavedChartConfig config, ResultModel resultModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 0.67; // 8px
    final padding = context.spacing(size: SpacingSize.small);
    final fontSize = context.responsiveFontSize(10);
    final iconSize = context.iconSize(size: IconSize.small);
    final spacing = context.spacing(size: SpacingSize.small) / 2;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Select the saved config
          resultModel.selectSavedConfig(config.name);
          
          // Parse and apply the saved config
          final parsedConfig = config.getParsedConfig();
          if (parsedConfig['dimension']?.isNotEmpty ?? false) {
            resultModel.selectDimension(parsedConfig['dimension']!);
          }
          if (parsedConfig['fact']?.isNotEmpty ?? false) {
            resultModel.selectFact(parsedConfig['fact']!);
          }
          if (parsedConfig['aggregation']?.isNotEmpty ?? false) {
            resultModel.selectAggregation(parsedConfig['aggregation']!);
          }
          if (parsedConfig['chartType']?.isNotEmpty ?? false) {
            resultModel.selectGraph(parsedConfig['chartType']!);
          }
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          margin: EdgeInsets.only(bottom: spacing),
          padding: EdgeInsets.symmetric(horizontal: padding * 1.5, vertical: padding),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase().replaceAll("_", " "),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.87),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: iconSize,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableOptionItem(String label, String? selectedValue, Function(String) onTap) {
    final isSelected = selectedValue == label;

    return _buildSelectableOptionItemContent(context, label, isSelected, onTap);
  }

  Widget _buildSavedConfigItem(String label, SavedChartConfig config, ResultModel resultModel) {
    final isSelected = resultModel.selectedSavedConfigName == config.name;

    return _buildSavedConfigItemContent(context, label, isSelected, config, resultModel);
  }
}

class _ExpansionSectionConfig {
  const _ExpansionSectionConfig({
    required this.title,
    required this.items,
  });

  final String title;
  final List<Widget> items;
}

