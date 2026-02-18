import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';

class FilePreview extends StatelessWidget {
  final FilePickerResult? filePickerResult;
  final Function(PlatformFile) onRemoveFile;

  const FilePreview({
    super.key,
    required this.filePickerResult,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    if (filePickerResult == null || filePickerResult!.files.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: filePickerResult!.files.map((file) {
          final theme = Theme.of(context);
          final textTheme = theme.textTheme;
          final colorScheme = theme.colorScheme;
          final iconSize = context.iconSize(size: IconSize.small);
          final fontSize = context.responsiveFontSize(11);
          final spacing = context.spacing(size: SpacingSize.small);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(context.borderRadius * 0.67),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getFileIcon(file.name),
                  size: iconSize,
                  color: colorScheme.onSurface,
                ),
                SizedBox(width: spacing),
                Flexible(
                  child: Text(
                    file.name,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: fontSize,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: spacing),
                Text(
                  "(${(file.size / 1024).round()} KB)",
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: fontSize,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(width: spacing),
                CustomIconButton(
                  icon: Icons.close,
                  iconSize: iconSize * 0.83,
                  padding: spacing / 8,
                  tooltip: "Remove file",
                  onPressed: () => onRemoveFile(file),
                  iconColor: colorScheme.secondary,
                  backgroundColor: colorScheme.primary,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }
}

