import { ChatRepository } from '../db/chat.db.js';
import { AIFactory } from './manager.js';
import { GoogleGenAI } from '@google/genai';
import { getModelLimit } from '../types/models.js';
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
  ): Promise<{ text: string; artifact: any; messageId: string; currentUsage?: number; maxLimit?: number }> {
    
    if (chatId) {
       await ChatRepository.updateChatModel(chatId, modelId);
    }

    await ChatRepository.saveMessage(chatId, userId, 'user', userMessage, modelId);

    const usage = await ChatRepository.getModelUsage(chatId, modelId);
    const limit = getModelLimit(modelId);
    
    let currentCount = usage?.token_usage_count || 0;
    const lastReset = usage?.last_limit_reset_at ? new Date(usage.last_limit_reset_at).getTime() : Date.now();
    const hoursSinceReset = (Date.now() - lastReset) / (3600000);

    if (currentCount >= limit.max && hoursSinceReset < limit.resetHours) {
        const warningText = `🚨 **Model Limit Reached.**\n\nYou have used up todays quota** for ${modelId} in this chat.\n\n💡 *Tip: Switch to another model to continue.*`;

        const savedWarning = await ChatRepository.saveMessage(chatId, userId, 'assistant', warningText, modelId, 0);

        return {
            text: warningText,
            artifact: null,
            messageId: savedWarning.id,
            currentUsage: currentCount,
            maxLimit: limit.max
        };
    }

    const history = await ChatRepository.getHistory(chatId, userId);
    const chatData = await ChatRepository.getChat(chatId, userId); 
    const adapter = AIFactory.createAdapter(modelId);
    const response = await adapter.sendMessage(history, chatData.current_artifact, apiKey);

    const savedAiMessage = await ChatRepository.saveMessage(
      chatId, userId, 'assistant', response.text, modelId, response.tokensUsed.output
    );

    await ChatRepository.updateUsage(chatId, modelId, response.tokensUsed.total, limit.resetHours);

    if (response.artifact) {
      await ChatRepository.updateChatState(chatId, userId, response.artifact, modelId);
    }

    return {
      text: response.text,
      artifact: response.artifact,
      messageId: savedAiMessage.id,
      currentUsage: currentCount + response.tokensUsed.total,
      maxLimit: limit.max
    };
  }
}