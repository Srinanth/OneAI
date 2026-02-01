import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/data/models/chat_state.dart';
import 'package:ui/logic/chat_provider.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/chat_message_list.dart';

class ChatInterface extends ConsumerStatefulWidget {
  final String selectedModelId;
  const ChatInterface({super.key, required this.selectedModelId});

  @override
  ConsumerState<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends ConsumerState<ChatInterface> {
  final ScrollController scrollController = ScrollController();
  bool showScrollButton = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(activeChatProvider.notifier);
      final chatId = ref.read(activeChatProvider).chatId;
      if (chatId != null && notifier.hasMore) {
        notifier.loadChat(chatId, isLoadMore: true);
      }
    }

    if (scrollController.offset > 300 && !showScrollButton) {
      setState(() => showScrollButton = true);
    } else if (scrollController.offset <= 300 && showScrollButton) {
      setState(() => showScrollButton = false);
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ChatState>(activeChatProvider, (previous, next) {
      if (previous == null) return;
      final bool newMessage = next.messages.isNotEmpty && 
          (previous.messages.isEmpty || next.messages.first.id != previous.messages.first.id);

      if (newMessage && next.messages.length > previous.messages.length) {
        _scrollToBottom();
      }
    });

    return Stack(
      children: [
        Column(
          children: [
            Expanded(child: ChatMessageList(scrollController: scrollController)),
            ChatInputArea(
              selectedModelId: widget.selectedModelId,
              onMessageSent: _scrollToBottom,
            ),
          ],
        ),
        if (showScrollButton)
          Positioned(
            bottom: 100, right: 20, 
            child: FloatingActionButton.small(
              onPressed: _scrollToBottom, 
              child: const Icon(Icons.arrow_downward),
            ),
          ),
      ],
    );
  }
}