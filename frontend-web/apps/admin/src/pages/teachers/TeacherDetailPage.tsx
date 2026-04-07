import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { AdminLayout } from '../../components/AdminLayout';
import { User } from '../../features/user-management/store';
import { 
  ArrowLeft, 
  User as UserIcon, 
  Mail, 
  Calendar, 
  MapPin, 
  Phone, 
  Shield, 
  Clock,
  Circle,
  Trash2,
  CheckCircle2,
  AlertTriangle,
  Zap,
  ZapOff
} from 'lucide-react';
import { useUserStore, UserStatus } from '../../features/user-management/store';
import { toast } from '@english-learning/ui';


import { apiClient } from '@english-learning/api';

export const TeacherDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { updateUserStatus, updateUserPro, deleteUser } = useUserStore();
  const [teacher, setTeacher] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [isUpdating, setIsUpdating] = useState(false);

  useEffect(() => {
    const fetchTeacherDetail = async () => {
      setLoading(true);
      try {
        const response = await apiClient.get(`/admin/users/${id}`);
        setTeacher(response.data);
      } catch (err) {
        console.error('Error fetching teacher details:', err);
      } finally {
        setLoading(false);
      }
    };

    if (id) fetchTeacherDetail();
  }, [id]);

  const handleStatusToggle = async () => {
    if (!teacher) return;
    const newStatus: UserStatus = teacher.status === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    
    setIsUpdating(true);
    const updated = await updateUserStatus(teacher.id, newStatus);
    setIsUpdating(false);
    
    if (updated) {
      setTeacher(updated);
      toast.success(`Teacher status updated to ${newStatus}`);
    } else {
      toast.error('Failed to update status');
    }
  };

  const handleProToggle = async () => {
    if (!teacher) return;
    setIsUpdating(true);
    const updated = await updateUserPro(teacher.id, !teacher.isPro);
    setIsUpdating(false);
    
    if (updated) {
      setTeacher(updated);
      toast.success(`Teacher PRO status ${!teacher.isPro ? 'activated' : 'deactivated'}`);
    } else {
      toast.error('Failed to update PRO status');
    }
  };

  const handleDelete = async () => {
    if (!teacher) return;
    if (window.confirm(`Are you sure you want to delete teacher "${teacher.fullName || teacher.email}"? This cannot be undone.`)) {
      setIsUpdating(true);
      const success = await deleteUser(teacher.id);
      setIsUpdating(false);
      
      if (success) {
        toast.success('Teacher deleted successfully');
        navigate('/admin/teachers/list');
      } else {
        toast.error('Failed to delete teacher');
      }
    }
  };

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        </div>
      </AdminLayout>
    );
  }

  if (!teacher) {
    return (
      <AdminLayout>
        <div className="text-center py-12">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Teacher not found</h2>
          <button 
            onClick={() => navigate('/admin/teachers/list')}
            className="mt-4 text-primary hover:underline flex items-center justify-center gap-2 mx-auto"
          >
            <ArrowLeft size={16} /> Back to List
          </button>
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
        {}
        <div className="flex items-center justify-between">
          <button 
            onClick={() => navigate('/admin/teachers/list')}
            className="flex items-center gap-2 text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white transition-colors group"
          >
            <div className="p-2 rounded-full group-hover:bg-gray-100 dark:group-hover:bg-slate-800 transition-all">
              <ArrowLeft size={20} />
            </div>
            <span className="font-medium">Back to Teachers</span>
          </button>

          <div className="flex items-center gap-3">
             <button 
              onClick={handleStatusToggle}
              disabled={isUpdating}
              className={`flex items-center gap-2 px-4 py-2 rounded-xl font-bold transition-all disabled:opacity-50 ${
                teacher.status === 'ACTIVE' 
                  ? 'bg-amber-50 text-amber-600 hover:bg-amber-600 hover:text-white' 
                  : 'bg-green-50 text-green-600 hover:bg-green-600 hover:text-white'
              }`}
            >
              {teacher.status === 'ACTIVE' ? <AlertTriangle size={18} /> : <CheckCircle2 size={18} />}
              {teacher.status === 'ACTIVE' ? 'Suspend' : 'Activate'}
            </button>

            <button 
              onClick={handleProToggle}
              disabled={isUpdating}
              className={`flex items-center gap-2 px-4 py-2 rounded-xl font-bold transition-all disabled:opacity-50 ${
                teacher.isPro 
                  ? 'bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white' 
                  : 'bg-indigo-50 text-indigo-600 hover:bg-indigo-600 hover:text-white'
              }`}
            >
              {teacher.isPro ? <ZapOff size={18} /> : <Zap size={18} />}
              {teacher.isPro ? 'Revoke PRO' : 'Grant PRO'}
            </button>

             <button 
              onClick={handleDelete}
              disabled={isUpdating}
              className="flex items-center gap-2 px-4 py-2 bg-red-50 text-red-600 hover:bg-red-600 hover:text-white rounded-xl font-bold transition-all disabled:opacity-50"
            >
              <Trash2 size={18} /> Delete Account
            </button>
          </div>
        </div>

        {}
        <div className="bg-white dark:bg-slate-900 rounded-3xl p-8 shadow-sm border border-gray-100 dark:border-slate-800 relative overflow-hidden">
          <div className="absolute top-0 right-0 p-8">
            <span className={`px-4 py-1.5 rounded-full text-xs font-bold tracking-wider uppercase ${
              teacher.status === 'ACTIVE' 
                ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' 
                : 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400'
            }`}>
              {teacher.status}
            </span>
          </div>

          <div className="flex flex-col md:flex-row gap-8 items-start">
            <div className="w-32 h-32 rounded-3xl bg-primary/10 flex items-center justify-center text-primary shrink-0 shadow-inner">
              <UserIcon size={64} />
            </div>
            
            <div className="space-y-4 flex-1">
              <div>
                <h1 className="text-4xl font-black text-gray-900 dark:text-white tracking-tight capitalize">
                  {teacher.fullName || 'Unnamed Teacher'}
                </h1>
                <p className="text-lg text-gray-500 dark:text-gray-400 mt-1 flex items-center gap-2">
                  <Mail size={18} /> {teacher.email}
                </p>
              </div>

              <div className="flex flex-wrap gap-4 pt-2">
                <div className="px-4 py-2 bg-gray-50 dark:bg-slate-800 rounded-2xl flex items-center gap-2 text-sm font-medium text-gray-600 dark:text-gray-300">
                  <Shield size={16} className="text-blue-500" />
                  Role: <span className="text-gray-900 dark:text-white font-bold">{teacher.role}</span>
                </div>
                <div className="px-4 py-2 bg-gray-50 dark:bg-slate-800 rounded-2xl flex items-center gap-2 text-sm font-medium text-gray-600 dark:text-gray-300">
                  <Clock size={16} className="text-orange-500" />
                  Joined: <span className="text-gray-900 dark:text-white font-bold">
                    {new Date(teacher.createdAt).toLocaleDateString()}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {}
          <div className="lg:col-span-3 space-y-8">
            <div className="bg-white dark:bg-slate-900 rounded-3xl p-8 shadow-sm border border-gray-100 dark:border-slate-800 space-y-6">
              <h3 className="text-xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                <Circle size={8} className="fill-primary text-primary" />
                Detailed Profile Information
              </h3>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-8 pt-4">
                <div className="space-y-2">
                  <label className="text-xs font-black text-gray-400 dark:text-slate-500 uppercase tracking-widest pl-1">PHONE NUMBER</label>
                  <div className="flex items-center gap-3 p-4 bg-gray-50 dark:bg-slate-800/50 rounded-2xl border border-transparent hover:border-primary/20 transition-all group">
                    <div className="p-2 bg-white dark:bg-slate-800 rounded-xl shadow-sm group-hover:text-primary transition-colors">
                      <Phone size={20} />
                    </div>
                    <span className="font-semibold text-gray-900 dark:text-white">
                      {teacher.phoneNumber || 'Not provided'}
                    </span>
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-xs font-black text-gray-400 dark:text-slate-500 uppercase tracking-widest pl-1">BIRTHDAY</label>
                  <div className="flex items-center gap-3 p-4 bg-gray-50 dark:bg-slate-800/50 rounded-2xl border border-transparent hover:border-primary/20 transition-all group">
                    <div className="p-2 bg-white dark:bg-slate-800 rounded-xl shadow-sm group-hover:text-primary transition-colors">
                      <Calendar size={20} />
                    </div>
                    <span className="font-semibold text-gray-900 dark:text-white">
                      {teacher.birthday ? new Date(teacher.birthday).toLocaleDateString() : 'Not provided'}
                    </span>
                  </div>
                </div>

                <div className="space-y-2 md:col-span-2">
                  <label className="text-xs font-black text-gray-400 dark:text-slate-500 uppercase tracking-widest pl-1">ADDRESS</label>
                  <div className="flex items-center gap-3 p-4 bg-gray-50 dark:bg-slate-800/50 rounded-2xl border border-transparent hover:border-primary/20 transition-all group">
                    <div className="p-2 bg-white dark:bg-slate-800 rounded-xl shadow-sm group-hover:text-primary transition-colors">
                      <MapPin size={20} />
                    </div>
                    <span className="font-semibold text-gray-900 dark:text-white">
                      {teacher.address || 'Not provided'}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white dark:bg-slate-900 rounded-3xl p-6 shadow-sm border border-gray-100 dark:border-slate-800 space-y-4">
              <h4 className="font-bold text-gray-900 dark:text-white text-sm uppercase tracking-widest text-center border-b border-gray-100 dark:border-slate-800 pb-3">
                Account Metadata
              </h4>
              <div className="space-y-4">
                <div className="flex justify-between items-center text-sm">
                  <span className="text-gray-500">Verified Email</span>
                  <span className={`px-2 py-0.5 rounded-lg text-[10px] font-bold ${teacher.isEmailConfirmed ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                    {teacher.isEmailConfirmed ? 'YES' : 'NO'}
                  </span>
                </div>
                <div className="flex justify-between items-center text-sm">
                  <span className="text-gray-500">Account ID</span>
                  <span className="font-mono font-bold text-xs bg-gray-100 dark:bg-slate-800 px-2 py-0.5 rounded text-gray-700 dark:text-gray-300">#{teacher.id}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
};
