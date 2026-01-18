import { ChatRepository } from '../db/chat.db.js';
import { AIFactory } from './manager.js';
import { AI_CONFIG } from '../config/ai.js';

export class ChatService {

  static async startSession(userId: string, modelId?: string, title?: string) {
    const selectedModel = modelId || AI_CONFIG.DEFAULT_MODEL;
    const projectTitle = title || 'New Project';
    return await ChatRepository.createChat(userId, selectedModel, projectTitle);
  }

  static async processMessage(userId: string, chatId: string, userMessage: string, apiKey: string, forcedModelId?: string) {
    
    const [chat, rawHistory] = await Promise.all([
      ChatRepository.getChat(chatId, userId),
      ChatRepository.getHistory(chatId)
    ]);


    const formattedHistory = rawHistory.map((msg: any) => ({
      id: msg.id,
      role: msg.role,
      content: msg.content,
      timestamp: new Date(msg.created_at)
    }));

    const fullHistory = [
      ...formattedHistory,
      { id: 'temp', role: 'user', content: userMessage, timestamp: new Date() }
    ] as any[];

    const activeModelId = forcedModelId || chat.model_id;
    const adapter = AIFactory.createAdapter(activeModelId);

    const aiResponse = await adapter.sendMessage(
      fullHistory,
      chat.current_artifact,
      apiKey
    );

    await Promise.all([
      ChatRepository.saveMessage(chatId, userId, 'user', userMessage),
      ChatRepository.saveMessage(chatId, userId, 'assistant', aiResponse.text),
      ChatRepository.updateChatState(chatId, userId, aiResponse.artifact, activeModelId)
    ]);

    return aiResponse;
  }
}