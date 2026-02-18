import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/chat/chat_bubble.dart';
import 'package:foretale_application/ui/widgets/ai_box/presentation/shared/scroll_helper.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';

/// Message list widget for chat mode
class ChatMessageList extends StatelessWidget {
  final ScrollController scrollController;
  final ChatDrivingModel drivingModel;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.drivingModel,
  });

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserDetailsModel>(context, listen: false);

    return Consumer<InquiryResponseModel>(
      builder: (context, inquiryResponseModel, child) {
        // Show loading state if page is loading
        if (inquiryResponseModel.getIsPageLoading) {
          return buildLoadingState(context);
        }

        final responses = inquiryResponseModel.getResponseList;

        ScrollHelper.scrollToBottom(
          scrollController: scrollController,
          reversed: true,
        );

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.all(15),
          itemCount: responses.length,
          cacheExtent: 1000,
          itemBuilder: (context, index) {
            final item = responses[index];
            return Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: ChatBubble(
                key: Key(item.responseId.toString()),
                inquiryResponse: item,
                drivingModel: drivingModel,
                userDetailsModel: userModel,
              ),
            );
          },
        );
      },
    );
  }
}

