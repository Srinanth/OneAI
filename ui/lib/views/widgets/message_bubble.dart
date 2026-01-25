import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool isThinking;

  const MessageBubble({
    super.key, 
    required this.content, 
    required this.isUser, 
    this.isThinking = false
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // thinking bubble (simple animation placeholder)
    if (isThinking) {
       return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const SizedBox(
            width: 24, 
            height: 24, 
            child: CircularProgressIndicator(strokeWidth: 2)
          ),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        // Use MarkdownBody for rich text (bold, code blocks, etc.)
        child: MarkdownBody(
          data: content,
          selectable: true, 
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            code: TextStyle(
              backgroundColor: isUser ? Colors.white24 : Colors.grey.shade300,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            codeblockDecoration: BoxDecoration(
              color: isUser ? Colors.black26 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}