//core
import 'package:flutter/widgets.dart';
import 'package:foretale_application/core/utils/responsive.dart';

class AIAssistantWideLayout extends StatelessWidget {
  final Widget conversationPanel;
  final Widget sidePanel;
  final int sidePanelFlex;
  final int conversationPanelFlex;

  const AIAssistantWideLayout({
    super.key,
    required this.conversationPanel,
    required this.sidePanel,
    this.sidePanelFlex = 1,
    this.conversationPanelFlex = 3,
  });

  @override
  Widget build(BuildContext context) {
    final space = context.spacing(size: SpacingSize.small);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: sidePanelFlex,
          child: sidePanel,
        ),
        SizedBox(width: space),
        Expanded(
          flex: conversationPanelFlex,
          child: conversationPanel,
        ),
      ],
    );
  }
}