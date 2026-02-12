import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui/data/models/chat_group.dart';
import 'package:ui/data/models/search.dart';
import '../models/message.dart';
import '../models/chat_session.dart';
import '../services/api_client.dart';

class ChatDB {
  final _supabase = Supabase.instance.client;

  Future<List<ChatMessage>> fetchMessages({
    required String chatId,
    required int start,
    required int limit,
  }) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .range(start, start + limit - 1);

    return (response as List).map((json) => ChatMessage.fromJson(json)).toList();
  }

  Future<int> fetchDailyUsage(String modelId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _supabase
        .from('user_daily_usage')
        .select('token_count')
        .eq('user_id', userId)
        .eq('model_id', modelId)
        .eq('usage_date', today)
        .maybeSingle();
        
    return response?['token_count'] as int? ?? 0;
  }

  Future<List<ChatSession>> fetchChatSessions({String? groupId}) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return [];

  var query = _supabase
      .from('chats')
      .select()
      .eq('user_id', user.id);

  if (groupId == null) {
    query = query.isFilter('group_id', null);
  } else {
    query = query.eq('group_id', groupId);
  }

  final response = await query.order('updated_at', ascending: true);

  return (response as List).map((json) => ChatSession.fromJson(json)).toList();
}

  Future<void> renameSession(String chatId, String newTitle) async {
    await _supabase
    .from('chats')
    .update({'title': newTitle})
    .eq('id', chatId);
  }

  Future<void> deleteSession(String chatId) async {
    await _supabase
    .from('chats')
    .delete()
    .eq('id', chatId);
  }

  Future<Map<String, dynamic>> createNewChat(String content, String modelId, String apiKey) {
    return ApiClient.startChat(content, modelId, apiKey);
  }

  Future<Map<String, dynamic>> sendToAI(String chatId, String content, String modelId, String apiKey) {
    return ApiClient.sendMessage(chatId, content, modelId, apiKey);
  }

  Future<ChatGroup?> createGroup(String name) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    final response = await _supabase.from('chat_groups').insert({
      'user_id': user.id,
      'name': name,
    }).select().single();

    return ChatGroup.fromJson(response);
  }

  Future<void> deleteGroup(String groupId) async {
    await _supabase.from('chat_groups').delete().eq('id', groupId);
  }

  Future<List<ChatGroup>> fetchGroups() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('chat_groups')
        .select()
        .eq('user_id', user.id)
        .order('updated_at', ascending: false);

    return (response as List).map((json) => ChatGroup.fromJson(json)).toList();
  }

  Future<void> moveChatToGroup(String chatId, String? groupId) async {
    await _supabase.from('chats').update({
      'group_id': groupId,
      'updated_at': DateTime.now().toIso8601String()
    }).eq('id', chatId);
  }
  
  Future<List<SearchResult>> searchMessages(String query, {String? chatId}) async {
    if (query.trim().isEmpty) return [];

    final params = {
      'search_query': query,
      'target_chat_id': chatId,
    };

    final response = await _supabase.rpc('search_messages', params: params);

    return (response as List).map((json) => SearchResult.fromJson(json)).toList();
  }
}