import { ChatRepository } from '../db/chat.db.js';
import { AIFactory } from './manager.js';
import { AIResponse } from '../types/ai.js';
import { GoogleGenAI } from '@google/genai';

export class ChatService {

  static async generateSmartTitle(firstMessage: string, apiKey: string, modelId: string): Promise<string> {
    
    if (modelId.includes('gemini')) {
      try {
        const client = new GoogleGenAI({ apiKey: apiKey });
        
        const prompt = `Summarize this chat message into a short, punchy title (max 4 words). No quotes. Message: "${firstMessage}"`;

        const response = await client.models.generateContent({
          model: 'gemini-2.5-flash',
          contents: [{ 
            parts: [{ text: prompt }] 
          }],
        });
        
        return response.text?.replace(/['"]/g, '').trim() || 'New Chat';

      } catch (e) {
        console.warn('Gemini Title Gen Failed:', e);
      }
    }

    if (modelId.includes('deepseek')) {
      try {
        const response = await fetch('https://openrouter.ai/api/v1', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${apiKey}`
          },
          body: JSON.stringify({
            model: "deepseek/deepseek-chat",
            messages: [{ 
              role: "user", 
              content: `Summarize this into a short title (max 4 words). No quotes: "${firstMessage}"` 
            }],
            temperature: 0.7
          })
        });

        const data = await response.json();
        if (!response.ok) throw new Error(data.error?.message || 'DeepSeek API Error');
        return data.choices[0].message.content.replace(/['"]/g, '').trim();
      } catch (e) {
         console.warn('DeepSeek Title Gen Failed:', e);
      }
    }

    return firstMessage.length > 30 
      ? `${firstMessage.substring(0, 30)}...` 
      : firstMessage;
  }

  static async startSession(userId: string, modelId: string, initialMessage: string, apiKey: string) {
    const title = await this.generateSmartTitle(initialMessage, apiKey, modelId);

    return await ChatRepository.createChat(userId, modelId, title);
  }

  static async processMessage(
    userId: string, 
    chatId: string, 
    userMessage: string, 
    apiKey: string, 
    modelId: string
  ): Promise<{ text: string; artifact: any; messageId: string }> {
    
    if (chatId) {
       await ChatRepository.updateChatModel(chatId, modelId);
    }

    await ChatRepository.saveMessage(chatId, userId, 'user', userMessage, modelId);

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