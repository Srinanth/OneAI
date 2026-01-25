// Renders individual text bubbles. Uses 'flutter_markdown' to display rich text (bold, lists, code) from the AI. Aligns User messages to the right and AI to the left.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool isThinking; // For the "..." loading state

  const MessageBubble({
    super.key,
    required this.content,
    required this.isUser,
    this.isThinking = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          border: isUser ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: isThinking
            ? _buildThinkingIndicator(colorScheme.onSurface)
            : MarkdownBody(
                data: content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.inter(
                    color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  code: GoogleFonts.robotoMono(
                    backgroundColor: isUser ? Colors.white24 : Colors.grey.shade100,
                    color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontSize: 13,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: isUser ? Colors.white12 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildThinkingIndicator(Color color) {
    return SizedBox(
      width: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _dot(color),
          _dot(color),
          _dot(color),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.5), shape: BoxShape.circle),
    );
  }
}