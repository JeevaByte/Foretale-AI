import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/sql.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/lightweight_code_field.dart';
import 'inline_element_parser.dart';
import 'table_parser.dart';
import 'parser_utils.dart';

/// Parser for block markdown elements (headings, paragraphs, lists, blockquotes, etc.)
class BlockElementParser {
  final TextStyle baseTextStyle;
  final bool isUser;
  final InlineElementParser inlineParser;

  BlockElementParser({
    required this.baseTextStyle,
    required this.isUser,
  }) : inlineParser = InlineElementParser(
          baseTextStyle: baseTextStyle,
          isUser: isUser,
        );

  Widget _buildLinkElement(BuildContext context, md.Element element) {
    final colorScheme = Theme.of(context).colorScheme;
    return SelectableText(
      ParserUtils.decodeHtmlEntities(element.textContent),
      style: baseTextStyle.copyWith(
        color: isUser 
            ? Colors.white.withValues(alpha: 0.9) 
            : colorScheme.secondary,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _buildBlockquoteElement(BuildContext context, List<md.Node> children, Color textColor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isUser 
                ? Colors.white.withValues(alpha: 0.9) 
                : colorScheme.secondary,
            width: 3,
          ),
        ),
      ),
      child: inlineParser.buildInlineNodes(
        children,
        baseTextStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: textColor.withValues(alpha: 0.8),
        ),
        textColor,
      ),
    );
  }

  /// Builds Flutter widgets from markdown elements
  Widget buildElement(md.Element element, BuildContext context) {
    final textColor = ParserUtils.getTextColor(baseTextStyle, isUser);
    final children = element.children ?? [];
    
    switch (element.tag) {
      case 'p':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: inlineParser.buildInlineNodes(
            children,
            baseTextStyle,
            textColor,
          ),
        );

      case 'h1':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: inlineParser.buildInlineNodes(
            children,
            baseTextStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textColor,
          ),
        );

      case 'h2':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: inlineParser.buildInlineNodes(
            children,
            baseTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textColor,
          ),
        );

      case 'h3':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: inlineParser.buildInlineNodes(
            children,
            baseTextStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textColor,
          ),
        );

      case 'h4':
      case 'h5':
      case 'h6':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: inlineParser.buildInlineNodes(
            children,
            baseTextStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textColor,
          ),
        );

      case 'strong':
      case 'b':
        return inlineParser.buildInlineNodes(
          children,
          baseTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textColor,
        );

      case 'em':
      case 'i':
        return inlineParser.buildInlineNodes(
          children,
          baseTextStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: textColor,
          ),
          textColor,
        );

      case 'code':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isUser 
                ? Colors.white.withValues(alpha: 0.2) 
                : Colors.black.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: SelectableText(
            ParserUtils.decodeHtmlEntities(element.textContent),
            style: baseTextStyle.copyWith(
              fontFamily: 'monospace',
              color: textColor,
            ),
          ),
        );

      case 'pre':
        return SqlCodeBlock(
          code: ParserUtils.decodeHtmlEntities(element.textContent),
          baseTextStyle: baseTextStyle,
          isUser: isUser,
        );

      case 'ul':
      case 'ol':
        return Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children
                .whereType<md.Element>()
                .where((e) => e.tag == 'li')
                .toList()
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final li = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      element.tag == 'ol' ? '${index + 1}. ' : '• ',
                      style: baseTextStyle.copyWith(color: textColor),
                    ),
                    Expanded(
                      child: inlineParser.buildInlineNodes(
                        li.children ?? [],
                        baseTextStyle,
                        textColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );

      case 'a':
        return _buildLinkElement(context, element);

      case 'blockquote':
        return _buildBlockquoteElement(context, children, textColor);

      case 'hr':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 1,
          color: textColor.withValues(alpha: 0.3),
        );

      case 'table':
        return TableParser.buildTable(element);

      default:
        return inlineParser.buildInlineNodes(children, baseTextStyle, textColor);
    }
  }
}

class SqlCodeBlock extends StatefulWidget {
  final String code;
  final TextStyle baseTextStyle;
  final bool isUser;

  const SqlCodeBlock({
    super.key,
    required this.code,
    required this.baseTextStyle,
    required this.isUser,
  });

  @override
  State<SqlCodeBlock> createState() => _SqlCodeBlockState();
}

class _SqlCodeBlockState extends State<SqlCodeBlock> {
  late CodeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CodeController(
      text: widget.code.trimRight(),
      language: sql,
    );
  }

  @override
  void didUpdateWidget(SqlCodeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code) {
      _controller.text = widget.code.trimRight();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, TextStyle> _buildThemeStyles(BuildContext context, Color textColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      backgroundColor: colorScheme.surface,
      color: textColor,
    ) ?? TextStyle(
      backgroundColor: colorScheme.surface,
      color: textColor,
    );

    return {
      ...monokaiSublimeTheme,
      'root': baseStyle,
      'code': baseStyle,
    };
  }

  double _editorHeight() {
    final lineCount = widget.code.split('\n').length;
    final estimated = lineCount * 20.0;
    return math.max(140, math.min(320, estimated));
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.code.trim()));
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = ParserUtils.getTextColor(
      widget.baseTextStyle,
      widget.isUser,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.primary;
    final editorHeight = _editorHeight();
    final borderRadius = context.borderRadius;
    final padding = context.spacing(size: SpacingSize.medium);
    final margin = context.spacing(size: SpacingSize.small) * 0.75;
    final iconSize = context.iconSize(size: IconSize.small);
    final iconPadding = context.spacing(size: SpacingSize.small) / 2;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: margin),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: SizedBox(
              height: editorHeight,
              child: LightweightCodeField(
                controller: _controller,
                readOnly: true,
                backgroundColor: colorScheme.primary,
                styles: _buildThemeStyles(context, textColor),
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ) ?? TextStyle(color: colorScheme.onPrimary),
                gutterStyle: GutterStyle.none,
                expands: true,
              ),
            ),
          ),
          Positioned(
            top: iconPadding,
            right: iconPadding,
            child: IconButton(
              icon: Icon(Icons.copy, size: iconSize),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 16,
              color: colorScheme.onPrimary,
              tooltip: 'Copy code',
              onPressed: _copyCode,
            ),
          ),
        ],
      ),
    );
  }
}

