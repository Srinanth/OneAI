import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool isThinking;
  final String? modelIcon;

  const MessageBubble({
    super.key, 
    required this.content, 
    required this.isUser, 
    this.isThinking = false,
    this.modelIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (isThinking) {
       return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 24, height: 24, 
            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary)
          ),
        ),
      );
    }

    final backgroundColor = isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final textColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: content,
                  selectable: true, 
                  styleSheet: _getMarkdownStyle(context, textColor, isUser),
                ),
              ],
            ),
          ),
          
          if (!isUser && modelIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    modelIcon!.contains('gemini') ? Icons.auto_awesome : Icons.psychology,
                    size: 12,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    modelIcon!.contains('gemini') ? 'Gemini' : 'DeepSeek',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _getMarkdownStyle(BuildContext context, Color textColor, bool isUser) {
      final theme = Theme.of(context);
    final codeBg = isUser ? Colors.black26 : theme.colorScheme.surface;
    
    final baseTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: textColor,
      fontSize: 16,
      height: 1.4,
    );

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: baseTextStyle,
      listBullet: baseTextStyle,
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        color: isUser ? Colors.white : theme.colorScheme.onSurfaceVariant,
        backgroundColor: codeBg,
      ),
      codeblockDecoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}