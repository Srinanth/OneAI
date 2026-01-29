import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/chat_provider.dart';
import 'message_bubble.dart';

class ChatMessageList extends ConsumerWidget {
  final ScrollController scrollController;

  const ChatMessageList({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(activeChatProvider);
    final messages = chatState.messages;
    final isLoading = chatState.isLoading;
    final hasMore = ref.read(activeChatProvider.notifier).hasMore;

    if (messages.isEmpty && !isLoading) return const _LandingUI();

    return ListView.builder(
      controller: scrollController,
      reverse: true, // Anchor to bottom
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length + (isLoading ? 1 : 0) + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (isLoading && index == 0) {
          return const RepaintBoundary(
            child: MessageBubble(content: '', isUser: false, isThinking: true),
          );
        }

        final messageIndex = isLoading ? index - 1 : index;

        if (messageIndex == messages.length && hasMore) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (messageIndex < 0 || messageIndex >= messages.length) return const SizedBox.shrink();

        final message = messages[messageIndex];
        return RepaintBoundary(
          child: MessageBubble(
            content: message.content,
            isUser: message.role == 'user',
            modelIcon: message.role == 'assistant' ? message.modelUsed : null,
          ),
        );
      },
    );
  }
}
class _LandingUI extends StatelessWidget {
  const _LandingUI();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("How can I help you today?", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
        ],
      ),
    );
  }
}