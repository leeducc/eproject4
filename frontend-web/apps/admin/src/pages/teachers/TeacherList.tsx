import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useUserStore } from '../../features/user-management/store';
import { AdminLayout } from '../../components/AdminLayout';
import { Search, RefreshCcw, User as UserIcon, Mail, Calendar, UserPlus, Trash2, X } from 'lucide-react';
import { toast } from '@english-learning/ui';

export const TeacherList: React.FC = () => {
  const navigate = useNavigate();
  const { 
    users, 
    isLoading, 
    fetchUsers, 
    searchQuery, 
    setSearchQuery, 
    setRoleFilter,
    deleteUser,
    createTeacher
  } = useUserStore();

  const [searchTerm, setSearchTerm] = useState(searchQuery);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [newTeacher, setNewTeacher] = useState({ email: '', fullName: '', password: '' });
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    setRoleFilter('TEACHER');
  }, [setRoleFilter]);

  useEffect(() => {
    const timer = setTimeout(() => {
      setSearchQuery(searchTerm);
    }, 500);
    return () => clearTimeout(timer);
  }, [searchTerm, setSearchQuery]);

  useEffect(() => {
    fetchUsers();
  }, [searchQuery, fetchUsers]);

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-GB', {
      day: '2-digit',
      month: 'short',
      year: 'numeric'
    });
  };

  const handleDelete = async (userId: number, name: string) => {
    if (window.confirm(`Are you sure you want to delete teacher "${name}"? This action cannot be undone.`)) {
      const success = await deleteUser(userId);
      if (success) {
        toast.success('Teacher deleted successfully');
      } else {
        toast.error('Failed to delete teacher');
      }
    }
  };

  const handleCreateTeacher = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    const result = await createTeacher(newTeacher);
    setIsSubmitting(false);
    if (result) {
      toast.success('Teacher created successfully. Notification email sent.');
      setIsAddModalOpen(false);
      setNewTeacher({ email: '', fullName: '', password: '' });
      fetchUsers();
    } else {
      toast.error('Failed to create teacher. Email might already be registered.');
    }
  };

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-700">
        {}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
          <div className="space-y-1">
            <h1 className="text-3xl font-bold text-gray-900 dark:text-white tracking-tight">Teacher Management</h1>
            <p className="text-gray-500 dark:text-gray-400">View and manage all registered teachers in the system.</p>
          </div>
          <button 
            onClick={() => setIsAddModalOpen(true)}
            className="flex items-center gap-2 px-6 py-3 bg-primary text-white rounded-2xl font-bold hover:bg-primary/90 transition-all shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-[0.98]"
          >
            <UserPlus size={20} /> Add New Teacher
          </button>
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
                  <th className="px-6 py-4 text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider">Teacher</th>
                  <th className="px-6 py-4 text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider text-center">Joined Date</th>
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
                    <td colSpan={4} className="px-6 py-12 text-center text-gray-500 dark:text-gray-400 font-medium">No teachers found matching your criteria.</td>
                  </tr>
                ) : (
                  users.map((user) => (
                    <tr key={user.id} className="hover:bg-gray-50/50 dark:hover:bg-slate-800/50 transition-colors group">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-4">
                          <div className="relative">
                            <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary">
                              <UserIcon size={20} />
                            </div>
                            {user.isOnline && (
                              <div className="absolute -top-0.5 -right-0.5 w-3.5 h-3.5 bg-green-500 border-2 border-white dark:border-slate-900 rounded-full animate-pulse shadow-sm" />
                            )}
                          </div>
                          <div>
                            <div className="font-semibold text-gray-900 dark:text-white capitalize flex items-center gap-2">
                              {user.fullName || 'No Name'}
                              {user.isOnline && <span className="text-[10px] text-green-500 font-bold uppercase tracking-widest">Online</span>}
                            </div>
                            <div className="text-sm text-gray-500 dark:text-gray-400 flex items-center gap-1">
                              <Mail size={12} /> {user.email}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-gray-50 dark:bg-slate-800 text-gray-600 dark:text-gray-300 text-sm">
                          <Calendar size={14} /> {formatDate(user.createdAt)}
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
                            onClick={() => navigate(`/admin/teachers/${user.id}`)}
                            className="px-3 py-1.5 bg-primary/10 text-primary hover:bg-primary hover:text-white rounded-lg text-xs font-bold transition-all"
                          >
                            View Details
                          </button>
                          <button 
                            onClick={() => handleDelete(user.id, user.fullName || user.email)}
                            className="p-1.5 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 hover:bg-red-600 hover:text-white rounded-lg transition-all"
                            title="Delete Teacher"
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

        {}
        {isAddModalOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-300">
            <div className="bg-white dark:bg-slate-900 rounded-3xl w-full max-w-md shadow-2xl border border-gray-100 dark:border-slate-800 overflow-hidden animate-in zoom-in-95 duration-300">
              <div className="flex items-center justify-between p-6 border-b border-gray-100 dark:border-slate-800">
                <h3 className="text-xl font-bold text-gray-900 dark:text-white">Add New Teacher</h3>
                <button onClick={() => setIsAddModalOpen(false)} className="p-2 hover:bg-gray-100 dark:hover:bg-slate-800 rounded-full transition-colors">
                  <X size={20} className="text-gray-500" />
                </button>
              </div>
              <form onSubmit={handleCreateTeacher} className="p-6 space-y-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">FULL NAME</label>
                  <input
                    required
                    type="text"
                    value={newTeacher.fullName}
                    onChange={(e) => setNewTeacher({ ...newTeacher, fullName: e.target.value })}
                    placeholder="Enter teacher's full name"
                    className="w-full px-4 py-2.5 bg-gray-50 dark:bg-slate-800 border-none rounded-xl focus:ring-2 focus:ring-primary/20 transition-all dark:text-white"
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">EMAIL ADDRESS</label>
                  <input
                    required
                    type="email"
                    value={newTeacher.email}
                    onChange={(e) => setNewTeacher({ ...newTeacher, email: e.target.value })}
                    placeholder="teacher@example.com"
                    className="w-full px-4 py-2.5 bg-gray-50 dark:bg-slate-800 border-none rounded-xl focus:ring-2 focus:ring-primary/20 transition-all dark:text-white"
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">PASSWORD (OPTIONAL)</label>
                  <input
                    type="password"
                    value={newTeacher.password}
                    onChange={(e) => setNewTeacher({ ...newTeacher, password: e.target.value })}
                    placeholder="Auto-generated if left blank"
                    className="w-full px-4 py-2.5 bg-gray-50 dark:bg-slate-800 border-none rounded-xl focus:ring-2 focus:ring-primary/20 transition-all dark:text-white"
                  />
                </div>
                <div className="pt-4">
                  <button
                    disabled={isSubmitting}
                    type="submit"
                    className="w-full py-3 bg-primary text-white rounded-xl font-bold hover:bg-primary/90 transition-all disabled:opacity-50"
                  >
                    {isSubmitting ? 'Creating...' : 'Create Teacher Account'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
};
