import { Message } from './chat';
import { Artifact } from './artifact';

// The standardized response i expect from any of those models
export interface AIResponse {
  text: string;           // The conversational part
  artifact: Artifact;     // The structured JSON part
  tokensUsed: {
    input: number;
    output: number;
    total: number;
  };
}

export interface AIModelAdapter {       // this is for the model swtiching without losing context
  id: string;             // e.g. 'gpt-4o'
  maxTokens: number;      // e.g. 128000
  sendMessage(
    messages: Message[], 
    currentArtifact: Artifact, 
    apiKey: string
  ): Promise<AIResponse>;
}