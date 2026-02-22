import Anthropic from "@anthropic-ai/sdk";
import { AIModelAdapter, AIResponse } from "../../types/ai.js";
import { Message } from "../../types/chat.js";
import { Artifact } from "../../types/artifact.js";
import { GET_SYSTEM_PROMPT } from "../../prompts/system.js";
import { ArtifactService } from "../artifact.service.js";

export class ClaudeAdapter implements AIModelAdapter {
  public id: string;
  public maxTokens = 200000;
  private artifactService: ArtifactService;

  constructor(modelId: string) {
    this.id = modelId;
    this.artifactService = new ArtifactService();
  }

  public async sendMessage(messages: Message[], currentArtifact: Artifact, apiKey: string): Promise<AIResponse> {
    if (!apiKey) throw new Error("Anthropic API Key is missing.");

    const client = new Anthropic({ apiKey });

    const apiMessages: any[] = messages.map((m) => ({
      role: m.role === "assistant" ? "assistant" : "user",
      content: m.content,
    }));

    try {
      const completion = await client.messages.create({
        model: this.id,
        system: GET_SYSTEM_PROMPT(),
        messages: apiMessages,
        max_tokens: 4096,
        temperature: 0.7,
      });

      const textBlock = completion.content.find((block) => block.type === "text");
      const rawContent = textBlock?.type === "text" ? textBlock.text : "";

      const newArtifact = this.artifactService.parseFromText(rawContent, currentArtifact);
      const cleanText = this.artifactService.cleanResponse(rawContent);
      const usage = completion.usage;

      return {
        text: cleanText,
        artifact: newArtifact,
        tokensUsed: {
          input: usage?.input_tokens || 0,
          output: usage?.output_tokens || 0,
          total: (usage?.input_tokens || 0) + (usage?.output_tokens || 0),
        },
      };
    } catch (error: any) {
      console.error(`Claude Adapter (${this.id}) Error:`, error);
      throw new Error(error?.message || "Anthropic API Error");
    }
  }
}