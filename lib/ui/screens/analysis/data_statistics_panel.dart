import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/screens/analysis/data_statistics_service.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:intl/intl.dart';

class DataStatisticsPanel extends StatefulWidget {
  final List<TableColumn> columns;
  final List<Map<String, dynamic>> data;

  const DataStatisticsPanel({
    super.key,
    required this.columns,
    required this.data,
  });

  @override
  State<DataStatisticsPanel> createState() => _DataStatisticsPanelState();
}

class _DataStatisticsPanelState extends State<DataStatisticsPanel> {
  late Map<String, dynamic> _tableStats;
  late List<ColumnStats> _columnStats;
  bool _isCalculated = false;

  @override
  void initState() {
    super.initState();
    _calculateStatistics();
  }

  @override
  void didUpdateWidget(DataStatisticsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recalculate if data or columns have changed
    if (oldWidget.data != widget.data || oldWidget.columns != widget.columns) {
      _calculateStatistics();
    }
  }

  void _calculateStatistics() {
    if (widget.data.isEmpty || widget.columns.isEmpty) {
      _tableStats = {};
      _columnStats = [];
      _isCalculated = true;
      return;
    }

    _tableStats = DataStatisticsService.calculateTableStatistics(
      columns: widget.columns,
      data: widget.data,
    );

    _columnStats = DataStatisticsService.calculateColumnStatistics(
      columns: widget.columns,
      data: widget.data,
    );

    _isCalculated = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCalculated || widget.data.isEmpty || widget.columns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTableStatistics(context),
      ],
    );
  }

  Widget _buildTableStatistics(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing(size: SpacingSize.medium);
    final runSpacing = context.spacing(size: SpacingSize.small) * 1.5;
    
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        _buildStatCard(context, 'Total Records', _tableStats['totalRecords'].toString(), Icons.table_rows, colorScheme.primary),
        //_buildStatCard('# Columns', _tableStats['totalColumns'].toString(), Icons.view_column, Colors.blue),
        //_buildStatCard('Text', _tableStats['textColumns'].toString(), Icons.text_fields, Colors.orange),
        //_buildStatCard('Numeric', _tableStats['numericColumns'].toString(), Icons.trending_up, Colors.green),
        //_buildStatCard('Categorical', _tableStats['categoricalColumns'].toString(), Icons.category, Colors.blue),
        //_buildStatCard('Date', _tableStats['dateColumns'].toString(), Icons.calendar_month, Colors.red),
      ],
    );
  }


  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final borderRadius = context.borderRadius * 0.67; // 8px
    final padding = context.spacing(size: SpacingSize.small);
    final iconSize = context.iconSize(size: IconSize.small);
    final fontSize = context.responsiveFontSize(12);
    final valueFontSize = context.responsiveFontSize(18);
    final spacing = context.spacing(size: SpacingSize.small) * 0.5;
    
    return Container(
      width: 140,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: iconSize),
              SizedBox(width: spacing),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: fontSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnStatistics(BuildContext context) {
    return Column(
      children: _columnStats.map((stats) => _buildColumnStatCard(context, stats)).toList(),
    );
  }

  Widget _buildColumnLabelText(BuildContext context, String label) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(12);
    return Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        fontSize: fontSize,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCellTypeText(BuildContext context, String cellType) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(12);
    return Text(
      cellType.toUpperCase(),
      style: theme.textTheme.bodySmall?.copyWith(
        fontSize: fontSize,
      ),
    );
  }

  Widget _buildColumnStatCard(BuildContext context, ColumnStats stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade500, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColumnLabelText(context, stats.columnLabel),
                SizedBox(height: context.spacing(size: SpacingSize.small) / 2),
                _buildCellTypeText(context, stats.cellType.name),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMetric(context, 'Null', '${stats.nullCount} (${stats.nullPercentage.toStringAsFixed(1)}%)', Colors.red),
                const SizedBox(width: 50),
                _buildMetric(context, 'Unique', stats.uniqueValues.toString(), Colors.grey.shade800),
              ],
            ),
          ),
          Expanded(
            child: _buildDataTypeStats(context, stats),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(12);
    final spacing = context.spacing(size: SpacingSize.small) / 2;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildDataTypeStats(BuildContext context, ColumnStats stats) {
    switch (stats.cellType) {
      case CustomCellType.number:
        return _buildNumericStats(context, stats);
      case CustomCellType.date:
        return _buildDateStats(context, stats);
      default:
        return _buildStringStats(context, stats);
    }
  }

  Widget _buildNumericStats(BuildContext context, ColumnStats stats) {
    if (stats.minValue == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(12);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Min: ${stats.minValue!.toStringAsFixed(1)} | Max: ${stats.maxValue!.toStringAsFixed(1)}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
          ),
        ),
        Text(
          'Avg: ${stats.averageValue!.toStringAsFixed(1)} | Std: ${stats.standardDeviation!.toStringAsFixed(1)}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildDateStats(BuildContext context, ColumnStats stats) {
    if (stats.minDate == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(12);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Min: ${DateFormat('MMM dd').format(stats.minDate!)} | Max: ${DateFormat('MMM dd').format(stats.maxDate!)}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
          ),
        ),
        Text(
          'Range: ${stats.dateRangeDays} days',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildStringStats(BuildContext context, ColumnStats stats) {
    if (stats.minLength == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(12);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Min: ${stats.minLength} | Max: ${stats.maxLength}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
          ),
        ),
        Text(
          'Avg: ${stats.averageLength!.toStringAsFixed(1)}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
} 