import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/responsive.dart';

/// A simple, generic table widget for displaying data in tabular format
class SimpleTableWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const SimpleTableWidget({
    super.key,
    required this.data,
  });

  @override
  State<SimpleTableWidget> createState() => _SimpleTableWidgetState();
}

class _SimpleTableWidgetState extends State<SimpleTableWidget> {
  static const double _maxTableHeight = 400;

  late final ScrollController _horizontalController;
  late final ScrollController _verticalController;

  List<Map<String, dynamic>> get data => widget.data;

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return EmptyState(
        title: 'No data available',
        subtitle: 'No data available',
        icon: Icons.data_object,
      );
    }

    // Get all unique keys from all data entries, preserving order
    final allKeys = <String>[];
    final seenKeys = <String>{};
    
    for (final item in data) {
      for (final key in item.keys) {
        if (!seenKeys.contains(key)) {
          allKeys.add(key);
          seenKeys.add(key);
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth && constraints.maxWidth.isFinite;
        final maxWidth = hasBoundedWidth ? constraints.maxWidth : null;

        Widget tableContent = Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicWidth(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: maxWidth ?? 0,
              ),
              child: _buildTable(context, allKeys),
            ),
          ),
        );

        tableContent = ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: _maxTableHeight,
          ),
          child: ClipRect(
            child: Scrollbar(
              controller: _verticalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalController,
                scrollDirection: Axis.vertical,
                physics: const ClampingScrollPhysics(),
                child: tableContent,
              ),
            ),
          ),
        );

        final scrollable = Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          trackVisibility: true,
          notificationPredicate: (notification) => notification.depth == 0,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: tableContent,
          ),
        );

        if (maxWidth != null) {
          return ClipRect(
            child: SizedBox(
              width: maxWidth,
              child: scrollable,
            ),
          );
        }

        return ClipRect(child: scrollable);
      },
    );
  }

  Widget _buildTable(BuildContext context, List<String> keys) {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade800,
        width: 0.5,
      ),
      columnWidths: _calculateColumnWidths(context, keys),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          children: keys.map((key) => _buildHeaderCell(context, key)).toList(),
        ),
        // Data rows
        ...data.map((item) => TableRow(
          children: keys.map((key) => _buildDataCell(context, item[key])).toList(),
        )),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    final theme = Theme.of(context);
    final padding = context.spacing(size: SpacingSize.small) / 2;
    final fontSize = context.responsiveFontSize(12);
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: padding * 0.75, vertical: padding / 2),
      child: Text(
        _formatHeaderText(text),
        style: theme.textTheme.labelMedium?.copyWith(
          fontSize: fontSize,
        ),
        textAlign: TextAlign.left,
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildDataCell(BuildContext context, dynamic value) {
    final theme = Theme.of(context);
    final padding = context.spacing(size: SpacingSize.small) / 2;
    final fontSize = context.responsiveFontSize(12);
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: padding * 0.75, vertical: padding / 2),
      child: Text(
        _formatValue(value),
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: fontSize,
        ),
        textAlign: TextAlign.left,
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.visible,
      ),
    );
  }

  String _formatHeaderText(String text) {
    return text
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is Map || value is List) {
      return value.toString();
    }
    if (value is num) {
      // Format numbers with proper precision and commas
      if (value % 1 == 0) {
        // Integer
        return value.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},'
        );
      } else {
        // Decimal
        return value.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},'
        );
      }
    }
    return value.toString();
  }

  Map<int, TableColumnWidth> _calculateColumnWidths(BuildContext context, List<String> keys) {
    final widths = <int, TableColumnWidth>{};
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(12);
    final textStyle = theme.textTheme.bodySmall?.copyWith(fontSize: fontSize);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(fontSize: fontSize);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      
      // Calculate header text width
      final headerText = _formatHeaderText(key);
      textPainter.text = TextSpan(text: headerText, style: headerStyle);
      textPainter.layout();
      double maxWidth = textPainter.width;
      
      // Find maximum cell value width for this column
      for (final item in data) {
        final cellValue = _formatValue(item[key]);
        textPainter.text = TextSpan(text: cellValue, style: textStyle);
        textPainter.layout();
        if (textPainter.width > maxWidth) {
          maxWidth = textPainter.width;
        }
      }
      
      // Add padding (horizontal: 6 * 2 = 12)
      final calculatedWidth = maxWidth + 6.0;
      
      // Set minimum width of 60 (reduced from 80 for compactness)
      final finalWidth = calculatedWidth.clamp(60.0, double.infinity);
      
      widths[i] = FixedColumnWidth(finalWidth);
    }
    
    return widths;
  }

}
