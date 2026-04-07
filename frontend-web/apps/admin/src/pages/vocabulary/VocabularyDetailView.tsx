import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { AdminLayout } from '../../components/AdminLayout';
import { 
  VocabularyItem, 
  VocabularyDetail as WordDetails, 
  VocabularyPractice 
} from '../../features/vocabulary/types';
import { useVocabularyStore } from '../../features/vocabulary/store';
import { ArrowLeft, Save, Sparkles, Plus, Trash2, Edit3, Type, List, FileText, ChevronDown, ChevronUp, History as HistoryIcon, RefreshCw, Star } from 'lucide-react';
import { VocabularyHistoryModal } from '../../features/vocabulary/components/VocabularyHistoryModal';
import { PracticeHistoryModal } from '../../features/vocabulary/components/PracticeHistoryModal';
import { AIGeneratingOverlay } from '../../features/vocabulary/components/AIGeneratingOverlay';
import { ConfirmDialog } from '@english-learning/ui';
import { toast } from '@english-learning/ui';

export const VocabularyDetailView: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { 
    items, 
    fetchVocabularyPaginated,
    fetchWordDetails,
    fetchWordPracticeAll,
    updateWord,
    updatePractice,
    deletePractice,
    createPractice,
    ensureAIContent
  } = useVocabularyStore();

  const [item, setItem] = useState<VocabularyItem | null>(null);
  const [details, setDetails] = useState<WordDetails | null>(null);
  const [practices, setPractices] = useState<VocabularyPractice[]>([]);
  const [isAILoading, setIsAILoading] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [editValues, setEditValues] = useState<VocabularyItem | null>(null);
  const [practiceToDelete, setPracticeToDelete] = useState<number | null>(null);
  const [historyWordId, setHistoryWordId] = useState<number | null>(null);
  const [historyPracticeId, setHistoryPracticeId] = useState<number | null>(null);
  const [expandedPractices, setExpandedPractices] = useState<Set<number>>(new Set());
  
  
  const [editPracticeId, setEditPracticeId] = useState<number | null>(null);
  const [editingPracticeContent, setEditingPracticeContent] = useState<any>(null);
  
  const abortControllerRef = useRef<AbortController | null>(null);

  
  useEffect(() => {
    const loadItem = async () => {
      if (items.length === 0) {
        await fetchVocabularyPaginated({ limit: 100 });
      }
      const found = items.find(i => i.id === Number(id));
      if (found) {
        setItem(found);
        setEditValues(found);
      }
    };
    loadItem();
  }, [id, items, fetchVocabularyPaginated]);

  
  useEffect(() => {
    if (!item) return;

    const loadInitialContent = async () => {
      try {
        const [deta, pracs] = await Promise.all([
          fetchWordDetails(item.word),
          fetchWordPracticeAll(item.word)
        ]);
        setDetails(deta);
        setPractices(pracs);
      } catch (err) {
        console.error("Failed to load initial content:", err);
      }
    };

    loadInitialContent();
  }, [item, fetchWordDetails, fetchWordPracticeAll]);

  const handleGenerateAI = async () => {
    if (!item) return;
    
    setIsAILoading(true);
    abortControllerRef.current = new AbortController();
    
    try {
      await ensureAIContent(item.word, abortControllerRef.current.signal);
      
      
      if (!abortControllerRef.current.signal.aborted) {
        const [newDeta, newPracs] = await Promise.all([
          fetchWordDetails(item.word),
          fetchWordPracticeAll(item.word)
        ]);
        setDetails(newDeta);
        setPractices(newPracs);
        toast.success("AI Content generated successfully.");
      }
    } catch (err: any) {
      if (err.name !== 'AbortError') {
        toast.error("Failed to generate AI content.");
      }
    } finally {
      setIsAILoading(false);
      abortControllerRef.current = null;
    }
  };

  const handleCancelAI = () => {
    if (abortControllerRef.current) {
      abortControllerRef.current.abort();
      setIsAILoading(false);
      toast.info("AI Generation cancelled.");
    }
  };

  const handleSaveWord = async () => {
    if (editValues && id) {
      try {
        await updateWord(Number(id), editValues);
        setItem(editValues);
        setDetails({
          definition: editValues.definition || '',
          examples: editValues.examples || [],
          synonyms: editValues.synonyms || []
        });
        setIsEditing(false);
        toast.success("Word updated successfully.");
      } catch (err) {
        toast.error("Failed to update word.");
      }
    }
  };
  
  const handleTogglePremium = async () => {
    if (!item || !id) return;
    try {
      const updatedItem = { ...item, isPremium: !item.isPremium };
      await updateWord(Number(id), updatedItem);
      setItem(updatedItem);
      toast.success(updatedItem.isPremium ? "Marked as premium content." : "Removed from premium content.");
    } catch (err) {
      toast.error("Failed to update premium status.");
    }
  };

  const handleDeletePractice = async () => {
    if (practiceToDelete) {
      try {
        await deletePractice(practiceToDelete);
        setPractices(practices.filter(p => p.id !== practiceToDelete));
        setPracticeToDelete(null);
        toast.success("Practice question deleted.");
      } catch (err) {
        toast.error("Failed to delete practice question.");
      }
    }
  };
  const handleAddManually = async () => {
    if (!item) return;
    const dummyPractice = {
      type: 'MULTIPLE_CHOICE',
      question: `Sample question for ${item.word}`,
      options: ['Option A', 'Option B', 'Option C', 'Option D'],
      answer: 'Option A'
    };
    try {
      const newPrac = await createPractice(item.word, dummyPractice);
      setPractices([newPrac, ...practices]);
      toast.success("Manual practice template added.");
      setExpandedPractices(new Set([newPrac.id!]));
    } catch (err) {
      toast.error("Failed to add manual practice.");
    }
  };

  const handleEditPractice = (prac: VocabularyPractice) => {
    setEditPracticeId(prac.id);
    setEditingPracticeContent(prac.content);
    setExpandedPractices(prev => {
      const next = new Set(prev);
      next.add(prac.id);
      return next;
    });
  };

  const handleCancelEditPractice = () => {
    setEditPracticeId(null);
    setEditingPracticeContent(null);
  };

  const handleSavePractice = async (id: number) => {
    try {
      await updatePractice(id, JSON.stringify(editingPracticeContent));
      setPractices(prev => prev.map(p => 
        p.id === id ? { ...p, content: editingPracticeContent, jsonContent: JSON.stringify(editingPracticeContent) } : p
      ));
      handleCancelEditPractice();
      toast.success("Practice question updated.");
    } catch (err) {
      toast.error("Failed to update practice question.");
    }
  };

  const handleToggleExpand = (id: number) => {
    setExpandedPractices(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  if (!item) return <AdminLayout><div className="p-8">Loading...</div></AdminLayout>;

  return (
    <AdminLayout>
      <AIGeneratingOverlay 
        isOpen={isAILoading} 
        word={item.word} 
        onCancel={handleCancelAI}
      />
      <div className="p-8 space-y-8 bg-[#0B0F1A] min-h-screen text-white">
        {}
        <div className="flex items-center gap-4">
          <button 
            onClick={() => navigate('/admin/questions/vocabulary')}
            className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
          >
            <ArrowLeft size={20} />
          </button>
          <div>
            <h1 className="text-3xl font-bold uppercase tracking-tight">{item.word}</h1>
            <p className="text-gray-400 text-sm">Vocabulary Detail & AI Resources</p>
          </div>
          <div className="ml-auto flex gap-3">
             <button
              onClick={() => setHistoryWordId(Number(id))}
              className="flex items-center gap-2 px-4 py-2 bg-gray-800 hover:bg-gray-700 rounded-xl transition-all font-medium border border-gray-700"
            >
              <HistoryIcon size={18} />
              History
            </button>
            <button
              onClick={handleTogglePremium}
              className={`flex items-center gap-2 px-4 py-2 rounded-xl transition-all font-medium border ${
                item.isPremium 
                  ? 'bg-amber-400/20 text-amber-400 border-amber-400/30 shadow-lg shadow-amber-500/10' 
                  : 'bg-gray-800 text-gray-400 border-gray-700 hover:bg-gray-700'
              }`}
            >
              <Star size={18} fill={item.isPremium ? "currentColor" : "none"} />
              {item.isPremium ? 'Premium Content' : 'Mark as Premium'}
            </button>
            <button
              onClick={handleGenerateAI}
              disabled={isAILoading}
              className="flex items-center gap-2 px-4 py-2 bg-emerald-600/20 hover:bg-emerald-600/30 text-emerald-400 rounded-xl transition-all font-medium border border-emerald-600/30 shadow-lg shadow-emerald-500/10"
            >
              <RefreshCw size={18} className={isAILoading ? 'animate-spin' : ''} />
              Generate AI Content
            </button>
            <button
              onClick={() => isEditing ? handleSaveWord() : setIsEditing(true)}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-500 rounded-xl transition-all font-medium shadow-lg shadow-blue-500/20"
            >
              {isEditing ? <Save size={18} /> : <Edit3 size={18} />}
              {isEditing ? 'Save' : 'Edit'}
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
          {}
          <div className="lg:col-span-4 space-y-8">
            <section className="bg-[#1A2235]/40 border border-gray-800 rounded-3xl p-6 backdrop-blur-sm shadow-xl">
              <div className="flex items-center gap-2 mb-6 text-blue-400">
                <Type size={20} />
                <h3 className="font-bold uppercase tracking-wider text-sm">Core Metadata</h3>
              </div>
              
              <div className="space-y-4">
                <div>
                  <label className="text-xs text-gray-400 font-bold uppercase mb-1 block">Word / Phrase</label>
                  <input
                    type="text"
                    disabled={!isEditing}
                    value={editValues?.word || ''}
                    onChange={(e) => setEditValues(prev => prev ? {...prev, word: e.target.value} : null)}
                    className="w-full bg-[#0F172A] border border-gray-700 rounded-xl px-4 py-3 focus:border-blue-500 outline-none transition-all disabled:opacity-50"
                  />
                </div>
                <div>
                  <label className="text-xs text-gray-400 font-bold uppercase mb-1 block">Part of Speech</label>
                  <input
                    type="text"
                    disabled={!isEditing}
                    value={editValues?.pos || ''}
                    onChange={(e) => setEditValues(prev => prev ? {...prev, pos: e.target.value} : null)}
                    className="w-full bg-[#0F172A] border border-gray-700 rounded-xl px-4 py-3 focus:border-blue-500 outline-none transition-all disabled:opacity-50"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="text-xs text-gray-400 font-bold uppercase mb-1 block">Level</label>
                    <input
                      type="text"
                      disabled={!isEditing}
                      value={editValues?.level || ''}
                      onChange={(e) => setEditValues(prev => prev ? {...prev, level: e.target.value} : null)}
                      className="w-full bg-[#0F172A] border border-gray-700 rounded-xl px-4 py-3 focus:border-blue-500 outline-none transition-all disabled:opacity-50 uppercase"
                    />
                  </div>
                  <div>
                    <label className="text-xs text-gray-400 font-bold uppercase mb-1 block">Type</label>
                    <input
                      type="text"
                      disabled={!isEditing}
                      value={editValues?.type || ''}
                      onChange={(e) => setEditValues(prev => prev ? {...prev, type: e.target.value} : null)}
                      className="w-full bg-[#0F172A] border border-gray-700 rounded-xl px-4 py-3 focus:border-blue-500 outline-none transition-all disabled:opacity-50"
                    />
                  </div>
                </div>
              </div>
            </section>

            <section className="bg-[#1A2235]/40 border border-gray-800 rounded-3xl p-6 backdrop-blur-sm shadow-xl">
              <div className="flex items-center gap-2 mb-6 text-purple-400">
                <Sparkles size={20} />
                <h3 className="font-bold uppercase tracking-wider text-sm">AI Definition</h3>
              </div>
              {details?.definition || isEditing ? (
                <div className="space-y-6">
                  <div>
                    <label className="text-xs text-gray-500 font-bold uppercase tracking-widest mb-2 block">Phonetic</label>
                    {isEditing ? (
                      <input
                        type="text"
                        value={editValues?.phonetic || ''}
                        onChange={(e) => setEditValues(prev => prev ? {...prev, phonetic: e.target.value} : null)}
                        className="w-full bg-[#0F172A] border border-gray-700 rounded-xl px-4 py-3 focus:border-blue-500 outline-none transition-all text-gray-300 text-sm"
                        placeholder="/əˈdæpt/"
                      />
                    ) : (
                      <div className="bg-[#0F172A] p-4 rounded-xl border border-gray-800">
                        <p className="text-gray-300 font-serif italic text-lg">{details?.phonetic || 'N/A'}</p>
                      </div>
                    )}
                  </div>
                  <div>
                    <label className="text-xs text-gray-500 font-bold uppercase tracking-widest mb-2 block">Definition</label>
                    {isEditing ? (
                      <textarea
                        value={editValues?.definition || ''}
                        onChange={(e) => setEditValues(prev => prev ? {...prev, definition: e.target.value} : null)}
                        className="w-full bg-[#0F172A] border border-gray-700 rounded-xl px-4 py-3 focus:border-blue-500 outline-none transition-all min-h-[100px] text-gray-300 text-sm italic"
                      />
                    ) : (
                      <div className="bg-[#0F172A] p-4 rounded-xl border border-gray-800">
                        <p className="text-gray-300 leading-relaxed italic">{details?.definition}</p>
                      </div>
                    )}
                  </div>

                  <div className="space-y-3">
                    <label className="text-xs text-gray-500 font-bold uppercase tracking-widest block">Examples</label>
                    {(isEditing ? editValues?.examples : details?.examples)?.map((ex, idx) => (
                      <div key={idx} className="bg-gray-800/20 p-3 rounded-lg border-l-2 border-purple-500/50">
                        {isEditing ? (
                          <input
                            type="text"
                            value={ex}
                            onChange={(e) => {
                              const newExs = [...(editValues?.examples || [])];
                              newExs[idx] = e.target.value;
                              setEditValues(prev => prev ? {...prev, examples: newExs} : null);
                            }}
                            className="bg-transparent w-full text-sm text-gray-400 outline-none"
                          />
                        ) : (
                          <p className="text-sm text-gray-400 leading-relaxed">{ex}</p>
                        )}
                      </div>
                    ))}
                  </div>

                  <div className="space-y-3">
                    <label className="text-xs text-gray-500 font-bold uppercase tracking-widest block">Synonyms</label>
                    {isEditing ? (
                      <input
                        type="text"
                        value={editValues?.synonyms?.join(', ') || ''}
                        onChange={(e) => {
                          const sins = e.target.value.split(',').map(s => s.trim());
                          setEditValues(prev => prev ? {...prev, synonyms: sins} : null);
                        }}
                        placeholder="synonym1, synonym2, synonym3"
                        className="w-full bg-[#0F172A] border border-gray-800 rounded-lg p-2 text-sm text-blue-400 border-dashed"
                      />
                    ) : (
                      <div className="flex flex-wrap gap-2">
                        {details?.synonyms?.map((syn, idx) => (
                          <span key={idx} className="bg-blue-500/10 text-blue-400 px-3 py-1.5 rounded-xl text-sm font-medium border border-blue-500/20">
                            {syn}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              ) : (
                <div className="py-8 text-center text-gray-500 flex flex-col items-center gap-3">
                  <Sparkles size={32} className="opacity-20" />
                  <p className="text-sm italic">Click "Generate AI Content" to populate definitions and examples.</p>
                </div>
              )}
            </section>
          </div>

          {}
          <div className="lg:col-span-8 flex flex-col h-full">
             <section className="bg-[#1A2235]/40 border border-gray-800 rounded-3xl p-6 backdrop-blur-sm shadow-xl flex-grow">
              <div className="flex items-center justify-between mb-8">
                <div className="flex items-center gap-2 text-emerald-400">
                  <List size={22} />
                  <h3 className="font-bold uppercase tracking-wider text-sm">Practice Question Bank</h3>
                </div>
                <div className="flex items-center gap-2">
                  <button 
                    onClick={handleAddManually}
                    className="flex items-center gap-2 px-4 py-2 bg-emerald-600/20 hover:bg-emerald-600/30 text-emerald-400 rounded-xl transition-all text-xs font-bold border border-emerald-600/30"
                  >
                    <Plus size={16} />
                    Add Manually
                  </button>
                </div>
              </div>

              {practices.length > 0 ? (
                <div className="grid grid-cols-1 gap-4">
                  {practices.map((prac) => {
                    const isExpanded = expandedPractices.has(prac.id!);
                    return (
                      <div 
                        key={prac.id}
                        className="group bg-[#0F172A]/80 border border-gray-800 rounded-2xl overflow-hidden hover:border-gray-700 transition-all duration-300"
                      >
                        <div className="p-4 flex items-center justify-between cursor-pointer" onClick={() => handleToggleExpand(prac.id!)}>
                          <div className="flex items-center gap-4">
                            <div className="p-2.5 bg-gray-800 rounded-xl group-hover:scale-110 transition-transform">
                              <FileText size={18} className="text-blue-400" />
                            </div>
                            <div>
                              <div className="flex items-center gap-2 mb-1">
                                <span className="text-[10px] bg-blue-500/10 text-blue-400 px-2 py-0.5 rounded font-bold uppercase tracking-wider">
                                  {prac.quizType.replace(/_/g, ' ')}
                                </span>
                                <span className="text-[10px] text-gray-500 font-medium">v{prac.version}</span>
                              </div>
                              <p className="text-sm font-medium text-gray-200 line-clamp-1">
                                {prac.content?.question || 
                                 prac.content?.sentence || 
                                 (prac.content?.pairs?.[0]?.word ? prac.content.pairs[0].word + '...' : 'No preview available')}
                              </p>
                            </div>
                          </div>
                          <div className="flex items-center gap-2">
                              <button
                                 onClick={(e) => {
                                   e.stopPropagation();
                                   handleEditPractice(prac);
                                 }}
                                 className="p-2 text-gray-500 hover:text-emerald-400 hover:bg-emerald-500/10 rounded-lg transition-all"
                                 title="Edit practice"
                               >
                                 <Edit3 size={16} />
                               </button>
                              <button
                                 onClick={(e) => {
                                   e.stopPropagation();
                                   setHistoryPracticeId(prac.id!);
                                 }}
                                 className="p-2 text-gray-500 hover:text-blue-400 hover:bg-blue-500/10 rounded-lg transition-all"
                                 title="View history"
                               >
                                 <HistoryIcon size={16} />
                               </button>
                            <button
                              onClick={(e) => { e.stopPropagation(); setPracticeToDelete(prac.id!); }}
                              className="p-2 text-gray-500 hover:text-red-400 hover:bg-red-500/10 rounded-lg transition-all"
                            >
                              <Trash2 size={16} />
                            </button>
                            {isExpanded ? <ChevronUp size={20} className="text-gray-600" /> : <ChevronDown size={20} className="text-gray-600" />}
                          </div>
                        </div>

                        {isExpanded && (
                          <div className="px-5 pb-5 pt-2 border-t border-gray-800/50 bg-gray-900/30">
                            {prac.quizType === 'MATCHING' ? (
                              <div className="grid grid-cols-2 gap-3 mt-2">
                                {prac.content?.pairs?.map((pair: any, i: number) => (
                                  <div key={i} className="flex items-center gap-3 bg-black/20 p-3 rounded-lg border border-gray-800/50">
                                    <span className="text-sm text-blue-400 font-bold">{pair.word}</span>
                                    <span className="text-gray-600">→</span>
                                    <span className="text-sm text-gray-400">{pair.definition}</span>
                                  </div>
                                ))}
                              </div>
                            ) : (
                              editPracticeId === prac.id ? (
                                <div className="space-y-4">
                                  <div className="space-y-2">
                                    <label className="text-[10px] font-bold text-gray-500 uppercase">Question / Sentence</label>
                                    <textarea
                                      className="w-full bg-black/40 border border-gray-700 rounded-xl p-3 text-sm text-gray-200 focus:border-emerald-500/50 focus:ring-1 focus:ring-emerald-500/30 outline-none transition-all"
                                      rows={2}
                                      value={editingPracticeContent.question || editingPracticeContent.sentence || ''}
                                      onChange={(e) => setEditingPracticeContent({ 
                                        ...editingPracticeContent, 
                                        [editingPracticeContent.question !== undefined ? 'question' : 'sentence']: e.target.value 
                                      })}
                                    />
                                  </div>
                                  <div className="grid grid-cols-2 gap-3">
                                    {editingPracticeContent.options?.map((opt: string, i: number) => (
                                      <div key={i} className="space-y-1">
                                        <label className="text-[10px] font-bold text-gray-500 uppercase text-center w-full block">Option {i + 1}</label>
                                        <input
                                          type="text"
                                          className="w-full bg-black/40 border border-gray-700 rounded-xl p-2 text-sm text-gray-200 focus:border-emerald-500/50 outline-none"
                                          value={opt}
                                          onChange={(e) => {
                                            const newOpts = [...editingPracticeContent.options];
                                            newOpts[i] = e.target.value;
                                            setEditingPracticeContent({ ...editingPracticeContent, options: newOpts });
                                          }}
                                        />
                                      </div>
                                    ))}
                                  </div>
                                  <div className="space-y-2">
                                    <label className="text-[10px] font-bold text-gray-500 uppercase">Correct Answer</label>
                                    <select
                                      className="w-full bg-black/40 border border-gray-700 rounded-xl p-2 text-sm text-gray-200 focus:border-emerald-500/50 outline-none"
                                      value={editingPracticeContent.answer}
                                      onChange={(e) => setEditingPracticeContent({ ...editingPracticeContent, answer: e.target.value })}
                                    >
                                      {editingPracticeContent.options?.map((opt: string, i: number) => (
                                        <option key={i} value={opt}>{opt}</option>
                                      ))}
                                    </select>
                                  </div>
                                  <div className="flex gap-2 pt-2">
                                    <button
                                      onClick={() => handleSavePractice(prac.id!)}
                                      className="flex-grow py-2 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl text-xs font-bold transition-colors"
                                    >
                                      Save Changes
                                    </button>
                                    <button
                                      onClick={handleCancelEditPractice}
                                      className="px-4 py-2 bg-gray-800 hover:bg-gray-700 text-gray-300 rounded-xl text-xs font-bold transition-colors"
                                    >
                                      Cancel
                                    </button>
                                  </div>
                                </div>
                              ) : (
                                <div className="space-y-4">
                                  <p className="text-sm text-gray-300 bg-black/20 p-4 rounded-xl border border-gray-800">
                                    {prac.content?.question || prac.content?.sentence}
                                  </p>
                                  <div className="grid grid-cols-2 gap-3">
                                    {prac.content?.options?.map((opt: string, i: number) => (
                                      <div key={i} className={`p-3 rounded-xl border text-sm flex justify-between ${opt === prac.content?.answer ? 'bg-emerald-500/10 border-emerald-500/30 text-emerald-400' : 'bg-gray-800/30 border-gray-800 text-gray-500'}`}>
                                        {opt}
                                        {opt === prac.content?.answer && <Sparkles size={14} className="opacity-50" />}
                                      </div>
                                    ))}
                                  </div>
                                </div>
                              )
                            )}
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              ) : (
                <div className="h-64 flex flex-col items-center justify-center text-gray-500 bg-black/10 rounded-3xl border border-dashed border-gray-800">
                  <FileText size={48} className="opacity-10 mb-4" />
                  <p className="text-sm">No practice questions. Use "Generate AI Content".</p>
                </div>
              )}
            </section>
          </div>
        </div>
      </div>

      <ConfirmDialog
        isOpen={!!practiceToDelete}
        title="Delete Question?"
        message="Are you sure you want to remove this practice question? This action cannot be undone."
        onConfirm={handleDeletePractice}
        onClose={() => setPracticeToDelete(null)}
        variant="danger"
      />

      <VocabularyHistoryModal
        isOpen={!!historyWordId}
        onClose={() => setHistoryWordId(null)}
        vocabularyId={Number(id)}
      />

      <PracticeHistoryModal
        isOpen={!!historyPracticeId}
        onClose={() => setHistoryPracticeId(null)}
        practiceId={historyPracticeId!}
      />
    </AdminLayout>
  );
};
