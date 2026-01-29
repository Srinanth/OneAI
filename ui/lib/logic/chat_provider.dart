import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/core/constants.dart';
import '../data/models/message.dart'; 
import '../data/models/chat_state.dart';
import '../data/db/chat.dart';
import 'chat_list_provider.dart';

final chatdb = Provider((ref) => ChatDB());

class ActiveChatNotifier extends Notifier<ChatState> {
  bool _hasMore = true;
  bool _isFetchingMore = false;
  late ChatDB _repository;

  @override
  ChatState build() {_repository = ref.watch(chatdb);
    return ChatState();
  }

  void clear() {
    state = ChatState();
    _hasMore = true;
    _isFetchingMore = false;
  }

  bool get hasMore => _hasMore;

  Future<void> updateModelUsage(String newModelId) async {
    state = state.copyWith(
      lastUsedModel: newModelId,
      maxLimit: AppConstants.getLimitForModel(newModelId),
    );
    
    try {
      final usage = await _repository.fetchDailyUsage(newModelId);
      state = state.copyWith(currentUsage: usage);
    } catch (e) {
      state = state.copyWith(currentUsage: 0);
    }
  }

  Future<void> loadChat(String chatId, {bool isLoadMore = false}) async {
    if (isLoadMore && (!_hasMore || _isFetchingMore || state.isLoading)) return;

    if (!isLoadMore) {
      state = state.copyWith(chatId: chatId, isLoading: true, messages: []);
      _hasMore = true;
    } else {
      _isFetchingMore = true;
    }

    try {
      final int limit = isLoadMore ? 5 : 10;
      final fetchedMessages = await _repository.fetchMessages(
        chatId: chatId, 
        start: state.messages.length, 
        limit: limit,
      );
      
      if (fetchedMessages.length < limit) _hasMore = false;

      state = state.copyWith(
        messages: isLoadMore ? [...state.messages, ...fetchedMessages] : fetchedMessages, 
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    } finally {
      _isFetchingMore = false;
    }
  }

  Future<void> sendMessage(String content, String modelId, String apiKey) async {
    if (content.trim().isEmpty) return;

    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final tempUserMsg = ChatMessage(id: tempId, role: 'user', content: content, timestamp: DateTime.now());

    state = state.copyWith(messages: [tempUserMsg, ...state.messages], isLoading: true);

    try {
      String currentChatId = state.chatId ?? '';

      if (state.chatId == null) {
        final startResponse = await _repository.createNewChat(content, modelId, apiKey);
        currentChatId = startResponse['data']['id']; 
        state = state.copyWith(chatId: currentChatId);
        ref.read(chatListProvider.notifier).refresh();
      }

      final msgResponse = await _repository.sendToAI(currentChatId, content, modelId, apiKey);
      final data = msgResponse['data'];

      if (data == null) throw Exception("Server returned no data");

      final aiMsg = ChatMessage(
        id: (data['messageId'] ?? data['id'] ?? DateTime.now().toString()).toString(),
        role: 'assistant',
        content: data['text'] ?? data['content'] ?? '',
        timestamp: DateTime.now(),
        modelUsed: modelId,
      );

      state = state.copyWith(
        messages: [aiMsg, ...state.messages], 
        isLoading: false,
        currentUsage: data['currentUsage'] ?? state.currentUsage,
      );
    } catch (e) {
      handleSendError(e, tempId);
    }
  }

  void handleSendError(dynamic e, String tempId) {
    final errorMessage = parseError(e);
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != tempId).toList(),
      isLoading: false, 
      error: errorMessage,
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (state.error == errorMessage) state = state.copyWith(error: null);
    });
  }

  String parseError(dynamic e) {
    final err = e.toString();
    if (err.contains('timeout')) return "Timeout: AI is taking too long.";
    if (err.contains('SocketException')) return "Connection Error: Backend unreachable.";
    if (err.contains('429')) return "Daily limit reached.";
    return "Error: $err";
  }
}

final activeChatProvider = NotifierProvider<ActiveChatNotifier, ChatState>(() => ActiveChatNotifier());