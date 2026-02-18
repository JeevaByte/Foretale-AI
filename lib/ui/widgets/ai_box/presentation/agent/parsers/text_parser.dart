import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'parser_utils.dart';

/// Parser for plain text nodes
class TextParser {
  final TextStyle baseTextStyle;
  final bool isUser;

  const TextParser({
    required this.baseTextStyle,
    required this.isUser,
  });

  /// Builds a widget from a text node
  Widget buildTextNode(md.Text node) {
    return SelectableText(
      ParserUtils.decodeHtmlEntities(node.textContent),
      style: baseTextStyle,
    );
  }
}

