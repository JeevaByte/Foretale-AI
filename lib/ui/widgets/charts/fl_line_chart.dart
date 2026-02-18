import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/charts/chart_colors_util.dart';

class FlLineChart extends StatelessWidget {
  final List<String> dimensions;
  final List<double> measures;
  final double height;
  final double width;
  final bool showValues;
  final bool showLabels;
  final Color? color;
  final bool showDots;
  final bool showGrid;

  const FlLineChart({
    super.key,
    required this.dimensions,
    required this.measures,
    this.height = 200,
    this.width = 300,
    this.showValues = true,
    this.showLabels = true,
    this.color,
    this.showDots = true,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final smallFont = context.responsiveFontSize(10);
    
    if (dimensions.isEmpty || measures.isEmpty || dimensions.length != measures.length) {
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

    // Rotate crowded x-axis labels to maintain readability.
    final bool shouldRotateLabels = dimensions.length > 8;

    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: showGrid,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
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
              axisNameSize: 40,
              axisNameWidget: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Categories',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: smallFont,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: showLabels,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dimensions.length) {
                    final labelWidget = Text(
                      dimensions[index],
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: smallFont,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );

                    return Padding(
                      padding: EdgeInsets.only(top: shouldRotateLabels ? 12 : 8),
                      child: shouldRotateLabels
                          ? Transform.rotate(
                              angle: -math.pi / 2,
                              alignment: Alignment.topLeft,
                              child: labelWidget,
                            )
                          : labelWidget,
                    );
                  }
                  return const Text('');
                },
                reservedSize: shouldRotateLabels ? 100 : 70,
              ),
            ),
            leftTitles: AxisTitles(
              axisNameSize: 20,
              axisNameWidget: Text(
                'Values',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: smallFont,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
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
          minX: 0,
          maxX: (dimensions.length - 1).toDouble(),
          minY: 0,
          maxY: measures.reduce((a, b) => a > b ? a : b) * 1.1, // Add 10% padding
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(dimensions.length, (index) {
                return FlSpot(index.toDouble(), measures[index]);
              }),
              isCurved: true,
              color: color ?? ChartColorsUtil.getColorByIndex(0),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: showDots,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: color ?? ChartColorsUtil.getColorByIndex(0),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: (color ?? ChartColorsUtil.getColorByIndex(0)).withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.black87,
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final index = touchedSpot.x.toInt();
                  if (index >= 0 && index < dimensions.length) {
                    return LineTooltipItem(
                      '${dimensions[index]}\n${measures[index].toStringAsFixed(0)}',
                      textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: smallFont,
                      ) ?? TextStyle(
                        color: Colors.white,
                        fontSize: smallFont,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

}
