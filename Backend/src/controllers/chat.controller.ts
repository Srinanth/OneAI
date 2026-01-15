import { Request, Response } from 'express';
import { AIFactory } from '../services/manager.js';
import { createInitialArtifact } from '../types/artifact.js';



// test controller, ill do it later with db






export class ChatController {

  static async startChat(req: Request, res: Response) {
    res.json({
      success: true,
      data: {
        chatId: 'test-session',
        modelId: req.body.modelId || 'gemini-1.5-flash',
        artifact: createInitialArtifact()
      }
    });
  }

  static async sendMessage(req: Request, res: Response) {
    try {
      const { 
        message, 
        apiKey, 
        modelId,
        history, 
        currentArtifact 
      } = req.body; 

      if (!message || !apiKey) {
        return res.status(400).json({ error: 'Message and API Key are required' });
      }

     const previousMessages = history || [];

      // 2. ADD the new user message to the end
      const fullConversation = [
        ...previousMessages,
        { role: 'user', content: message }
      ];

      // 3. Setup Artifact
      const artifact = currentArtifact || createInitialArtifact();
      const activeModelId = modelId || 'gemini-1.5-flash';

      // 4. RUN AI (Send the FULL conversation)
      const adapter = AIFactory.createAdapter(activeModelId);
      const aiResponse = await adapter.sendMessage(
        fullConversation, // <--- Passing the combined list
        artifact, 
        apiKey
      );
      // 3. RETURN EVERYTHING (So you can chain it in the next request)
      res.json({
        success: true,
        data: {
          response: aiResponse.text,
          artifact: aiResponse.artifact,
          history: [
            ...fullConversation, // Return the full history including AI reply
            { role: 'assistant', content: aiResponse.text }
          ]
        }
      });

    } catch (error: any) {
      console.error('Chat Error:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }
}