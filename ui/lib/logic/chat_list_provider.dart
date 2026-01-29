import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_session.dart';
import '../data/db/chat.dart';
import 'chat_provider.dart';

final chatDBProvider = Provider((ref) => ChatDB());

class ChatListNotifier extends AsyncNotifier<List<ChatSession>> {
  late ChatDB _db;

  @override
  Future<List<ChatSession>> build() async {
    _db = ref.watch(chatDBProvider);
    return _db.fetchChatSessions();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _db.fetchChatSessions());
  }

  Future<void> renameChat(String chatId, String newTitle) async {
    await _db.renameSession(chatId, newTitle);
    
    state.whenData((chats) {
      state = AsyncValue.data(
        chats.map((c) => c.id == chatId ? c.copyWith(title: newTitle) : c).toList(),
      );
    });
  }

  Future<void> deleteChat(String chatId) async {
    await _db.deleteSession(chatId);
    
    state.whenData((chats) {
      state = AsyncValue.data(chats.where((c) => c.id != chatId).toList());
    });
    
    final activeChat = ref.read(activeChatProvider);
    if (activeChat.chatId == chatId) {
      ref.read(activeChatProvider.notifier).clear();
    }
  }
}

final chatListProvider = AsyncNotifierProvider<ChatListNotifier, List<ChatSession>>(() {
  return ChatListNotifier();
});