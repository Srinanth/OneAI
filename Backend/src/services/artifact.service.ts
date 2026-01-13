import { Artifact } from '../types/artifact';

export class ArtifactService {
  private static STARTING = '---ARTIFACT_START---';
  private static ENDING = '---ARTIFACT_END---';

  /**
   * Extracts and parses the artifact JSON from the raw AI response.
   * @param Response - The full string response from the AI.
   * @param previousArtifact - The last known good state.
   * @returns The final resultant artifact.
   */


  public parseFromText(Response: string, previousArtifact: Artifact): Artifact {
    try {
      const startIndex = Response.indexOf(ArtifactService.STARTING);
      const endIndex = Response.indexOf(ArtifactService.ENDING);

      if (startIndex === -1 || endIndex === -1) {
        console.log('ArtifactService: The AI did not successfully respond with provided rules. so using prev state.');
        return previousArtifact;
      }

      let jsonString = Response.substring(
        startIndex + ArtifactService.STARTING.length, 
        endIndex
      ).trim();

      jsonString = jsonString.replace(/^```json/, '').replace(/^```/, '').replace(/```$/, '');

      const parsed: any = JSON.parse(jsonString);

      const safeArtifact: Artifact = {
        version: typeof parsed.version === 'number' ? parsed.version : previousArtifact.version,
        summary: parsed.summary || previousArtifact.summary,
        facts: Array.isArray(parsed.facts) ? parsed.facts : previousArtifact.facts,
        decisions: Array.isArray(parsed.decisions) ? parsed.decisions : previousArtifact.decisions,
        open_questions: Array.isArray(parsed.open_questions) ? parsed.open_questions : previousArtifact.open_questions,
        assumptions: Array.isArray(parsed.assumptions) ? parsed.assumptions : previousArtifact.assumptions,
        last_updated: parsed.last_updated ? new Date(parsed.last_updated) : new Date()
      };

      return safeArtifact;

    } catch (error) {
      console.error('ArtifactService: Failed to parse JSON, returns prev artifact.', error);
      return previousArtifact;
    }
  }

  public cleanResponse(Response: string): string {
    const startIndex = Response.indexOf(ArtifactService.STARTING);
    if (startIndex === -1) return Response;
    
    return Response.substring(0, startIndex).trim();
  }
}