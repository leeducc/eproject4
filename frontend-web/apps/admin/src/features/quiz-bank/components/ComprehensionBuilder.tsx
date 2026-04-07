import React, { useState } from 'react';
import { useQuizBankStore } from '../store';
import { 
  QuestionGroup, 
  SkillType, 
  DifficultyBand, 
  Question, 
  QuestionType 
} from '../types';
import { 
  Plus, 
  Trash2, 
  ChevronDown, 
  ChevronUp, 
  FileText, 
  Music, 
  Save, 
  PlusCircle,
  Upload,
  X
} from 'lucide-react';
import { toast } from '@english-learning/ui';
import { MultipleChoiceBuilder } from './MultipleChoiceBuilder';
import { FillInTheBlankBuilder } from './FillInTheBlankBuilder';
import { MatchingBuilder } from './MatchingBuilder';

interface ComprehensionBuilderProps {
  skill?: SkillType;
  initialGroup?: QuestionGroup | null;
  onSave?: () => void;
}

export const ComprehensionBuilder: React.FC<ComprehensionBuilderProps> = ({ 
  skill = 'READING', 
  initialGroup, 
  onSave 
}) => {
  const { currentUser, createGroup, updateGroup, createQuestion, updateQuestion, deleteQuestion, uploadMedia } = useQuizBankStore();
  
  const [title, setTitle] = useState(initialGroup?.title || '');
  const [content, setContent] = useState(initialGroup?.content || '');
  const [mediaUrl, setMediaUrl] = useState(initialGroup?.mediaUrl || '');
  const [mediaType, setMediaType] = useState(initialGroup?.mediaType || '');
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialGroup?.difficultyBand || 'BAND_0_4');
  const [isSaving, setIsSaving] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  
  
  const [childQuestions, setChildQuestions] = useState<Partial<Question>[]>(
    initialGroup?.questions || []
  );
  const [expandedIndex, setExpandedIndex] = useState<number | null>(0);
  const [showTypeSelector, setShowTypeSelector] = useState(false);

  const handleMediaUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    console.log('[ComprehensionBuilder] Starting media upload', { fileName: file.name, fileSize: file.size, fileType: file.type });
    setIsUploading(true);
    try {
      const storedPath = await uploadMedia(file, 'questions');
      console.log('[ComprehensionBuilder] Media uploaded successfully', { storedPath });
      setMediaUrl(storedPath);
      setMediaType(file.type.startsWith('audio/') ? 'AUDIO' : 'IMAGE');
      toast.success("Media uploaded successfully");
    } catch (error) {
      console.error('[ComprehensionBuilder] Media upload failed', error);
      toast.error("Failed to upload media");
    } finally {
      setIsUploading(false);
    }
  };

  const handleAddQuestion = (type: QuestionType) => {
    console.log('[ComprehensionBuilder] Adding new child question', { type, currentCount: childQuestions.length });
    const newQuestion: Partial<Question> = {
      type,
      skill,
      difficultyBand,
      data: type === 'MULTIPLE_CHOICE' ? { options: [{id: '1', label: 'Option 1'}, {id: '2', label: 'Option 2'}], correct_ids: [], multiple_select: false } :
            type === 'MATCHING' ? { left_items: [], right_items: [], solution: {} } :
            { template: '', blanks: {} },
      isPremiumContent: false,
      tags: []
    };
    setChildQuestions([...childQuestions, newQuestion]);
    setExpandedIndex(childQuestions.length);
    setShowTypeSelector(false);
  };

  const handleRemoveQuestion = async (index: number) => {
    const q = childQuestions[index];
    if (q.id) {
       
       if (window.confirm("Delete this child question permanently?")) {
         await deleteQuestion(q.id);
       } else {
         return;
       }
    }
    setChildQuestions(childQuestions.filter((_, i) => i !== index));
    if (expandedIndex === index) setExpandedIndex(null);
  };

  const handleSave = async () => {
    console.log('[ComprehensionBuilder] Attempting to save comprehension', { title, questionsCount: childQuestions.length });
    if (!title.trim() || !content.trim()) {
      toast.error("Please provide a title and passage content.");
      return;
    }

    if (childQuestions.length === 0) {
      toast.error("Please add at least one child question.");
      return;
    }

    setIsSaving(true);
    try {
      const groupPayload = {
        title,
        content,
        mediaUrl,
        mediaType,
        skill,
        difficultyBand,
        authorId: currentUser.id
      };

      console.log('[ComprehensionBuilder] Saving group payload', groupPayload);
      let group;
      if (initialGroup) {
        group = await updateGroup(initialGroup.id, groupPayload);
      } else {
        group = await createGroup(groupPayload);
      }

      console.log('[ComprehensionBuilder] Group saved, now saving child questions', { groupId: group.id });
      for (const q of childQuestions) {
        const payload = { ...q, groupId: group.id };
        if (q.id) {
          await updateQuestion(q.id, payload);
        } else {
          await createQuestion(payload as any);
        }
      }

      console.log('[ComprehensionBuilder] Everything saved successfully');
      toast.success("Comprehension saved successfully!");
      if (onSave) onSave();
    } catch (error) {
      console.error('[ComprehensionBuilder] Save failed', error);
      toast.error("Failed to save comprehension.");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="space-y-8 max-w-5xl mx-auto pb-20">
      {}
      <div className="bg-white dark:bg-slate-900 rounded-xl border dark:border-slate-800 shadow-sm overflow-hidden">
        <div className="p-4 bg-gray-50 dark:bg-slate-800/50 border-b dark:border-slate-800 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="p-2 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded-lg">
              {skill === 'READING' ? <FileText size={20} /> : <Music size={20} />}
            </span>
            <h3 className="font-bold text-gray-800 dark:text-slate-100 uppercase tracking-wider text-sm">
              {skill === 'READING' ? 'Passage Details' : 'Audio Script & Media'}
            </h3>
          </div>
          <select 
            className="bg-white dark:bg-slate-800 border dark:border-slate-700 rounded-lg px-3 py-1.5 text-sm outline-none focus:ring-2 focus:ring-blue-100 transition-all dark:text-slate-200"
            value={difficultyBand}
            onChange={(e) => setDifficultyBand(e.target.value as DifficultyBand)}
          >
            <option value="BAND_0_4">Level 0-4</option>
            <option value="BAND_5_6">Level 5-6</option>
            <option value="BAND_7_8">Level 7-8</option>
            <option value="BAND_9">Level 9</option>
          </select>
        </div>
        
        <div className="p-6 space-y-4">
          <div>
            <label className="text-xs font-bold text-gray-400 uppercase mb-1 block">Title</label>
            <input 
              type="text"
              placeholder="Enter title (e.g., Global Warming Part 1)..."
              className="w-full bg-gray-50 dark:bg-slate-800 border dark:border-slate-700 rounded-lg px-4 py-2.5 text-gray-700 dark:text-slate-200 outline-none focus:ring-2 focus:ring-blue-100 transition-all"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
          </div>
          
          <div>
            <label className="text-xs font-bold text-gray-400 uppercase mb-1 block">
              {skill === 'READING' ? 'Passage Text' : 'Script / Audio Description'}
            </label>
            <textarea 
              placeholder="Paste your long text here..."
              className="w-full bg-gray-50 dark:bg-slate-800 border dark:border-slate-700 rounded-lg px-4 py-3 text-gray-700 dark:text-slate-200 outline-none focus:ring-2 focus:ring-blue-100 transition-all min-h-[250px] leading-relaxed"
              value={content}
              onChange={(e) => setContent(e.target.value)}
            />
          </div>

          <div className="pt-4 border-t dark:border-slate-800">
            <label className="text-xs font-bold text-gray-400 uppercase mb-2 block">Attached Media (Audio/Image)</label>
            <div className="flex items-center gap-4">
              <label className="flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-slate-800 hover:bg-gray-200 dark:hover:bg-slate-700 rounded-lg cursor-pointer transition-colors text-sm font-medium text-gray-600 dark:text-slate-300 border dark:border-slate-700">
                <Upload size={16} />
                {isUploading ? "Uploading..." : "Upload Media"}
                <input 
                  type="file" 
                  className="hidden" 
                  onChange={handleMediaUpload}
                  accept="audio/*,image/*" 
                />
              </label>

              {mediaUrl && (
                <div className="flex items-center gap-3 bg-blue-50 dark:bg-blue-900/10 p-2 border border-blue-100 dark:border-blue-900/30 rounded-lg animate-in fade-in duration-300">
                  <div className="p-2 bg-blue-100 dark:bg-blue-900/40 text-blue-600 dark:text-blue-400 rounded-md">
                    {mediaType === 'AUDIO' ? <Music size={18} /> : <FileText size={18} />}
                  </div>
                  <div className="flex-1 min-w-0 pr-4">
                    <p className="text-xs font-bold text-gray-800 dark:text-slate-200 truncate max-w-[200px]">{mediaUrl.split('/').pop()}</p>
                    <p className="text-[10px] text-gray-500 uppercase tracking-tight">{mediaType}</p>
                  </div>
                  <button 
                    onClick={() => { setMediaUrl(''); setMediaType(''); }}
                    className="p-1 text-gray-400 hover:text-red-500 transition-colors"
                  >
                    <X size={16} />
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-bold text-gray-800 dark:text-slate-100 flex items-center gap-2">
            Child Questions <span className="bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 text-xs px-2 py-0.5 rounded-full">{childQuestions.length}</span>
          </h3>
          
          <div className="relative">
            <button 
              onClick={() => setShowTypeSelector(!showTypeSelector)}
              className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 transition-all shadow-md active:scale-95"
            >
              <PlusCircle size={18} /> Add Child Question
            </button>
            
            {showTypeSelector && (
              <div className="absolute right-0 mt-2 w-56 bg-white dark:bg-slate-800 rounded-xl shadow-xl border dark:border-slate-700 z-50 p-2 overflow-hidden animate-in fade-in slide-in-from-top-2 duration-200">
                {['MULTIPLE_CHOICE', 'FILL_BLANK', 'MATCHING'].map((type) => (
                  <button
                    key={type}
                    onClick={() => handleAddQuestion(type as QuestionType)}
                    className="w-full text-left px-4 py-2.5 text-sm hover:bg-gray-50 dark:hover:bg-slate-700 rounded-lg transition-colors text-gray-700 dark:text-slate-200 capitalize font-medium"
                  >
                    {type.replace('_', ' ').toLowerCase()}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>

        <div className="space-y-4">
          {childQuestions.map((q, idx) => (
            <div key={idx} className="bg-white dark:bg-slate-900 rounded-xl border dark:border-slate-800 shadow-sm overflow-hidden transition-all duration-300">
               <div 
                 className={`p-4 flex items-center justify-between cursor-pointer hover:bg-gray-50 dark:hover:bg-slate-800/30 transition-colors ${expandedIndex === idx ? 'border-b dark:border-slate-800 bg-gray-50 dark:bg-slate-800/30' : ''}`}
                 onClick={() => setExpandedIndex(expandedIndex === idx ? null : idx)}
               >
                 <div className="flex items-center gap-3">
                   <span className="w-8 h-8 rounded-full bg-gray-100 dark:bg-slate-800 flex items-center justify-center text-xs font-bold text-gray-500">
                    {idx + 1}
                   </span>
                   <div>
                     <p className="text-sm font-bold text-gray-800 dark:text-slate-100 capitalize">
                       {q.type?.replace('_', ' ').toLowerCase()}
                     </p>
                     <p className="text-xs text-gray-500 dark:text-slate-400 truncate max-w-md">
                       {(q as any).instruction || "No instruction set..."}
                     </p>
                   </div>
                 </div>
                 
                 <div className="flex items-center gap-2">
                   <button 
                     onClick={(e) => { e.stopPropagation(); handleRemoveQuestion(idx); }}
                     className="p-2 text-gray-400 hover:text-red-500 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 transition-all"
                   >
                     <Trash2 size={16} />
                   </button>
                   {expandedIndex === idx ? <ChevronUp size={20} className="text-gray-400" /> : <ChevronDown size={20} className="text-gray-400" />}
                 </div>
               </div>

               {expandedIndex === idx && (
                 <div className="p-6 bg-white dark:bg-slate-900 animate-in slide-in-from-top-2 duration-300">
                   {q.type === 'MULTIPLE_CHOICE' ? (
                     <MultipleChoiceBuilder 
                       skill={skill} 
                       initialQuestion={q as Question} 
                       onSave={(updatedData) => {
                         const newQuestions = [...childQuestions];
                         newQuestions[idx] = { ...newQuestions[idx], ...updatedData };
                         setChildQuestions(newQuestions);
                         toast.success("Draft saved - persist by saving comprehension");
                       }} 
                     />
                   ) : q.type === 'MATCHING' ? (
                     <MatchingBuilder 
                       skill={skill} 
                       initialQuestion={q as Question} 
                       onSave={(updatedData) => {
                         const newQuestions = [...childQuestions];
                         newQuestions[idx] = { ...newQuestions[idx], ...updatedData };
                         setChildQuestions(newQuestions);
                         toast.success("Draft saved - persist by saving comprehension");
                       }} 
                     />
                   ) : (
                     <FillInTheBlankBuilder 
                       skill={skill} 
                       initialQuestion={q as Question} 
                       onSave={(updatedData) => {
                         const newQuestions = [...childQuestions];
                         newQuestions[idx] = { ...newQuestions[idx], ...updatedData };
                         setChildQuestions(newQuestions);
                         toast.success("Draft saved - persist by saving comprehension");
                       }} 
                     />
                   )}
                 </div>
               )}
            </div>
          ))}
          
          {childQuestions.length === 0 && (
            <div className="text-center py-16 bg-gray-50 dark:bg-slate-800/30 rounded-2xl border-2 border-dashed border-gray-200 dark:border-slate-800">
              <Plus size={48} className="mx-auto text-gray-300 mb-4" />
              <h4 className="text-gray-600 dark:text-slate-400 font-medium">No questions added yet</h4>
              <p className="text-xs text-gray-400 mt-1">Click "Add Child Question" to begin</p>
            </div>
          )}
        </div>
      </div>

      {}
      <div className="fixed bottom-8 left-1/2 -translate-x-1/2 flex items-center gap-4 bg-white/80 dark:bg-slate-900/80 backdrop-blur-md border dark:border-slate-800 px-6 py-4 rounded-2xl shadow-2xl z-50">
        <button 
          onClick={handleSave}
          disabled={isSaving}
          className="bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white px-10 py-3 rounded-xl font-bold flex items-center gap-2 shadow-lg shadow-blue-500/30 transition-all active:scale-95"
        >
          {isSaving ? "Saving..." : <><Save size={20} /> Save All Changes</>}
        </button>
      </div>
    </div>
  );
};
