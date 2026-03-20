import { create } from 'zustand';
import { 
  VocabularyItem, 
  VocabularyDetail, 
  VocabularyPractice, 
  VocabularyHistory, 
  PracticeHistory 
} from './types';

interface VocabularyState {
  items: VocabularyItem[];
  isLoading: boolean;
  error: string | null;

  // Actions
  fetchVocabularyPaginated: (params: {
    type?: string;
    levelGroup?: string;
    search?: string;
    limit: number;
    lastSeenId?: number | null;
    append?: boolean;
  }) => Promise<any>;

  fetchWordDetails: (word: string) => Promise<VocabularyDetail | null>;
  fetchWordPracticeAll: (word: string) => Promise<VocabularyPractice[]>;
  
  createWord: (item: VocabularyItem) => Promise<VocabularyItem>;
  updateWord: (id: number, item: VocabularyItem) => Promise<VocabularyItem>;
  deleteWord: (id: number) => Promise<void>;

  updatePractice: (id: number, jsonContent: string) => Promise<void>;
  deletePractice: (id: number) => Promise<void>;
  createPractice: (word: string, practice: any) => Promise<VocabularyPractice>;

  fetchWordHistory: (id: number) => Promise<VocabularyHistory[]>;
  rollbackWordToVersion: (historyId: number) => Promise<void>;
  
  fetchPracticeHistory: (id: number) => Promise<PracticeHistory[]>;
  rollbackPracticeToVersion: (historyId: number) => Promise<void>;

  ensureAIContent: (word: string, signal?: AbortSignal) => Promise<void>;
  
  importVocabulary: (file: File) => Promise<{ message: string; count: number }>;
  downloadSampleExcel: () => Promise<void>;
}

const API_BASE_URL = 'http://localhost:8123/api/v1/vocabulary';

const getHeaders = () => {
  const adminToken = localStorage.getItem('admin_token');
  const teacherToken = localStorage.getItem('teacher_token');
  const token = adminToken || teacherToken;

  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {})
  };
};

export const useVocabularyStore = create<VocabularyState>((set) => ({
  items: [],
  isLoading: false,
  error: null,

  fetchVocabularyPaginated: async ({ type, levelGroup, search, limit, lastSeenId, append = false }) => {
    set({ isLoading: true, error: null });
    try {
      const params = new URLSearchParams();
      if (type) params.append('type', type);
      if (levelGroup) params.append('levelGroup', levelGroup);
      if (search) params.append('search', search);
      if (lastSeenId) params.append('lastSeenId', lastSeenId.toString());
      params.append('limit', limit.toString());

      const response = await fetch(`${API_BASE_URL}?${params.toString()}`, {
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to fetch vocabulary');
      const data = await response.json();
      
      set((state) => ({
        items: append ? [...state.items, ...data.items] : data.items,
        isLoading: false
      }));
      
      return data;
    } catch (err: any) {
      console.error('[VocabularyStore] fetchVocabularyPaginated Error:', err);
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },

  fetchWordDetails: async (word: string) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/${encodeURIComponent(word)}/details`, {
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to fetch word details');
      const data = await response.json();
      set({ isLoading: false });
      return data;
    } catch (err: any) {
      console.error('[VocabularyStore] fetchWordDetails Error:', err);
      set({ error: err.message, isLoading: false });
      return null;
    }
  },

  fetchWordPracticeAll: async (word: string) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/${encodeURIComponent(word)}/practice/all`, {
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to fetch practice questions');
      const data = await response.json();
      
      const parsedData = data.map((prac: any) => ({
        ...prac,
        content: prac.jsonContent ? JSON.parse(prac.jsonContent) : null
      }));

      set({ isLoading: false });
      return parsedData;
    } catch (err: any) {
      console.error('[VocabularyStore] fetchWordPracticeAll Error:', err);
      set({ error: err.message, isLoading: false });
      return [];
    }
  },

  createWord: async (item) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(API_BASE_URL, {
        method: 'POST',
        headers: getHeaders(),
        body: JSON.stringify(item)
      });
      if (!response.ok) throw new Error('Failed to create word');
      const data = await response.json();
      set((state) => ({ items: [...state.items, data], isLoading: false }));
      return data;
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },

  updateWord: async (id, item) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/${id}`, {
        method: 'PUT',
        headers: getHeaders(),
        body: JSON.stringify(item)
      });
      if (!response.ok) throw new Error('Failed to update word');
      const data = await response.json();
      set((state) => ({
        items: state.items.map(i => i.id === id ? data : i),
        isLoading: false
      }));
      return data;
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },

  deleteWord: async (id) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/${id}`, {
        method: 'DELETE',
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to delete word');
      set((state) => ({
        items: state.items.filter(i => i.id !== id),
        isLoading: false
      }));
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },

  updatePractice: async (id, jsonContent) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/practice/${id}`, {
        method: 'PUT',
        headers: getHeaders(),
        body: jsonContent
      });
      if (!response.ok) throw new Error('Failed to update practice');
      set({ isLoading: false });
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },

  deletePractice: async (id) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/practice/${id}`, {
        method: 'DELETE',
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to delete practice');
      set({ isLoading: false });
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },

  createPractice: async (word, practice) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/practice/${encodeURIComponent(word)}`, {
        method: 'POST',
        headers: getHeaders(),
        body: JSON.stringify(practice)
      });
      if (!response.ok) throw new Error('Failed to create practice');
      const data = await response.json();
      const parsed = {
        ...data,
        content: data.jsonContent ? JSON.parse(data.jsonContent) : null
      };
      set({ isLoading: false });
      return parsed;
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },

  fetchWordHistory: async (id: number) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/${id}/history`, { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch history');
      const data = await response.json();
      set({ isLoading: false });
      return data;
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      return [];
    }
  },

  rollbackWordToVersion: async (historyId: number) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/history/${historyId}/rollback`, {
        method: 'POST',
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to rollback');
      set({ isLoading: false });
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },

  fetchPracticeHistory: async (id: number) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/practice/${id}/history`, { headers: getHeaders() });
      if (!response.ok) throw new Error('Failed to fetch history');
      const data = await response.json();
      set({ isLoading: false });
      return data;
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      return [];
    }
  },

  rollbackPracticeToVersion: async (historyId: number) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/practice/history/${historyId}/rollback`, {
        method: 'POST',
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to rollback');
      set({ isLoading: false });
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },

  ensureAIContent: async (word: string, signal?: AbortSignal) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/${encodeURIComponent(word)}/ensure-ai-content`, {
        method: 'POST',
        headers: getHeaders(),
        signal: signal
      });
      if (!response.ok) throw new Error('Failed to ensure AI content');
      set({ isLoading: false });
    } catch (err: any) {
      if (err.name === 'AbortError') {
         console.log('[VocabularyStore] ensureAIContent Aborted by user');
         set({ isLoading: false });
         return;
      }
      console.error('[VocabularyStore] ensureAIContent Error:', err);
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },
  
  importVocabulary: async (file: File) => {
    set({ isLoading: true, error: null });
    const formData = new FormData();
    formData.append('file', file);
    
    // Custom headers for FormData (exclude Content-Type to let browser set boundary)
    const adminToken = localStorage.getItem('admin_token');
    const teacherToken = localStorage.getItem('teacher_token');
    const token = adminToken || teacherToken;
    const headers: any = token ? { 'Authorization': `Bearer ${token}` } : {};

    try {
      const response = await fetch(`${API_BASE_URL}/import`, {
        method: 'POST',
        headers,
        body: formData
      });
      if (!response.ok) throw new Error('Failed to import vocabulary');
      const data = await response.json();
      set({ isLoading: false });
      return data;
    } catch (err: any) {
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },

  downloadSampleExcel: async () => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`${API_BASE_URL}/sample`, {
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to download sample file');
      
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'vocabulary_sample.xlsx';
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
      
      set({ isLoading: false });
    } catch (err: any) {
      console.error('[VocabularyStore] downloadSampleExcel Error:', err);
      set({ error: err.message, isLoading: false });
      throw err;
    }
  },
}));
