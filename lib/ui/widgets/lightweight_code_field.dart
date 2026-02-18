import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

/// Minimal wrapper around [CodeField] so callers can reuse a consistent editor.
class LightweightCodeField extends StatelessWidget {
  final CodeController controller;
  final Map<String, TextStyle>? styles;
  final TextStyle? textStyle;
  final TextSelectionThemeData? textSelectionTheme;
  final Color? backgroundColor;
  final GutterStyle? gutterStyle;
  final bool readOnly;
  final bool expands;
  final ValueChanged<String>? onChanged;
  final Key? fieldKey;

  const LightweightCodeField({
    super.key,
    required this.controller,
    this.styles,
    this.textStyle,
    this.textSelectionTheme,
    this.backgroundColor,
    this.gutterStyle,
    this.readOnly = false,
    this.expands = false,
    this.onChanged,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = textStyle ?? const TextStyle(fontFamily: 'SourceCodePro', fontSize: 14);
    final effectiveTheme = CodeThemeData(
      styles: styles ??
          {
            'root': effectiveStyle,
            'code': effectiveStyle,
          },
    );

    return CodeTheme(
      data: effectiveTheme,
      child: CodeField(
        key: fieldKey,
        controller: controller,
        background: backgroundColor ?? Colors.transparent,
        textStyle: effectiveStyle,
        textSelectionTheme: textSelectionTheme,
        gutterStyle: gutterStyle,
        readOnly: readOnly,
        expands: expands,
        onChanged: onChanged,
      ),
    );
  }
}

