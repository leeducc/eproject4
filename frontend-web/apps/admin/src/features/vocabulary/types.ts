import { Role } from '../quiz-bank/types';

export interface VocabularyItem {
  id?: number;
  word: string;
  type: string; 
  level: string;
  levelGroup: string;
  pos: string;
  definitionUrl?: string;
  voiceUrl?: string;
  definition?: string;
  examples?: string[];
  synonyms?: string[];
  phonetic?: string;
  isPremium?: boolean;
}

export interface VocabularyDetail {
  definition: string;
  examples: string[];
  synonyms: string[];
  phonetic?: string;
}

export interface VocabularyPractice {
  id: number;
  word: string;
  quizType: string;
  jsonContent: string; 
  content?: PracticeQuiz;
  version?: number;
}

export interface PracticeQuiz {
  type: string;
  question?: string;
  options?: string[];
  answer?: string;
  pairs?: { word: string; meaning: string }[];
  sentence?: string;
}

export interface VocabularyHistory {
  id: number;
  vocabularyId: number;
  editorId: number;
  editorName?: string;
  action: string;
  snapshot: string;
  changes?: string;
  createdAt: string;
}

export interface PracticeHistory {
  id: number;
  practiceId: number;
  editorId: number;
  editorName?: string;
  action: string;
  snapshot: string;
  version?: number;
  createdAt: string;
}
