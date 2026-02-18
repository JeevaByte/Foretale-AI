import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/columns_model.dart';
import 'package:foretale_application/models/file_upload_summary_model.dart';
import 'package:foretale_application/ui/widgets/dropdowns/custom_dropdown_search.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';

class ColumnMappingScreen extends StatefulWidget {
  final VoidCallback onConfirm;

  const ColumnMappingScreen({super.key, required this.onConfirm});

  @override
  State<ColumnMappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends State<ColumnMappingScreen> {
  final String _currentFileName = "column_mapping_screen.dart";

  late ColumnsModel _columnsModel;
  late UploadSummaryModel _uploadSummaryModel;

  @override
  void initState() {
    super.initState();
    _columnsModel = Provider.of<ColumnsModel>(context, listen: false);
    _uploadSummaryModel = Provider.of<UploadSummaryModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColumnsModel>(
      builder: (context, model, _) {
        if (model.getIsPageLoading) {
          return buildLoadingState(context);
        }

        if (model.sourceFields.isEmpty) {
          return const EmptyState(
            title: "No source fields found",
            subtitle: "Please upload a file to get started",
            icon: Icons.file_upload_outlined,
          );
        }

        if (model.destinationFieldMap.isEmpty) {
          return const EmptyState(
            title: "No target fields found",
            subtitle: "Please try again later or contact support",
            icon: Icons.file_upload_outlined,
          );
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildActionButtons(context, model),
              const SizedBox(height: 20),
              Expanded(
                child: CustomContainer(
                  title: "Field Mapping: ${_uploadSummaryModel.getActiveFileUploadSelectionName} → ${_uploadSummaryModel.getActiveTableSelectionName}",
                  child: SingleChildScrollView(
                    child: buildMappingRows(context, model),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ColumnsModel model) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomIconButton(
          iconSize: iconSize,
          onPressed: () => _confirmAndUpload(),
          icon: Icons.save_rounded,
          tooltip: 'Save Mappings and Confirm Upload',
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
          isProcessing: model.getIsUpdatingFileUpload,
        )
      ],
    );
  }

  Widget _buildMappingHeader(BuildContext context) {
    final theme = Theme.of(context);
    final padding = context.cardPadding;
    final borderRadius = context.borderRadius * 0.67;
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: padding * 0.75, horizontal: padding),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "Source Fields",
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Target Fields",
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMappingRow(BuildContext context, String fieldName, String type, int maxLength, List<dynamic> samples, String? currentMapping, ColumnsModel model) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final padding = context.cardPadding;
    final borderRadius = context.borderRadius * 0.67;
    final spacing = context.spacing(size: SpacingSize.small);
    final iconSize = context.iconSize(size: IconSize.small) * 1.2;
    
    return Container(
      margin: EdgeInsets.only(bottom: spacing * 0.625),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: currentMapping != null 
              ? colorScheme.primary 
              : colorScheme.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          if (currentMapping != null) ...[
            Icon(
              Icons.check_circle,
              size: iconSize,
              color: Colors.green.shade500,
            ),
          ] else ...[
            Icon(
              Icons.cancel,
              size: iconSize,
              color: Colors.red.shade500,
            ),
          ],
          SizedBox(width: spacing * 2.5),
          // Source field info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: spacing / 2),
                Text(
                  fieldName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                    fontSize: context.responsiveFontSize(14),
                  ),
                ),
                SizedBox(height: spacing / 4),
                Text(
                  '$type • $maxLength chars',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: context.responsiveFontSize(10),
                    color: colorScheme.primary,
                  ),
                ),
                if (samples.isNotEmpty) ...[
                  SizedBox(height: spacing / 4),
                  Text(
                    'Samples: ${samples.join(', ')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: context.responsiveFontSize(9),
                      color: colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: spacing * 6.25),
          // Target field dropdown with description
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdownSearch(
                  items: model.destinationFieldMap.keys.toList(),
                  selectedItem: currentMapping,
                  title: '',
                  isEnabled: true,
                  onChanged: (value) {
                    if (value == null || value.isEmpty) {
                      model.removeActiveSelectedMappings(fieldName);
                    } else {
                      model.removeActiveSelectedMappings(fieldName);
                      model.addActiveSelectedMappings(value, fieldName);
                    }
                  },
                  hintText: "Select target field",
                  showSearchBox: true,
                ),
                SizedBox(height: spacing / 2),
                Text(
                  currentMapping != null 
                      ?  model.destinationFieldMap[currentMapping] ?? "No description available"
                      : "Select a target field to see its description",
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMappingRows(BuildContext context, ColumnsModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        _buildMappingHeader(context),
        SizedBox(height: context.spacing(size: SpacingSize.small)),
        // Mapping rows
        ...model.sourceFieldInfo.map<Widget>((column) {
          final fieldName = column['name'];
          final metadata = column['metadata'] ?? {};
          final type = metadata['type'] ?? 'Unknown';
          final maxLength = metadata['maxLength'] ?? 0;
          final samples = metadata['sampleValues'];
          
          // Find current mapping for this source field
          final currentMapping = model.activeSelectedMappings.entries
              .where((entry) => entry.value == fieldName)
              .map((entry) => entry.key)
              .firstOrNull;

          return _buildMappingRow(context, fieldName, type, maxLength, samples, currentMapping, model);
        }),
      ],
    );
  }

  Future<void> _handleMappingConfirm() async {
    try {
      if (_columnsModel.activeSelectedMappings.isEmpty) {
        if (!mounted) return;
        SnackbarMessage.showErrorMessage(context, "Please select at least one mapping.");
        return;
      }

      _columnsModel.setIsUpdatingFileUpload = true;

      final dbCompatibleMappings = _createDbCompatibleMappings();
      final jsonString = jsonEncode(dbCompatibleMappings);
      await _columnsModel.updateFileUpload(context, jsonString);

      if (!mounted) return;
      SnackbarMessage.showSuccessMessage(context, "Mappings are saved successfully");
    } catch (e, errorStackTrace) {
      if (!mounted) return;
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_handleMappingConfirm");
    } finally {
      if (mounted) {
        _columnsModel.setIsUpdatingFileUpload = false;
      }
    } 
  }

  void _confirmAndUpload() async {
    try {
      await _handleMappingConfirm();
      if (mounted) {
        widget.onConfirm();
      }
    } catch (e, errorStackTrace) {
      if (!mounted) return;
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_confirmAndUpload");
    }
  }

  Map<String, String?> _createDbCompatibleMappings() {
    return {
      for (var entry in _columnsModel.technicalFieldMap.entries)
        _columnsModel.technicalFieldMap[entry.key]!: _columnsModel.activeSelectedMappings[entry.key]
    };
  }

  Map<String, String?> _createUiCompatibleMappings() {
    return {
      for (var entry in _columnsModel.technicalFieldMap.entries)
        if (_columnsModel.columnMappings[entry.value] != null)
          entry.key: _columnsModel.columnMappings[entry.value]!
    };
  }

  Future<void> _loadPage() async {
    try {
      if (!mounted) return;
      _columnsModel.setIsPageLoading = true;
      await _columnsModel.fetchColumnsByTable(context);
      await _columnsModel.fetchColumnsCsvDetails(context);

      final uiCompatibleMappings = _createUiCompatibleMappings();

      if (!mounted) return;
      _columnsModel.activeSelectedMappings = uiCompatibleMappings;
    } catch (e, errorStackTrace) {
      if (!mounted) return;
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage");
    } finally {
      if (mounted) {
        _columnsModel.setIsPageLoading = false;
      }
    }
  }
}

