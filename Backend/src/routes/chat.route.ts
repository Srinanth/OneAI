import { Router } from 'express';
import { ChatController } from '../controllers/chat.controller.js';

const router = Router();

router.post('/start', ChatController.startChat);

router.post('/:chatId/message', ChatController.sendMessage);

router.get('/usage/:userId/:modelId', ChatController.getUsage);

export default router;