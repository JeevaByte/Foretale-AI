import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

/// Shared utilities for message parsing
class ParserUtils {
  static final _unescape = HtmlUnescape();

  /// Decodes HTML entities in text
  static String decodeHtmlEntities(String text) {
    return _unescape.convert(text);
  }

  /// Gets the text color based on user mode and base style
  static Color getTextColor(TextStyle? style, bool isUser) {
    return style?.color ?? (isUser ? Colors.white : Colors.black87);
  }
}

