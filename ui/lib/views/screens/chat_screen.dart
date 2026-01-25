// The core interface of the app, designed to mimic ChatGPT/Gemini. It displays the active conversation in the center and features a 'ModelSelector' in the message bar to switch LLMs instantly.
// It also includes a Side Menu (Drawer) to access the history of previous chats.


import 'package:flutter/material.dart';
import '../widgets/message_bubble.dart';
import '../widgets/model_selector.dart';
import '../../core/constants.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId; // If null, it's a new chat
  final String? initialTitle;

  const ChatScreen({super.key, this.chatId, this.initialTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Local state for UI testing (will replace with Provider later)
  String _selectedModel = AppConstants.supportedModels.first;
  bool _isTyping = false;
  
  // Mock Data to visualize UI
  final List<Map<String, dynamic>> _messages = [
    {'role': 'assistant', 'content': 'Hello! I am your AI assistant. **How can I help you today?**'},
    {'role': 'user', 'content': 'I need a Flutter UI for a chat app.'},
    {'role': 'assistant', 'content': 'Here is a breakdown of what you need:\n\n1. `ListView` for messages.\n2. `TextField` for input.\n3. `Markdown` support.\n\nShall I write the code?'},
  ];

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isTyping = true;
      _textController.clear();
    });

    // Simulate AI thinking delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({'role': 'assistant', 'content': 'This is a mock response from **$_selectedModel**.'});
          _scrollToBottom();
        });
      }
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // Small delay to ensure list has rendered the new item
    Future.delayed(const Duration(milliseconds: 100), () {
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
    return Scaffold(
      appBar: AppBar(
        title: widget.initialTitle != null 
            ? Text(widget.initialTitle!) 
            : ModelSelector(
                currentModelId: _selectedModel,
                onModelChanged: (newModel) => setState(() => _selectedModel = newModel),
              ),
        centerTitle: true,
        actions: [
          // Token Badge (Visual only for now)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: const Text(
              '120 Tokens',
              style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // If it's the last item and we are typing, show the loading bubble
                if (_isTyping && index == _messages.length) {
                  return const MessageBubble(content: '', isUser: false, isThinking: true);
                }

                final msg = _messages[index];
                return MessageBubble(
                  content: msg['content'],
                  isUser: msg['role'] == 'user',
                );
              },
            ),
          ),

          // 2. Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none, // Removed border for cleaner look inside the bubble
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.arrow_upward),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}