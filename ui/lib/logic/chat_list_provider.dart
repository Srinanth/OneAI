import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/chat_session.dart';
import 'chat_provider.dart';
class ChatListNotifier extends AsyncNotifier<List<ChatSession>> {
  
  @override
  Future<List<ChatSession>> build() async {
    return fetchChats();
  }

  Future<List<ChatSession>> fetchChats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    final response = await Supabase.instance.client
        .from('chats')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => ChatSession.fromJson(json)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchChats());
  }
 Future<void> renameChat(String chatId, String newTitle) async {
  await Supabase.instance.client.from('chats').update({'title': newTitle}).eq('id', chatId);
  
  if (state.hasValue) {
    state = AsyncValue.data(
      state.value!.map((c) => c.id == chatId ? c.copyWith(title: newTitle) : c).toList()
    );
  }
}

Future<void> deleteChat(String chatId) async {
  await Supabase.instance.client.from('chats').delete().eq('id', chatId);
  
  if (state.hasValue) {
    state = AsyncValue.data(state.value!.where((c) => c.id != chatId).toList());
  }
  
  if (ref.read(activeChatProvider).chatId == chatId) {
    ref.read(activeChatProvider.notifier).clear();
  }
}
}

final chatListProvider = AsyncNotifierProvider<ChatListNotifier, List<ChatSession>>(() {
  return ChatListNotifier();
});