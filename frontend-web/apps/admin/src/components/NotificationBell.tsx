import React, { useState, useEffect, useRef } from 'react';
import { Bell, MessageSquare, User, X } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useChatNotificationStore } from '../features/chat/notificationStore';

export const NotificationBell: React.FC<{ token: string; profile: { userId: number } }> = ({ token, profile }) => {
  const [isOpen, setIsOpen] = useState(false);
  const navigate = useNavigate();
  const dropdownRef = useRef<HTMLDivElement>(null);
  
  const { 
    totalUnread, 
    notifications, 
    fetchUnreadStatus, 
    initializeWebSocket, 
    markAsRead 
  } = useChatNotificationStore();

  useEffect(() => {
    fetchUnreadStatus();
    initializeWebSocket(profile.userId, token);
  }, [profile.userId, fetchUnreadStatus, initializeWebSocket, token]);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleNotificationClick = (senderId: number) => {
    setIsOpen(false);
    navigate(`/admin/communication/chat?teacherId=${senderId}`);
    markAsRead(senderId);
  };

  return (
    <div className="relative" ref={dropdownRef}>
      <button 
        onClick={() => setIsOpen(!isOpen)}
        className={`relative p-2.5 rounded-2xl transition-all duration-300 ${
            isOpen 
              ? 'bg-primary text-white shadow-lg shadow-primary/30 rotate-12 scale-110' 
              : 'bg-gray-100 hover:bg-gray-200 text-gray-600'
        }`}
      >
        <Bell size={22} className={totalUnread > 0 ? 'animate-bounce' : ''} />
        {totalUnread > 0 && (
          <span className="absolute -top-1.5 -right-1.5 flex h-6 w-6 items-center justify-center rounded-full bg-red-500 text-[10px] font-black text-white ring-4 ring-white shadow-sm animate-in zoom-in duration-300">
            {totalUnread > 99 ? '99+' : totalUnread}
          </span>
        )}
      </button>

      {isOpen && (
        <div className="absolute right-0 mt-4 w-80 bg-white dark:bg-slate-900 rounded-3xl shadow-2xl border border-gray-100 dark:border-slate-800 z-[100] overflow-hidden animate-in fade-in slide-in-from-top-4 duration-300">
          <div className="p-5 border-b border-gray-100 dark:border-slate-800 flex justify-between items-center bg-gray-50/50 dark:bg-slate-800/50">
            <h3 className="font-black text-gray-900 dark:text-white flex items-center gap-2">
                <MessageSquare className="text-primary" size={18} /> New Messages
            </h3>
            <button onClick={() => setIsOpen(false)} className="text-gray-400 hover:text-gray-600 transition-colors">
                <X size={18} />
            </button>
          </div>
          
          <div className="max-h-[400px] overflow-y-auto custom-scrollbar">
            {notifications.length === 0 ? (
              <div className="p-10 text-center flex flex-col items-center gap-3">
                <div className="p-3 bg-gray-100 dark:bg-slate-800 rounded-full text-gray-300">
                    <Bell size={32} />
                </div>
                <p className="text-sm font-bold text-gray-400 uppercase tracking-widest">No new alerts</p>
              </div>
            ) : (
              notifications.map((n: any) => (
                <button
                  key={n.senderId}
                  onClick={() => handleNotificationClick(n.senderId)}
                  className="w-full p-4 flex items-start gap-4 hover:bg-primary/5 transition-all text-left group border-b border-gray-50 dark:border-slate-800/50 last:border-none"
                >
                  <div className="relative pt-1">
                    <div className="p-2.5 bg-gray-100 dark:bg-slate-800 rounded-xl group-hover:bg-primary/10 group-hover:text-primary transition-colors">
                      <User size={20} />
                    </div>
                    {n.count > 0 && (
                      <span className="absolute -top-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full bg-primary text-[10px] font-black text-white ring-2 ring-white shadow-sm">
                        {n.count}
                      </span>
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-center mb-0.5">
                      <h4 className="font-bold text-sm text-gray-900 dark:text-white truncate">
                        {n.senderName}
                      </h4>
                    </div>
                    <p className="text-xs text-gray-500 dark:text-gray-400 truncate font-medium">
                      {n.lastMessage}
                    </p>
                  </div>
                </button>
              ))
            )}
          </div>
          
          {notifications.length > 0 && (
            <div className="p-3 bg-gray-50 dark:bg-slate-800/50 border-t border-gray-100 dark:border-slate-800">
                <button 
                  onClick={() => navigate('/admin/communication/chat')}
                  className="w-full py-2.5 text-xs font-black text-primary hover:bg-primary/10 rounded-xl uppercase tracking-widest transition-all"
                >
                    View All Chats
                </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
