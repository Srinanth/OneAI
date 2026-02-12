import { AIModelAdapter } from "../types/ai.js";
import { GeminiAdapter } from "./adapter/gemini.adapter.js";
import { OpenRouterAdapter } from "./adapter/openrouter.adapter.js";

export class AIFactory {
  /**
   * Returns the correct adapter based on the model ID.
   * @param modelId
   */
  static createAdapter(modelId: string): AIModelAdapter {
    

    if (modelId.startsWith("gemini")) {
      return new GeminiAdapter(modelId);
    }

    if (modelId.startsWith("deepseek") || modelId.startsWith("openai/")) {
      return new OpenRouterAdapter(modelId);
    }
    
    throw new Error(`Model ID '${modelId}' is not supported yet.`);
  }
}