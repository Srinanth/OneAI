import * as cheerio from 'cheerio';
import { RecursiveCharacterTextSplitter } from "@langchain/textsplitters";
import { EmbeddingService } from "./embedding.service.js";
import { supabase } from "../supabase.js";

export class SearchService {
  private static readonly USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Mobile/15E148 Safari/604.1'
  ];

  private static getHeaders() {
    return {
      'User-Agent': this.USER_AGENTS[Math.floor(Math.random() * this.USER_AGENTS.length)]!,
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.5',
      'DNT': '1',
      'Upgrade-Insecure-Requests': '1',
    };
  }

static async getWebUrls(query: string): Promise<string[]> {
        try {
            const searchUrl = `https://duckduckgo.com/html/?q=${encodeURIComponent(query)}`;
            const response = await fetch(searchUrl, { 
            headers: {
            ...this.getHeaders(),
            'Referer': 'https://duckduckgo.com/',
        }
    });

    if (!response.ok) throw new Error(`Status ${response.status}`);
    
    const html = await response.text();
    const $ = cheerio.load(html);
    const links: string[] = [];
    $('a').each((_, el) => {
      let url = $(el).attr('href');
      
      if (url) {
        if (url.includes('uddg=')) {
          const encodedUrl = url.split('uddg=')[1]?.split('&')[0];
          if (encodedUrl) {
            url = decodeURIComponent(encodedUrl);
          }
        }
        const isExternal = url.startsWith('http') && !url.includes('duckduckgo.com');
        const isNotJunk = !url.includes('bit.ly') && !url.includes('feedback');

        if (isExternal && isNotJunk) {
          if (!links.includes(url)) {
            links.push(url);
          }
        }
      }
    });

    const resultLinks = links.filter(l => !l.includes('google.com')).slice(0, 3);
    return resultLinks;
  } catch (e) {
    console.error(" Search failed:", e);
    return [];
  }
}

  static async crawlAndExtract(url: string): Promise<string> {
    const domain = new URL(url).hostname;
    try {
      const response = await fetch(url, { 
        headers: this.getHeaders(),
        signal: AbortSignal.timeout(8000)
      });

      if (!response.ok) return "";
      
      const html = await response.text();
      const $ = cheerio.load(html);

      $('script, style, nav, footer, header, aside, .ads, #comments, .menu, .sidebar').remove();

      const contentSelectors = ['article', 'main', '.content', '.post-content', '.entry-content', 'body'];
      let mainText = "";

      for (const selector of contentSelectors) {
        const text = $(selector).text().trim();
        if (text.length > 600) { 
          mainText = text;
          break;
        }
      }

      const result = mainText.replace(/\s+/g, ' ').trim();
      return result;
    } catch (e) {
      console.warn(` Crawl timed out/failed: ${domain}`);
      return "";
    }
  }

  static async processAndStore(chatId: string, url: string, rawText: string) {
    if (!rawText || rawText.length < 150) return;
    const splitter = new RecursiveCharacterTextSplitter({
      chunkSize: 600,
      chunkOverlap: 100,
    });

    const chunks = await splitter.splitText(rawText);
    const validChunks = chunks.filter(c => c.length > 100).slice(0, 10);

    try {
      const insertData = await Promise.all(
        validChunks.map(async (chunk) => {
          const embedding = await EmbeddingService.generate(chunk);
          return {
            chat_id: chatId,
            content: chunk,
            embedding: embedding,
            url: url
          };
        })
      );

      const { error } = await supabase.from('search_context').insert(insertData);
      if (error) throw error;
    } catch (e) {
      console.error(" Storage Error:", e);
    }
  }

  static async getRelevantContext(chatId: string, userQuery: string): Promise<string> {
      const queryVector = await EmbeddingService.generate(userQuery);

      const { data: contextChunks, error } = await supabase.rpc('match_search_context', {
        query_embedding: queryVector,
        match_threshold: 0.35,
        match_count: 5,
        p_chat_id: chatId
      });

      if (error || !contextChunks) return "";
      return contextChunks
        .map((c: any) => `[Source: ${c.url}]\n${c.content}`)
        .join("\n\n---\n\n");   
  }

  static buildRAGPrompt(userQuery: string, context: string): string {
    return `
      You are an AI assistant with real-time web access. 
      Use the provided SEARCH CONTEXT to answer the user query accurately.
      
      SEARCH CONTEXT:
      ${context}

      USER QUERY:
      ${userQuery}

      INSTRUCTIONS:
      1. Prioritize information from the search context.
      2. If you use information from the context, cite the [Source: URL] inline.
      3. If the context is insufficient, state that the search results were limited but provide an answer based on your general knowledge.
    `;
  }
}