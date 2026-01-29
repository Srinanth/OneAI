// lib/presentation/screens/chat_interface.dart
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
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(activeChatProvider.notifier);
      final chatId = ref.read(activeChatProvider).chatId;
      if (chatId != null && notifier.hasMore) {
        notifier.loadChat(chatId, isLoadMore: true);
      }
    }

    if (_scrollController.offset > 300 && !_showScrollButton) {
      setState(() => _showScrollButton = true);
    } else if (_scrollController.offset <= 300 && _showScrollButton) {
      setState(() => _showScrollButton = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
            Expanded(child: ChatMessageList(scrollController: _scrollController)),
            ChatInputArea(
              selectedModelId: widget.selectedModelId,
              onMessageSent: _scrollToBottom,
            ),
          ],
        ),
        if (_showScrollButton)
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