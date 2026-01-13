import { AIModelAdapter } from "../types/ai";
import { GeminiAdapter } from "./adapter/gemini.adapter";
import { DeepSeekAdapter } from "./adapter/deepseek.adapter";

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