import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/message.dart'; 
import '../data/services/api_client.dart';
import 'chat_list_provider.dart'; 

class ChatState {
  final String? chatId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.chatId,
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    String? chatId,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      chatId: chatId ?? this.chatId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ActiveChatNotifier extends Notifier<ChatState> {
  
  @override
  ChatState build() {
    return ChatState();
  }

  Future<void> loadChat(String chatId) async {
    state = ChatState(chatId: chatId, isLoading: true);
    
    try {
      final response = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      final messages = data.map((json) => ChatMessage.fromJson(json)).toList();

      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clear() {
    state = ChatState();
  }

  Future<void> sendMessage(String content, String modelId, String apiKey) async {
    if (content.trim().isEmpty) return;

    final tempUserMsg = ChatMessage(
      id: 'temp-${DateTime.now()}', 
      role: 'user', 
      content: content, 
      timestamp: DateTime.now()
    );
    
    state = state.copyWith(messages: [...state.messages, tempUserMsg], isLoading: true);

    try {
      String currentChatId = state.chatId ?? '';

      if (state.chatId == null) {
        final startResponse = await ApiClient.startChat(
           content.length > 20 ? '${content.substring(0, 20)}...' : content, 
           modelId
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
        id: data['id'] ?? 'ai-${DateTime.now()}', 
        role: 'assistant', 
        content: data['content'],
        timestamp: DateTime.now()
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