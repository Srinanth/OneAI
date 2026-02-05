import 'chat_group.dart';
import 'chat_session.dart';

class ChatListState {
  final List<ChatGroup> groups;
  final List<ChatSession> chats;

  const ChatListState({
    this.groups = const [],
    this.chats = const [],
  });

  ChatListState copyWith({
    List<ChatGroup>? groups,
    List<ChatSession>? chats,
  }) {
    return ChatListState(
      groups: groups ?? this.groups,
      chats: chats ?? this.chats,
    );
  }
}