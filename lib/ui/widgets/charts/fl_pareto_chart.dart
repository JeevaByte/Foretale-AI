import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/charts/chart_colors_util.dart';
import 'package:foretale_application/models/enums/chart_enums.dart';

class FlParetoChart extends StatelessWidget {
  final List<String> dimensions;
  final List<double> measures;
  final double height;
  final double width;
  final bool showValues;
  final bool showLabels;
  final Color? color;
  final double elementWidth;
  final SortingDirection sortingDirection;
  final String? xAxisName;
  final String? yAxisName;

  const FlParetoChart({
    super.key,
    required this.dimensions,
    required this.measures,
    this.height = 200,
    this.width = 300,
    this.showValues = true,
    this.showLabels = true,
    this.color,
    this.elementWidth = 50,
    this.sortingDirection = SortingDirection.none,
    this.xAxisName,
    this.yAxisName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final smallFont = context.responsiveFontSize(10);
    
    // Create data points for the chart
    List<ChartData> chartData = List.generate(dimensions.length, (index) {
      return ChartData(
        dimensions[index],
        measures[index],
        color ?? ChartColorsUtil.getColorWithPrimaryFromTheme(index, context),
      );
    });

    // Apply sorting if specified (Pareto charts typically show descending order)
    if (sortingDirection != SortingDirection.none) {
      chartData.sort((a, b) {
        int comparison = a.value.compareTo(b.value);
        return sortingDirection == SortingDirection.ascending 
            ? comparison 
            : -comparison;
      });
    } else {
      // Default to descending order for Pareto chart
      chartData.sort((a, b) => b.value.compareTo(a.value));
    }

    // Calculate cumulative percentages
    double total = chartData.fold(0.0, (sum, item) => sum + item.value);
    List<CumulativeData> cumulativeData = [];
    double cumulativeSum = 0.0;
    
    for (int i = 0; i < chartData.length; i++) {
      cumulativeSum += chartData[i].value;
      cumulativeData.add(CumulativeData(
        chartData[i].category,
        chartData[i].value,
        (cumulativeSum / total) * 100,
        chartData[i].color,
      ));
    }

    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          isVisible: showLabels,
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          labelStyle: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: smallFont,
          ),
          title: AxisTitle(
            text: xAxisName ?? 'Categories',
            textStyle: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: smallFont,
            ),
          ),
        ),
        primaryYAxis: NumericAxis(
          isVisible: showLabels,
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          labelStyle: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: smallFont,
          ),
          title: AxisTitle(
            text: yAxisName ?? 'Frequency',
            textStyle: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: smallFont,
            ),
          ),
        ),
        axes: <ChartAxis>[
          NumericAxis(
            name: 'secondaryYAxis',
            opposedPosition: true,
            isVisible: showLabels,
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            labelStyle: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: smallFont,
            ),
            title: AxisTitle(
              text: 'Cumulative %',
              textStyle: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: smallFont,
              ),
            ),
            minimum: 0,
            maximum: 100,
          ),
        ],
        series: <CartesianSeries>[
          ColumnSeries<CumulativeData, String>(
            dataSource: cumulativeData,
            name: "Frequency",
            xValueMapper: (CumulativeData data, _) => data.category,
            yValueMapper: (CumulativeData data, _) => data.value,
            pointColorMapper: (CumulativeData data, _) => data.color,
            borderRadius: BorderRadius.circular(2),
            width: elementWidth/100,
          ),
          LineSeries<CumulativeData, String>(
            dataSource: cumulativeData,
            name: "Cumulative %",
            xValueMapper: (CumulativeData data, _) => data.category,
            yValueMapper: (CumulativeData data, _) => data.cumulativePercentage,
            color: Colors.red,
            width: 2,
            yAxisName: 'secondaryYAxis',
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 4,
              width: 4,
              color: Colors.red,
            ),
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          color: colorScheme.surface,
          textStyle: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
            fontSize: smallFont,
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

class CumulativeData {
  final String category;
  final double value;
  final double cumulativePercentage;
  final Color color;

  CumulativeData(this.category, this.value, this.cumulativePercentage, this.color);
}
