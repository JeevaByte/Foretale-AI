import 'package:flutter/material.dart';
import 'package:foretale_application/models/chart_metadata_model.dart';
import 'package:foretale_application/models/enums/chart_enums.dart';
import 'package:foretale_application/ui/widgets/charts/fl_bar_chart.dart';
import 'package:foretale_application/ui/widgets/charts/fl_column_chart.dart';
import 'package:foretale_application/ui/widgets/charts/fl_line_chart.dart';
import 'package:foretale_application/ui/widgets/charts/fl_pie_chart.dart';
import 'package:foretale_application/ui/widgets/charts/fl_scatter_chart.dart';
import 'package:foretale_application/ui/widgets/charts/fl_pareto_chart.dart';

class AutoChart extends StatelessWidget {
  final List<String> dimensions;
  final List<double> measures;
  final ChartMetadata metadata;
  final double height;
  final double width;
  final bool showValues;
  final bool showLabels;
  final Color? color;
  final ChartType? forcedChartType;
  final SortingDirection sortingDirection;
  final String? xAxisName;
  final String? yAxisName;

  const AutoChart({
    super.key,
    required this.dimensions,
    required this.measures,
    required this.metadata,
    this.height = 200,
    this.width = 300,
    this.showValues = true,
    this.showLabels = true,
    this.color,
    this.forcedChartType,
    this.sortingDirection = SortingDirection.none,
    this.xAxisName,
    this.yAxisName,
  });

  @override
  Widget build(BuildContext context) {
    if (dimensions.length != measures.length) {
      return SizedBox(
        height: height,
        width: width,
        child: Center(
          child: Text(
            'No data available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final chartType = forcedChartType ?? _determineBestChartType();
    
    switch (chartType) {
      case ChartType.bar:
        return FlBarChart(
          dimensions: dimensions,
          measures: measures,
          height: height,
          width: width,
          showValues: showValues,
          showLabels: showLabels,
          color: color,
          sortingDirection: sortingDirection,
          xAxisName: xAxisName,
          yAxisName: yAxisName,
        );
      
      case ChartType.column:
        return FlColumnChart(
          dimensions: dimensions,
          measures: measures,
          height: height,
          width: width,
          showValues: showValues,
          showLabels: showLabels,
          color: color,
          sortingDirection: sortingDirection,
          xAxisName: xAxisName,
          yAxisName: yAxisName,
        );
      
      case ChartType.line:
        return FlLineChart(
          dimensions: dimensions,
          measures: measures,
          height: height,
          width: width,
          showValues: showValues,
          showLabels: showLabels,
          color: color,
        );
      
      case ChartType.pie:
        return FlPieChart(
          dimensions: dimensions,
          measures: measures,
          height: height,
          width: width,
          showValues: showValues,
          showLabels: showLabels,
          colors: null, // Let FlPieChart handle colors automatically
        );
      
      case ChartType.scatter:
        // For scatter chart, we need to convert dimensions to numeric values
        final xValues = _convertDimensionsToNumeric();
        return FlScatterChart(
          xValues: xValues,
          yValues: measures,
          labels: dimensions,
          height: height,
          width: width,
          showValues: showValues,
          showLabels: showLabels,
          color: color,
        );
      
      case ChartType.pareto:
        return FlParetoChart(
          dimensions: dimensions,
          measures: measures,
          height: height,
          width: width,
          showValues: showValues,
          showLabels: showLabels,
          color: color,
          sortingDirection: sortingDirection,
          xAxisName: xAxisName,
          yAxisName: yAxisName,
        );
    }
  }

  ChartType _determineBestChartType() {
    // Use metadata to make intelligent chart selection decisions
    
    // 1. PIE CHART: Best for parts of a whole
    if (_shouldUsePieChart()) {
      return ChartType.pie;
    }
    
    // 2. LINE CHART: Best for time series and trends
    if (_shouldUseLineChart()) {
      return ChartType.line;
    }
    
    // 3. SCATTER CHART: Best for correlation analysis
    if (_shouldUseScatterChart()) {
      return ChartType.scatter;
    }
    
    // 4. BAR vs COLUMN: Choose based on data characteristics
    if (_shouldUseBarChart()) {
      return ChartType.bar;
    }
    
    // 5. Default to column chart
    return ChartType.column;
  }

  bool _shouldUsePieChart() {
    // Use pie chart when:
    // - Small dataset (≤6 items)
    // - Represents parts of a whole (percentage-like data)
    // - No negative values
    // - Low cardinality (few unique values)
    return metadata.isSmallDataset &&
           metadata.isPercentageData &&
           !metadata.hasNegativeValues &&
           metadata.isLowCardinality;
  }

  bool _shouldUseLineChart() {
    // Use line chart when:
    // - Time series data
    // - Temporal data type
    // - Sequential/ordered data
    // - Medium to large dataset
    return metadata.isTimeSeries ||
           metadata.dataType == DataType.temporal ||
           (metadata.dataType == DataType.ordinal && metadata.isMediumDataset);
  }

  bool _shouldUseScatterChart() {
    // Use scatter chart when:
    // - High cardinality (many unique values)
    // - Numerical data type
    // - Wide range of values
    // - Looking for correlations
    return metadata.isHighCardinality &&
           metadata.dataType == DataType.numerical &&
           metadata.isWideRange;
  }

  bool _shouldUseBarChart() {
    // Use bar chart when:
    // - Small dataset (≤5 items)
    // - Categorical data
    // - Not time series
    // - Good for comparisons
    // - Long labels (bar charts handle long labels better)
    return metadata.isSmallDataset &&
           metadata.dataType == DataType.categorical &&
           !metadata.isTimeSeries &&
           metadata.hasLongLabels;
  }

  List<double> _convertDimensionsToNumeric() {
    // Convert string dimensions to numeric values for scatter plot
    // This is a simple implementation - in practice, you might want more sophisticated conversion
    return List.generate(dimensions.length, (index) => index.toDouble());
  }
}
