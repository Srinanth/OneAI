import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/settings_provider.dart';
import '../../logic/chat_provider.dart';
import '../screens/settings_screen.dart';

class ChatInputArea extends ConsumerStatefulWidget {
  final String selectedModelId; 
  final VoidCallback onMessageSent;

  const ChatInputArea({
    super.key,
    required this.selectedModelId,
    required this.onMessageSent,
  });

  @override
  ConsumerState<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends ConsumerState<ChatInputArea> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final settings = ref.read(settingsProvider);
    String targetModelId = '';
    String apiKey = '';

    switch (widget.selectedModelId) {
      case 'Gemini':
        targetModelId = settings.selectedGemini;
        apiKey = settings.geminiKey;
        break;
      case 'DeepSeek':
        targetModelId = settings.selectedDeepSeek;
        apiKey = settings.deepSeekKey;
        break;
      case 'ChatGPT':
        targetModelId = settings.selectedOpenRouter;
        apiKey = settings.openRouterKey;
        break;
      default:
        targetModelId = widget.selectedModelId;
        apiKey = settings.geminiKey;
    }

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Missing API Key for ${widget.selectedModelId}'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ),
      );
      return;
    }

    _textController.clear();
    ref.read(activeChatProvider.notifier).sendMessage(
      text,
      targetModelId,
      apiKey,
    );

    widget.onMessageSent();
  }

  @override
  Widget build(BuildContext context) {
    final isSending = ref.watch(activeChatProvider.select((s) => s.isLoading));

    return Container(
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
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton.filled(
            onPressed: isSending ? null : _handleSend,
            icon: const Icon(Icons.arrow_upward),
          ),
        ],
      ),
    );
  }
}