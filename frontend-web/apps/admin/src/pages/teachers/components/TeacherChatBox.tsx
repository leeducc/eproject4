import React, { useState, useEffect, useRef } from 'react';
import { 
  Send, 
  Paperclip, 
  X,
  FileIcon,
  Download,
  History,
  User
} from 'lucide-react';
import SockJS from 'sockjs-client';
import Stomp from 'stompjs';
import { toast } from '@english-learning/ui';
import { useChatNotificationStore } from '../../../features/chat/notificationStore';

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

interface EditHistory {
  id: number;
  oldContent: string;
  editedAt: string;
}

interface TeacherChatBoxProps {
  teacherId: number;
}

interface TeacherProfile {
  id: number;
  fullName: string;
  isOnline: boolean;
}

export const TeacherChatBox: React.FC<TeacherChatBoxProps> = ({ teacherId }) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [inputValue, setInputValue] = useState('');
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [showHistory, setShowHistory] = useState<number | null>(null);
  const [historyData, setHistoryData] = useState<EditHistory[]>([]);
  const [currentUserId, setCurrentUserId] = useState<number | null>(null);
  const [teacherProfile, setTeacherProfile] = useState<TeacherProfile | null>(null);
  
  const scrollRef = useRef<HTMLDivElement>(null);
  const stompClientRef = useRef<Stomp.Client | null>(null);
  const { markAsRead, fetchUnreadStatus } = useChatNotificationStore();

  useEffect(() => {
    fetchHistory();
    fetchTeacherProfile();
    connectWebSocket();
    markAsRead(teacherId);
    return () => disconnectWebSocket();
  }, [teacherId]);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const fetchHistory = async () => {
    try {
      const response = await fetch(`http://localhost:8123/api/chat/${teacherId}`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
      });
      if (response.ok) {
        setMessages(await response.json());
      }
    } catch (err) {
      console.error('Failed to fetch chat history', err);
    }
  };

  const fetchTeacherProfile = async () => {
    try {
      const response = await fetch(`http://localhost:8123/api/admin/users/${teacherId}`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
      });
      if (response.ok) {
        setTeacherProfile(await response.json());
      }
    } catch (err) {
      console.error('Failed to fetch teacher profile', err);
    }
  };

  const connectWebSocket = () => {
    const socket = new SockJS('http://localhost:8123/ws-chat');
    const client = Stomp.over(socket);
    client.debug = () => {};
    
    fetch('http://localhost:8123/api/profile', {
      headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
    })
    .then(res => res.json())
    .then(profile => {
      setCurrentUserId(profile.userId);
      const token = localStorage.getItem('admin_token');
      client.connect({ 'Authorization': 'Bearer ' + token }, () => {
        client.subscribe(`/topic/chat/${profile.userId}`, (message) => {
          const newMessage = JSON.parse(message.body);
          
          if (newMessage.senderId === teacherId || newMessage.receiverId === teacherId) {
            updateMessageList(newMessage);
            if (newMessage.senderId === teacherId) {
                markAsRead(teacherId);
            }
          }
          fetchUnreadStatus();
        });
      });
    });

    stompClientRef.current = client;
  };

  const disconnectWebSocket = () => {
    if (stompClientRef.current?.connected) {
      stompClientRef.current.disconnect(() => {});
    }
  };

  const updateMessageList = (newMessage: Message) => {
    setMessages((prev) => {
      if (prev.find(m => m.id === newMessage.id)) return prev;
      return [...prev, newMessage];
    });
  };

  const handleSend = async () => {
    if (!inputValue.trim() && !selectedFile) return;

    setIsUploading(true);
    const formData = new FormData();
    formData.append('receiverId', teacherId.toString());
    if (inputValue.trim()) formData.append('content', inputValue);
    if (selectedFile) formData.append('file', selectedFile);

    try {
      const response = await fetch('http://localhost:8123/api/chat/send', {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` },
        body: formData
      });

      if (response.ok) {
        const newMessage = await response.json();
        updateMessageList(newMessage);
        setInputValue('');
        setSelectedFile(null);
      }
    } catch (err) {
      toast.error('Failed to send message');
    } finally {
      setIsUploading(false);
    }
  };

  const fetchEditHistory = async (messageId: number) => {
    try {
      const response = await fetch(`http://localhost:8123/api/chat/message/${messageId}/history`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
      });
      if (response.ok) {
        setHistoryData(await response.json());
        setShowHistory(messageId);
      }
    } catch (err) {
      toast.error('Failed to fetch history');
    }
  };

  const onFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (file.size > 10 * 1024 * 1024) {
        toast.error('File size must be less than 10MB');
        return;
      }
      setSelectedFile(file);
    }
  };

  return (
    <div className="flex flex-col h-[600px] bg-white dark:bg-slate-900 rounded-3xl shadow-xl overflow-hidden border border-gray-100 dark:border-slate-800 relative">
      <div className="p-4 bg-primary text-white flex justify-between items-center shadow-md z-10">
        <div className="flex items-center gap-3">
          <div className={`p-2 rounded-2xl ${teacherProfile?.isOnline ? 'bg-white/20' : 'bg-gray-400/20 opacity-50'}`}>
            <User size={24} />
          </div>
          <div>
            <h3 className="font-bold flex items-center gap-2 leading-tight">
              {teacherProfile?.fullName || "Chat with Teacher"}
              {teacherProfile?.isOnline && (
                <span className="flex h-2 w-2 rounded-full bg-green-400 animate-pulse shadow-sm" />
              )}
            </h3>
            <div className="flex items-center gap-1.5 mt-0.5">
              <span className="text-[10px] font-bold uppercase tracking-widest opacity-70">
                {teacherProfile?.isOnline ? "Active Now" : "Currently Offline"}
              </span>
            </div>
          </div>
        </div>
        {selectedFile && (
          <div className="text-xs bg-white/20 px-2 py-1 rounded flex items-center gap-1 animate-in slide-in-from-right-4">
            <Paperclip size={12} /> {selectedFile.name}
            <button onClick={() => setSelectedFile(null)} className="hover:text-red-300 transition-colors"><X size={12} /></button>
          </div>
        )}
      </div>

      <div ref={scrollRef} className="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50/50 dark:bg-slate-950/50 custom-scrollbar">
        {messages.map((msg: Message) => {
          const isMe = msg.senderId === currentUserId;
          return (
            <div key={msg.id} className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}>
              <div className={`max-w-[80%] rounded-2xl p-3 shadow-sm relative group transition-all ${
                isMe 
                  ? 'bg-primary text-white rounded-tr-none' 
                  : 'bg-white dark:bg-slate-800 text-gray-900 dark:text-white rounded-tl-none border border-gray-100 dark:border-slate-700'
              }`}>
                {msg.mediaUrl && (
                  <div className="mb-2 rounded-xl overflow-hidden shadow-inner">
                    {msg.mediaType === 'IMAGE' ? (
                      <img src={`http://localhost:8123${msg.mediaUrl}`} alt="Sent" className="max-w-full h-auto cursor-pointer" onClick={() => window.open(`http://localhost:8123${msg.mediaUrl}`)} />
                    ) : (
                      <a href={`http://localhost:8123${msg.mediaUrl}`} target="_blank" rel="noreferrer" className="flex items-center gap-2 p-3 bg-black/10 rounded-lg text-sm font-bold">
                        <FileIcon size={20} /> View Document <Download size={16} />
                      </a>
                    )}
                  </div>
                )}
                <p className="whitespace-pre-wrap text-sm leading-relaxed">{msg.content}</p>
                <div className={`flex items-center gap-2 mt-1.5 text-[10px] font-bold ${isMe ? 'text-white/70' : 'text-gray-400'}`}>
                  {new Date(msg.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  {msg.isEdited && (
                    <button onClick={() => fetchEditHistory(msg.id)} className="hover:underline flex items-center gap-0.5">
                      <History size={10} /> Edited
                    </button>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {showHistory && (
        <div className="absolute inset-0 bg-black/30 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white dark:bg-slate-900 rounded-3xl w-full max-w-sm p-6 shadow-2xl animate-in zoom-in-95">
            <div className="flex justify-between items-center mb-4">
              <h4 className="font-bold flex items-center gap-2">
                <History size={18} className="text-primary" /> Edit History
              </h4>
              <button onClick={() => setShowHistory(null)} className="p-1 hover:bg-gray-100 dark:hover:bg-slate-800 rounded-full transition-colors font-bold"><X size={20} /></button>
            </div>
            <div className="space-y-4 max-h-60 overflow-y-auto pr-2 custom-scrollbar">
              {historyData.map((h: any) => (
                <div key={h.id} className="p-4 bg-gray-50 dark:bg-slate-800 rounded-2xl border border-gray-100 dark:border-slate-700">
                  <p className="text-sm">{h.oldContent}</p>
                  <span className="text-[10px] text-gray-400 mt-2 block font-bold">
                    {new Date(h.editedAt).toLocaleString()}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      <div className="p-4 border-t border-gray-100 dark:border-slate-800 bg-white dark:bg-slate-900">
        <div className="flex items-end gap-2 bg-gray-50 dark:bg-slate-800 p-2 rounded-2xl border border-gray-100 dark:border-slate-700 focus-within:ring-2 focus-within:ring-primary/20 transition-all">
          <input type="file" id="chat-file" className="hidden" accept="image/*,.pdf" onChange={onFileChange} />
          <button 
            onClick={() => document.getElementById('chat-file')?.click()}
            className="p-3 text-gray-400 hover:text-primary transition-colors rounded-xl hover:bg-white dark:hover:bg-slate-700"
          >
            <Paperclip size={20} />
          </button>
          <textarea
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            placeholder="Type a message..."
            className="flex-1 bg-transparent border-none focus:ring-0 text-sm py-2 resize-none max-h-32 text-gray-900 dark:text-white font-medium"
            rows={1}
            onKeyDown={(e) => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); handleSend(); } }}
          />
          <button
            onClick={handleSend}
            disabled={isUploading || (!inputValue.trim() && !selectedFile)}
            className="p-3 bg-primary text-white rounded-xl hover:scale-105 active:scale-95 transition-all shadow-lg shadow-primary/20 disabled:opacity-50 disabled:scale-100"
          >
            {isUploading ? <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : <Send size={20} />}
          </button>
        </div>
      </div>
    </div>
  );
};
