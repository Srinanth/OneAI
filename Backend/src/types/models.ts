// List of all models
export type ModelId = 
  | 'gpt-4o' 
  | 'gpt-3.5-turbo' 
  | 'claude-3-5-sonnet' 
  | 'deepseek-coder';

export type AIProviderId = 'openai' | 'anthropic' | 'deepseek';

// What the Frontend needs to render the dropdown
export interface ModelConfig {
  id: ModelId;
  displayName: string;    // e.g: "GPT-4 Omni"
  provider: AIProviderId; // which model used
  contextWindow: number;
}