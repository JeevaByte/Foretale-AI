import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class ProjectHeaderSection extends StatelessWidget {
  final String projectName;
  final String sectionTitle;
  final EdgeInsetsGeometry? padding;

  const ProjectHeaderSection({
    super.key,
    required this.projectName,
    required this.sectionTitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing(size: SpacingSize.medium);
    final fontSize = context.responsiveFontSize(16);
    final subFontSize = context.responsiveFontSize(14);
    
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.only(left: spacing, top: spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(projectName.isNotEmpty)
          Text(
            projectName.toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          if(sectionTitle.isNotEmpty && projectName.isNotEmpty)
          Text(
            " | ",
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            sectionTitle.toUpperCase(),
            style: projectName.isEmpty
                ? theme.textTheme.titleMedium?.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  )
                : theme.textTheme.titleSmall?.copyWith(
                    fontSize: subFontSize,
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );
  }
}
