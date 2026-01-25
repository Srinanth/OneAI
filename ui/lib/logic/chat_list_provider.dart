import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/chat_session.dart';

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
}

final chatListProvider = AsyncNotifierProvider<ChatListNotifier, List<ChatSession>>(() {
  return ChatListNotifier();
});