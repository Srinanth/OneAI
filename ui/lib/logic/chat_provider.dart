import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/message.dart'; 
import '../data/services/api_client.dart';
import 'chat_list_provider.dart';
import 'states/chat_state.dart';

class ActiveChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState();
  }

  void clear() {
    state = ChatState();
  }

  Future<void> loadChat(String chatId) async {
    state = ChatState(chatId: chatId, isLoading: true);
    
    try {
      final messagesResponse = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      final List<dynamic> msgData = messagesResponse as List<dynamic>;
      final messages = msgData.map((json) => ChatMessage.fromJson(json)).toList();

      final chatResponse = await Supabase.instance.client
          .from('chats')
          .select('model_id')
          .eq('id', chatId)
          .single();
      
      final savedModelId = chatResponse['model_id'] as String?;

      state = state.copyWith(
        messages: messages, 
        isLoading: false,
        lastUsedModel: savedModelId,
        chatId: chatId
      );

    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> sendMessage(String content, String modelId, String apiKey) async {
    if (content.trim().isEmpty) return;

    final tempUserMsg = ChatMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}', 
      role: 'user', 
      content: content, 
      timestamp: DateTime.now()
    );
    
    state = state.copyWith(messages: [...state.messages, tempUserMsg], isLoading: true);

    try {
      String currentChatId = state.chatId ?? '';

      if (state.chatId == null) {
        final startResponse = await ApiClient.startChat(
           content, 
           modelId,
           apiKey
        );
        
        currentChatId = startResponse['data']['id']; 
        state = state.copyWith(chatId: currentChatId);
        
        ref.read(chatListProvider.notifier).refresh();
      }

      final msgResponse = await ApiClient.sendMessage(
        currentChatId, 
        content, 
        modelId, 
        apiKey
      );
      
      final data = msgResponse['data'];
      final aiMsg = ChatMessage(
        id: data['id'] ?? 'ai-${DateTime.now().millisecondsSinceEpoch}', 
        role: 'assistant', 
        content: data['content'],
        timestamp: DateTime.now(),
        modelUsed: data['model_id'] 
      );

      state = state.copyWith(messages: [...state.messages, aiMsg], isLoading: false);

    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final activeChatProvider = NotifierProvider<ActiveChatNotifier, ChatState>(() {
  return ActiveChatNotifier();
});