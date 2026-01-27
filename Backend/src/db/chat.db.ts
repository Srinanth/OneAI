import { supabase } from '../services/supabase.js';
import { createInitialArtifact } from '../types/artifact.js';

export class ChatRepository {
  
  static async createChat(userId: string, modelId: string, title: string) {
    const { data, error } = await supabase
      .from('chats')
      .insert({
        user_id: userId,
        model_id: modelId,
        title: title,
        current_artifact: createInitialArtifact()
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async getChat(chatId: string, userId: string) {
    const { data, error } = await supabase
      .from('chats')
      .select('*')
      .eq('id', chatId)
      .eq('user_id', userId)
      .single();
      
    if (error || !data) throw new Error('Chat not found or access denied');
    return data;
  }

  static async getHistory(chatId: string, userId: string) {
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .eq('chat_id', chatId)
      .eq('user_id', userId)
      .order('created_at', { ascending: true });

    if (error) throw error;
    return data || [];
  }

static async saveMessage(chatId: string, userId: string, role: 'user' | 'assistant', content: string, modelId?: string,tokens?:Number) {
    const { data, error } = await supabase
        .from('messages')
        .insert({
            chat_id: chatId,
            user_id: userId,
            role,
            content,
            model_id: modelId,
            token_count: tokens
        })
        .select()
        .single();

    if (error) throw error;
    return data;
}

  static async getModelUsage(chatId: string, modelId: string) {
    const { data, error } = await supabase
        .from('chat_model_usage')
        .select('token_usage_count, last_limit_reset_at')
        .eq('chat_id', chatId)
        .eq('model_id', modelId)
        .maybeSingle();

    if (error) throw error;
    return data;
  }

  static async updateUsage(chatId: string, modelId: string, tokens?:Number, resetHours?: Number) {
    const { error } = await supabase.rpc('increment_chat_usage_v2', { 
      chat_id_param: chatId, 
      model_id_param: modelId,
      tokens_to_add: tokens,
      reset_hours: resetHours
    });

    if (error) throw error;
  }

  static async updateChatState(chatId: string, userId: string, artifact: any, modelId: string) {
    const { error } = await supabase
      .from('chats')
      .update({ 
        current_artifact: artifact,
        model_id: modelId 
      })
      .eq('id', chatId)
      .eq('user_id', userId);

    if (error) throw error;
  }

  static async updateChatModel(chatId: string, modelId: string) {
    await supabase.from('chats').update({ model_id: modelId }).eq('id', chatId);
  }

  static async deleteChat(chatId: string, userId: string) {
    const { error } = await supabase.from('chats').delete().eq('id', chatId).eq('user_id', userId);
    if (error) throw error;
  }

  static async renameChat(chatId: string, userId: string, newTitle: string) {
    const { error } = await supabase.from('chats')
        .update({ title: newTitle, is_custom_title: true })
        .eq('id', chatId).eq('user_id', userId);
    if (error) throw error;
  }
}