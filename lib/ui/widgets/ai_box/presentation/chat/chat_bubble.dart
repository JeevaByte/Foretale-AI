import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_attachment_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/ai_box/business/chat/input_area_service.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/chat/response_text_widget.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';

class ChatBubble extends StatelessWidget {
  final InquiryResponse inquiryResponse;
  final ChatDrivingModel drivingModel;
  final UserDetailsModel userDetailsModel;

  const ChatBubble({
    super.key,
    required this.inquiryResponse,
    required this.drivingModel,
    required this.userDetailsModel,
  });

  @override
  Widget build(BuildContext context) {
    final responseId = inquiryResponse.responseId;
    final isAiMagicResponse = inquiryResponse.isAiMagicResponse;
    final isUser = (isAiMagicResponse == 1) ? false : inquiryResponse.responseByMachineId == userDetailsModel.getUserMachineId;
    final responseText = inquiryResponse.responseText;
    final responseDate = inquiryResponse.responseDate;
    final attachments = inquiryResponse.attachments;
    final userId = userDetailsModel.getUserMachineId ?? 'Unknown';
    final userName = userDetailsModel.getName ?? 'Unknown';

    return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: _buildRegularResponse(
          context, 
          responseText, 
          responseDate, 
          attachments, 
          isAiMagicResponse, 
          responseId, 
          isUser, 
          userId, 
          userName));
  }

  Widget _buildRegularResponse(
    BuildContext context, 
    String responseText,
    String responseDate,
    List<InquiryAttachment> attachments,
    int isAiMagicResponse,
    int responseId,
    bool isUser,
    String userId,
    String userName) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 1.67; // 20px
    final smallRadius = context.borderRadius * 0.5; // 6px
    final padding = context.spacing(size: SpacingSize.medium) * 0.94; // 15px
    
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          color: isUser ? colorScheme.surface.withValues(alpha: 0.8) : colorScheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
            bottomLeft: isUser ? Radius.circular(borderRadius) : Radius.circular(smallRadius),
            bottomRight: isUser ? Radius.circular(smallRadius) : Radius.circular(borderRadius),
          ),
          border: Border.all(
            color: isUser ? colorScheme.primary.withValues(alpha: 0.8) : colorScheme.primary.withValues(alpha: 0.4),
            width: 1
          ),
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
          // First row: User name, date, and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateText(context, responseDate),
              const SizedBox(width: 8),
              inquiryResponse.isResponseDeleteAvailable ? _buildDeleteButton(context, responseId) : const SizedBox.shrink(),

          ],),
          const SizedBox(height: 2),
          _buildUserNameSection(context, isUser, isAiMagicResponse, userName),
          // Second row: Text content
          const SizedBox(height: 2),
          ResponseTextWidget(responseText: responseText),
          const SizedBox(height: 8),
          // Third row: Attachments
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._buildAttachments(context, attachments, isUser),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildDateText(BuildContext context, String responseDate) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(8);
    return Text(
      responseDate.split(' ')[0],
      style: textTheme.bodySmall?.copyWith(
        fontSize: fontSize,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildUserNameSection(BuildContext context, bool isUser, int isAiMagicResponse, String userName) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(14);
    return Column(
      children: [
        Text(
          isUser?'': (isAiMagicResponse == 1)? 'AI Assistant' : userName,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        Divider(color: colorScheme.primary, height: 0.5),
      ],
    );
  }

  List<Widget> _buildAttachments(BuildContext context, List<InquiryAttachment> attachments, bool isUser) {
    return attachments.map((attachment) {
      return Container(
        padding: const EdgeInsets.only(bottom: 2, right: 8, left: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            attachment.isDownloadAvailable ? _buildDownloadButton(context, attachment) : const SizedBox.shrink(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAttachmentFileName(context, attachment.fileName),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }


  Widget _buildAttachmentFileName(BuildContext context, String fileName) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(10);
    return Text(
      fileName,
      style: textTheme.bodySmall?.copyWith(
        fontSize: fontSize,
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusIcon(BuildContext context, String tooltip, IconData icon, Function() onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small);
    final padding = context.spacing(size: SpacingSize.small) / 4;
    return CustomIconButton(
      icon: icon,
      iconSize: iconSize,
      padding: padding,
      tooltip: tooltip,
      onPressed: onPressed,
      iconColor: colorScheme.primary,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
    );
  }


  Widget _buildDeleteButton(BuildContext context, int responseId) {
    return _buildStatusIcon(
      context,
      "Delete",
      Icons.delete_rounded,
      () {InputAreaService.deleteResponse(context, responseId, drivingModel);},
    );
  }

  Widget _buildDownloadButton(BuildContext context, InquiryAttachment attachment) {
    return _buildStatusIcon(
      context,
      "Download",
      Icons.download,
      () => InputAreaService.handleDownload(context, attachment),
    );
  }
}

