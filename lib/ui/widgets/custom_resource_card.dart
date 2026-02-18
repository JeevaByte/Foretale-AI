import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class ResourceCard extends StatelessWidget {
  final String title;
  final String url;

  const ResourceCard({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = context.spacing(size: SpacingSize.medium);
    final borderRadius = context.borderRadius * 1.5;
    final iconSize = context.iconSize(size: IconSize.small);
    final titleFontSize = context.responsiveFontSize(14);
    final urlFontSize = context.responsiveFontSize(12);
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: spacing,
        horizontal: context.spacing(size: SpacingSize.small) / 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // You can use url_launcher package to open the URL here
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing,
              vertical: spacing * 0.875,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(spacing / 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Icon(
                    Icons.link_rounded,
                    color: colorScheme.primary,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: titleFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (url.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: spacing / 8),
                          child: Text(
                            url,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: urlFontSize,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: spacing / 2),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing * 0.75,
                      vertical: spacing / 2,
                    ),
                    child: Text(
                      "Open",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}