export type Role = 'ADMIN' | 'TEACHER';
export type SkillType = 'READING' | 'LISTENING' | 'VOCABULARY' | 'WRITING';
export type QuestionType = 'MULTIPLE_CHOICE' | 'MATCHING' | 'FILL_BLANK';
export type DifficultyBand = 'BAND_0_4' | 'BAND_5_6' | 'BAND_7_8' | 'BAND_9';

export interface Passage {
  id: number;
  title: string;
  content: string; // Text content or URL for script
  media_url?: string; // Audio file URL
  skill: SkillType;
}

// -- Question Data Payloads --

export interface MultipleChoiceData {
  options: { id: string; label: string }[];
  correct_ids: string[];
  multiple_select: boolean;
  answer_with_image?: boolean;
}

export interface MatchingData {
  left_items: { id: number | string; text: string }[];
  right_items: { id: number | string; text: string }[];
  solution: Record<string, string>; // Maps left_id to right_id
}

export interface FillBlankData {
  template: string; // e.g., "The [blank1] is [blank2]."
  blanks: Record<string, { correct: string[]; max_words: number }>;
  answer_pool?: string[]; // Optional: For drag-and-drop word banks
}

export interface Question {
  id: number;
  skill: SkillType; // Added skill association directly to question for easy filtering
  type: QuestionType;
  difficultyBand: DifficultyBand;
  instruction?: string;
  explanation?: string;
  data: any | MultipleChoiceData | MatchingData | FillBlankData;
  isPremiumContent: boolean;
}

export interface Exam {
  id: number;
  title: string;
  description?: string;
  created_at: string;
  categories: SkillType[];
  question_ids: number[]; // References to Questions stored in the Exam
}
