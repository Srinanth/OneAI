import { Artifact } from './artifact';

export type Role = 'system' | 'user' | 'assistant';
// actually roles are used to pass context bw admin,user,ai models

export interface Message {
  id: string;
  role: Role;
  content: string;      // The text displayed to the user
  timestamp: Date;
}

export interface ChatSession {
  id: string;
  userId?: string;
  modelId: string;
  createdAt: Date;
  updatedAt: Date;
  totalTokensUsed: number; // use tiktoken and measure how much we use + set a safe limit - hardcode it
  messageCount: number; // this is for the frontend to setup pagination
  currentArtifact: Artifact; // for the latest state 
}