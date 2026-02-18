import 'package:flutter/material.dart';

class ScrollHelper {
  static void scrollToBottom({
    required ScrollController scrollController,
    bool reversed = false,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      final position = scrollController.position;
      final targetOffset = reversed 
          ? position.minScrollExtent 
          : position.maxScrollExtent;

      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}

