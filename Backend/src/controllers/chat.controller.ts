import {Response } from 'express';
import { ChatService } from '../services/chat.service.js';
import { AuthenticatedRequest } from '../middleware/auth.js';

export class ChatController {

  static async startChat(req: AuthenticatedRequest, res: Response) {
    try {
      const { modelId, title,userId, apiKey } = req.body;
      
      if (!userId) {
        return res.status(401).json({ success: false, error: 'Unauthorized: Missing userId' });
      }

      const chat = await ChatService.startSession(userId, modelId, title, apiKey);

      res.status(201).json({ success: true, data: chat });
    } catch (error: any) {
      console.error('Start Chat Error:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async sendMessage(req: AuthenticatedRequest, res: Response) {
    try {
      const { chatId } = req.params;
      const { message, apiKey, modelId,userId } = req.body;

      if (!chatId || typeof chatId !== 'string') {
        return res.status(400).json({ success: false, error: 'Invalid Chat ID' });
    }

      if (!chatId) return res.status(400).json({ success: false, error: 'Invalid Chat ID' });
      if (!userId) return res.status(401).json({ success: false, error: 'Unauthorized userID' });
      if (!message) return res.status(400).json({ success: false, error: 'Message is required' });
      
      if (!apiKey) return res.status(400).json({ success: false, error: 'API Key is required' });
      const activeModelId = modelId || 'gemini-2.5-flash';
      const result = await ChatService.processMessage(
        userId, 
        chatId, 
        message, 
        apiKey, 
        activeModelId
      );

      res.json({
        success: true,
        data: {
          id: result.messageId,
          content: result.text,
          role: 'assistant',
          artifact: result.artifact,
          model_id: activeModelId
        }
      });

    } catch (error: any) {
      console.error('Message Error:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }
}