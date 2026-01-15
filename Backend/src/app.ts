import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import chatRoutes from './routes/chat.route.js';

dotenv.config();

const app = express();

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-public-id'],
  exposedHeaders: ['x-public-id']
}));
app.use(express.json());

// Routes
app.use('/api/chat', chatRoutes);

app.get('/', (_req, res) => {
  res.send('Just the Server is running');
});

export default app;