import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/charts/chart_colors_util.dart';
import 'package:foretale_application/models/enums/chart_enums.dart';

class FlBarChart extends StatelessWidget {
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

  const FlBarChart({
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

    // Apply sorting if specified
    if (sortingDirection != SortingDirection.none) {
      chartData.sort((a, b) {
        int comparison = a.value.compareTo(b.value);
        return sortingDirection == SortingDirection.ascending 
            ? comparison 
            : -comparison;
      });
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
            text: yAxisName ?? 'Values',
            textStyle: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: smallFont,
            ),
          ),
        ),
        series: <CartesianSeries<ChartData, String>>[
          BarSeries<ChartData, String>(
            dataSource: chartData,
            name: "More Info", //mention the dimension name here
            xValueMapper: (ChartData data, _) => data.category,
            yValueMapper: (ChartData data, _) => data.value,
            pointColorMapper: (ChartData data, _) => data.color,

            borderRadius: BorderRadius.circular(2),
            width: elementWidth/100, // Convert to percentage
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

