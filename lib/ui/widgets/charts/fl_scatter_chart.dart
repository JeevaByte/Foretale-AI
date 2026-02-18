import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class FlScatterChart extends StatelessWidget {
  final List<double> xValues;
  final List<double> yValues;
  final List<String>? labels;
  final double height;
  final double width;
  final bool showValues;
  final bool showLabels;
  final Color? color;
  final bool showGrid;
  final double dotRadius;

  const FlScatterChart({
    super.key,
    required this.xValues,
    required this.yValues,
    this.labels,
    this.height = 200,
    this.width = 300,
    this.showValues = true,
    this.showLabels = true,
    this.color,
    this.showGrid = true,
    this.dotRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final smallFont = context.responsiveFontSize(10);
    
    if (xValues.isEmpty || yValues.isEmpty || xValues.length != yValues.length) {
      return SizedBox(
        height: height,
        width: width,
        child: Center(
          child: Text(
            'No data available',
            style: textTheme.bodyMedium,
          ),
        ),
      );
    }

    final minX = xValues.reduce((a, b) => a < b ? a : b);
    final maxX = xValues.reduce((a, b) => a > b ? a : b);
    final minY = yValues.reduce((a, b) => a < b ? a : b);
    final maxY = yValues.reduce((a, b) => a > b ? a : b);
    final rangeX = (maxX - minX).abs();
    final rangeY = (maxY - minY).abs();
    final safeRangeX = rangeX == 0 ? 1 : rangeX;
    final safeRangeY = rangeY == 0 ? 1 : rangeY;

    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: List.generate(xValues.length, (index) {
            return ScatterSpot(
              xValues[index],
              yValues[index],
            );
          }),
          minX: minX - safeRangeX * 0.1,
          maxX: maxX + safeRangeX * 0.1,
          minY: minY - safeRangeY * 0.1,
          maxY: maxY + safeRangeY * 0.1,
          gridData: FlGridData(
            show: showGrid,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: safeRangeY / 5,
            verticalInterval: safeRangeX / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showLabels,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: smallFont,
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showLabels,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: smallFont,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          scatterTouchData: ScatterTouchData(
            enabled: true,
          ),
        ),
      ),
    );
  }

}
