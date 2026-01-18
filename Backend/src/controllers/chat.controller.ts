import { Request, Response } from 'express';
import { ChatService } from '../services/chat.service.js';

export class ChatController {

  static async startChat(req: Request, res: Response) {
    try {
      const { modelId, title, userId } = req.body;

      if (!userId) {
        return res.status(401).json({ success: false, error: 'Unauthorized: Missing userId' });
      }

      const chat = await ChatService.startSession(userId, modelId, title);

      res.status(201).json({ success: true, data: chat });
    } catch (error: any) {
      console.error('Start Chat Error:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

static async sendMessage(req: Request, res: Response) {
    try {
      const { chatId } = req.params;
      const { message, apiKey, modelId, userId } = req.body;

      if (!chatId || typeof chatId !== 'string') {
        return res.status(400).json({ success: false, error: 'Invalid Chat ID' });
      }

      if (!userId) return res.status(401).json({ success: false, error: 'Unauthorized' });
      if (!message) return res.status(400).json({ success: false, error: 'Message is required' });
      if (!apiKey) return res.status(400).json({ success: false, error: 'API Key is required' });

      const result = await ChatService.processMessage(
        userId, 
        chatId, 
        message, 
        apiKey, 
        modelId
      );

      res.json({
        success: true,
        data: {
          response: result.text,
          artifact: result.artifact
        }
      });

    } catch (error: any) {
      console.error('Message Error:', error);
      const status = error.message.includes('not found') ? 404 : 500;
      res.status(status).json({ success: false, error: error.message });
    }
  }
}