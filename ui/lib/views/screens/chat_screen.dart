import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/logic/settings_provider.dart';
import 'package:ui/views/screens/settings_screen.dart';
import '../../logic/chat_provider.dart';
import '../../core/constants.dart';
import '../widgets/message_bubble.dart';
import '../widgets/model_selector.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? chatId;
  final String? initialTitle;

  const ChatScreen({super.key, this.chatId, this.initialTitle});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _selectedModel = AppConstants.supportedModels.first;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.chatId != null) {
        ref.read(activeChatProvider.notifier).loadChat(widget.chatId!);
      } else {
        ref.read(activeChatProvider.notifier).clear();
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // 1. Get the correct key from settings
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final apiKey = settingsNotifier.getKeyForModel(_selectedModel);

    // 2. Validate
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Missing API Key for $_selectedModel'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const SettingsScreen())
            ),
          ),
        ),
      );
      return;
    }
    
    _textController.clear();
    
    // 3. Send
    ref.read(activeChatProvider.notifier).sendMessage(
      text, 
      _selectedModel, 
      apiKey // <--- Using the saved key!
    );
    
    _scrollToBottom();
  }

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
    final chatState = ref.watch(activeChatProvider);
    final messages = chatState.messages;

    return Scaffold(
      appBar: AppBar(
        title: widget.initialTitle != null 
            ? Text(widget.initialTitle!) 
            : ModelSelector(
                currentModelId: _selectedModel,
                onModelChanged: (val) => setState(() => _selectedModel = val),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.error != null
                ? Center(child: Text('Error: ${chatState.error}'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: messages.length + (chatState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (chatState.isLoading && index == messages.length) {
                        return const MessageBubble(content: '', isUser: false, isThinking: true);
                      }

                      final msg = messages[index];
                      return MessageBubble(
                        content: msg.content,
                        isUser: msg.isUser,
                      );
                    },
                  ),
          ),
          
          // Input Area
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
                      hintText: 'Ask the AI...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton.filled(
                  onPressed: chatState.isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}