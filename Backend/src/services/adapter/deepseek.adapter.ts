import OpenAI from "openai";
import { AIModelAdapter, AIResponse } from "../../types/ai.js";
import { Message } from "../../types/chat.js";
import { Artifact } from "../../types/artifact.js";
import { GET_SYSTEM_PROMPT } from "../../prompts/system.js";
import { ArtifactService } from "../artifact.service.js";

export class DeepSeekAdapter implements AIModelAdapter {
  public id: string;
  public maxTokens = 64000;
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
  }
}