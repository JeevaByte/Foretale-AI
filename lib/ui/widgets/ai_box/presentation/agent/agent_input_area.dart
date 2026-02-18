import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/ai_box/state/base_ai_box_provider.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/shared/input_container.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/shared/mode_toggle_button.dart';
import 'package:provider/provider.dart';

class AgentInputArea extends StatefulWidget {
  final ChatDrivingModel drivingModel;

  const AgentInputArea({
    super.key,
    required this.drivingModel,
  });

  @override
  State<AgentInputArea> createState() => _AgentInputAreaState();
}

class _AgentInputAreaState extends State<AgentInputArea> {
  final TextEditingController _responseController = TextEditingController();

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BaseAIBoxProvider>(
      builder: (context, provider, child) {
        final hasText = _responseController.text.trim().isNotEmpty;
        final isEnabled = provider.isConnected && !provider.isLoading && hasText;

        return InputContainer(
          isAgentMode: true,
          responseField: _buildResponseTextField(provider),
          actionRowChildren: [
            ModeToggleButton(drivingModel: widget.drivingModel),
            const Spacer(),
            _buildSendButton(context, provider, isEnabled),
          ],
        );
      },
    );
  }

  Widget _buildSendButton(BuildContext context, BaseAIBoxProvider provider, bool isEnabled) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small);
    final padding = context.spacing(size: SpacingSize.small);
    return CustomIconButton(
      icon: Icons.send_rounded,
      iconSize: iconSize,
      padding: padding,
      tooltip: "Send",
      onPressed: () => _handleSend(provider),
      iconColor: colorScheme.surfaceBright,
      backgroundColor: colorScheme.primary,
      isEnabled: isEnabled,
    );
  }

  Widget _buildResponseTextField(BaseAIBoxProvider provider) {
    final isEnabled = provider.isConnected && !provider.isLoading;
    final padding = context.spacing(size: SpacingSize.small) / 2;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: TextField(
        controller: _responseController,
        enabled: isEnabled,
        maxLines: 5,
        minLines: 1,
        textInputAction: TextInputAction.send,
        textAlignVertical: TextAlignVertical.top,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) {
          if (isEnabled && _responseController.text.trim().isNotEmpty) {
            _handleSend(provider);
          }
        },
        decoration: InputDecoration(
          hintText: "Ask anything about the project...",
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: EdgeInsets.only(top: padding),
          hoverColor: Colors.transparent,
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  void _handleSend(BaseAIBoxProvider provider) {
    final responseText = _responseController.text.trim();

    if (responseText.isEmpty) {
      return;
    }

    if (!provider.isConnected || provider.isLoading) {
      return;
    }

    provider.sendMessage(responseText);
    _clearInput();
  }

  void _clearInput() {
    setState(() {
      _responseController.clear();
    });
  }
}

