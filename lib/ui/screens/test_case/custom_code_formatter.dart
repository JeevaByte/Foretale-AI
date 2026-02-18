import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/sql.dart';

import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';

class CustomCodeFormatter extends StatefulWidget {
  final String initialCode;
  final bool isCodeRunning;
  final Function(String)? onCodeChanged;
  final double? height;
  final double? width;
  final String theme;
  final VoidCallback? onSaveQuery;
  final VoidCallback? onRunQuery;
  final bool showSaveRunButtons;
  final bool showValidationButton;
  final bool isReadOnly;

  const CustomCodeFormatter({
    super.key,
    this.isCodeRunning = false,
    required this.initialCode,
    this.onCodeChanged,
    this.height,
    this.width,
    this.theme = 'monokai',
    this.onSaveQuery,
    this.onRunQuery,
    this.showSaveRunButtons = false,
    this.showValidationButton = true,
    this.isReadOnly = false,

  });

  @override
  State<CustomCodeFormatter> createState() => _CustomCodeFormatterState();
}

class _CustomCodeFormatterState extends State<CustomCodeFormatter> {
  late CodeController _codeController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.initialCode,
      language: sql,
    );
  }

  @override
  void didUpdateWidget(CustomCodeFormatter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCode != widget.initialCode) {
      _codeController.text = widget.initialCode;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Map<String, TextStyle> _getThemeStyles(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseTheme = widget.theme.toLowerCase() == 'github' 
        ? githubTheme 
        : monokaiSublimeTheme;

    return {
      ...baseTheme,
      'root': TextStyle(
        backgroundColor: colorScheme.surface,
        color: colorScheme.onSurface,
      ),
      'code': TextStyle(
        backgroundColor: colorScheme.surface,
        color: colorScheme.onSurface,
      ),
    };
  }

  void _onCodeChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {

      if (widget.onCodeChanged != null && value.isNotEmpty) {
        widget.onCodeChanged?.call(value.trim());
      }

    });
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(14);
    final iconSize = context.iconSize(size: IconSize.small) * 1.125;
    final spacing = context.spacing(size: SpacingSize.small) / 2;
    final padding = context.spacing(size: SpacingSize.small);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: spacing),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Code Editor', 
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: fontSize),
            ),
          ),
          
          if (widget.showSaveRunButtons) ...[
            SizedBox(width: spacing),
            CustomIconButton(
              icon: Icons.save,
              onPressed: widget.onSaveQuery ?? () {},
              tooltip: 'Save',
              iconSize: iconSize,
              isEnabled: widget.isCodeRunning,
              iconColor: colorScheme.primary,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
            ),
            SizedBox(width: spacing),
            CustomIconButton(
              icon: Icons.play_arrow,
              onPressed: widget.onRunQuery ?? () {},
              tooltip: 'Save & Run',
              iconSize: iconSize,
              isEnabled: widget.isCodeRunning,
              iconColor: colorScheme.primary,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditorContainer() {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = context.borderRadius;
    final padding = context.cardPadding * 1.5;
    
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: _buildCodeField(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(14);
    
    return CodeTheme(
      data: CodeThemeData(styles: _getThemeStyles(context)),
      child: CodeField(
        key: ValueKey(widget.initialCode),
        background: Colors.transparent,
        controller: _codeController,
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: fontSize,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: colorScheme.onPrimary,
          selectionColor: colorScheme.primary.withValues(alpha: 0.3),
          selectionHandleColor: colorScheme.primary,
        ),
        gutterStyle: GutterStyle(
          textStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        readOnly: widget.isReadOnly,
        onChanged: widget.isReadOnly ? null : _onCodeChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildEditorContainer();
  }
}
