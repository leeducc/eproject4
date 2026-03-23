import { create } from 'zustand';
import { Passage, Question, Role, Exam, SkillType, QuestionHistory, QuestionGroup } from './types';

interface QuizBankState {
  currentUser: { role: Role; name: string; id?: number };
  passages: Passage[];
  questions: Question[];
  questionGroups: QuestionGroup[];
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
    authorId?: number;
    limit: number; 
    lastSeenId?: number | null; 
    append?: boolean 
  }) => Promise<any>;
  fetchQuestionById: (id: number) => Promise<Question | null>;
  createQuestion: (question: Omit<Question, 'id'>, mediaFiles?: File[]) => Promise<any>;
  updateQuestion: (id: number, question: Partial<Question>, mediaFiles?: File[]) => Promise<any>;
  deleteQuestion: (id: number) => Promise<void>;
  uploadMedia: (file: File, context?: string) => Promise<string>;
  importQuestions: (file: File) => Promise<void>;
  exportQuestions: () => Promise<void>;
  downloadSampleExcel: () => Promise<void>;
  fetchQuestionHistory: (id: number) => Promise<QuestionHistory[]>;
  rollbackToVersion: (historyId: number) => Promise<void>;

  // Question Groups
  fetchGroups: (skill?: SkillType) => Promise<void>;
  fetchGroupById: (id: number) => Promise<QuestionGroup | null>;
  createGroup: (group: any, mediaFile?: File) => Promise<any>;
  updateGroup: (id: number, group: any, mediaFile?: File) => Promise<any>;
  deleteGroup: (id: number) => Promise<void>;

  fetchExams: () => Promise<void>;
  fetchExamById: (id: number) => Promise<Exam | null>;
  createExam: (exam: Omit<Exam, 'id' | 'created_at'>) => Promise<void>;
  updateExam: (id: number, exam: Partial<Exam>) => Promise<void>;
  deleteExam: (id: number) => Promise<void>;
  
  // Tags
  fetchTags: () => Promise<any[]>;
  filterQuestionsByTags: (request: any) => Promise<Question[]>;
}

const API_BASE_URL = 'http://localhost:8123/api/v1';

const getHeaders = () => {
  const adminToken = localStorage.getItem('admin_token');
  const teacherToken = localStorage.getItem('teacher_token');
  const token = adminToken || teacherToken;
  
  console.log(`[QuizBankStore] getHeaders - using token: ${token ? (adminToken ? 'admin' : 'teacher') : 'none'}`);
  
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {})
  };
};

const getInitialUser = () => {
  const adminToken = localStorage.getItem('admin_token');
  const teacherToken = localStorage.getItem('teacher_token');
  const isTeacherPath = typeof window !== 'undefined' && window.location.pathname.startsWith('/teacher');
  
  if (isTeacherPath && teacherToken) {
    const savedUser = localStorage.getItem('teacher_user');
    if (savedUser) {
      try {
        return JSON.parse(savedUser);
      } catch (e) {
        console.error('[QuizBankStore] Failed to parse teacher_user', e);
      }
    }
    return { name: 'Teacher User', role: 'TEACHER' as Role };
  }
  
  if (adminToken) {
    const savedUser = localStorage.getItem('admin_user');
    if (savedUser) {
      try {
        return JSON.parse(savedUser);
      } catch (e) {
        console.error('[QuizBankStore] Failed to parse admin_user', e);
      }
    }
    return { name: 'Admin User', role: 'ADMIN' as Role };
  } else if (teacherToken) {
    const savedUser = localStorage.getItem('teacher_user');
    if (savedUser) {
      try {
        return JSON.parse(savedUser);
      } catch (e) {
        console.error('[QuizBankStore] Failed to parse teacher_user', e);
      }
    }
    return { name: 'Teacher User', role: 'TEACHER' as Role };
  }
  
  return { name: 'Guest User', role: 'TEACHER' as Role };
};

export const useQuizBankStore = create<QuizBankState>((set, get) => ({
  currentUser: getInitialUser(),
  passages: [
    { id: 1, title: 'Sample Passage 1', content: 'This is a test passage.', skill: 'READING' }
  ],
  questions: [],
  questionGroups: [],
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

  fetchQuestionsPaginated: async ({ skill, type, difficulty, search, authorId, limit, lastSeenId, append = false }) => {
    set({ isLoading: true, error: null });
    try {
      const params = new URLSearchParams();
      if (skill) params.append('skill', skill);
      if (type) params.append('type', type);
      if (difficulty) params.append('difficulty', difficulty);
      if (search) params.append('search', search);
      if (authorId) params.append('authorId', authorId.toString());
      if (lastSeenId) params.append('lastSeenId', lastSeenId.toString());
      params.append('limit', limit.toString());

      const response = await fetch(`${API_BASE_URL}/questions/paginated?${params.toString()}`, {
        headers: getHeaders()
      });
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
      return newQuestion;
    } catch (err: any) {
      console.error('[QuizBankStore] createQuestion Error:', err);
      set({ error: err.message || 'Failed to create question', isLoading: false });
      throw err;
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
      return updatedQuestion;
    } catch (err: any) {
      console.error('[QuizBankStore] updateQuestion Error:', err);
      set({ error: err.message || 'Failed to update question', isLoading: false });
      throw err;
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
    const { currentUser, questions, deleteGroup } = get();
    if (currentUser.role === 'TEACHER') {
      console.warn(`[QuizBankStore] Action blocked: TEACHER cannot delete questions.`);
      return;
    }

    const questionToDelete = questions.find(q => q.id === id);
    if (questionToDelete?.isGroup) {
      return deleteGroup(id);
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

  fetchGroups: async (skill?: SkillType) => {
    set({ isLoading: true, error: null });
    try {
      const url = skill ? `${API_BASE_URL}/quizbank/groups?skill=${skill}` : `${API_BASE_URL}/quizbank/groups`;
      const response = await fetch(url, { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch groups');
      const data = await response.json();
      set({ questionGroups: data, isLoading: false });
    } catch (err: any) {
      console.error('[QuizBankStore] fetchGroups Error:', err);
      set({ error: err.message || 'Failed to fetch groups', isLoading: false });
    }
  },

  createGroup: async (groupConfig) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/quizbank/groups`, {
        method: 'POST',
        headers: getHeaders(),
        body: JSON.stringify(groupConfig),
      });
      if (!response.ok) throw new Error('Failed to create question group');
      const newGroup = await response.json();
      set((state) => ({ questionGroups: [...state.questionGroups, newGroup], isLoading: false }));
      return newGroup;
    } catch (err: any) {
      console.error('[QuizBankStore] createGroup Error:', err);
      set({ error: err.message || 'Failed to create group', isLoading: false });
      throw err;
    }
  },

  updateGroup: async (id, updatedFields) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/quizbank/groups/${id}`, {
        method: 'PUT',
        headers: getHeaders(),
        body: JSON.stringify(updatedFields),
      });
      if (!response.ok) throw new Error('Failed to update question group');
      const updatedGroup = await response.json();
      set((state) => ({
        isLoading: false,
        questionGroups: state.questionGroups.map((g) => (g.id === id ? updatedGroup : g)),
      }));
      return updatedGroup;
    } catch (err: any) {
      console.error('[QuizBankStore] updateGroup Error:', err);
      set({ error: err.message || 'Failed to update group', isLoading: false });
      throw err;
    }
  },

  deleteGroup: async (id) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/quizbank/groups/${id}`, {
        method: 'DELETE',
        headers: getHeaders(),
      });
      if (!response.ok) throw new Error('Failed to delete question group');
      set((state) => ({
        isLoading: false,
        questionGroups: state.questionGroups.filter((g) => g.id !== id),
      }));
    } catch (err: any) {
      console.error('[QuizBankStore] deleteGroup Error:', err);
      set({ error: err.message || 'Failed to delete group', isLoading: false });
    }
  },

  fetchGroupById: async (id: number) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/quizbank/groups/${id}`, { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch group');
      const data = await response.json();
      console.log(`[QuizBankStore] Fetched group ${id}`, data);
      
      set((state) => ({
        isLoading: false,
        questionGroups: state.questionGroups.some(g => g.id === id)
          ? state.questionGroups.map(g => g.id === id ? data : g)
          : [...state.questionGroups, data]
      }));
      
      return data;
    } catch (err: any) {
      console.error('[QuizBankStore] fetchGroupById Error:', err);
      set({ error: err.message || 'Failed to fetch group', isLoading: false });
      return null;
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

  fetchExamById: async (id: number) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/exams/${id}`, { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch exam');
      const data = await response.json();
      set({ isLoading: false });
      return data;
    } catch (err: any) {
      console.error('[QuizBankStore] fetchExamById Error:', err);
      set({ error: err.message || 'Failed to fetch exam', isLoading: false });
      return null;
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

  importQuestions: async (file: File) => {
    set({ isLoading: true, error: null });
    try {
      const formData = new FormData();
      formData.append('file', file);

      const headers = getHeaders();
      delete (headers as any)['Content-Type'];

      const response = await fetch(`${API_BASE_URL}/questions/import`, {
        method: 'POST',
        headers,
        body: formData,
      });

      if (!response.ok) throw new Error('Failed to import questions');
      
      console.log('[QuizBankStore] Questions imported successfully');
      set({ isLoading: false });
    } catch (err: any) {
      console.error('[QuizBankStore] importQuestions Error:', err);
      set({ error: err.message || 'Failed to import questions', isLoading: false });
      throw err;
    }
  },

  exportQuestions: async () => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/questions/export`, {
        method: 'GET',
        headers: getHeaders(),
      });

      if (!response.ok) throw new Error('Failed to export questions');

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `questions_${new Date().toISOString().split('T')[0]}.xlsx`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
      
      set({ isLoading: false });
    } catch (err: any) {
      console.error('[QuizBankStore] exportQuestions Error:', err);
      set({ error: err.message || 'Failed to export questions', isLoading: false });
      throw err;
    }
  },

  downloadSampleExcel: async () => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/questions/sample-excel`, {
        method: 'GET',
        headers: getHeaders(),
      });

      if (!response.ok) throw new Error('Failed to download sample excel');

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `sample_questions.xlsx`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
      
      set({ isLoading: false });
    } catch (err: any) {
      console.error('[QuizBankStore] downloadSampleExcel Error:', err);
      set({ error: err.message || 'Failed to download sample excel', isLoading: false });
      throw err;
    }
  },

  fetchQuestionHistory: async (id: number) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/questions/${id}/history`, { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch question history');
      const data = await response.json();
      set({ isLoading: false });
      return data;
    } catch (err: any) {
      console.error('[QuizBankStore] fetchQuestionHistory Error:', err);
      set({ error: err.message || 'Failed to fetch question history', isLoading: false });
      return [];
    }
  },

  rollbackToVersion: async (historyId: number) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/questions/history/${historyId}/rollback`, {
        method: 'POST',
        headers: getHeaders(),
      });
      if (!response.ok) throw new Error('Failed to rollback question');
      
      console.log(`[QuizBankStore] Rolled back to version ${historyId}`);
      set({ isLoading: false });
    } catch (err: any) {
      console.error('[QuizBankStore] rollbackToVersion Error:', err);
      set({ error: err.message || 'Failed to rollback question', isLoading: false });
      throw err;
    }
  },

  fetchTags: async () => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/quizbank/tags`, { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch tags');
      const data = await response.json();
      set({ isLoading: false });
      return data;
    } catch (err: any) {
      console.error('[QuizBankStore] fetchTags Error:', err);
      set({ error: err.message || 'Failed to fetch tags', isLoading: false });
      return [];
    }
  },

  filterQuestionsByTags: async (filterRequest: any) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/questions/filter`, {
        method: 'POST',
        headers: getHeaders(),
        body: JSON.stringify(filterRequest),
      });
      if (!response.ok) throw new Error('Failed to filter questions');
      const data = await response.json();
      set({ questions: data, isLoading: false });
      return data;
    } catch (err: any) {
      console.error('[QuizBankStore] filterQuestions Error:', err);
      set({ error: err.message || 'Failed to filter questions', isLoading: false });
      return [];
    }
  },
}));
