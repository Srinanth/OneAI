import { AIModelAdapter } from "../types/ai.js";
import { GeminiAdapter } from "./adapter/gemini.adapter.js";
import { OpenRouterAdapter } from "./adapter/openrouter.adapter.js";
import { GPTAdapter } from "./adapter/gpt.adapter.js";
import { DeepSeekAdapter } from "./adapter/deepseek.adapter.js";
import { GrokAdapter } from "./adapter/grok.adapter.js";
import { ClaudeAdapter } from "./adapter/claude.adapter.js";

export class AIFactory {
  /**
   * Returns the correct adapter based on the model ID.
   * @param modelId
   */
  static createAdapter(modelId: string): AIModelAdapter {
    
    if (modelId.includes("/")) {
      return new OpenRouterAdapter(modelId);
    }

    if (modelId.startsWith("gemini")) {
      return new GeminiAdapter(modelId);
    }

    if (modelId.startsWith("gpt") || modelId.startsWith("o1") || modelId.startsWith("o3")) {
      return new GPTAdapter(modelId);
    }

    if (modelId.startsWith("deepseek")) {
      return new DeepSeekAdapter(modelId);
    }

    if (modelId.startsWith("grok")) {
      return new GrokAdapter(modelId);
    }

    if (modelId.startsWith("claude")) {
      return new ClaudeAdapter(modelId);
    }
    
    throw new Error(`Model ID '${modelId}' is not supported yet.`);
  }
}