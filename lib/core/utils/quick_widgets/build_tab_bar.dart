import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

Widget buildTab(
  BuildContext context, {
  required TabController tabController,
  required List<Widget> tabs,
  required Function(int index, bool isActivateTabs) onTap,
  required bool isActivateTabs,
}) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  final double borderRadius = context.borderRadius;
  final double indicatorWidth = context.indicatorWidth;
  final double fontSize = context.responsiveFontSize(14);

  return Card(
    elevation: isDark ? 0 : 1,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
    child: ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: IgnorePointer(
        ignoring: !isActivateTabs,
        child: TabBar(
          controller: tabController,
          isScrollable: context.isMobile && tabs.length > 2,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: colorScheme.primaryContainer,
              width: indicatorWidth,
            ),
          ),
          dividerColor: Colors.transparent,
          labelStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
          unselectedLabelStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: fontSize,
          ),
          labelColor: isActivateTabs
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.4),
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
          tabs: tabs,
          onTap: (index) => onTap(index, isActivateTabs),
        ),
      ),
    ),
  );
}
