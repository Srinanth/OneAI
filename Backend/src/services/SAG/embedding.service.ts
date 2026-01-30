import { pipeline } from '@xenova/transformers';

export class EmbeddingService {
  private static instance: any;

  static async getExtractor() {
    if (!this.instance) {
      this.instance = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
    }
    return this.instance;
  }

  static async generate(text: string): Promise<number[]> {
    const extractor = await this.getExtractor();
    const output = await extractor(text, { 
      pooling: 'mean', 
      normalize: true 
    });
    
    return Array.from(output.data);
  }
}