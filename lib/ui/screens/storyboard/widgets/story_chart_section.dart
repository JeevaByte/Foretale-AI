import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/chart_metadata_model.dart';
import 'package:foretale_application/models/enums/chart_enums.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/ui/widgets/charts/auto_chart.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';

class StoryChartSection extends StatefulWidget {
  const StoryChartSection({
    super.key,
    required this.resultModel,
  });

  final ResultModel resultModel;

  @override
  State<StoryChartSection> createState() => _StoryChartSectionState();
}

class _StoryChartSectionState extends State<StoryChartSection> {
  ResultModel get _resultModel => widget.resultModel;
  final String _currentFileName = 'story_chart_section.dart';

  @override
  Widget build(BuildContext context) {
    if (!_hasRequiredSelections()) {
      return _buildSelectionEmptyState();
    }

    if (_resultModel.tableData.isEmpty) {
      return const Center(
        child: EmptyState(
          title: "No data available",
          subtitle: "No data found for the selected test",
          icon: Icons.data_usage,
        ),
      );
    }

    final chartData = StoryChartHelper.prepareChartData(_resultModel);

    if (chartData.isEmpty) {
      return const Center(
        child: EmptyState(
          title: "No valid data",
          subtitle: "Selected columns don't contain valid data for charting",
          icon: Icons.error_outline,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisOptionsChips(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildChartTitleWidget(context),
              ),
              Selector<ResultModel, bool>(
                selector: (context, resultModel) => resultModel.getIsStoryPointSaving,
                builder: (context, isStoryPointSaving, child) => CustomIconButton(
                  onPressed: () => _saveStoryPointConfig(context),
                  icon: Icons.save_as_rounded,
                  tooltip: "Save",
                  isProcessing: isStoryPointSaving,
                ),
              ),
              const SizedBox(width: 8),
              CustomIconButton(
                onPressed: () => _resultModel.toggleSort(),
                icon: _resultModel.isSortedAscending ? Icons.arrow_upward : Icons.arrow_downward,
                tooltip: _resultModel.isSortedAscending ? "Sort Descending" : "Sort Ascending",
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildChart(context, chartData),
          ),
        ],
      ),
    );
  }

  bool _hasRequiredSelections() {
    return _resultModel.selectedDimension != null && _resultModel.selectedFact != null;
  }

  Widget _buildSelectionEmptyState() {
    return Center(
      child: EmptyState(
        title: "Select chart options",
        subtitle: "Choose analysis options to display the chart",
        icon: Icons.bar_chart,
      ),
    );
  }

  Widget _buildChartTitleWidget(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(16);
    return Text(
      _buildChartTitle(),
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildAutoChart(BuildContext context, List<String> dimensions, List<double> measures, List<Map<String, dynamic>> chartData, ColorScheme colorScheme) {
    return AutoChart(
      dimensions: dimensions,
      measures: measures,
      metadata: StoryChartHelper.createChartMetadata(chartData),
      height: 300,
      width: double.infinity,
      showValues: true,
      showLabels: true,
      color: colorScheme.primary,
      sortingDirection: _resultModel.isSortedAscending ? SortingDirection.ascending : SortingDirection.descending,
      xAxisName: _formatLabelOrNull(_resultModel.selectedDimension),
      yAxisName: _formatLabelOrNull(_resultModel.selectedFact),
      forcedChartType: () {
        switch (_resultModel.selectedGraph) {
          case "Bar Chart":
            return ChartType.bar;
          case "Column Chart":
            return ChartType.column;
          case "Line Chart":
            return ChartType.line;
          case "Pie Chart":
            return ChartType.pie;
          case "Scatter Plot":
            return ChartType.scatter;
          case "Pareto Chart":
            return ChartType.pareto;
          default:
            return null;
        }
      }(),
    );
  }

  Widget _buildGraphChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomChip(
      label: _resultModel.selectedGraph!,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      textColor: colorScheme.primary,
      border: Border.all(color: colorScheme.primary, width: 1),
      leadingIcon: Icons.bar_chart,
    );
  }

  Widget _buildChart(BuildContext context, List<Map<String, dynamic>> chartData) {
    final dimensions = chartData.map((item) => item['dimension'] as String).toList();
    final measures = chartData.map((item) => item['fact'] as double).toList();
    final colorScheme = Theme.of(context).colorScheme;
    
    return _buildAutoChart(context, dimensions, measures, chartData, colorScheme);
  }

  Widget _buildAnalysisOptionsChips() {
    final chips = <Widget>[];

    if (_resultModel.selectedGraph != null) {
      chips.add(
        _buildGraphChip(context),
      );
    }

    if (_resultModel.selectedDimension != null) {
      chips.add(
        CustomChip(
          label: _formatLabel(_resultModel.selectedDimension),
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          textColor: Colors.blue.shade700,
          border: Border.all(color: Colors.blue.shade300, width: 1),
          leadingIcon: Icons.category,
        ),
      );
    }

    if (_resultModel.selectedFact != null) {
      chips.add(
        CustomChip(
          label: _formatLabel(_resultModel.selectedFact),
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          textColor: Colors.green.shade700,
          border: Border.all(color: Colors.green.shade300, width: 1),
          leadingIcon: Icons.analytics,
        ),
      );
    }

    if (_resultModel.selectedAggregation != null) {
      chips.add(
        CustomChip(
          label: _formatLabel(
            _resultModel.selectedAggregation,
            fallback: "Sum",
          ),
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          textColor: Colors.orange.shade700,
          border: Border.all(color: Colors.orange.shade300, width: 1),
          leadingIcon: Icons.functions,
        ),
      );
    }

    if (_resultModel.selectedGraph != null) {
      chips.add(
        CustomChip(
          label: _resultModel.isSortedAscending ? "Ascending" : "Descending",
          backgroundColor: Colors.purple.withValues(alpha: 0.1),
          textColor: Colors.purple.shade700,
          border: Border.all(color: Colors.purple.shade300, width: 1),
          leadingIcon: _resultModel.isSortedAscending ? Icons.arrow_upward : Icons.arrow_downward,
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: chips,
    );
  }

  Future<void> _saveStoryPointConfig(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    if (_resultModel.getSelectedTestId == 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Select a test before saving to story.')),
      );
      return;
    }

    if (_resultModel.selectedGraph == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Select a chart type before saving to story.')),
      );
      return;
    }

    try{
      _resultModel.setIsStoryPointSaving = true;
      final storyPointJson = jsonEncode(
        StoryChartHelper.buildStoryPointConfig(_resultModel),
      );

      await _resultModel.saveStoryPointConfig(
        context,
        storyPointJson,
        name: _buildChartTitle(),
        recordStatus: 'A',
      );
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(
          context, 
          e.toString(),
          showUserMessage: false,
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_saveStoryPointConfig");
    } finally {
      _resultModel.setIsStoryPointSaving = false;
    }
  }

  String _formatLabel(String? value, {String fallback = ''}) {
    final resolved = (value ?? fallback).trim();
    if (resolved.isEmpty) return '';
    return resolved.toUpperCase().replaceAll("_", " ");
  }

  String? _formatLabelOrNull(String? value, {String fallback = ''}) {
    final label = _formatLabel(value, fallback: fallback);
    return label.isEmpty ? null : label;
  }

  String _buildChartTitle() {
    final factLabel = _formatLabel(_resultModel.selectedFact);
    final aggregationLabel = _formatLabel(
      _resultModel.selectedAggregation,
      fallback: "Sum",
    );
    final dimensionLabel = _formatLabel(_resultModel.selectedDimension);
    return "$aggregationLabel of $factLabel by $dimensionLabel";
  }
}

class StoryChartHelper {
  const StoryChartHelper._();

  static List<Map<String, dynamic>> prepareChartData(ResultModel resultModel) {
    final dimensionColumn = resultModel.tableColumnsList.firstWhere(
      (col) => col.columnLabel == resultModel.selectedDimension,
      orElse: () => TableColumn(),
    );

    final factColumn = resultModel.tableColumnsList.firstWhere(
      (col) => col.columnLabel == resultModel.selectedFact,
      orElse: () => TableColumn(),
    );

    if (dimensionColumn.columnName.isEmpty || factColumn.columnName.isEmpty) {
      return [];
    }

    final aggregation = resultModel.selectedAggregation ?? "Sum";
    final Map<String, List<double>> groupedData = {};

    for (final row in resultModel.tableData) {
      final dimensionValue = row[dimensionColumn.columnName]?.toString() ?? '';
      final factValue = row[factColumn.columnName];

      if (dimensionValue.isEmpty || factValue == null) continue;

      final numericValue = factValue is num ? factValue.toDouble() : double.tryParse(factValue.toString());

      if (numericValue != null) {
        groupedData.putIfAbsent(dimensionValue, () => []).add(numericValue);
      }
    }

    return groupedData.entries.map((entry) {
      final dimension = entry.key;
      final values = entry.value;

      final aggregatedValue = switch (aggregation) {
        "Sum" => values.reduce((a, b) => a + b),
        "Count" => values.length.toDouble(),
        "Average" => values.reduce((a, b) => a + b) / values.length,
        "Min" => values.reduce((a, b) => a < b ? a : b),
        "Max" => values.reduce((a, b) => a > b ? a : b),
        "Median" => _median(values),
        "Mode" => _mode(values),
        "Count Distinct" => values.toSet().length.toDouble(),
        _ => values.reduce((a, b) => a + b),
      };

      return {
        'dimension': dimension,
        'fact': aggregatedValue,
      };
    }).toList();
  }

  static ChartMetadata createChartMetadata(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) {
      return const ChartMetadata(
        dataType: DataType.categorical,
        maxLength: 0,
        dataPoints: 0,
        uniqueValues: 0,
      );
    }

    final measures = chartData.map((item) => item['fact'] as double).toList();
    final dimensions = chartData.map((item) => item['dimension'] as String).toList();

    return ChartMetadata(
      dataType: DataType.categorical,
      maxLength: dimensions.map((d) => d.length).reduce((a, b) => a > b ? a : b),
      dataPoints: chartData.length,
      minValue: measures.reduce((a, b) => a < b ? a : b),
      maxValue: measures.reduce((a, b) => a > b ? a : b),
      uniqueValues: dimensions.toSet().length,
      hasNullValues: false,
      isTimeSeries: false,
    );
  }

  static Map<String, dynamic> buildStoryPointConfig(ResultModel resultModel) {
    return {
      'dimension': resultModel.selectedDimension ?? '',
      'fact': resultModel.selectedFact ?? '',
      'aggregation': resultModel.selectedAggregation ?? 'Sum',
      'chartType': resultModel.selectedGraph ?? '',
      'sortingDirection': resultModel.isSortedAscending ? 'ascending' : 'descending',
    };
  }

  static double _median(List<double> values) {
    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;

    if (sorted.length.isOdd) {
      return sorted[middle];
    }

    return (sorted[middle - 1] + sorted[middle]) / 2;
  }

  static double _mode(List<double> values) {
    final frequency = <double, int>{};
    for (final value in values) {
      frequency[value] = (frequency[value] ?? 0) + 1;
    }

    return frequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  
}

