import { create } from 'zustand';
import { Passage, Question, Role, Exam, SkillType } from './types';

interface QuizBankState {
  currentUser: { role: Role; name: string };
  passages: Passage[];
  questions: Question[];
  exams: Exam[];
  isLoading: boolean;
  error: string | null;
  
  // Actions
  switchRole: (role: Role) => void;
  
  // Async Data Fetching
  fetchQuestions: (skill?: SkillType) => Promise<void>;
  fetchQuestionsPaginated: (params: { 
    skill?: SkillType; 
    type?: string; 
    difficulty?: string; 
    search?: string;
    limit: number; 
    lastSeenId?: number | null; 
    append?: boolean 
  }) => Promise<any>;
  fetchQuestionById: (id: number) => Promise<Question | null>;
  createQuestion: (question: Omit<Question, 'id'>, mediaFiles?: File[]) => Promise<void>;
  updateQuestion: (id: number, question: Partial<Question>, mediaFiles?: File[]) => Promise<void>;
  deleteQuestion: (id: number) => Promise<void>;
  uploadMedia: (file: File, context?: string) => Promise<string>;

  fetchExams: () => Promise<void>;
  createExam: (exam: Omit<Exam, 'id' | 'created_at'>) => Promise<void>;
  updateExam: (id: number, exam: Partial<Exam>) => Promise<void>;
  deleteExam: (id: number) => Promise<void>;
}

const API_BASE_URL = 'http://localhost/api/v1';

const getHeaders = () => {
  const token = localStorage.getItem('admin_token');
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {})
  };
};

export const useQuizBankStore = create<QuizBankState>((set, get) => ({
  currentUser: { role: 'ADMIN', name: 'Admin User' },
  passages: [
    { id: 1, title: 'Sample Passage 1', content: 'This is a test passage.', skill: 'READING' }
  ],
  questions: [],
  exams: [],
  isLoading: false,
  error: null,

  switchRole: (role: Role) => set((state) => {
    console.log(`[QuizBankStore] Switched role to ${role}`);
    return { currentUser: { ...state.currentUser, role } };
  }),

  fetchQuestions: async (skill?: SkillType) => {
    set({ isLoading: true, error: null });
    try {
      const url = skill ? `${API_BASE_URL}/questions?skill=${skill}` : `${API_BASE_URL}/questions`;
      const response = await fetch(url, { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch questions');
      const data = await response.json();
      set({ questions: data, isLoading: false });
    } catch (err: any) {
      console.error('[QuizBankStore] fetchQuestions Error:', err);
      set({ error: err.message || 'Failed to fetch questions', isLoading: false });
    }
  },

  fetchQuestionsPaginated: async ({ skill, type, difficulty, search, limit, lastSeenId, append }) => {
    set({ isLoading: true, error: null });
    try {
      const url = new URL(`${API_BASE_URL}/questions/paginated`);
      if (skill) url.searchParams.append('skill', skill);
      if (type) url.searchParams.append('type', type);
      if (difficulty) url.searchParams.append('difficulty', difficulty);
      if (search) url.searchParams.append('search', search);
      if (limit) url.searchParams.append('limit', limit.toString());
      if (lastSeenId) url.searchParams.append('lastSeenId', lastSeenId.toString());

      const response = await fetch(url.toString(), { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch paginated questions');
      const data = await response.json(); // { items, nextCursor, hasMore }
      
      set((state) => ({ 
        questions: append ? [...state.questions, ...data.items] : data.items,
        isLoading: false 
      }));
      
      return data; // Return full payload for component-level cursor management
    } catch (err: any) {
      console.error('[QuizBankStore] fetchQuestionsPaginated Error:', err);
      set({ error: err.message || 'Failed to fetch paginated questions', isLoading: false });
      throw err;
    }
  },

  fetchQuestionById: async (id: number) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/questions/${id}`, { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch question');
      const data = await response.json();
      console.log(`[QuizBankStore] Fetched question ${id}`, data);
      
      // Update the local list if it exists
      set((state) => ({
        isLoading: false,
        questions: state.questions.some(q => q.id === id) 
          ? state.questions.map(q => q.id === id ? data : q)
          : [...state.questions, data]
      }));
      
      return data;
    } catch (err: any) {
      console.error('[QuizBankStore] fetchQuestionById Error:', err);
      set({ error: err.message || 'Failed to fetch question', isLoading: false });
      return null;
    }
  },

  createQuestion: async (questionConfig, mediaFiles?: File[]) => {
    set({ isLoading: true, error: null });
    try {
      const token = localStorage.getItem('admin_token');
      console.log('[QuizBankStore] createQuestion - token present:', !!token);
      console.log('[QuizBankStore] createQuestion - payload:', questionConfig);

      const headers = getHeaders();
      delete (headers as any)['Content-Type'];

      const formData = new FormData();
      formData.append(
        'question',
        new Blob([JSON.stringify(questionConfig)], { type: 'application/json' })
      );
      if (mediaFiles && mediaFiles.length > 0) {
        mediaFiles.forEach(file => formData.append('media', file));
      }

      const response = await fetch(`${API_BASE_URL}/questions`, {
        method: 'POST',
        headers,
        body: formData,
      });

      if (!response.ok) {
        const errorBody = await response.text();
        console.error(`[QuizBankStore] createQuestion - HTTP ${response.status}:`, errorBody);
        throw new Error(`Failed to create question (${response.status}): ${errorBody}`);
      }

      const newQuestion = await response.json();
      console.log(`[QuizBankStore] Created question`, newQuestion);
      set((state) => ({ questions: [...state.questions, newQuestion], isLoading: false }));
    } catch (err: any) {
      console.error('[QuizBankStore] createQuestion Error:', err);
      set({ error: err.message || 'Failed to create question', isLoading: false });
    }
  },

  updateQuestion: async (id, updatedFields, mediaFiles?: File[]) => {
    set({ isLoading: true, error: null });
    try {
      const headers = getHeaders();
      delete (headers as any)['Content-Type'];

      const formData = new FormData();
      formData.append(
        'question',
        new Blob([JSON.stringify(updatedFields)], { type: 'application/json' })
      );
      if (mediaFiles && mediaFiles.length > 0) {
        mediaFiles.forEach(file => formData.append('media', file));
      }

      const response = await fetch(`${API_BASE_URL}/questions/${id}`, {
        method: 'PUT',
        headers,
        body: formData,
      });
      if (!response.ok) throw new Error('Failed to update question');
      const updatedQuestion = await response.json();
      console.log(`[QuizBankStore] Updating question ${id} with`, updatedQuestion);
      set((state) => ({
        isLoading: false,
        questions: state.questions.map((q) => (q.id === id ? updatedQuestion : q)),
      }));
    } catch (err: any) {
      console.error('[QuizBankStore] updateQuestion Error:', err);
      set({ error: err.message || 'Failed to update question', isLoading: false });
    }
  },

  uploadMedia: async (file: File, context?: string) => {
    set({ isLoading: true, error: null });
    try {
      const formData = new FormData();
      formData.append('file', file);

      const headers = getHeaders();
      delete (headers as any)['Content-Type'];

      const url = new URL(`${API_BASE_URL.replace('/v1', '')}/media/upload`);
      if (context) {
        url.searchParams.append('context', context);
      }

      const response = await fetch(url.toString(), {
        method: 'POST',
        headers,
        body: formData,
      });

      if (!response.ok) {
        throw new Error('Failed to upload media');
      }

      const data = await response.json();
      console.log(`[QuizBankStore] Media uploaded to ${context || 'default'}:`, data.storedPath);
      set({ isLoading: false });
      return data.storedPath;
    } catch (err: any) {
      console.error('[QuizBankStore] uploadMedia Error:', err);
      set({ error: err.message || 'Failed to upload media', isLoading: false });
      throw err;
    }
  },

  deleteQuestion: async (id) => {
    const { currentUser } = get();
    if (currentUser.role === 'TEACHER') {
      console.warn(`[QuizBankStore] Action blocked: TEACHER cannot delete questions.`);
      return; 
    }
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/questions/${id}`, {
        method: 'DELETE',
        headers: getHeaders(),
      });
      if (!response.ok) throw new Error('Failed to delete question');
      console.log(`[QuizBankStore] Deleted question ${id}`);
      set((state) => ({
        isLoading: false,
        questions: state.questions.filter((q) => q.id !== id),
      }));
    } catch (err: any) {
      console.error('[QuizBankStore] deleteQuestion Error:', err);
      set({ error: err.message || 'Failed to delete question', isLoading: false });
    }
  },

  fetchExams: async () => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/exams`, { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch exams');
      const data = await response.json();
      set({ exams: data, isLoading: false });
    } catch (err: any) {
      console.error('[QuizBankStore] fetchExams Error:', err);
      set({ error: err.message || 'Failed to fetch exams', isLoading: false });
    }
  },

  createExam: async (examConfig) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/exams`, {
        method: 'POST',
        headers: getHeaders(),
        body: JSON.stringify(examConfig),
      });
      if (!response.ok) throw new Error('Failed to create exam');
      const newExam = await response.json();
      console.log(`[QuizBankStore] Created exam`, newExam);
      set((state) => ({ exams: [...state.exams, newExam], isLoading: false }));
    } catch (err: any) {
      console.error('[QuizBankStore] createExam Error:', err);
      set({ error: err.message || 'Failed to create exam', isLoading: false });
    }
  },

  updateExam: async (id, updatedFields) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/exams/${id}`, {
        method: 'PUT',
        headers: getHeaders(),
        body: JSON.stringify(updatedFields),
      });
      if (!response.ok) throw new Error('Failed to update exam');
      const updatedExam = await response.json();
      console.log(`[QuizBankStore] Updating exam ${id} with`, updatedExam);
      set((state) => ({
        isLoading: false,
        exams: state.exams.map((e) => (e.id === id ? updatedExam : e)),
      }));
    } catch (err: any) {
      console.error('[QuizBankStore] updateExam Error:', err);
      set({ error: err.message || 'Failed to update exam', isLoading: false });
    }
  },

  deleteExam: async (id) => {
    const { currentUser } = get();
    if (currentUser.role === 'TEACHER') {
      console.warn(`[QuizBankStore] Action blocked: TEACHER cannot delete exams.`);
      return;
    }
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/exams/${id}`, {
        method: 'DELETE',
        headers: getHeaders(),
      });
      if (!response.ok) throw new Error('Failed to delete exam');
      console.log(`[QuizBankStore] Deleted exam ${id}`);
      set((state) => ({
        isLoading: false,
        exams: state.exams.filter((e) => e.id !== id),
      }));
    } catch (err: any) {
      console.error('[QuizBankStore] deleteExam Error:', err);
      set({ error: err.message || 'Failed to delete exam', isLoading: false });
    }
  },
}));
