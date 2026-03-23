export type Role = 'ADMIN' | 'TEACHER';
export type SkillType = 'READING' | 'LISTENING' | 'VOCABULARY' | 'WRITING';
export type QuestionType = 'MULTIPLE_CHOICE' | 'MATCHING' | 'FILL_BLANK' | 'ESSAY' | 'COMPREHENSION';
export type DifficultyBand = 'BAND_0_4' | 'BAND_5_6' | 'BAND_7_8' | 'BAND_9';

export interface QuestionGroup {
  id: number;
  skill: SkillType;
  title: string;
  content: string;
  mediaUrl?: string;
  mediaType?: string;
  difficultyBand: DifficultyBand;
  authorId?: number;
  createdAt: string;
  questions: Question[];
  tags: Tag[];
}

export interface Tag {
  id: number;
  name: string;
  namespace: string;
  color?: string;
}

export interface Passage {
  id: number;
  title: string;
  content: string; // Text content or URL for script
  media_url?: string; // Audio file URL
  skill: SkillType;
}

// -- Question Data Payloads --

export interface MultipleChoiceData {
  options: { id: string; label: string; image?: string }[];
  correct_ids: string[];
  multiple_select: boolean;
  answer_with_image?: boolean;
}

export interface MatchingData {
  left_items: { id: string; text: string; image?: string }[];
  right_items: { id: string; text: string; image?: string }[];
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
  mediaUrls?: string[];
  mediaTypes?: string[];
  retainedMediaUrls?: string[];
  data: any | MultipleChoiceData | MatchingData | FillBlankData;
  isPremiumContent: boolean;
  groupId?: number;
  authorId?: number;
  isGroup?: boolean;
  childCount?: number;
  tags: Tag[];
}

export type ExamType = 'ORG_EXAM' | 'REAL_EXAM' | 'IELTS';

export interface Exam {
  id: number;
  title: string;
  description?: string;
  exam_type: ExamType;
  created_at: string;
  categories: SkillType[];
  question_ids: number[]; // References to Questions stored in the Exam
  group_ids: number[]; // References to QuestionGroups stored in the Exam
  tags: Tag[];
}

export interface QuestionHistory {
  id: number;
  questionId: number;
  editorId: number;
  editorEmail: string;
  action: string;
  snapshot: string;
  changes?: string;
  createdAt: string;
}
