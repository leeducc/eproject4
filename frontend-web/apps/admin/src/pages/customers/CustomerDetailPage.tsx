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
  Clock,
  Circle,
  Coins,
  Gem
} from 'lucide-react';

export const CustomerDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [customer, setCustomer] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchCustomerDetail = async () => {
      setLoading(true);
      try {
        const token = localStorage.getItem('admin_token');
        const response = await fetch(`http://localhost:8123/api/admin/users/${id}`, {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        if (response.ok) {
          const data = await response.json();
          setCustomer(data);
        } else {
          console.error('Failed to fetch customer details');
        }
      } catch (err) {
        console.error('Error fetching customer details:', err);
      } finally {
        setLoading(false);
      }
    };

    if (id) fetchCustomerDetail();
  }, [id]);

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        </div>
      </AdminLayout>
    );
  }

  if (!customer) {
    return (
      <AdminLayout>
        <div className="text-center py-12">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Customer not found</h2>
          <button 
            onClick={() => navigate('/admin/customers/list')}
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
        {/* Breadcrumbs & Actions */}
        <div className="flex items-center justify-between">
          <button 
            onClick={() => navigate('/admin/customers/list')}
            className="flex items-center gap-2 text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white transition-colors group"
          >
            <div className="p-2 rounded-full group-hover:bg-gray-100 dark:group-hover:bg-slate-800 transition-all">
              <ArrowLeft size={20} />
            </div>
            <span className="font-medium">Back to Customers</span>
          </button>
        </div>

        {/* Profile Header Card */}
        <div className="bg-white dark:bg-slate-900 rounded-3xl p-8 shadow-sm border border-gray-100 dark:border-slate-800 relative overflow-hidden">
          <div className="absolute top-0 right-0 p-8 flex gap-3">
             {customer.isPro && (
               <span className="px-4 py-1.5 rounded-full text-xs font-bold tracking-wider uppercase bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400 flex items-center gap-1">
                 <Gem size={12} /> PRO
               </span>
             )}
            <span className={`px-4 py-1.5 rounded-full text-xs font-bold tracking-wider uppercase ${
              customer.status === 'ACTIVE' 
                ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' 
                : 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400'
            }`}>
              {customer.status}
            </span>
          </div>

          <div className="flex flex-col md:flex-row gap-8 items-start">
            <div className="w-32 h-32 rounded-3xl bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center text-indigo-600 dark:text-indigo-400 shrink-0 shadow-inner">
              <UserIcon size={64} />
            </div>
            
            <div className="space-y-4 flex-1">
              <div>
                <h1 className="text-4xl font-black text-gray-900 dark:text-white tracking-tight capitalize">
                  {customer.fullName || 'Sample Customer'}
                </h1>
                <p className="text-lg text-gray-500 dark:text-gray-400 mt-1 flex items-center gap-2">
                  <Mail size={18} /> {customer.email}
                </p>
              </div>

              <div className="flex flex-wrap gap-4 pt-2">
                <div className="px-4 py-2 bg-gray-50 dark:bg-slate-800 rounded-2xl flex items-center gap-2 text-sm font-medium text-gray-600 dark:text-gray-300">
                  <Coins size={16} className="text-amber-500" />
                  iCoins: <span className="text-gray-900 dark:text-white font-bold">{customer.iCoinBalance}</span>
                </div>
                <div className="px-4 py-2 bg-gray-50 dark:bg-slate-800 rounded-2xl flex items-center gap-2 text-sm font-medium text-gray-600 dark:text-gray-300">
                  <Clock size={16} className="text-orange-500" />
                  Joined: <span className="text-gray-900 dark:text-white font-bold">
                    {new Date(customer.createdAt).toLocaleDateString()}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Details Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Info */}
          <div className="lg:col-span-2 space-y-8">
            <div className="bg-white dark:bg-slate-900 rounded-3xl p-8 shadow-sm border border-gray-100 dark:border-slate-800 space-y-6">
              <h3 className="text-xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                <Circle size={8} className="fill-indigo-500 text-indigo-500" />
                Customer Profile Information
              </h3>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-8 pt-4">
                <div className="space-y-2">
                  <label className="text-xs font-black text-gray-400 dark:text-slate-500 uppercase tracking-widest pl-1">PHONE NUMBER</label>
                  <div className="flex items-center gap-3 p-4 bg-gray-50 dark:bg-slate-800/50 rounded-2xl border border-transparent hover:border-indigo-500/20 transition-all group">
                    <div className="p-2 bg-white dark:bg-slate-800 rounded-xl shadow-sm group-hover:text-indigo-600 transition-colors">
                      <Phone size={20} />
                    </div>
                    <span className="font-semibold text-gray-900 dark:text-white">
                      {customer.phoneNumber || 'Not provided'}
                    </span>
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-xs font-black text-gray-400 dark:text-slate-500 uppercase tracking-widest pl-1">BIRTHDAY</label>
                  <div className="flex items-center gap-3 p-4 bg-gray-50 dark:bg-slate-800/50 rounded-2xl border border-transparent hover:border-indigo-500/20 transition-all group">
                    <div className="p-2 bg-white dark:bg-slate-800 rounded-xl shadow-sm group-hover:text-indigo-600 transition-colors">
                      <Calendar size={20} />
                    </div>
                    <span className="font-semibold text-gray-900 dark:text-white">
                      {customer.birthday ? new Date(customer.birthday).toLocaleDateString() : 'Not provided'}
                    </span>
                  </div>
                </div>

                <div className="space-y-2 md:col-span-2">
                  <label className="text-xs font-black text-gray-400 dark:text-slate-500 uppercase tracking-widest pl-1">ADDRESS</label>
                  <div className="flex items-center gap-3 p-4 bg-gray-50 dark:bg-slate-800/50 rounded-2xl border border-transparent hover:border-indigo-500/20 transition-all group">
                    <div className="p-2 bg-white dark:bg-slate-800 rounded-xl shadow-sm group-hover:text-indigo-600 transition-colors">
                      <MapPin size={20} />
                    </div>
                    <span className="font-semibold text-gray-900 dark:text-white">
                      {customer.address || 'Not provided'}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* side panels can be added here */}
        </div>
      </div>
    </AdminLayout>
  );
};
