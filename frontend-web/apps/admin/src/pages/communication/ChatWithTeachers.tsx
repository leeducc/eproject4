import React, { useState, useEffect, useRef } from 'react';
import { useSearchParams } from 'react-router-dom';
import { 
  Send, 
  Paperclip, 
  FileIcon, 
  Download, 
  User, 
  Search, 
  Pin, 
  MessageSquare,
  X
} from 'lucide-react';
import SockJS from 'sockjs-client';
import Stomp from 'stompjs';
import { toast } from '@english-learning/ui';
import { apiClient } from '@english-learning/api';
import { AdminLayout } from '../../components/AdminLayout';
import { useChatNotificationStore } from '../../features/chat/notificationStore';

interface Message {
  id: number;
  senderId: number;
  receiverId: number;
  content: string;
  mediaUrl?: string;
  mediaType?: 'IMAGE' | 'PDF';
  isEdited: boolean;
  createdAt: string;
}

interface UserStatus {
  id: number;
  fullName: string;
  email: string;
  isOnline: boolean;
  isPinned: boolean;
  unreadCount?: number;
  lastMessage?: string;
}

const ChatWithTeachers: React.FC = () => {
  const [searchParams] = useSearchParams();
  const [teachers, setTeachers] = useState<UserStatus[]>([]);
  const [selectedTeacherId, setSelectedTeacherId] = useState<number | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [inputValue, setInputValue] = useState('');
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [currentUserId, setCurrentUserId] = useState<number | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  
  const scrollRef = useRef<HTMLDivElement>(null);
  const stompClientRef = useRef<Stomp.Client | null>(null);
  const { unreadCounts, markAsRead, fetchUnreadStatus } = useChatNotificationStore();

  
  useEffect(() => {
    const teacherId = searchParams.get('teacherId');
    if (teacherId) {
      setSelectedTeacherId(parseInt(teacherId));
    }
  }, [searchParams]);

  
  useEffect(() => {
    const init = async () => {
      try {
        const profileRes = await apiClient.get('/profile');
        const profile = profileRes.data;
        console.log("[ChatWithTeachers] Profile fetched:", profile);
        setCurrentUserId(profile.userId);
        
        fetchTeacherList();
        connectWebSocket(profile.userId);
      } catch (err) {
        console.error('[ChatWithTeachers] Initialization failed', err);
      }
    };
    init();
    return () => disconnectWebSocket();
  }, []);

  const fetchTeacherList = async () => {
    try {
      const response = await apiClient.get('/chat/teachers');
      setTeachers(response.data);
    } catch (err) {
      console.error('Failed to fetch teachers', err);
    }
  };

  const fetchConversation = async (otherId: number) => {
    try {
      const response = await apiClient.get(`/chat/${otherId}`);
      setMessages(response.data);
    } catch (err) {
        console.error('Failed to fetch conversation', err);
    }
  };

  useEffect(() => {
    if (selectedTeacherId) {
      fetchConversation(selectedTeacherId);
      markAsRead(selectedTeacherId);
    }
  }, [selectedTeacherId, markAsRead]);

  const connectWebSocket = (userId: number) => {
    const socket = new SockJS('http://localhost:8123/ws-chat');
    const client = Stomp.over(socket);
    client.debug = (str) => {
        if (str.includes("CONNECTED") || str.includes("ERROR")) {
            console.log("[ChatWithTeachers] STOMP Debug:", str);
        }
    };
    
    const token = localStorage.getItem('admin_token');
    client.connect({ 'Authorization': 'Bearer ' + token }, () => {
      console.log("[ChatWithTeachers] STOMP Connected as user:", userId);
      
      
      client.subscribe(`/topic/chat/${userId}`, (message) => {
        const newMessage = JSON.parse(message.body);
        console.log("[ChatWithTeachers] New message received:", newMessage);
        
        
        setSelectedTeacherId(prev => {
            if (prev && (newMessage.senderId === prev || newMessage.receiverId === prev)) {
                setMessages(prevMsgs => {
                    if (prevMsgs.find(m => m.id === newMessage.id)) return prevMsgs;
                    return [...prevMsgs, newMessage];
                });
                if (newMessage.senderId === prev) {
                    markAsRead(prev);
                }
            }
            return prev;
        });
        
        
        fetchTeacherList();
        fetchUnreadStatus();
      });

      
      client.subscribe('/topic/user-status', (statusMessage) => {
        const data = JSON.parse(statusMessage.body);
        console.log("[ChatWithTeachers] User status update received:", data);
        setTeachers(prevTeachers => prevTeachers.map(teacher => 
          teacher.id === data.userId ? { ...teacher, isOnline: data.isOnline } : teacher
        ));
      });
    });
    stompClientRef.current = client;
  };

  const disconnectWebSocket = () => {
    if (stompClientRef.current?.connected) {
      stompClientRef.current.disconnect(() => {});
    }
  };

  const handleSend = async () => {
    if ((!inputValue.trim() && !selectedFile) || !selectedTeacherId) return;

    setIsUploading(true);
    const formData = new FormData();
    formData.append('receiverId', selectedTeacherId.toString());
    if (inputValue.trim()) formData.append('content', inputValue);
    if (selectedFile) formData.append('file', selectedFile);

    try {
      await apiClient.post('/chat/send', formData);
      setInputValue('');
      setSelectedFile(null);
    } catch (err) {
      toast.error('Failed to send message');
    } finally {
      setIsUploading(false);
    }
  };

  const togglePin = async (teacherId: number, e: React.MouseEvent) => {
    e.stopPropagation();
    try {
      await apiClient.post(`/chat/${teacherId}/pin`);
      fetchTeacherList();
    } catch (err) {
      toast.error('Failed to toggle pin');
    }
  };

  useEffect(() => {
    if (scrollRef.current) {
        scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const filteredTeachers = teachers
    .filter(t => t.fullName.toLowerCase().includes(searchTerm.toLowerCase()))
    .sort((a, b) => {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        if (a.isOnline && !b.isOnline) return -1;
        if (!a.isOnline && b.isOnline) return 1;
        return 0;
    });

  return (
    <AdminLayout>
      <div className="flex h-[calc(100vh-160px)] gap-6 animate-in fade-in slide-in-from-bottom-4 duration-700">
        
        {}
        <div className="w-80 bg-white dark:bg-slate-900 rounded-3xl shadow-xl border border-gray-100 dark:border-slate-800 flex flex-col overflow-hidden">
          <div className="p-6 border-b border-gray-100 dark:border-slate-800">
            <h2 className="text-xl font-black mb-4 flex items-center gap-2 text-gray-900 dark:text-white">
              <MessageSquare className="text-primary" /> Teachers
            </h2>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input 
                type="text" 
                placeholder="Search teachers..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2.5 bg-gray-50 dark:bg-slate-800/50 rounded-2xl border-none focus:ring-2 focus:ring-primary/20 text-sm dark:text-white"
              />
            </div>
          </div>
          
          <div className="flex-1 overflow-y-auto p-3 space-y-1 custom-scrollbar">
            {filteredTeachers.map(teacher => (
              <button
                key={teacher.id}
                onClick={() => setSelectedTeacherId(teacher.id)}
                className={`w-full p-4 rounded-2xl flex items-center gap-3 transition-all relative group ${
                  selectedTeacherId === teacher.id 
                    ? 'bg-primary/10 text-primary shadow-sm' 
                    : 'hover:bg-gray-50 dark:hover:bg-slate-800/50 text-gray-600 dark:text-gray-400'
                }`}
              >
                <div className="relative">
                  <div className="p-2.5 bg-gray-100 dark:bg-slate-700 rounded-xl">
                    <User size={20} />
                  </div>
                  {teacher.isOnline && (
                    <div className="absolute -top-1 -right-1 w-3.5 h-3.5 bg-green-500 border-2 border-white dark:border-slate-900 rounded-full animate-pulse" />
                  )}
                </div>
                <div className="flex-1 text-left min-w-0">
                  <div className="flex items-center justify-between gap-2">
                    <h4 className="font-bold text-sm truncate dark:text-white">{teacher.fullName}</h4>
                    <div className="flex items-center gap-2">
                      {unreadCounts[teacher.id] > 0 && (
                        <span className="flex h-5 min-w-[20px] px-1 items-center justify-center rounded-full bg-primary text-white text-[10px] font-black shadow-sm animate-in zoom-in duration-300">
                          {unreadCounts[teacher.id]}
                        </span>
                      )}
                      {teacher.isPinned && <Pin size={12} className="text-primary fill-primary" />}
                    </div>
                  </div>
                  <p className="text-[10px] uppercase tracking-wider font-bold opacity-60">Teaching Staff</p>
                </div>
                
                <div 
                  onClick={(e) => togglePin(teacher.id, e)}
                  className={`p-1.5 rounded-lg opacity-0 group-hover:opacity-100 transition-all hover:bg-white dark:hover:bg-slate-700 shadow-sm ${teacher.isPinned ? 'opacity-100' : ''}`}
                >
                  <Pin size={14} className={teacher.isPinned ? 'text-primary fill-primary' : 'text-gray-400'} />
                </div>
              </button>
            ))}
          </div>
        </div>

        {}
        <div className="flex-1 bg-white dark:bg-slate-900 rounded-3xl shadow-xl border border-gray-100 dark:border-slate-800 flex flex-col overflow-hidden">
          {selectedTeacherId ? (
            <>
              {}
              <div className="p-5 bg-white dark:bg-slate-900 border-b border-gray-100 dark:border-slate-800 flex justify-between items-center z-10">
                <div className="flex items-center gap-3">
                  <div className="p-2.5 bg-primary/10 text-primary rounded-xl">
                    <User size={24} />
                  </div>
                  <div>
                    <h3 className="font-bold text-lg leading-tight dark:text-white">
                      {teachers.find(t => t.id === selectedTeacherId)?.fullName}
                    </h3>
                    <div className="flex items-center gap-1.5 mt-0.5">
                      <div className={`w-2 h-2 rounded-full ${teachers.find(t => t.id === selectedTeacherId)?.isOnline ? 'bg-green-500' : 'bg-gray-300'}`} />
                      <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">
                        {teachers.find(t => t.id === selectedTeacherId)?.isOnline ? 'Active Now' : 'Offline'}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {}
              <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-6 bg-gray-50/30 dark:bg-slate-950/30">
                {messages.map((msg) => {
                  const isMe = msg.senderId === currentUserId;
                  return (
                    <div key={msg.id} className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}>
                      <div className={`max-w-[70%] rounded-3xl p-4 shadow-sm relative transition-all ${
                        isMe 
                          ? 'bg-primary text-white rounded-tr-none' 
                          : 'bg-white dark:bg-slate-800 text-gray-900 dark:text-white rounded-tl-none border border-gray-100 dark:border-slate-700'
                      }`}>
                        {msg.mediaUrl && (
                          <div className="mb-3 rounded-2xl overflow-hidden shadow-inner font-bold">
                            {msg.mediaType === 'IMAGE' ? (
                              <img src={`http://localhost:8123${msg.mediaUrl}`} alt="Sent" className="max-w-full h-auto" />
                            ) : (
                              <a href={`http://localhost:8123${msg.mediaUrl}`} download className="flex items-center gap-2 p-3 bg-black/10 text-sm">
                                <FileIcon size={20} /> Document.pdf <Download size={16} />
                              </a>
                            )}
                          </div>
                        )}
                        <p className="text-sm leading-relaxed font-medium">{msg.content}</p>
                        <div className={`text-[10px] mt-2 font-bold opacity-60 ${isMe ? 'text-right' : ''}`}>
                          {new Date(msg.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>

              {}
              <div className="p-6 bg-white dark:bg-slate-900 border-t border-gray-100 dark:border-slate-800">
                <div className="flex items-end gap-3 bg-gray-50 dark:bg-slate-800/50 p-3 rounded-2xl shadow-inner">
                  <input type="file" id="chat-file" className="hidden" onChange={(e) => setSelectedFile(e.target.files?.[0] || null)} />
                  <button 
                    onClick={() => document.getElementById('chat-file')?.click()}
                    className={`p-3 rounded-xl transition-all ${selectedFile ? 'text-primary bg-primary/10' : 'text-gray-400 hover:text-primary'}`}
                  >
                    <Paperclip size={20} />
                  </button>
                  <textarea
                    value={inputValue}
                    onChange={(e) => setInputValue(e.target.value)}
                    placeholder="Type your message..."
                    className="flex-1 bg-transparent border-none focus:ring-0 text-sm py-2 resize-none max-h-32 font-medium dark:text-white"
                    rows={1}
                    onKeyDown={(e) => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); handleSend(); } }}
                  />
                  <button
                    onClick={handleSend}
                    disabled={isUploading || (!inputValue.trim() && !selectedFile)}
                    className="p-3.5 bg-primary text-white rounded-xl shadow-lg shadow-primary/20 hover:scale-105 active:scale-95 transition-all"
                  >
                    {isUploading ? <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : <Send size={20} />}
                  </button>
                </div>
              </div>
            </>
          ) : (
            <div className="h-full flex flex-col items-center justify-center text-gray-400 space-y-6 bg-gray-50/10 dark:bg-slate-900">
              <div className="w-32 h-32 bg-gray-50 dark:bg-slate-800 rounded-full flex items-center justify-center shadow-inner">
                <MessageSquare size={64} className="opacity-20 text-primary" />
              </div>
              <div className="text-center max-w-xs">
                <h3 className="text-xl font-black text-gray-900 dark:text-white mb-2">Select a Conversation</h3>
                <p className="text-sm font-bold opacity-60 uppercase tracking-widest">Choose a teacher to start</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
};

export default ChatWithTeachers;
