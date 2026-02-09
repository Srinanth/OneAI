import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_session.dart';
import '../data/models/chat_group.dart';
import '../data/models/chat_list_state.dart';
import '../data/db/chat.dart';
import 'chat_provider.dart';

final chatDBProvider = Provider((ref) => ChatDB());

class ChatListNotifier extends AsyncNotifier<ChatListState> {
  late ChatDB _db;

  @override
  Future<ChatListState> build() async {
    ref.keepAlive();
    _db = ref.watch(chatDBProvider);
    return _fetchData();
  }

  Future<ChatListState> _fetchData() async {
    final results = await Future.wait([
      _db.fetchGroups(),
      _db.fetchChatSessions(groupId: null),
    ]);

    return ChatListState(
      groups: results[0] as List<ChatGroup>,
      chats: results[1] as List<ChatSession>,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }

  Future<void> createGroup(String name) async {
    final newGroup = await _db.createGroup(name);
      if (newGroup != null) {
      state.whenData((current) {
        state = AsyncValue.data(current.copyWith(
          groups: [newGroup, ...current.groups], 
        ));
      });
    }
  }

  Future<void> deleteGroup(String groupId) async {
    await _db.deleteGroup(groupId);

    state.whenData((current) {
      final updatedGroups = current.groups.where((g) => g.id != groupId).toList();
      
      state = AsyncValue.data(current.copyWith(groups: updatedGroups));
      _fetchData().then((newState) {
         state = AsyncValue.data(newState);
      });
    });
  }

  Future<void> moveChat(String chatId, String? groupId) async {
    await _db.moveChatToGroup(chatId, groupId);
    state.whenData((current) {
      
      if (groupId != null) {
        final updatedChats = current.chats.where((c) => c.id != chatId).toList();
        
        state = AsyncValue.data(current.copyWith(chats: updatedChats));
      } 
      
      else {
        _fetchData().then((newState) {
           state = AsyncValue.data(newState);
        });
      }
    });
  }

  //  Chat Operations 

  Future<void> renameChat(String chatId, String newTitle) async {
    await _db.renameSession(chatId, newTitle);

    state.whenData((currentState) {
      final updatedChats = currentState.chats.map((c) {
        return c.id == chatId ? c.copyWith(title: newTitle) : c;
      }).toList();

      state = AsyncValue.data(currentState.copyWith(chats: updatedChats));
    });
  }

  Future<void> deleteChat(String chatId) async {
    await _db.deleteSession(chatId);

    state.whenData((currentState) {
      final updatedChats = currentState.chats.where((c) => c.id != chatId).toList();
      state = AsyncValue.data(currentState.copyWith(chats: updatedChats));
    });

    final activeChat = ref.read(activeChatProvider);
    if (activeChat.chatId == chatId) {
      ref.read(activeChatProvider.notifier).clear();
    }
  }
}

final chatListProvider = AsyncNotifierProvider<ChatListNotifier, ChatListState>(() {
  return ChatListNotifier();
});