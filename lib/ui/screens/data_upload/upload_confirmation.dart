import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/ecs/ecs_task_service.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/columns_model.dart';
import 'package:foretale_application/models/enums/upload_status_enum.dart';
import 'package:foretale_application/models/file_upload_summary_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';

class UploadConfirmationPage extends StatefulWidget {
  const UploadConfirmationPage({
    super.key, 
    required this.onConfirm,
    this.pollingController,
    this.onStartPolling,
  });
  final VoidCallback onConfirm;
  final ChangeNotifier? pollingController;
  final VoidCallback? onStartPolling;

  @override
  State<UploadConfirmationPage> createState() => _UploadConfirmationPageState();
}

class _UploadConfirmationPageState extends State<UploadConfirmationPage> {
  final String _currentFileName = "upload_confirmation.dart";

  late ColumnsModel _columnsModel;
  late UploadSummaryModel _uploadSummaryModel;
  late UserDetailsModel _userDetailsModel;

  @override
  void initState() {
    super.initState();
    _columnsModel = Provider.of<ColumnsModel>(context, listen: false);
    _uploadSummaryModel = Provider.of<UploadSummaryModel>(context, listen: false);
    _userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColumnsModel>(
      builder: (context, model, _) {
        if (model.getIsPageLoading) {
          return buildLoadingState(context);
        }

        if (model.activeSelectedMappings.isEmpty) {
          return const EmptyState(
            title: "No mappings found",
            subtitle: "Please go back and configure column mappings",
            icon: Icons.map_outlined,
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
                  title: "Upload Confirmation: ${_uploadSummaryModel.getActiveFileUploadSelectionName} → ${_uploadSummaryModel.getActiveTableSelectionName}",
                  child: SingleChildScrollView(
                    child: _buildConfirmationContent(context, model),
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
          onPressed: () => _startUpload(),
          icon: Icons.upload_rounded,
          tooltip: 'Confirm and Start Upload',
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
          isProcessing: model.getIsInitiatingUpload,
        )
      ],
    );
  }

  Widget _buildMappingsHeader(BuildContext context, ColumnsModel model) {
    final theme = Theme.of(context);
    final spacing = context.spacing(size: SpacingSize.small);
    return Row(
      children: [
        Text(
          'Column Mappings',
          style: theme.textTheme.bodyMedium,
        ),
        SizedBox(width: spacing),
        Text(
          '(${model.activeSelectedMappings.length})',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildMappingItem(BuildContext context, String sourceField, String targetField) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = context.spacing(size: SpacingSize.medium);
    final borderRadius = context.borderRadius * 0.67;
    
    return Container(
      margin: EdgeInsets.only(bottom: spacing * 0.625),
      padding: EdgeInsets.all(context.spacing(size: SpacingSize.small) / 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.primary,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: context.iconSize(size: IconSize.small) * 1.2,
            color: Colors.green.shade500,
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$sourceField → $targetField',
                  style: theme.textTheme.bodyMedium,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationContent(BuildContext context, ColumnsModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 12),
        
        // Mappings header
        _buildMappingsHeader(context, model),
        SizedBox(height: context.spacing(size: SpacingSize.medium)),
        
        // Mappings list
        _buildMappingsList(context, model),
      ],
    );
  }

  Widget _buildMappingsList(BuildContext context, ColumnsModel model) {
    return Column(
      children: model.activeSelectedMappings.entries.map<Widget>((entry) {
        final targetField = entry.key;
        final sourceField = entry.value;
        
        return _buildMappingItem(context, sourceField ?? '', targetField);
      }).toList(),
    );
  }

  void _startUpload() async{
    try {
      _columnsModel.setIsInitiatingUpload = true;
      final payload = {
        'user_id': _userDetailsModel.getUserMachineId,
        'file_upload_id': _uploadSummaryModel.activeFileUploadId.toString(),
      };
      //update the file upload status to uploading
      _uploadSummaryModel.updateFileUploadStatus(
        context,
        _uploadSummaryModel.activeFileUploadId,
        _uploadSummaryModel.getActiveTableSelectionName,
        UploadStatus.pending,
        "Data upload initiated successfully.",
        "0"
      );

      await ECSTaskService().invokeCSVUploadTask(csvUploadPayload: payload);

      if (!mounted) return;
      SnackbarMessage.showSuccessMessage(context,"Data upload initiated successfully.");

      //wait for 1 second
      await Future.delayed(const Duration(seconds: 1)).then((value) {
        // Start polling if callback is provided
        if (widget.onStartPolling != null) {
          widget.onStartPolling!();
        }
        //navigate to the first tab
        widget.onConfirm();
      });
      
    } catch (e, errorStackTrace) {
      if (!mounted) return;
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_startUpload");
    } finally {
      if (mounted) {
        _columnsModel.setIsInitiatingUpload = false;
      }
    }
  }
}
