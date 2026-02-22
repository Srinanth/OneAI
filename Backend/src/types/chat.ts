
export type Role = 'system' | 'user' | 'assistant';
// actually roles are used to pass context bw admin,user,ai models

export interface Message {
  id: string;
  role: Role;
  content: string;      // The text displayed to the user
  timestamp: Date;
}

