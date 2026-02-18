import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/ai_box/business/chat/input_area_service.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/shared/input_container.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/shared/file_preview.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/shared/mode_toggle_button.dart';
import 'package:provider/provider.dart';

class ChatInputArea extends StatefulWidget {
  final ChatDrivingModel drivingModel;

  const ChatInputArea({
    super.key,
    required this.drivingModel,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final String _currentFileName = 'ChatInputArea.dart';
  final TextEditingController _responseController = TextEditingController();
  FilePickerResult? _filePickerResult;
  late final InputAreaService _inputAreaService;
  late UserDetailsModel _userDetailsModel;

  @override
  void initState() {
    super.initState();
    _userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    _inputAreaService = InputAreaService();
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _responseController.text.trim().isNotEmpty;

    return InputContainer(
      isAgentMode: false,
      filePreview: FilePreview(
        filePickerResult: _filePickerResult,
        onRemoveFile: _handleRemoveFile,
      ),
      responseField: _buildResponseTextField(),
      actionRowChildren: [
        ModeToggleButton(drivingModel: widget.drivingModel),
        const SizedBox(width: 12),
        _buildAttachButton(context),
        const SizedBox(width: 8),
        const Spacer(),
        _buildSendButton(context, hasText),
      ],
    );
  }

  Widget _buildAttachButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 1.2;
    final padding = context.spacing(size: SpacingSize.small) * 0.75;
    return CustomIconButton(
      icon: Icons.attach_file_rounded,
      iconSize: iconSize,
      padding: padding,
      tooltip: "Attach File",
      onPressed: _pickFile,
      iconColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      borderWidth: 0.5,
    );
  }

  Widget _buildSendButton(BuildContext context, bool hasText) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 1.2;
    final padding = context.spacing(size: SpacingSize.small) * 0.75;
    return CustomIconButton(
      icon: Icons.send_rounded,
      iconSize: iconSize,
      padding: padding,
      tooltip: "Send",
      onPressed: _handleSend,
      iconColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.primary,
      isEnabled: hasText,
      borderWidth: 0,
    );
  }

  Widget _buildResponseTextField() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final padding = context.spacing(size: SpacingSize.small) / 2;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: TextField(
        controller: _responseController,
        maxLines: 5,
        minLines: 1,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Add notes, clarifications, or questions...",
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: EdgeInsets.zero,
        ),
        style: textTheme.bodyMedium,
      ),
    );
  }

  void _handleRemoveFile(PlatformFile file) {
    setState(() {
      _filePickerResult = _inputAreaService.removeFile(_filePickerResult, file);
    });
  }

  void _handleSend() {
    final responseText = _responseController.text.trim();
    final hasFiles = _filePickerResult?.files.isNotEmpty ?? false;

    if (responseText.isEmpty && !hasFiles) {
      return;
    }

    _inputAreaService.handleSend(
      context: context,
      drivingModel: widget.drivingModel,
      responseText: responseText,
      userId: _userDetailsModel.getUserMachineId!,
      filePickerResult: _filePickerResult,
      clearInputAndFiles: _clearInputAndFiles,
      requestPath: _currentFileName,
    );
  }

  void _clearInputAndFiles() {
    setState(() {
      _responseController.clear();
      _filePickerResult = null;
    });
  }

  Future<void> _pickFile() async {
    final result = await _inputAreaService.pickFile(
      context: context,
      currentResult: _filePickerResult,
      requestPath: _currentFileName,
    );
    if (!mounted) return;
    setState(() {
      _filePickerResult = result;
    });
  }
}

