
export type DecisionStatus = 'proposed' | 'accepted' | 'rejected';

export interface Decision {
  id: string;
  title: string;
  status: DecisionStatus;
  rationale: string;
}



export interface Artifact {
  version: number;          // a version number to increment 
  summary: string;           // A 1-2 sentence high-level summary of the project state
  facts: string[];           // what we know rn (e.g: "User is using TypeScript")
  decisions: Decision[];       // Choices made (e.g: "Using Clean Architecture")
  open_questions: string[];  // What the AI needs to ask next (e.g: "Which DB?")
  assumptions: string[];     // Implicit context (e.g: "User has Docker installed")
  last_updated: Date;       // metadata , maybe useful later ig
}

export const createInitialArtifact = (): Artifact => ({
  version: 1,
  summary: "New project initialization.",
  facts: [],
  decisions: [],
  open_questions: [],
  assumptions: [],
  last_updated: new Date()
});



// self note- later in controller do: 
// const newChat = {
//   currentArtifact: createInitialArtifact(), this creates a new obj every time i call it so no two ppl shares same memory for chat
// }; somethin like this so 