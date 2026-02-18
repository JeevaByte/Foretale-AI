import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

import 'parsers/block_element_parser.dart';
import 'parsers/parser_utils.dart';
import 'parsers/table_parser.dart';
import 'parsers/text_parser.dart';

/// Simple message parser that decodes HTML entities
class MessageParser extends StatelessWidget {
  final String content;
  final bool isUser;
  final TextStyle baseTextStyle;

  const MessageParser({
    super.key,
    required this.content,
    required this.isUser,
    required this.baseTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final decoded = ParserUtils.decodeHtmlEntities(content);
    if (decoded.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final blockParser = BlockElementParser(
      baseTextStyle: baseTextStyle,
      isUser: isUser,
    );
    final textParser = TextParser(
      baseTextStyle: baseTextStyle,
      isUser: isUser,
    );

    final widgets = <Widget>[];
    final tableResult = TableParser.tryParseMarkdownTable(decoded);

    List<Widget> buildMarkdownWidgets(String text) {
      if (text.trim().isEmpty) return const <Widget>[];
      final document = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored);
      final normalizedText = text.endsWith('\n') ? text : '$text\n';
      final nodes = document.parseLines(const LineSplitter().convert(normalizedText));
      final parsedWidgets = <Widget>[];

      for (final node in nodes) {
        if (node is md.Element) {
          parsedWidgets.add(blockParser.buildElement(node, context));
        } else if (node is md.Text) {
          parsedWidgets.add(textParser.buildTextNode(node));
        }
      }
      return parsedWidgets;
    }

    if (tableResult != null) {
      final lines = decoded.split('\n');
      final before = lines.sublist(0, tableResult.startLine).join('\n');
      final after = tableResult.endLine + 1 < lines.length
          ? lines.sublist(tableResult.endLine + 1).join('\n')
          : '';

      widgets.addAll(buildMarkdownWidgets(before));
      widgets.add(tableResult.widget);
      widgets.addAll(buildMarkdownWidgets(after));
    } else {
      widgets.addAll(buildMarkdownWidgets(decoded));
    }

    if (widgets.isEmpty) {
      return SelectableText(
        decoded,
        style: baseTextStyle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}
