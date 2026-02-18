import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'dart:convert';

class ResponseTextWidget extends StatelessWidget {
  final String responseText;

  const ResponseTextWidget({
    super.key,
    required this.responseText,
  });

  @override
  Widget build(BuildContext context) {
    final parsedList = _parseListFromString(responseText);
    
    if (parsedList != null) {
      return _buildListResponse(context, parsedList);
    } else {
      return _buildPlainText(context);
    }
  }

  List<String>? _parseListFromString(String text) {
    try {
      final trimmed = text.trim();

      // Check if it's a JSON array
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        final parsed = json.decode(trimmed);
        if (parsed is List) {
          return parsed.map((item) => item.toString()).toList();
        }
      }
      
      // Check if it's a semicolon-separated list
      if (trimmed.contains(';')) {
        final items = trimmed.split(';')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
        if (items.length > 1) {
          return items;
        }
      }
    } catch (e) {
      print("Error parsing list from string: $e");
    }
    return null;
  }

  Widget _buildPlainText(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(14);
    return Text(
      responseText,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: fontSize,
      ),
    );
  }

  Widget _buildListNumber(BuildContext context, int number) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(14);
    return Text(
      '$number. ',
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String item) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(14);
    return Text(
      item,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: fontSize,
      ),
    );
  }

  Widget _buildListResponse(BuildContext context, List<String> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(bottom: index < list.length - 1 ? 8.0 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildListNumber(context, index + 1),
              Expanded(
                child: _buildListItem(context, item),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

