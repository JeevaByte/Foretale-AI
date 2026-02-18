import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'parser_utils.dart';

/// Parser for inline markdown elements (bold, italic, code, links)
class InlineElementParser {
  final TextStyle baseTextStyle;
  final bool isUser;

  const InlineElementParser({
    required this.baseTextStyle,
    required this.isUser,
  });

  /// Builds TextSpans from markdown elements for RichText
  List<TextSpan> buildTextSpansFromElement(
    md.Element element,
    TextStyle baseStyle,
    Color textColor,
  ) {
    final List<TextSpan> spans = <TextSpan>[];
    final children = element.children ?? [];

    switch (element.tag) {
      case 'strong':
      case 'b':
        for (final child in children) {
          if (child is md.Text) {
            spans.add(TextSpan(
              text: ParserUtils.decodeHtmlEntities(child.textContent),
              style: baseStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ));
          } else if (child is md.Element) {
            spans.addAll(buildTextSpansFromElement(child, baseStyle, textColor));
          }
        }
        break;

      case 'em':
      case 'i':
        for (final child in children) {
          if (child is md.Text) {
            spans.add(TextSpan(
              text: ParserUtils.decodeHtmlEntities(child.textContent),
              style: baseStyle.copyWith(
                fontStyle: FontStyle.italic,
                color: textColor,
              ),
            ));
          } else if (child is md.Element) {
            spans.addAll(buildTextSpansFromElement(child, baseStyle, textColor));
          }
        }
        break;

      case 'code':
        spans.add(TextSpan(
          text: ParserUtils.decodeHtmlEntities(element.textContent),
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            color: textColor,
          ),
        ));
        break;

      case 'a':
        // Note: This method doesn't have BuildContext, so we use a default color
        // The actual color will be set by the caller if needed
        spans.add(TextSpan(
          text: ParserUtils.decodeHtmlEntities(element.textContent),
          style: baseStyle.copyWith(
            color: isUser 
                ? Colors.white.withValues(alpha: 0.9) 
                : Colors.blue, // Default link color, will be overridden by theme if context available
            decoration: TextDecoration.underline,
          ),
        ));
        break;

      default:
        for (final child in children) {
          if (child is md.Text) {
            spans.add(TextSpan(
              text: ParserUtils.decodeHtmlEntities(child.textContent),
              style: baseStyle.copyWith(color: textColor),
            ));
          } else if (child is md.Element) {
            spans.addAll(buildTextSpansFromElement(child, baseStyle, textColor));
          }
        }
    }

    return spans;
  }

  /// Builds inline text widgets from nodes
  Widget buildInlineNodes(
    List<md.Node> nodes,
    TextStyle effectiveStyle,
    Color textColor,
  ) {
    if (nodes.isEmpty) return const SizedBox.shrink();

    final textSpans = <TextSpan>[];
    
    for (final node in nodes) {
      if (node is md.Text) {
        textSpans.add(TextSpan(
          text: ParserUtils.decodeHtmlEntities(node.textContent),
          style: effectiveStyle.copyWith(color: textColor),
        ));
      } else if (node is md.Element) {
        textSpans.addAll(buildTextSpansFromElement(node, effectiveStyle, textColor));
      }
    }

    if (textSpans.length == 1 && textSpans.first.style == effectiveStyle) {
      // Simple text, use SelectableText widget
      return SelectableText(
        textSpans.first.text ?? '',
        style: textSpans.first.style,
      );
    }

    return SelectableText.rich(
      TextSpan(children: textSpans),
    );
  }
}

