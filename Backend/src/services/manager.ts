import { AIModelAdapter } from "../types/ai.js";
import { GeminiAdapter } from "./adapter/gemini.adapter.js";
import { DeepSeekAdapter } from "./adapter/deepseek.adapter.js";

export class AIFactory {
  /**
   * Returns the correct adapter based on the model ID.
   * @param modelId"
   */
  static createAdapter(modelId: string): AIModelAdapter {
    
    if (modelId.startsWith("deepseek")) {
      return new DeepSeekAdapter(modelId);
    }
    
    if (modelId.startsWith("gemini")) {
      return new GeminiAdapter(modelId);
    }

    throw new Error(`Model ID '${modelId}' is not supported yet.`);
  }
}