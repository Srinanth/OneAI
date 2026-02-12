import OpenAI from "openai";
import { AIModelAdapter, AIResponse } from "../../types/ai.js";
import { Message } from "../../types/chat.js";
import { Artifact } from "../../types/artifact.js";
import { GET_SYSTEM_PROMPT } from "../../prompts/system.js";
import { ArtifactService } from "../artifact.service.js";

export class OpenRouterAdapter implements AIModelAdapter {
  public id: string;
  public maxTokens = 128000;
  private artifactService: ArtifactService;

  constructor(modelId: string) {
    this.id = modelId;
    this.artifactService = new ArtifactService();
  }

  public async sendMessage(
    messages: Message[],
    currentArtifact: Artifact,
    apiKey: string
  ): Promise<AIResponse> {
    
    if (!apiKey) {
      throw new Error("API Key is missing. Please check your settings.");
    }
    
    if (!apiKey.startsWith("sk-or-v1-")) {
      console.warn(`[OpenRouterAdapter] Warning: Key for model ${this.id} does not start with 'sk-or-v1-'. You might be using a native provider key instead of an OpenRouter key.`);
    }

    const client = new OpenAI({
      apiKey: apiKey,
      baseURL: "https://openrouter.ai/api/v1",
      defaultHeaders: {
        "HTTP-Referer": "*", 
        "X-Title": "My AI App",
      }
    });

    const apiMessages: any[] = [
      { role: "system", content: GET_SYSTEM_PROMPT() },
      ...messages.map((m) => ({
        role: m.role,
        content: m.content,
      })),
    ];

    try {
      const completion = await client.chat.completions.create({
        model: this.id,
        messages: apiMessages,
        temperature: 0.7,
        stream: false,
      });

      const rawContent = completion.choices[0]?.message?.content || "";
      const newArtifact = this.artifactService.parseFromText(rawContent, currentArtifact);
      const cleanText = this.artifactService.cleanResponse(rawContent);
      const usage = completion.usage;

      return {
        text: cleanText,
        artifact: newArtifact,
        tokensUsed: {
          input: usage?.prompt_tokens || 0,
          output: usage?.completion_tokens || 0,
          total: usage?.total_tokens || 0,
        },
      };

    } catch (error: any) {
      console.error(`OpenRouter Adapter (${this.id}) Error:`, error);
      
      const errorMsg = error?.error?.message || error.message || "Unknown Error";

      if (errorMsg.includes("User not found") || error.status === 401) {
        throw new Error("Invalid OpenRouter API Key. Please ensure you are using a key starting with 'sk-or-v1-' from openrouter.ai, NOT a native DeepSeek/OpenAI key.");
      }
      if (errorMsg.includes("credits") || error.status === 402) {
        throw new Error("INSUFFICIENT_CREDITS"); 
      }
      if (error.status === 429) {
        throw new Error("RATE_LIMIT_EXCEEDED");
      }
      
      throw error;
    }
  }
}