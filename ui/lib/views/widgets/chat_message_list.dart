import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/chat_provider.dart';
import 'message_bubble.dart';

class ChatMessageList extends ConsumerWidget {
  final ScrollController scrollController;

  const ChatMessageList({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(activeChatProvider.select((s) => s.messages));
    final isLoading = ref.watch(activeChatProvider.select((s) => s.isLoading));
    final error = ref.watch(activeChatProvider.select((s) => s.error));

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (messages.isEmpty && !isLoading) {
      final theme = Theme.of(context);
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, size: 48, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                'Start a new conversation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a model above and type below.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (isLoading && index == messages.length) {
          return const MessageBubble(content: '', isUser: false, isThinking: true);
        }

        final msg = messages[index];
        return MessageBubble(
          content: msg.content,
          isUser: msg.isUser,
          modelIcon: msg.isUser ? null : msg.modelUsed,
        );
      },
    );
  }
}