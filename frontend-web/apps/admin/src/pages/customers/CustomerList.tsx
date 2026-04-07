import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useUserStore } from '../../features/user-management/store';
import { AdminLayout } from '../../components/AdminLayout';
import { Search, RefreshCcw, User as UserIcon, Mail, Coins, ShieldCheck, ShieldAlert, Trash2 } from 'lucide-react';
import { toast } from '@english-learning/ui';

export const CustomerList: React.FC = () => {
  const navigate = useNavigate();
  const { 
    users, 
    isLoading, 
    fetchUsers, 
    searchQuery, 
    setSearchQuery, 
    setRoleFilter,
    deleteUser
  } = useUserStore();

  const [searchTerm, setSearchTerm] = useState(searchQuery);

  useEffect(() => {
    setRoleFilter('CUSTOMER');
  }, [setRoleFilter]);

  useEffect(() => {
    const timer = setTimeout(() => {
      setSearchQuery(searchTerm);
    }, 500);
    return () => clearTimeout(timer);
  }, [searchTerm, setSearchQuery]);

  useEffect(() => {
    fetchUsers();
  }, [searchQuery]);

  const handleDelete = async (userId: number, name: string) => {
    if (window.confirm(`Are you sure you want to delete customer "${name}"? This action cannot be undone.`)) {
      const success = await deleteUser(userId);
      if (success) {
        toast.success('Customer deleted successfully');
      } else {
        toast.error('Failed to delete customer');
      }
    }
  };

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-700">
        {}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
          <div className="space-y-1">
            <h1 className="text-3xl font-bold text-gray-900 dark:text-white tracking-tight">Customer Management</h1>
            <p className="text-gray-500 dark:text-gray-400">Manage your student base, monitor their iCoins and PRO status.</p>
          </div>
        </div>

        {}
        <div className="bg-white dark:bg-slate-900 p-6 rounded-2xl shadow-sm border border-gray-100 dark:border-slate-800 transition-all mt-6">
          <div className="flex flex-col md:flex-row items-end gap-6">
            <div className="flex-1 w-full space-y-1.5">
              <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">SEARCH</label>
              <div className="relative group">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-primary transition-colors" size={20} />
                <input
                  type="text"
                  placeholder="Search by name or email..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 bg-gray-50 dark:bg-slate-800 border-none rounded-xl focus:ring-2 focus:ring-primary/20 transition-all dark:text-white"
                />
              </div>
            </div>

            <div className="flex items-center gap-3">
              <button
                onClick={() => {
                  setSearchTerm('');
                  fetchUsers();
                }}
                className="p-3 bg-gray-50 dark:bg-slate-800 text-gray-500 hover:text-primary hover:bg-primary/10 rounded-full transition-all duration-300"
                title="Reset Filters"
              >
                <RefreshCcw size={22} className={isLoading ? 'animate-spin' : ''} />
              </button>
            </div>
          </div>
        </div>

        {}
        <div className="bg-white dark:bg-slate-900 rounded-2xl shadow-sm border border-gray-100 dark:border-slate-800 overflow-hidden mt-6">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-gray-50/50 dark:bg-slate-800/50 border-b border-gray-100 dark:border-slate-800">
                  <th className="px-6 py-4 text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider">Customer</th>
                  <th className="px-6 py-4 text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider text-center">iCoin Balance</th>
                  <th className="px-6 py-4 text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider text-center">Plan</th>
                   <th className="px-6 py-4 text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider text-center">Status</th>
                  <th className="px-6 py-4 text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider text-center">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-slate-800">
                {isLoading ? (
                  Array.from({ length: 5 }).map((_, i) => (
                    <tr key={i} className="animate-pulse">
                      <td colSpan={4} className="px-6 py-4"><div className="h-12 bg-gray-100 dark:bg-slate-800 rounded-lg w-full"></div></td>
                    </tr>
                  ))
                ) : users.length === 0 ? (
                  <tr>
                    <td colSpan={4} className="px-6 py-12 text-center text-gray-500 dark:text-gray-400 font-medium">No customers found matching your criteria.</td>
                  </tr>
                ) : (
                  users.map((user) => (
                    <tr key={user.id} className="hover:bg-gray-50/50 dark:hover:bg-slate-800/50 transition-colors group">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-4">
                          <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary">
                            <UserIcon size={20} />
                          </div>
                          <div>
                            <div className="font-semibold text-gray-900 dark:text-white capitalize">{user.fullName || 'No Name'}</div>
                            <div className="text-sm text-gray-500 dark:text-gray-400 flex items-center gap-1">
                              <Mail size={12} /> {user.email}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-50 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400 font-bold">
                          <Coins size={16} /> {user.iCoinBalance}
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <div className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full font-bold text-sm ${user.isPro ? 'bg-indigo-100 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-400' : 'bg-gray-100 text-gray-600 dark:bg-slate-800 dark:text-gray-400'}`}>
                          {user.isPro ? <ShieldCheck size={16} /> : <ShieldAlert size={16} />}
                          {user.isPro ? 'PRO' : 'BASIC'}
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold tracking-wider ${
                          user.status === 'ACTIVE' 
                            ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' 
                            : user.status === 'SUSPENDED'
                            ? 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400'
                            : 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400'
                        }`}>
                          {user.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <div className="flex items-center justify-center gap-2">
                          <button 
                            onClick={() => navigate(`/admin/customers/${user.id}`)}
                            className="px-3 py-1.5 bg-primary/10 text-primary hover:bg-primary hover:text-white rounded-lg text-xs font-bold transition-all"
                          >
                            View Details
                          </button>
                          <button 
                            onClick={() => handleDelete(user.id, user.fullName || user.email)}
                            className="p-1.5 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 hover:bg-red-600 hover:text-white rounded-lg transition-all"
                            title="Delete Customer"
                          >
                            <Trash2 size={16} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
};
