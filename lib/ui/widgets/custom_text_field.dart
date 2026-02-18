import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator; // Add validator function
  final bool isEnabled;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final EdgeInsets? padding;

  const CustomTextField(
      {super.key,
      required this.controller,
      required this.label,
      this.obscureText = false,
      this.maxLines = 1,
      this.validator, // Add the validator parameter
      required this.isEnabled,
      this.onChanged,
      this.keyboardType,
      this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 1.5;
    final defaultPadding = context.spacing(size: SpacingSize.medium);
    final fontSize = context.responsiveFontSize(14);
    
    return TextFormField(
        enabled: isEnabled,
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: fontSize),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: fontSize),
          filled: true,
          fillColor: Colors.transparent,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          contentPadding: padding ?? EdgeInsets.symmetric(
            vertical: defaultPadding,
            horizontal: defaultPadding,
          ),
          hintText: '',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: fontSize,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        validator: validator,
        onChanged: onChanged);
  }
}

