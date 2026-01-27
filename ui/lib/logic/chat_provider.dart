import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/message.dart'; 
import '../data/services/api_client.dart';
import 'chat_list_provider.dart';
import '../data/models/chat_state.dart';
import '../core/constants.dart';

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
      final savedModelId = chatResponse['model_id'] as String? ?? AppConstants.supportedModels.first;
      int currentUsage = 0;

      final usageResponse = await Supabase.instance.client
            .from('chat_model_usage')
            .select('token_usage_count')
            .eq('chat_id', chatId)
            .eq('model_id', savedModelId)
            .maybeSingle();
      currentUsage = usageResponse?['token_usage_count'] as int? ?? 0;


      state = state.copyWith(
        messages: messages, 
        isLoading: false,
        lastUsedModel: savedModelId,
        chatId: chatId,
        currentUsage: currentUsage,
        maxLimit: AppConstants.getLimitForModel(savedModelId),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateModelUsage(String newModelId) async {
    if (state.chatId == null) {
      state = state.copyWith(
        lastUsedModel: newModelId,
        maxLimit: AppConstants.getLimitForModel(newModelId),
        currentUsage: 0,
      );
      return;
    }

    final usageResponse = await Supabase.instance.client
        .from('chat_model_usage')
        .select('token_usage_count')
        .eq('chat_id', state.chatId!)
        .eq('model_id', newModelId)
        .maybeSingle();

    state = state.copyWith(
      lastUsedModel: newModelId,
      maxLimit: AppConstants.getLimitForModel(newModelId),
      currentUsage: usageResponse?['token_usage_count'] as int? ?? 0,
    );
  }

  Future<void> sendMessage(String content, String modelId, String apiKey) async {
    if (content.trim().isEmpty) return;

    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final tempUserMsg = ChatMessage(
      id: tempId, 
      role: 'user', 
      content: content, 
      timestamp: DateTime.now()
    );
    
    state = state.copyWith(
      messages: [...state.messages, tempUserMsg], 
      isLoading: true,
      maxLimit: AppConstants.getLimitForModel(modelId),
    );

    try {
      String currentChatId = state.chatId ?? '';

      if (state.chatId == null) {
        final startResponse = await ApiClient.startChat(content, modelId, apiKey);
        currentChatId = startResponse['data']['id']; 
        state = state.copyWith(chatId: currentChatId);
        ref.read(chatListProvider.notifier).refresh();
      }

      final msgResponse = await ApiClient.sendMessage(currentChatId, content, modelId, apiKey);
    
    final data = msgResponse['data'];
    if (data == null) throw Exception("No data returned from API");

    final aiMsg = ChatMessage(
      id: (data['messageId'] ?? data['id'] ?? DateTime.now().toString()).toString(),
      role: 'assistant',
      content: data['text'] ?? data['content'] ?? '',
      timestamp: DateTime.now(),
      modelUsed: modelId,
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isLoading: false,
      currentUsage: data['currentUsage'] ?? state.currentUsage,
      maxLimit: data['maxLimit'] ?? state.maxLimit,
    );

  } catch (e) {
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != tempId).toList(),
      isLoading: false, 
      error: e.toString()
    );
  }
  }
}

final activeChatProvider = NotifierProvider<ActiveChatNotifier, ChatState>(() {
  return ActiveChatNotifier();
});