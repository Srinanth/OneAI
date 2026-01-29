import { GoogleGenAI } from "@google/genai";
import { AIModelAdapter, AIResponse } from "../../types/ai.js";
import { Message } from "../../types/chat.js";
import { Artifact } from "../../types/artifact";
import { GET_SYSTEM_PROMPT } from "../../prompts/system.js";
import { ArtifactService } from "../artifact.service.js";

export class GeminiAdapter implements AIModelAdapter {
  public id: string;
  public maxTokens: number;
  private artifactService: ArtifactService;

  constructor(modelId: string) {
    this.id = modelId; 
    this.maxTokens = 1000000;
    this.artifactService = new ArtifactService();
  }

  public async sendMessage(
    messages: Message[],
    currentArtifact: Artifact,
    apiKey: string
  ): Promise<AIResponse> {
    try {
      const ai = new GoogleGenAI({ apiKey });

      const conversationHistory = messages.map((msg) => ({
        role: msg.role === "assistant" ? "model" : "user",
        parts: [{ text: msg.content }],
      }));

      const response = await ai.models.generateContent({
        model: this.id,
        config: {
          systemInstruction: GET_SYSTEM_PROMPT(),
          temperature: 0.7,
        },
        contents: conversationHistory,
      });
      const responseText = response.text || "";

      const newArtifact = this.artifactService.parseFromText(responseText, currentArtifact);
      const cleanText = this.artifactService.cleanResponse(responseText);

      const usage = response.usageMetadata;

      return {
        text: cleanText,
        artifact: newArtifact,
        tokensUsed: {
          input: usage?.promptTokenCount || 0,
          output: usage?.candidatesTokenCount || 0,
          total: usage?.totalTokenCount || 0,
        },
      };

    } catch (error:any) {
    const status = error.status || (error.error && error.error.code);
    
    if (status === 404) {
      throw new Error("MODEL_NOT_FOUND");
    }
    if (status === 429) {
      throw new Error("PROVIDER_QUOTA_EXCEEDED");
    }
    
    console.error(`Gemini (${this.id}) Error:`, error.message);
    throw error;
    }
  }
}