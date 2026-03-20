import { create } from 'zustand';

export type UserRole = 'ADMIN' | 'TEACHER' | 'CUSTOMER';
export type UserStatus = 'ACTIVE' | 'SUSPENDED' | 'INACTIVE';

export interface User {
  id: number;
  email: string;
  role: UserRole;
  status: UserStatus;
  fullName: string | null;
  address: string | null;
  birthday: string | null;
  phoneNumber: string | null;
  createdAt: string;
  isPro: boolean;
  iCoinBalance: number;
  isEmailConfirmed: boolean;
}

interface UserState {
  users: User[];
  isLoading: boolean;
  error: string | null;
  
  // Filters
  searchQuery: string;
  roleFilter: UserRole | 'ALL';
  
  // Actions
  setSearchQuery: (query: string) => void;
  setRoleFilter: (role: UserRole | 'ALL') => void;
  fetchUsers: () => Promise<void>;
  updateUserBalance: (userId: number, amount: number) => void;
}

const API_BASE_URL = 'http://localhost:8123/api/admin';

const getHeaders = () => {
  const token = localStorage.getItem('admin_token');
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {})
  };
};

export const useUserStore = create<UserState>((set, get) => ({
  users: [],
  isLoading: false,
  error: null,
  searchQuery: '',
  roleFilter: 'ALL',

  setSearchQuery: (query: string) => {
    set({ searchQuery: query });
  },

  setRoleFilter: (role: UserRole | 'ALL') => {
    set({ roleFilter: role });
  },

  fetchUsers: async () => {
    set({ isLoading: true, error: null });
    try {
      const { searchQuery, roleFilter } = get();
      const params = new URLSearchParams();
      if (searchQuery) params.append('search', searchQuery);
      if (roleFilter !== 'ALL') params.append('role', roleFilter);

      const response = await fetch(`${API_BASE_URL}/users?${params.toString()}`, {
        headers: getHeaders()
      });

      if (!response.ok) throw new Error('Failed to fetch users');
      const data = await response.json();
      set({ users: data, isLoading: false });
    } catch (err: any) {
      console.error('[UserStore] fetchUsers Error:', err);
      set({ error: err.message || 'Failed to fetch users', isLoading: false });
    }
  },

  updateUserBalance: (userId: number, amount: number) => {
    set((state) => ({
      users: state.users.map((u) => u.id === userId ? { ...u, iCoinBalance: amount } : u)
    }));
  }
}));
