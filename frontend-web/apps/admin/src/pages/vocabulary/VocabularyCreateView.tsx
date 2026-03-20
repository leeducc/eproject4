import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { AdminLayout } from '../../components/AdminLayout';
import { VocabularyItem } from '../../features/vocabulary/types';
import { useVocabularyStore } from '../../features/vocabulary/store';
import { ArrowLeft, Save, Type, Sparkles } from 'lucide-react';
import { toast } from '@english-learning/ui';

export const VocabularyCreateView: React.FC = () => {
  const navigate = useNavigate();
  const { createWord } = useVocabularyStore();

  const [form, setForm] = useState<Partial<VocabularyItem>>({
    word: '',
    pos: '',
    level: 'a1',
    type: 'word'
  });

  const handleSave = async () => {
    if (!form.word || !form.pos || !form.level || !form.type) {
      toast.error("Please fill in all core metadata fields.");
      return;
    }

    try {
      const newItem = await createWord(form as VocabularyItem);
      toast.success("Vocabulary entry created! Redirecting to details...");
      navigate(`/admin/vocabulary/${newItem.id}`);
    } catch (err) {
      toast.error("Failed to create vocabulary entry.");
    }
  };

  return (
    <AdminLayout>
      <div className="p-8 space-y-8 bg-[#0B0F1A] min-h-screen text-white">
        {/* Header */}
        <div className="flex items-center gap-4">
          <button 
            onClick={() => navigate('/admin/questions/vocabulary')}
            className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
          >
            <ArrowLeft size={20} />
          </button>
          <div>
            <h1 className="text-3xl font-bold uppercase tracking-tight">New Vocabulary</h1>
            <p className="text-gray-400 text-sm">Manually create a dictionary entry</p>
          </div>
          <div className="ml-auto">
            <button
              onClick={handleSave}
              className="flex items-center gap-2 px-6 py-2.5 bg-blue-600 hover:bg-blue-500 rounded-xl transition-all font-bold shadow-lg shadow-blue-500/20"
            >
              <Save size={18} />
              Save & Create
            </button>
          </div>
        </div>

        <div className="max-w-4xl mx-auto">
           <section className="bg-[#1A2235]/40 border border-gray-800 rounded-3xl p-8 backdrop-blur-sm shadow-xl">
              <div className="flex items-center gap-2 mb-8 text-blue-400">
                <Type size={22} />
                <h3 className="font-bold uppercase tracking-wider text-sm">Core Metadata</h3>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="space-y-6">
                  <div>
                    <label className="text-xs text-gray-500 font-bold uppercase mb-2 block tracking-widest">Word / Phrase</label>
                    <input
                      type="text"
                      placeholder="e.g. Resilient"
                      value={form.word}
                      onChange={(e) => setForm(prev => ({...prev, word: e.target.value}))}
                      className="w-full bg-[#0F172A] border border-gray-700 rounded-xl px-4 py-3.5 focus:border-blue-500 outline-none transition-all placeholder:text-gray-600"
                    />
                  </div>
                  <div>
                    <label className="text-xs text-gray-500 font-bold uppercase mb-2 block tracking-widest">Part of Speech</label>
                    <input
                      type="text"
                      placeholder="e.g. Adjective"
                      value={form.pos}
                      onChange={(e) => setForm(prev => ({...prev, pos: e.target.value}))}
                      className="w-full bg-[#0F172A] border border-gray-700 rounded-xl px-4 py-3.5 focus:border-blue-500 outline-none transition-all placeholder:text-gray-600"
                    />
                  </div>
                </div>

                <div className="space-y-6">
                  <div>
                    <label className="text-xs text-gray-500 font-bold uppercase mb-2 block tracking-widest">Level (Global)</label>
                    <select
                      value={form.level}
                      onChange={(e) => setForm(prev => ({...prev, level: e.target.value}))}
                      className="w-full bg-[#0F172A] border border-gray-700 rounded-xl px-4 py-3.5 focus:border-blue-500 outline-none transition-all uppercase appearance-none"
                    >
                      <option value="a1">A1 - Beginner</option>
                      <option value="a2">A2 - Elementary</option>
                      <option value="b1">B1 - Pre-Intermediate</option>
                      <option value="b2">B2 - Intermediate</option>
                      <option value="c1">C1 - Advanced</option>
                      <option value="c2">C2 - Proficiency</option>
                    </select>
                  </div>
                  <div>
                    <label className="text-xs text-gray-500 font-bold uppercase mb-2 block tracking-widest">Type</label>
                    <select
                      value={form.type}
                      onChange={(e) => setForm(prev => ({...prev, type: e.target.value}))}
                      className="w-full bg-[#0F172A] border border-gray-700 rounded-xl px-4 py-3.5 focus:border-blue-500 outline-none transition-all appearance-none"
                    >
                      <option value="word">Single Word</option>
                      <option value="phrase">Phrase / Expression</option>
                    </select>
                  </div>
                </div>
              </div>

              <div className="mt-12 p-6 bg-blue-500/5 border border-blue-500/10 rounded-2xl flex items-start gap-4">
                 <div className="p-2 bg-blue-500/20 rounded-lg shrink-0">
                    <Sparkles size={20} className="text-blue-400" />
                 </div>
                 <div>
                    <p className="text-sm font-medium text-blue-300">AI Content Suggestion</p>
                    <p className="text-xs text-gray-400 mt-1">After saving, you'll be redirected to the detail page where you can generate AI definitions, examples, and practice questions automatically.</p>
                 </div>
              </div>
            </section>
        </div>
      </div>
    </AdminLayout>
  );
};
