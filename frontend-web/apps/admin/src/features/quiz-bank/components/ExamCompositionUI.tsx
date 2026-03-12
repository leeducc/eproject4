import React, { useState, useMemo } from 'react';
import { useQuizBankStore } from '../store';
import { SkillType } from '../types';
import { Search } from 'lucide-react';

interface ExamCompositionUIProps {
  onSave: () => void;
}

export const ExamCompositionUI: React.FC<ExamCompositionUIProps> = ({ onSave }) => {
  const { questions, createExam } = useQuizBankStore();
  
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedSkillFilter, setSelectedSkillFilter] = useState<SkillType | 'ALL'>('ALL');
  
  // Array of picked Question IDs
  const [selectedQuestions, setSelectedQuestions] = useState<number[]>([]);

  // Filter pool
  const filteredPool = useMemo(() => {
    return questions.filter(q => {
      const matchesSkill = selectedSkillFilter === 'ALL' || q.skill === selectedSkillFilter;
      const matchesSearch = q.instruction.toLowerCase().includes(searchQuery.toLowerCase()) || 
                            q.type.toLowerCase().includes(searchQuery.toLowerCase());
      return matchesSkill && matchesSearch;
    });
  }, [questions, selectedSkillFilter, searchQuery]);

  const toggleQuestionSelection = (id: number) => {
    setSelectedQuestions(prev => 
      prev.includes(id) 
        ? prev.filter(qId => qId !== id)
        : [...prev, id]
    );
  };

  const handleCreate = () => {
    if (!title.trim() || selectedQuestions.length === 0) {
      alert("Please enter a title and select at least one question.");
      return;
    }

    // Determine unique categories included
    const includedCategories = Array.from(new Set(
      selectedQuestions.map(id => questions.find(q => q.id === id)?.skill).filter(Boolean) as SkillType[]
    ));

    createExam({
      title,
      description,
      categories: includedCategories,
      question_ids: selectedQuestions
    });

    onSave(); // Close composer
  };

  return (
    <div className="flex flex-col md:flex-row gap-8 font-sans">
      
      {/* Left Column: Exam Meta Data */}
      <div className="w-full md:w-1/3 space-y-5 border-r pr-8">
         <div className="space-y-2">
            <label className="text-sm font-semibold text-gray-700 block">Exam Title <span className="text-red-500">*</span></label>
            <input 
              type="text" 
              className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-primary focus:border-primary outline-none text-sm"
              placeholder="e.g. Midterm Assessment 2024"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
         </div>
         
         <div className="space-y-2">
            <label className="text-sm font-semibold text-gray-700 block">Description</label>
            <textarea 
              className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-primary focus:border-primary outline-none text-sm resize-none h-24"
              placeholder="Optional description notes..."
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
         </div>

         <div className="bg-blue-50/50 border border-blue-100 p-4 rounded-xl mt-4">
            <h4 className="font-semibold text-blue-900 text-sm mb-2">Composition Summary</h4>
            <div className="flex justify-between items-center text-sm py-1">
              <span className="text-gray-600">Selected Questions:</span>
              <span className="font-bold text-gray-900">{selectedQuestions.length}</span>
            </div>
         </div>

         <button 
           onClick={handleCreate}
           disabled={!title.trim() || selectedQuestions.length === 0}
           className="w-full bg-primary hover:bg-primary/90 text-white font-medium py-2.5 rounded-lg transition-colors mt-6 disabled:opacity-50 disabled:cursor-not-allowed"
         >
           Create Exam
         </button>
      </div>

      {/* Right Column: Question Selection Pool */}
      <div className="w-full md:w-2/3 flex flex-col h-[600px]">
         <h3 className="text-lg font-bold text-gray-800 mb-4">Select Questions</h3>
         
         <div className="flex gap-4 mb-4">
           <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
              <input 
                type="text"
                placeholder="Search instructions or types..."
                className="w-full pl-9 pr-4 py-2 border rounded-md focus:ring-2 focus:ring-primary text-sm outline-none"
                value={searchQuery}
                onChange={e => setSearchQuery(e.target.value)}
              />
           </div>
           <select 
              className="border rounded-md px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-primary"
              value={selectedSkillFilter}
              onChange={e => setSelectedSkillFilter(e.target.value as any)}
           >
              <option value="ALL">All Categories</option>
              <option value="VOCABULARY">Vocabulary</option>
              <option value="LISTENING">Listening</option>
              <option value="READING">Reading</option>
              <option value="WRITING">Writing</option>
           </select>
         </div>

         {/* Question List */}
         <div className="flex-1 overflow-y-auto border rounded-lg bg-gray-50/30 p-2 space-y-2">
            {filteredPool.length === 0 ? (
               <div className="flex flex-col items-center justify-center text-gray-400 h-full p-8 text-center">
                 <p>No questions found in this category.</p>
                 <p className="text-sm">Create more questions in the Questions Bank first.</p>
               </div>
            ) : (
                filteredPool.map(q => {
                  const isSelected = selectedQuestions.includes(q.id);
                  return (
                    <div 
                      key={q.id} 
                      onClick={() => toggleQuestionSelection(q.id)}
                      className={`flex items-start gap-3 p-3 rounded-lg border cursor-pointer transition-all ${isSelected ? 'bg-blue-50 border-blue-200 shadow-sm' : 'bg-white border-gray-200 hover:border-blue-300'}`}
                    >
                       <div className="pt-0.5">
                         <input 
                           type="checkbox" 
                           checked={isSelected}
                           onChange={() => {}} // handled by parent div onClick
                           className="w-4 h-4 text-primary rounded border-gray-300 focus:ring-primary cursor-pointer"
                         />
                       </div>
                       <div className="flex-1">
                          <div className="flex justify-between items-start mb-1">
                             <div className="flex gap-2 items-center">
                                <span className={`text-[10px] uppercase font-bold px-2 py-0.5 rounded ${isSelected ? 'bg-blue-200 text-blue-800' : 'bg-gray-100 text-gray-600'}`}>
                                  {q.skill}
                                </span>
                                <span className="text-xs text-gray-500 font-medium">{q.type.replace('_', ' ')}</span>
                             </div>
                             <span className="text-xs font-bold text-gray-400">#{q.id.toString().slice(-4)}</span>
                          </div>
                          <p className={`text-sm ${isSelected ? 'font-medium text-blue-900' : 'text-gray-700'} line-clamp-2 leading-relaxed`}>
                             {q.instruction || (q.data as any).template || "Open writing task prompt..."}
                          </p>
                       </div>
                    </div>
                  );
                })
            )}
         </div>
      </div>

    </div>
  );
};
