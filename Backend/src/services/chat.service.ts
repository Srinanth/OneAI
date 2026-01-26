import { ChatRepository } from '../db/chat.db.js';
import { AIFactory } from './manager.js';
import { AIResponse } from '../types/ai.js';

export class ChatService {

  static async startSession(userId: string, modelId: string, title?: string) {
    const chatTitle = title || 'New Conversation';
    return await ChatRepository.createChat(userId, modelId, chatTitle);
  }

  static async processMessage(
    userId: string, 
    chatId: string, 
    userMessage: string, 
    apiKey: string, 
    modelId: string
  ): Promise<{ text: string; artifact: any; messageId: string }> {
    
    await ChatRepository.saveMessage(chatId, userId, 'user', userMessage);

    const history = await ChatRepository.getHistory(chatId, userId);
    const chatData = await ChatRepository.getChat(chatId, userId); 

    const adapter = AIFactory.createAdapter(modelId);

    const response: AIResponse = await adapter.sendMessage(
      history,
      chatData.current_artifact,
      apiKey
    );

    const savedAiMessage = await ChatRepository.saveMessage(
      chatId, 
      userId, 
      'assistant', 
      response.text,
      modelId
    );

    if (response.artifact) {
      await ChatRepository.updateChatState(chatId, userId, response.artifact, modelId);
    }

    return {
      text: response.text,
      artifact: response.artifact,
      messageId: savedAiMessage.id 
    };
  }
}