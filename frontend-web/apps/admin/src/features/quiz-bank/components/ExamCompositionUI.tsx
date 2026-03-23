import React, { useState, useMemo, useEffect } from 'react';
import { useQuizBankStore } from '../store';
import { SkillType, ExamType } from '../types';
import { Search, BookOpen, Layers, CheckCircle2, AlertCircle, Eye, X, Music, FileText } from 'lucide-react';
import { toast } from '@english-learning/ui';
import { getMediaUrl } from '../utils';
import { StudentPreview } from './StudentPreview';
import { Question } from '../types';

interface ExamCompositionUIProps {
  onSave: () => void;
  examId?: number;
  mode?: 'CREATE' | 'EDIT' | 'VIEW';
}

export const ExamCompositionUI: React.FC<ExamCompositionUIProps> = ({ onSave, examId, mode = 'CREATE' }) => {
  const { 
    questions, 
    questionGroups, 
    fetchQuestions, 
    fetchGroups, 
    createExam, 
    updateExam,
    fetchExamById 
  } = useQuizBankStore();
  
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [examType, setExamType] = useState<ExamType>('ORG_EXAM');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedSkillFilter, setSelectedSkillFilter] = useState<SkillType | 'ALL'>('ALL');
  
  // Selection
  const [selectedQuestions, setSelectedQuestions] = useState<number[]>([]);
  const [selectedGroups, setSelectedGroups] = useState<number[]>([]);

  // Preview
  const [previewItem, setPreviewItem] = useState<{ item: any, type: 'QUESTION' | 'GROUP' } | null>(null);

  useEffect(() => {
    fetchQuestions();
    fetchGroups();
    
    if (examId) {
      fetchExamById(examId).then(exam => {
        if (exam) {
          setTitle(exam.title);
          setDescription(exam.description || '');
          setExamType(exam.exam_type);
          setSelectedQuestions(exam.question_ids || []);
          setSelectedGroups(exam.group_ids || []);
        }
      });
    }
  }, [fetchQuestions, fetchGroups, examId, fetchExamById]);

  // Combined Pool
  const filteredPool = useMemo(() => {
    const qPool = questions.filter(q => {
      const matchesSkill = selectedSkillFilter === 'ALL' || q.skill === selectedSkillFilter;
      const matchesSearch = (q.instruction || '').toLowerCase().includes(searchQuery.toLowerCase()) || 
                            q.type.toLowerCase().includes(searchQuery.toLowerCase());
      return matchesSkill && matchesSearch;
    }).map(q => ({ ...q, isItemType: 'QUESTION' as const }));

    const gPool = questionGroups.filter(g => {
      const matchesSkill = selectedSkillFilter === 'ALL' || g.skill === selectedSkillFilter;
      const matchesSearch = (g.title || '').toLowerCase().includes(searchQuery.toLowerCase()) || 
                            (g.content || '').toLowerCase().includes(searchQuery.toLowerCase());
      return matchesSkill && matchesSearch;
    }).map(g => ({ ...g, isItemType: 'GROUP' as const }));

    return [...gPool, ...qPool].sort((a, b) => b.id - a.id);
  }, [questions, questionGroups, selectedSkillFilter, searchQuery]);

  const toggleSelection = (id: number, type: 'QUESTION' | 'GROUP') => {
    if (mode === 'VIEW') return;
    if (type === 'QUESTION') {
      setSelectedQuestions(prev => prev.includes(id) ? prev.filter(qId => qId !== id) : [...prev, id]);
    } else {
      setSelectedGroups(prev => prev.includes(id) ? prev.filter(gId => gId !== id) : [...prev, id]);
    }
  };

  // IELTS Validation Counts
  const ieltsCounts = useMemo(() => {
    const counts = { 
      listeningGroups: 0, 
      listeningQuestions: 0,
      readingGroups: 0, 
      readingQuestions: 0,
      writingQuestions: 0 
    };

    selectedGroups.forEach(id => {
      const g = questionGroups.find(x => x.id === id);
      if (g?.skill === 'LISTENING') {
        counts.listeningGroups++;
        counts.listeningQuestions += g.questions?.length || 0;
      }
      if (g?.skill === 'READING') {
        counts.readingGroups++;
        counts.readingQuestions += g.questions?.length || 0;
      }
    });

    selectedQuestions.forEach(id => {
      const q = questions.find(x => x.id === id);
      if (q?.skill === 'WRITING') {
        counts.writingQuestions++;
      }
    });

    return counts;
  }, [selectedQuestions, selectedGroups, questions, questionGroups]);

  const isIELTSValid = examType !== 'IELTS' || (
    ieltsCounts.listeningGroups === 4 && 
    ieltsCounts.listeningQuestions === 40 &&
    ieltsCounts.readingGroups === 3 && 
    ieltsCounts.readingQuestions === 40 &&
    ieltsCounts.writingQuestions === 2
  );

  const handleCreate = () => {
    if (!title.trim() || (selectedQuestions.length === 0 && selectedGroups.length === 0)) {
      toast.error("Please enter a title and select items.");
      return;
    }

    if (!isIELTSValid) {
      toast.error("IELTS Requirements: 4 Listening sections (40 Qs), 3 Reading passages (40 Qs), and 2 Writing tasks.");
      return;
    }

    // Determine unique categories
    const includedCategories = Array.from(new Set([
      ...selectedQuestions.map(id => questions.find(q => q.id === id)?.skill).filter(Boolean),
      ...selectedGroups.map(id => questionGroups.find(g => g.id === id)?.skill).filter(Boolean)
    ] as SkillType[]));

    if (mode === 'EDIT' && examId) {
      updateExam(examId, {
        title,
        description,
        exam_type: examType,
        categories: includedCategories,
        question_ids: selectedQuestions,
        group_ids: selectedGroups,
      }).then(() => {
        toast.success("Exam updated successfully");
        onSave();
      });
    } else {
      createExam({
        title,
        description,
        exam_type: examType,
        categories: includedCategories,
        question_ids: selectedQuestions,
        group_ids: selectedGroups,
        tags: []
      }).then(() => {
        toast.success("Exam created successfully");
        onSave();
      });
    }
  };

  return (
    <div className="flex flex-col lg:flex-row gap-8 font-sans p-2">
      
      {/* Left Column: Exam Meta Data */}
      <div className="w-full lg:w-80 space-y-6 lg:border-r lg:pr-8 bg-white text-gray-900 border-gray-100">
         <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="text-sm font-semibold text-gray-700 block text-gray-900">Exam Title <span className="text-red-500">*</span></label>
              <input 
                type="text" 
                className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all text-sm disabled:bg-gray-100 disabled:text-gray-500"
                placeholder="e.g. IELTS Academic Mock #1"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                disabled={mode === 'VIEW'}
              />
            </div>
            
            <div className="space-y-1.5">
              <label className="text-sm font-semibold text-gray-700 block text-gray-900">Exam Mode</label>
              <select 
                className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none text-sm bg-gray-50/50 disabled:bg-gray-100 disabled:text-gray-500"
                value={examType}
                onChange={(e) => setExamType(e.target.value as ExamType)}
                disabled={mode === 'VIEW'}
              >
                <option value="ORG_EXAM">General Mock Test</option>
                <option value="REAL_EXAM">Real Exam Simulator</option>
                <option value="IELTS">IELTS Full Format</option>
              </select>
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-semibold text-gray-700 block text-gray-900">Description</label>
              <textarea 
                className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none text-sm resize-none h-20 disabled:bg-gray-100 disabled:text-gray-500"
                placeholder="Passage notes, instructions..."
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                disabled={mode === 'VIEW'}
              />
            </div>
         </div>

         {/* IELTS Progress Tracker */}
         {examType === 'IELTS' && (
           <div className="bg-primary/5 border border-primary/20 p-4 rounded-xl space-y-3">
              <h4 className="font-bold text-primary text-xs uppercase tracking-wider">IELTS Requirements</h4>
              <ul className="space-y-2.5">
                <li className="flex flex-col gap-1 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="text-gray-600 font-medium">Listening (4 Sec, 40 Q)</span>
                    <div className="flex items-center gap-1.5">
                      {ieltsCounts.listeningGroups === 4 && ieltsCounts.listeningQuestions === 40 ? 
                        <CheckCircle2 size={14} className="text-green-500" /> : 
                        <AlertCircle size={14} className="text-amber-400" />
                      }
                    </div>
                  </div>
                  <div className="flex justify-between text-[10px] text-gray-400">
                    <span>Sec: {ieltsCounts.listeningGroups}/4</span>
                    <span>Qs: {ieltsCounts.listeningQuestions}/40</span>
                  </div>
                </li>
                <li className="flex flex-col gap-1 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="text-gray-600 font-medium">Reading (3 Pass, 40 Q)</span>
                    <div className="flex items-center gap-1.5">
                      {ieltsCounts.readingGroups === 3 && ieltsCounts.readingQuestions === 40 ? 
                        <CheckCircle2 size={14} className="text-green-500" /> : 
                        <AlertCircle size={14} className="text-amber-400" />
                      }
                    </div>
                  </div>
                  <div className="flex justify-between text-[10px] text-gray-400">
                    <span>Pass: {ieltsCounts.readingGroups}/3</span>
                    <span>Qs: {ieltsCounts.readingQuestions}/40</span>
                  </div>
                </li>
                <li className="flex flex-col gap-1 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="text-gray-600 font-medium">Writing Tasks (2 Req)</span>
                    <div className="flex items-center gap-1.5">
                      <span className={`font-bold ${ieltsCounts.writingQuestions === 2 ? 'text-green-600' : 'text-gray-900'}`}>{ieltsCounts.writingQuestions}/2</span>
                      {ieltsCounts.writingQuestions === 2 ? <CheckCircle2 size={14} className="text-green-500" /> : <AlertCircle size={14} className="text-amber-400" />}
                    </div>
                  </div>
                </li>
              </ul>
           </div>
         )}

         <div className="bg-gray-50 p-4 rounded-xl border border-gray-100">
            <h4 className="font-semibold text-gray-800 text-xs uppercase tracking-wider mb-2">Summary</h4>
            <div className="space-y-1">
              <div className="flex justify-between items-center text-xs">
                <span className="text-gray-500">Passages:</span>
                <span className="font-bold text-gray-900">{selectedGroups.length}</span>
              </div>
              <div className="flex justify-between items-center text-xs">
                <span className="text-gray-500">Standalone Qs:</span>
                <span className="font-bold text-gray-900">{selectedQuestions.length}</span>
              </div>
            </div>
         </div>

         {mode !== 'VIEW' && (
           <button 
             onClick={handleCreate}
             disabled={!title.trim() || (selectedQuestions.length === 0 && selectedGroups.length === 0) || !isIELTSValid}
             className="w-full bg-primary hover:bg-primary/90 text-white font-semibold py-2.5 rounded-xl shadow-lg shadow-primary/20 transition-all disabled:opacity-40 disabled:shadow-none"
           >
             {examType === 'IELTS' ? 'Update IELTS Exam' : (mode === 'EDIT' ? 'Update Exam' : 'Create Exam')}
           </button>
         )}
      </div>

      {/* Right Column: Resource Pool */}
      <div className="flex-1 flex flex-col h-[650px] bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden text-gray-900">
         <div className="p-4 border-b bg-gray-50/30">
            <h3 className="text-lg font-bold text-gray-800 mb-4 text-gray-900">Resource Bank</h3>
            <div className="flex flex-wrap gap-2">
              <div className="relative flex-1 min-w-[200px]">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
                  <input 
                    type="text"
                    placeholder="Search titles, skills, or content..."
                    className="w-full pl-9 pr-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary/20 text-sm outline-none"
                    value={searchQuery}
                    onChange={e => setSearchQuery(e.target.value)}
                  />
              </div>
              <select 
                  className="border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-primary/20 bg-white"
                  value={selectedSkillFilter}
                  onChange={e => setSelectedSkillFilter(e.target.value as any)}
              >
                  <option value="ALL">All Categories</option>
                  <option value="LISTENING">Listening</option>
                  <option value="READING">Reading</option>
                  <option value="WRITING">Writing</option>
                  <option value="VOCABULARY">Vocabulary</option>
              </select>
            </div>
         </div>

         <div className="flex-1 overflow-y-auto p-4 space-y-3 bg-gray-50/20">
            {filteredPool.length === 0 ? (
               <div className="flex flex-col items-center justify-center text-gray-400 h-full p-8 text-center bg-white rounded-xl border border-dashed border-gray-200">
                 <Search size={32} className="mb-3 opacity-20" />
                 <p className="font-medium">No results found.</p>
                 <p className="text-xs">Adjust filters or create more resources in the bank.</p>
               </div>
            ) : (
                filteredPool.map(item => {
                  const isItemType = item.isItemType;
                  const isSelected = isItemType === 'GROUP' 
                    ? selectedGroups.includes(item.id) 
                    : selectedQuestions.includes(item.id);
                  
                  return (
                    <div 
                      key={`${isItemType}-${item.id}`} 
                      className={`group relative flex items-start gap-4 p-4 rounded-xl border transition-all ${
                        isSelected 
                        ? 'bg-primary/5 border-primary ring-1 ring-primary/30' 
                        : 'bg-white border-gray-100 hover:border-primary/40 hover:shadow-md'
                      } ${mode === 'VIEW' && !isSelected ? 'opacity-50' : ''}`}
                    >
                       <div className="mt-1">
                         <div 
                           onClick={(e) => { e.stopPropagation(); toggleSelection(item.id, isItemType); }}
                           className={`w-5 h-5 rounded-md border-2 flex items-center justify-center transition-colors ${
                             mode === 'VIEW' ? 'cursor-default' : 'cursor-pointer'
                           } ${
                             isSelected ? 'bg-primary border-primary' : 'bg-white border-gray-200 group-hover:border-primary/50'
                           }`}
                         >
                           {isSelected && <CheckCircle2 size={14} className="text-white" />}
                         </div>
                       </div>

                       <div className={`flex-1 min-w-0 ${mode === 'VIEW' ? 'cursor-default' : 'cursor-pointer'}`} onClick={() => toggleSelection(item.id, isItemType)}>
                          <div className="flex flex-wrap items-center gap-2 mb-2">
                             <span className={`text-[9px] uppercase font-heavy px-2 py-0.5 rounded-full ${
                               item.skill === 'READING' ? 'bg-blue-100 text-blue-700' :
                               item.skill === 'LISTENING' ? 'bg-purple-100 text-purple-700' :
                               item.skill === 'WRITING' ? 'bg-amber-100 text-amber-700' :
                               'bg-gray-100 text-gray-700'
                             }`}>
                               {item.skill}
                             </span>
                             <span className="flex items-center gap-1 text-[10px] font-bold text-gray-400 uppercase">
                               {isItemType === 'GROUP' ? <Layers size={10} /> : <BookOpen size={10} />}
                               {isItemType === 'GROUP' ? 'Passage' : 'Task'}
                             </span>
                             {isItemType === 'GROUP' && (
                               <span className="text-[10px] text-primary font-bold">
                                 {(item as any).questions?.length || 0} Qs
                                </span>
                             )}
                          </div>
                          
                          <h4 className={`text-sm font-bold truncate ${isSelected ? 'text-primary' : 'text-gray-900'}`}>
                             {isItemType === 'GROUP' ? (item as any).title : (item as any).instruction}
                          </h4>
                          
                          <p className="text-xs text-gray-500 line-clamp-2 mt-1 leading-relaxed">
                             {isItemType === 'GROUP' ? (item as any).content : (item.data as any).template || "Standalone practice task..."}
                          </p>
                       </div>

                       {/* Preview Button */}
                       <div className="shrink-0 self-center">
                          <button 
                            onClick={(e) => {
                              e.stopPropagation();
                              setPreviewItem({ item, type: isItemType });
                            }}
                            className="p-2 text-gray-400 hover:text-primary hover:bg-primary/10 rounded-full transition-all opacity-0 group-hover:opacity-100"
                            title="Preview Content"
                          >
                            <Eye size={18} />
                          </button>
                       </div>
                    </div>
                  );
                })
            )}
         </div>
      </div>

      {/* Preview Modal Overlay */}
      {previewItem && (
        <div 
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-in fade-in duration-200" 
          onClick={() => setPreviewItem(null)}
        >
          <div 
            className="bg-white dark:bg-slate-900 rounded-3xl shadow-2xl max-w-4xl w-full max-h-[90vh] flex flex-col overflow-hidden animate-in zoom-in-95 duration-200 border border-transparent dark:border-slate-800"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="p-6 border-b border-gray-100 dark:border-slate-800 flex items-center justify-between bg-white dark:bg-slate-900 sticky top-0 z-10">
              <div className="flex items-center gap-3">
                <div className={`p-2 rounded-xl ${previewItem.type === 'GROUP' ? 'bg-purple-100 text-purple-600' : 'bg-blue-100 text-blue-600'}`}>
                  {previewItem.type === 'GROUP' ? <Layers size={20} /> : <BookOpen size={20} />}
                </div>
                <h3 className="text-xl font-bold text-gray-900 dark:text-slate-100">
                  {previewItem.type === 'GROUP' ? 'Passage Preview' : 'Question Preview'}
                </h3>
              </div>
              <button 
                onClick={() => setPreviewItem(null)}
                className="p-2 text-gray-400 hover:text-gray-600 dark:hover:text-slate-300 hover:bg-gray-100 dark:hover:bg-slate-800 rounded-full transition-all"
              >
                <X size={20} />
              </button>
            </div>

            {/* Modal Content */}
            <div className="flex-1 overflow-y-auto p-6 md:p-8 custom-scrollbar">
              {previewItem.type === 'GROUP' ? (
                <div className="space-y-8">
                  <div className="flex items-start gap-4">
                    <div className="flex-1">
                      <h2 className="text-2xl font-bold text-gray-900 dark:text-slate-100 leading-tight mb-2 text-gray-900">
                        {previewItem.item.title}
                      </h2>
                      <div className="flex flex-wrap gap-2">
                        <span className="text-[10px] font-heavy text-white px-2 py-0.5 rounded-full bg-purple-600 uppercase">
                          {previewItem.item.skill}
                        </span>
                        <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">
                          ID: #{previewItem.item.id} • {previewItem.item.questions?.length || 0} Questions
                        </span>
                      </div>
                    </div>
                  </div>

                  {previewItem.item.mediaUrl && (
                    <div className="rounded-2xl overflow-hidden border border-gray-100 dark:border-slate-800 shadow-sm">
                      {previewItem.item.mediaType?.startsWith('audio/') ? (
                        <div className="p-6 bg-purple-50 dark:bg-purple-900/10 flex flex-col md:flex-row items-center gap-6">
                          <div className="w-12 h-12 rounded-full bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center text-purple-600 dark:text-purple-400 shrink-0">
                            <Music size={24} />
                          </div>
                          <audio src={getMediaUrl(previewItem.item.mediaUrl)} controls className="w-full" />
                        </div>
                      ) : (
                        <div className="bg-gray-50 dark:bg-slate-800 p-2">
                          <img 
                            src={getMediaUrl(previewItem.item.mediaUrl)} 
                            alt="Passage content" 
                            className="w-full h-auto max-h-[400px] object-contain rounded-xl mx-auto" 
                          />
                        </div>
                      )}
                    </div>
                  )}

                  <div className="prose dark:prose-invert max-w-none">
                    <div className="bg-white dark:bg-slate-800/50 p-8 rounded-2xl border border-gray-100 dark:border-slate-800 text-gray-800 dark:text-slate-200 text-lg leading-relaxed whitespace-pre-wrap italic font-serif">
                      {previewItem.item.content}
                    </div>
                  </div>

                  <div className="space-y-6 pt-4 border-t dark:border-slate-800">
                    <h3 className="text-sm font-bold text-gray-400 dark:text-slate-500 uppercase tracking-widest flex items-center gap-2">
                       <FileText size={14} /> Questions for this passage
                    </h3>
                    <div className="grid gap-4">
                      {previewItem.item.questions?.map((q: any, idx: number) => (
                        <div key={q.id} className="p-5 bg-gray-50 dark:bg-slate-800/30 border border-gray-100 dark:border-slate-800 rounded-2xl group/q transition-all hover:border-primary/30">
                          <div className="flex items-center gap-2 mb-3">
                            <span className="text-[10px] font-heavy bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 px-2 py-0.5 rounded-full uppercase tracking-tighter">
                              Question {idx + 1}
                            </span>
                            <span className="text-[10px] text-gray-400 dark:text-slate-500 font-bold uppercase tracking-widest">
                              {q.type.replace('_', ' ')}
                            </span>
                          </div>
                          <p className="text-gray-900 dark:text-slate-200 font-medium text-base">
                            {q.instruction}
                          </p>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              ) : (
                <StudentPreview question={previewItem.item as Question} />
              )}
            </div>

            {/* Modal Footer */}
            <div className="p-6 border-t border-gray-100 dark:border-slate-800 flex justify-end items-center gap-4 bg-gray-50/50 dark:bg-slate-900/50">
              <span className="text-xs text-gray-500 font-medium hidden sm:block">
                Click outside to close
              </span>
              {mode !== 'VIEW' && (
                <button 
                  onClick={() => {
                    toggleSelection(previewItem.item.id, previewItem.type);
                    setPreviewItem(null);
                  }}
                  className={`flex items-center gap-2 px-8 py-3 rounded-2xl font-bold transition-all shadow-lg active:scale-95 ${
                    (previewItem.type === 'GROUP' ? selectedGroups.includes(previewItem.item.id) : selectedQuestions.includes(previewItem.item.id))
                    ? 'bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 border border-red-100 dark:border-red-900/30 hover:bg-red-100 dark:hover:bg-red-900/40 shadow-red-500/10'
                    : 'bg-primary text-white hover:bg-primary/90 shadow-primary/20 hover:shadow-primary/30'
                  }`}
                >
                  {(previewItem.type === 'GROUP' ? selectedGroups.includes(previewItem.item.id) : selectedQuestions.includes(previewItem.item.id)) ? (
                    <>
                      <X size={18} /> Remove from Exam
                    </>
                  ) : (
                    <>
                      <CheckCircle2 size={18} /> Add to Exam
                    </>
                  )}
                </button>
              )}
            </div>
          </div>
        </div>
      )}

    </div>
  );
};
