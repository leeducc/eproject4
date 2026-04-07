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
  isOnline: boolean;
}

interface UserState {
  users: User[];
  isLoading: boolean;
  error: string | null;
  
  
  searchQuery: string;
  roleFilter: UserRole | 'ALL';
  
  
  setSearchQuery: (query: string) => void;
  setRoleFilter: (role: UserRole | 'ALL') => void;
  fetchUsers: () => Promise<void>;
  updateUserBalance: (userId: number, amount: number) => Promise<User | null>;
  updateUserStatus: (userId: number, status: UserStatus) => Promise<User | null>;
  updateUserPro: (userId: number, isPro: boolean) => Promise<User | null>;
  deleteUser: (userId: number) => Promise<boolean>;
  createTeacher: (data: { email: string; fullName: string; password?: string }) => Promise<User | null>;
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

  updateUserBalance: async (userId: number, amount: number) => {
    try {
      const response = await fetch(`${API_BASE_URL}/users/${userId}/icoins?balance=${amount}`, {
        method: 'PATCH',
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to update balance');
      const updatedUser = await response.json();
      set((state) => ({
        users: state.users.map((u) => u.id === userId ? updatedUser : u)
      }));
      return updatedUser;
    } catch (err) {
      console.error('[UserStore] updateUserBalance Error:', err);
      return null;
    }
  },

  updateUserStatus: async (userId: number, status: UserStatus) => {
    try {
      const response = await fetch(`${API_BASE_URL}/users/${userId}/status?status=${status}`, {
        method: 'PATCH',
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to update status');
      const updatedUser = await response.json();
      set((state) => ({
        users: state.users.map((u) => u.id === userId ? updatedUser : u)
      }));
      return updatedUser;
    } catch (err) {
      console.error('[UserStore] updateUserStatus Error:', err);
      return null;
    }
  },

  updateUserPro: async (userId: number, isPro: boolean) => {
    try {
      const response = await fetch(`${API_BASE_URL}/users/${userId}/pro?isPro=${isPro}`, {
        method: 'PATCH',
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to update PRO status');
      const updatedUser = await response.json();
      set((state) => ({
        users: state.users.map((u) => u.id === userId ? updatedUser : u)
      }));
      return updatedUser;
    } catch (err) {
      console.error('[UserStore] updateUserPro Error:', err);
      return null;
    }
  },

  deleteUser: async (userId: number) => {
    try {
      const response = await fetch(`${API_BASE_URL}/users/${userId}`, {
        method: 'DELETE',
        headers: getHeaders()
      });
      if (!response.ok) throw new Error('Failed to delete user');
      set((state) => ({
        users: state.users.filter((u) => u.id !== userId)
      }));
      return true;
    } catch (err) {
      console.error('[UserStore] deleteUser Error:', err);
      return false;
    }
  },

  createTeacher: async (data: { email: string; fullName: string; password?: string }) => {
    try {
      
      const teacherData = {
        ...data,
        password: data.password || 'Teacher@123'
      };
      const response = await fetch(`${API_BASE_URL}/users/teachers`, {
        method: 'POST',
        headers: getHeaders(),
        body: JSON.stringify(teacherData)
      });
      if (!response.ok) throw new Error('Failed to create teacher');
      const newUser = await response.json();
      set((state) => ({
        users: [newUser, ...state.users]
      }));
      return newUser;
    } catch (err) {
      console.error('[UserStore] createTeacher Error:', err);
      return null;
    }
  }
}));
