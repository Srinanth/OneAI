import { AIModelAdapter, AIResponse } from "../../types/ai.js";
import { Message } from "../../types/chat.js";
import { Artifact } from "../../types/artifact.js";
import { ArtifactService } from "../artifact.service.js";

export class GPTAdapter implements AIModelAdapter {
  public id: string;
  public maxTokens: number;
  private artifactService: ArtifactService;

  constructor(modelId: string) {
    this.id = modelId;
    this.maxTokens = 128000;
    this.artifactService = new ArtifactService();
  }

  public async sendMessage(
    messages: Message[],
    currentArtifact: Artifact,
    apiKey: string
  ): Promise<AIResponse> {
    try {
      const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${apiKey}`,
          "Content-Type": "application/json",
          "HTTP-Referer": "*",
          "X-Title": "AI Chat App",
        },
        body: JSON.stringify({
          model: this.id,
          messages: messages.map(m => ({
            role: m.role,
            content: m.content
          })),
          temperature: 0.7,
        }),
      });

      const data = await response.json();

      if (!response.ok || data.error) {
      const errorMsg = data.error?.message || "OpenRouter Error";
      
      if (errorMsg.includes("credits") || errorMsg.includes("afford")) {
        throw new Error("INSUFFICIENT_CREDITS");
      }
      if (response.status === 429) {
        throw new Error("RATE_LIMIT_EXCEEDED");
      }
      throw new Error(errorMsg);
    }
      const responseText = data.choices[0].message.content;
      const newArtifact = this.artifactService.parseFromText(responseText, currentArtifact);
      const cleanText = this.artifactService.cleanResponse(responseText);

      const usage = data.usage;

      return {
        text: cleanText,
        artifact: newArtifact,
        tokensUsed: {
          input: usage?.prompt_tokens || 0,
          output: usage?.completion_tokens || 0,
          total: usage?.total_tokens || 0,
        },
      };
    } catch (error) {
      console.error(`GPT Adapter (${this.id}) Error:`, error);
      throw error;
    }
  }
}