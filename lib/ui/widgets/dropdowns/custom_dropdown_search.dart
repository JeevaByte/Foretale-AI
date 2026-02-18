import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class CustomDropdownSearch extends StatelessWidget {
  final List<String> items;
  final String title;
  final String hintText;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;
  final bool isEnabled;
  final bool showSearchBox;

  const CustomDropdownSearch({
    super.key,
    required this.items,
    required this.hintText,
    required this.onChanged,
    required this.title,
    this.selectedItem,
    required this.isEnabled,
    this.showSearchBox = false,
  });

  static const _borderRadius = BorderRadius.all(Radius.circular(4));
  static const _contentPadding = EdgeInsets.symmetric(vertical: 1, horizontal: 5);
  static const _menuBorderRadius = BorderRadius.all(Radius.circular(8));
  static const _itemPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const _itemHeight = 28.0;
  static const _clearButtonConstraints = BoxConstraints(minWidth: 20, minHeight: 20);
  static const _dropdownButtonConstraints = BoxConstraints(minWidth: 20, minHeight: 20);
  static const _popupConstraints = BoxConstraints(maxHeight: 300);
  
  OutlineInputBorder _baseBorder(ColorScheme colorScheme) => OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: BorderSide(
      color: colorScheme.outline.withValues(alpha: 0.3),
      width: 0.8,
    ),
  );
  
  OutlineInputBorder _focusedBorder(ColorScheme colorScheme) => OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: BorderSide(
      color: colorScheme.primary,
      width: 1.5,
    ),
  );
  
  OutlineInputBorder _enabledBorder(ColorScheme colorScheme) => OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: BorderSide(
      color: colorScheme.outline.withValues(alpha: 0.5),
      width: 0.8,
    ),
  );

  static const _clearButtonPadding = EdgeInsets.all(0);
  static const _dropdownButtonPadding = EdgeInsets.all(0);
  static const _emptyBuilderPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);


  InputDecoration _buildInputDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(10);
    final labelFontSize = context.responsiveFontSize(12);
    
    return InputDecoration(
      labelText: title,
      hintText: hintText,
      hintStyle: theme.textTheme.bodySmall?.copyWith(
        fontSize: fontSize,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        fontSize: labelFontSize,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.transparent,
      border: _baseBorder(colorScheme),
      focusedBorder: _focusedBorder(colorScheme),
      enabledBorder: _enabledBorder(colorScheme),
      contentPadding: _contentPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(10);
    final selectedValue = selectedItem?.trim().isEmpty ?? true ? null : selectedItem;
    final isClearVisible = selectedItem != null && isEnabled;
    final iconSize = context.iconSize(size: IconSize.small);
    
    return DropdownSearch<String>(
      enabled: isEnabled,
      items: items,
      selectedItem: selectedValue,
      onChanged: onChanged,
      validator: (value) => (value == null || value.isEmpty) ? '$title is required.' : null,
      dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: theme.textTheme.bodySmall?.copyWith(
          fontSize: fontSize,
          overflow: TextOverflow.ellipsis,
        ),
        dropdownSearchDecoration: _buildInputDecoration(context),
      ),
      clearButtonProps: ClearButtonProps(
        padding: _clearButtonPadding,
        isVisible: isClearVisible,
        icon: Icon(
          Icons.close,
          size: iconSize * 0.75,
          color: colorScheme.outline,
        ),
        splashRadius: 16,
        splashColor: colorScheme.outline.withValues(alpha: 0.1),
        highlightColor: colorScheme.outline.withValues(alpha: 0.05),
        constraints: _clearButtonConstraints,
      ),
      dropdownButtonProps: DropdownButtonProps(
        padding: _dropdownButtonPadding,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          size: context.iconSize(size: IconSize.medium),
          color: colorScheme.outline,
        ),
        splashRadius: 16,
        splashColor: colorScheme.outline.withValues(alpha: 0.2),
        highlightColor: colorScheme.outline.withValues(alpha: 0.1),
        constraints: _dropdownButtonConstraints,
      ),
      popupProps: PopupProps.menu(
        showSelectedItems: true,
        showSearchBox: showSearchBox,
        fit: FlexFit.loose,
        constraints: _popupConstraints,
        emptyBuilder: (context, searchEntry) => Container(
          padding: _emptyBuilderPadding,
          child: Text(
            'Loading...',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        itemBuilder: (context, item, isSelected) => _buildDropdownItem(context, item, isSelected),
        searchFieldProps: TextFieldProps(
          style: theme.textTheme.bodySmall?.copyWith(fontSize: fontSize),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: theme.textTheme.bodySmall?.copyWith(
              fontSize: fontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            labelStyle: theme.textTheme.bodySmall?.copyWith(
              fontSize: fontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: iconSize,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.spacing(size: SpacingSize.small),
              vertical: context.spacing(size: SpacingSize.small) * 0.75,
            ),
            border: OutlineInputBorder(
              borderRadius: _borderRadius,
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: _focusedBorder(colorScheme),
            enabledBorder: _enabledBorder(colorScheme),
            filled: true,
            fillColor: colorScheme.surface,
          ),
        ),
        menuProps: MenuProps(
          shape: RoundedRectangleBorder(borderRadius: _menuBorderRadius),
          backgroundColor: colorScheme.surface,
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildDropdownItem(BuildContext context, String item, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(12);
    
    return Container(
      padding: _itemPadding,
      height: _itemHeight,
      decoration: BoxDecoration(
        color: isSelected 
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.15),
            width: 0.8,
          ),
        ),
      ),
      child: Text(
        item,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
