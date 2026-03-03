import { AIModelAdapter } from "../types/ai.js";
import { GeminiAdapter } from "./adapter/gemini.adapter.js";
import { OpenRouterAdapter } from "./adapter/openrouter.adapter.js";
import { GPTAdapter } from "./adapter/gpt.adapter.js";
import { DeepSeekAdapter } from "./adapter/deepseek.adapter.js";
import { GrokAdapter } from "./adapter/grok.adapter.js";
import { ClaudeAdapter } from "./adapter/claude.adapter.js";

export class AIFactory {
 
  static createAdapter(modelId: string, apiKey: string): AIModelAdapter {
    
    if (apiKey.startsWith("sk-or-v1")) {
      return new OpenRouterAdapter(modelId);
    }

    const cleanModelId = modelId.split('/').pop() || modelId;

    if (cleanModelId.startsWith("gemini")) {
      return new GeminiAdapter(cleanModelId);
    }

    if (cleanModelId.startsWith("gpt") || cleanModelId.startsWith("o1") || cleanModelId.startsWith("o3")) {
      return new GPTAdapter(cleanModelId);
    }

    if (cleanModelId.startsWith("deepseek")) {
      return new DeepSeekAdapter(cleanModelId);
    }

    if (cleanModelId.startsWith("grok")) {
      return new GrokAdapter(cleanModelId);
    }

    if (cleanModelId.startsWith("claude")) {
      return new ClaudeAdapter(cleanModelId);
    }
    
    throw new Error(`Model ID '${modelId}' (Cleaned: '${cleanModelId}') is not supported yet.`);
  }
}