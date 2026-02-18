import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/charts/chart_colors_util.dart';

class FlPieChart extends StatelessWidget {
  final List<String> dimensions;
  final List<double> measures;
  final double height;
  final double width;
  final bool showValues;
  final bool showLabels;
  final bool showLegend;
  final List<Color>? colors;

  const FlPieChart({
    super.key,
    required this.dimensions,
    required this.measures,
    this.height = 200,
    this.width = 200,
    this.showValues = true,
    this.showLabels = true,
    this.showLegend = true,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
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

    final total = measures.reduce((a, b) => a + b);
    if (total == 0) {
      return SizedBox(
        height: height,
        width: width,
        child: Center(
          child: Text(
            'No data to display',
            style: textTheme.bodyMedium,
          ),
        ),
      );
    }

    final defaultColors = ChartColorsUtil.getColors(dimensions.length);
    List<Color> chartColors = colors ?? defaultColors;
    
    // Ensure we have enough colors for all dimensions
    if (chartColors.length < dimensions.length) {
      // If not enough colors provided, use default colors
      chartColors = ChartColorsUtil.getColors(dimensions.length);
    }

    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      child: showLegend ? _buildWithLegend(context, total, chartColors) : _buildChartOnly(context, total, chartColors),
    );
  }

  Widget _buildWithLegend(BuildContext context, double total, List<Color> chartColors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Chart
        Expanded(
          flex: 3,
          child: _buildChartOnly(context, total, chartColors),
        ),
        const SizedBox(height: 16),
        // Legend
        Expanded(
          flex: 1,
          child: _buildLegend(context, total, chartColors),
        ),
      ],
    );
  }

  Widget _buildChartOnly(BuildContext context, double total, List<Color> chartColors) {
    final textTheme = Theme.of(context).textTheme;
    final smallFont = context.responsiveFontSize(10);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final chartSize = availableWidth < availableHeight ? availableWidth : availableHeight;
        final radius = (chartSize - 40) / 2; // Leave padding
        
        return Center(
          child: SizedBox(
            width: chartSize,
            height: chartSize,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 0,
                sections: List.generate(dimensions.length, (index) {
                  return PieChartSectionData(
                    color: chartColors[index],
                    value: measures[index],
                    title: showValues ? measures[index].toStringAsFixed(0) : '',
                    radius: radius,
                    titleStyle: textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: smallFont,
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context, double total, List<Color> chartColors) {
    final textTheme = Theme.of(context).textTheme;
    final smallFont = context.responsiveFontSize(10);
    final tinyFont = context.responsiveFontSize(8);
    
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: List.generate(dimensions.length, (index) {
          final percentage = (measures[index] / total * 100).toStringAsFixed(1);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: chartColors[index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dimensions[index],
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: smallFont,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showValues)
                    Text(
                      '${measures[index].toStringAsFixed(0)} ($percentage%)',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: tinyFont,
                      ),
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

}
