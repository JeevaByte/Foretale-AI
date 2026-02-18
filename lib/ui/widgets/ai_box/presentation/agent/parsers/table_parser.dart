import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:foretale_application/ui/widgets/simple_table_widget.dart';
import 'parser_utils.dart';

/// Result of table detection with widget and line range information
class TableParseResult {
  final Widget widget;
  final int startLine;
  final int endLine;

  TableParseResult({
    required this.widget,
    required this.startLine,
    required this.endLine,
  });
}

/// Parser for markdown table elements
class TableParser {
  /// Detects and parses markdown table from raw text when markdown package
  /// has not yet processed the content.
  static TableParseResult? tryParseMarkdownTable(String content) {
    final lines = content.split('\n');
    if (lines.length < 3) return null;

    int? headerIndex;
    int? separatorIndex;

    final headerRegex = RegExp(r'^\s*\|?.+\|.+$');
    final separatorRegex = RegExp(r'^\s*\|?\s*(:?-+:?\s*\|)+\s*(:?-+:?\s*)?$');

    for (int i = 0; i < lines.length - 1; i++) {
      final line = lines[i].trimRight();
      final next = lines[i + 1].trimRight();

      if (headerRegex.hasMatch(line) && separatorRegex.hasMatch(next)) {
        headerIndex = i;
        separatorIndex = i + 1;
        break;
      }
    }

    if (headerIndex == null || separatorIndex == null) return null;

    final headers = _splitRow(lines[headerIndex]);
    if (headers.isEmpty) return null;

    final rows = <List<String>>[];
    int lastTableLine = separatorIndex;

    for (int i = separatorIndex + 1; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) break;
      if (!line.contains('|')) break;

      final row = _splitRow(line);
      if (row.isNotEmpty) {
        rows.add(row);
        lastTableLine = i;
      }
    }

    if (rows.isEmpty) return null;

    // Normalize all rows to header length
    for (var row in rows) {
      while (row.length < headers.length) {
        row.add('');
      }
      if (row.length > headers.length) {
        row.removeRange(headers.length, row.length);
      }
    }

    final tableData = rows.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      return map;
    }).toList();

    final tableWidget = Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 400),
      child: SimpleTableWidget(data: tableData),
    );

    return TableParseResult(
      widget: tableWidget,
      startLine: headerIndex,
      endLine: lastTableLine,
    );
  }

  /// Builds a Flutter Table widget from markdown table element
  static Widget buildTable(md.Element tableElement) {
    final children = tableElement.children ?? [];
    
    // Extract headers and rows
    List<String> headers = [];
    List<List<String>> rows = [];
    
    // Find thead or first tr for headers
    md.Element? thead;
    md.Element? tbody;
    
    for (final child in children) {
      if (child is md.Element) {
        if (child.tag == 'thead') {
          thead = child;
        } else if (child.tag == 'tbody') {
          tbody = child;
        } else if (child.tag == 'tr' && headers.isEmpty) {
          // If no thead, first tr is headers
          headers = _extractTableRowCells(child, isHeader: true);
        }
      }
    }
    
    // Extract headers from thead if present
    if (thead != null) {
      final theadRows = (thead.children ?? [])
          .whereType<md.Element>()
          .where((e) => e.tag == 'tr')
          .toList();
      if (theadRows.isNotEmpty) {
        headers = _extractTableRowCells(theadRows.first, isHeader: true);
      }
    }
    
    // Extract rows from tbody or directly from table
    if (tbody != null) {
      final tbodyRows = (tbody.children ?? [])
          .whereType<md.Element>()
          .where((e) => e.tag == 'tr')
          .toList();
      for (final tr in tbodyRows) {
        rows.add(_extractTableRowCells(tr, isHeader: false));
      }
    } else {
      // Extract rows directly from table (skip first if it was used as header)
      final tableRows = children
          .whereType<md.Element>()
          .where((e) => e.tag == 'tr')
          .toList();
      for (int i = headers.isEmpty ? 0 : 1; i < tableRows.length; i++) {
        rows.add(_extractTableRowCells(tableRows[i], isHeader: false));
      }
    }
    
    if (headers.isEmpty && rows.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // If no headers but we have rows, use first row as headers
    if (headers.isEmpty && rows.isNotEmpty) {
      headers = rows.first;
      rows = rows.sublist(1);
    }
    
    if (headers.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Convert to SimpleTableWidget format
    final tableData = rows.map((row) {
      final rowMap = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        final header = headers[i];
        final value = i < row.length ? row[i] : '';
        rowMap[header] = value;
      }
      return rowMap;
    }).toList();
    
    // Use SimpleTableWidget with fixed boundaries
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      constraints: const BoxConstraints(
        maxHeight: 400,
        maxWidth: double.infinity,
      ),
      child: SimpleTableWidget(data: tableData),
    );
  }

  /// Extracts cell text from a table row (tr element)
  static List<String> _extractTableRowCells(md.Element trElement, {required bool isHeader}) {
    final cells = <String>[];
    
    for (final child in trElement.children ?? []) {
      if (child is md.Element && (child.tag == 'th' || child.tag == 'td')) {
        // Recursively extract text to handle nested formatting (bold, italic, etc.)
        final cellText = _extractTextFromElement(child);
        cells.add(ParserUtils.decodeHtmlEntities(cellText).trim());
      }
    }
    
    return cells;
  }

  /// Recursively extracts plain text from an element and its children
  /// This ensures nested formatting (bold, italic, etc.) is properly extracted
  static String _extractTextFromElement(md.Element element) {
    final buffer = StringBuffer();
    
    for (final child in element.children ?? []) {
      if (child is md.Text) {
        buffer.write(child.textContent);
      } else if (child is md.Element) {
        buffer.write(_extractTextFromElement(child));
      }
    }
    
    return buffer.toString();
  }

  /// Parses a markdown table row into a list of cell strings for manual detection
  static List<String> _splitRow(String line) {
    var trimmed = line.trim();
    if (trimmed.isEmpty) return [];

    if (trimmed.startsWith('|')) {
      trimmed = trimmed.substring(1);
    }
    if (trimmed.endsWith('|')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }

    final parts = trimmed.split('|');
    return parts.map((part) {
      var cell = part.trim();
      cell = cell.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '');
      cell = cell.replaceAllMapped(RegExp(r'\*(.*?)\*'), (match) => match.group(1) ?? '');
      cell = cell.replaceAllMapped(RegExp(r'__(.*?)__'), (match) => match.group(1) ?? '');
      cell = cell.replaceAllMapped(RegExp(r'_(.*?)_'), (match) => match.group(1) ?? '');
      return ParserUtils.decodeHtmlEntities(cell);
    }).toList();
  }
}
