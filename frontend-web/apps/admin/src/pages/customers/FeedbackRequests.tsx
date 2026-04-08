import React, { useState, useEffect } from 'react';
import { AdminLayout } from '../../components/AdminLayout';

export const FeedbackRequests: React.FC = () => {
  const [feedbacks, setFeedbacks] = useState<any[]>([]);
  const [selectedFeedback, setSelectedFeedback] = useState<any | null>(null);
  const [messages, setMessages] = useState<any[]>([]);
  const [replyText, setReplyText] = useState('');
  const [page, setPage] = useState(0);

  useEffect(() => {
    fetchFeedbacks();
  }, [page]);

  const fetchFeedbacks = async () => {
    try {
      const response = await fetch(`http://localhost:8123/api/admin/feedback?page=${page}&size=20`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
      });
      if (response.ok) {
        const data = await response.json();
        setFeedbacks(data.content);
      }
    } catch (e) {
      console.error(e);
    }
  };

  const loadFeedbackDetails = async (id: number) => {
    try {
      const response = await fetch(`http://localhost:8123/api/admin/feedback/${id}`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
      });
      if (response.ok) {
        const data = await response.json();
        setSelectedFeedback(data.feedback);
        setMessages(data.messages);
      }
    } catch (e) {
      console.error(e);
    }
  };

  const submitReply = async () => {
    if (!replyText.trim() || !selectedFeedback) return;
    try {
      const response = await fetch(`http://localhost:8123/api/admin/feedback/${selectedFeedback.id}/reply`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('admin_token')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ textContent: replyText })
      });
      if (response.ok) {
        setReplyText('');
        loadFeedbackDetails(selectedFeedback.id);
        fetchFeedbacks(); // Refresh list to update status
      }
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <AdminLayout title="Feedback Requests">
      <div className="flex h-[calc(100vh-80px)] gap-4 p-4">
        <div className="w-1/3 flex flex-col gap-4 overflow-y-auto">
          {feedbacks.map(f => (
            <div 
              key={f.id} 
              className={`cursor-pointer transition-colors border rounded-xl overflow-hidden ${selectedFeedback?.id === f.id ? 'border-primary shadow-sm bg-primary/10' : 'bg-white dark:bg-slate-900 border-gray-200 dark:border-slate-800 hover:border-primary/50'}`}
              onClick={() => loadFeedbackDetails(f.id)}
            >
              <div className="p-4 pb-2">
                <div className="flex justify-between items-center">
                  <span className="font-semibold text-gray-900 dark:text-white">{f.userFullName}</span>
                  <span className={`px-2 py-1 text-xs rounded-full ${f.status === 'PENDING' ? 'bg-red-100 text-red-700' : 'bg-gray-100 text-gray-700'}`}>
                    {f.status}
                  </span>
                </div>
                <h3 className="text-md mt-1 font-medium text-gray-800 dark:text-gray-100">{f.title}</h3>
                <span className="text-xs text-gray-500 dark:text-gray-400">{new Date(f.createdAt).toLocaleString()}</span>
              </div>
            </div>
          ))}
          <div className="flex justify-between mt-4">
             <button className="px-4 py-2 border rounded-md" disabled={page === 0} onClick={() => setPage(p => p - 1)}>Previous</button>
             <button className="px-4 py-2 border rounded-md" onClick={() => setPage(p => p + 1)}>Next</button>
          </div>
        </div>

        <div className="w-2/3 h-full">
          {selectedFeedback ? (
            <div className="h-full flex flex-col bg-white dark:bg-slate-900 border border-gray-200 dark:border-slate-800 rounded-xl overflow-hidden relative">
              <div className="p-6 border-b border-gray-200 dark:border-slate-800">
                <div className="flex justify-between">
                   <h2 className="text-xl font-bold text-gray-900 dark:text-white">{selectedFeedback.title}</h2>
                   <span className={`px-2 py-1 text-xs rounded-full h-min ${selectedFeedback.status === 'PENDING' ? 'bg-red-100 text-red-700' : 'bg-gray-100 text-gray-700'}`}>
                     {selectedFeedback.status}
                   </span>
                </div>
                <div className="text-sm text-gray-500 dark:text-gray-400 mt-1">From: {selectedFeedback.userFullName} ({selectedFeedback.userEmail})</div>
              </div>
              <div className="flex-1 overflow-y-auto p-6 pb-[100px]">
                <div className="bg-gray-50 dark:bg-slate-800 p-4 rounded-md mb-6">
                  <p className="whitespace-pre-wrap text-gray-800 dark:text-gray-200">{selectedFeedback.textContent}</p>
                  {selectedFeedback.imageUrl && (
                    <img 
                      src={`http://localhost:8123${selectedFeedback.imageUrl}`} 
                      alt="Feedback attachment" 
                      className="mt-4 rounded-lg max-h-[300px] object-contain bg-black/5" 
                    />
                  )}
                </div>

                <div className="flex flex-col gap-4">
                  {messages.map(msg => (
                    <div key={msg.id} className={`flex ${msg.admin ? 'justify-end' : 'justify-start'}`}>
                      <div className={`max-w-[80%] rounded-lg p-3 ${msg.admin ? 'bg-primary text-white' : 'bg-gray-100 dark:bg-slate-800 text-gray-800 dark:text-gray-200'}`}>
                        <p className="whitespace-pre-wrap">{msg.textContent}</p>
                        <span className="text-xs opacity-70 mt-1 block">
                          {new Date(msg.createdAt).toLocaleString()} {msg.admin ? '(Admin Response)' : ''}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {selectedFeedback.status !== 'RESOLVED' && (
                <div className="absolute w-full bottom-0 p-4 bg-white dark:bg-slate-900 border-t border-gray-200 dark:border-slate-800">
                  <div className="flex gap-2">
                    <input 
                      value={replyText}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => setReplyText(e.target.value)}
                      placeholder="Type your response... (Will send an email)"
                      className="flex-1 px-3 py-2 border rounded-md"
                      onKeyDown={(e: React.KeyboardEvent<HTMLInputElement>) => { if(e.key === 'Enter') submitReply(); }}
                    />
                    <button className="px-4 py-2 bg-primary text-white rounded-md" onClick={submitReply}>Send Reply</button>
                  </div>
                </div>
              )}
            </div>
          ) : (
            <div className="h-full flex items-center justify-center text-gray-400 bg-white dark:bg-slate-900 border border-gray-200 dark:border-slate-800 rounded-xl">
              Select a feedback request to view details
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
};
