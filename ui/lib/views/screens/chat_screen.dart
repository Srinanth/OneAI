import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input_area.dart';

class ChatInterface extends ConsumerStatefulWidget {
  final String selectedModelId;

  const ChatInterface({
    super.key,
    required this.selectedModelId,
  });

  @override
  ConsumerState<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends ConsumerState<ChatInterface> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. The List
        Expanded(
          child: ChatMessageList(scrollController: _scrollController),
        ),

        // 2. The Input
        ChatInputArea(
          selectedModelId: widget.selectedModelId,
          onMessageSent: _scrollToBottom,
        ),
      ],
    );
  }
}