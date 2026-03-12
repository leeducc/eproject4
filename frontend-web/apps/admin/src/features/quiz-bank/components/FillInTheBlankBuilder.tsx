import React, { useState, useRef } from 'react';
import { useQuizBankStore } from '../store';
import { FillBlankData, DifficultyBand, SkillType, Question } from '../types';
import { Plus, Trash2, Edit2 } from 'lucide-react';

export interface FillInTheBlankBuilderProps {
  skill?: SkillType;
  initialQuestion?: Question | null;
  onSave?: () => void;
}

export const FillInTheBlankBuilder: React.FC<FillInTheBlankBuilderProps> = ({ skill = 'READING', initialQuestion, onSave }) => {
  const { currentUser, createQuestion, updateQuestion } = useQuizBankStore();
  const isTeacher = currentUser.role === 'TEACHER';
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialQuestion?.difficultyBand || 'BAND_5_6');
  const [instruction, setInstruction] = useState(initialQuestion?.instruction || 'Fill in the blanks with the correct words.');
  const [explanation, setExplanation] = useState(initialQuestion?.explanation || '');
  const [isPremium, setIsPremium] = useState<boolean>(initialQuestion?.isPremiumContent || false);
  
  const existingData = initialQuestion?.data as FillBlankData | undefined;
  const [template, setTemplate] = useState(existingData?.template || 'When selecting a style, consider your [blank1].');
  
  // Active blanks dictionary
  const [blanks, setBlanks] = useState<Record<string, { correct: string[]; max_words: number }>>(existingData?.blanks || {
    'blank1': { correct: ['Audience'], max_words: 1 }
  });
  
  // Distractor answer pool
  const [answerPool, setAnswerPool] = useState<string[]>(existingData?.answer_pool || ['Direction', 'Tone']);
  

  const [isEditing, setIsEditing] = useState(false);

  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Parse template into text chunks and blank tokens for visual display
  const renderTemplateTokens = () => {
    // regex to find [blankN]
    const regex = /(\[blank\d+\])/g;
    const parts = template.split(regex);
    
    return parts.map((part, index) => {
      const match = part.match(/\[blank(\d+)\]/);
      if (match) {
        const blankId = part.replace(/[\[\]]/g, ''); // "blank1"
        const num = match[1];
        const blankData = blanks[blankId];
        const label = blankData && blankData.correct.length > 0 ? blankData.correct[0] : '...';
        return (
          <span key={index} className="inline-flex items-center justify-center bg-blue-100 text-blue-800 border-blue-200 border rounded-full px-3 py-1 mx-1 font-medium text-sm">
            <span className="bg-white text-blue-600 rounded-full w-4 h-4 flex items-center justify-center text-[10px] mr-1 border border-blue-200">{num}</span>
            {label}
          </span>
        );
      }
      return <span key={index} className="text-gray-700 leading-relaxed max-w-none">{part}</span>;
    });
  };

  const handleCreateBlank = () => {
    if (!textareaRef.current) return;
    const { selectionStart, selectionEnd, value } = textareaRef.current;
    
    if (selectionStart === selectionEnd) {
      alert("Please highlight a word first to create a blank.");
      return;
    }

    const selectedText = value.substring(selectionStart, selectionEnd).trim();
    if (!selectedText) return;

    // Find next available blank ID
    let nextId = 1;
    while (blanks[`blank${nextId}`]) {
      nextId++;
    }
    const newBlankId = `blank${nextId}`;

    const newTemplate = value.substring(0, selectionStart) + `[${newBlankId}]` + value.substring(selectionEnd);
    
    setTemplate(newTemplate);
    setBlanks({
      ...blanks,
      [newBlankId]: { correct: [selectedText], max_words: selectedText.split(' ').length }
    });
    
    // reset selection
    setTimeout(() => {
      if (textareaRef.current) {
        textareaRef.current.focus();
        textareaRef.current.setSelectionRange(selectionStart, selectionStart + newBlankId.length + 2);
      }
    }, 0);
  };

  const syncBlanksWithTemplate = (newTemplate: string) => {
    setTemplate(newTemplate);
    // Remove blanks that are no longer in the template
    const currentBlankIds = Array.from(newTemplate.matchAll(/\[blank(\d+)\]/g)).map(m => m[0].replace(/[\[\]]/g, ''));
    const newBlanks = { ...blanks };
    let changed = false;
    
    Object.keys(newBlanks).forEach(id => {
      if (!currentBlankIds.includes(id)) {
        delete newBlanks[id];
        changed = true;
      }
    });
    
    if (changed) {
      setBlanks(newBlanks);
    }
  };

  const handleUpdateBlankLabel = (id: string, newLabel: string) => {
    setBlanks({
      ...blanks,
      [id]: { ...blanks[id], correct: [newLabel] }
    });
  };

  const handleDeleteBlank = (id: string) => {
    if (isTeacher) return;
    // Remove from template
    const newTemplate = template.replace(`[${id}]`, blanks[id]?.correct[0] || '');
    syncBlanksWithTemplate(newTemplate);
  };

  const handleAddDistractor = () => {
    setAnswerPool([...answerPool, 'New Option']);
  };

  const handleUpdateDistractor = (index: number, val: string) => {
    const newPool = [...answerPool];
    newPool[index] = val;
    setAnswerPool(newPool);
  };

  const handleDeleteDistractor = (index: number) => {
    if (isTeacher) return;
    setAnswerPool(answerPool.filter((_, i) => i !== index));
  };

  const handleSave = () => {
    if (!instruction.trim()) {
      alert("Please provide an instruction.");
      return;
    }
    if (!template.trim()) {
      alert("Please provide the sentence template.");
      return;
    }
    if (Object.keys(blanks).length === 0) {
      alert("Please create at least one blank in the sentence.");
      return;
    }
    for (const key in blanks) {
        if (!blanks[key].correct[0] || !blanks[key].correct[0].trim()) {
            alert("Please fill in the correct answer for all blanks.");
            return;
        }
    }

    const data: FillBlankData = {
      template,
      blanks,
      answer_pool: answerPool.length > 0 ? answerPool : undefined,
    };
    
    const payload = {
      skill,
      type: 'FILL_BLANK' as const,
      difficultyBand: difficultyBand,
      instruction,
      explanation,
      data,
      isPremiumContent: isPremium
    };

    if (initialQuestion) {
      console.log('[FillInTheBlankBuilder] Updating question', { data });
      updateQuestion(initialQuestion.id, payload);
    } else {
      console.log('[FillInTheBlankBuilder] Saving question', { data });
      createQuestion(payload);
    }
    if (onSave) onSave();
  };

  return (
    <div className="bg-white border rounded-lg shadow-sm w-full max-w-4xl mx-auto p-0 overflow-hidden font-sans mt-8">
      {/* Header */}
      <div className="flex items-center p-4 border-b bg-gray-50">
        <select 
          className="border-gray-300 rounded-md shadow-sm border p-2 text-sm bg-white"
          value={difficultyBand}
          onChange={(e) => setDifficultyBand(e.target.value as DifficultyBand)}
        >
          <option value="BAND_0_4">Level 0-4</option>
          <option value="BAND_5_6">Level 5-6</option>
          <option value="BAND_7_8">Level 7-8</option>
          <option value="BAND_9">Level 9</option>
        </select>
        <div className="ml-auto flex items-center gap-2 border-l pl-4 border-gray-200">
          <input 
            type="checkbox" 
            id="premium-fib"
            checked={isPremium}
            onChange={(e) => setIsPremium(e.target.checked)}
            className="w-4 h-4 text-amber-500 rounded border-gray-300 focus:ring-amber-500"
          />
          <label htmlFor="premium-fib" className="text-sm font-medium text-gray-700 flex items-center gap-1">Premium Content</label>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6 space-y-6">
        
        {/* Question Input */}
        <div className="space-y-2">
          <div className="flex items-center gap-2 text-sm font-bold text-gray-800 bg-gray-100 w-max px-2 py-1 rounded">
             <span className="bg-gray-800 text-white rounded w-4 h-4 flex items-center justify-center text-[10px]">?</span>
             Question / Instruction
          </div>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-gray-50/50 flex flex-col justify-between group">
            <div className="flex justify-between p-2">
               <textarea
                 className="w-full p-2 bg-transparent border-none focus:ring-0 resize-none outline-none font-medium text-gray-800 min-h-[50px]"
                 placeholder="Type your instruction..."
                 value={instruction}
                 onChange={(e) => setInstruction(e.target.value)}
               />
            </div>
          </div>
        </div>

        {/* Interactive Editor Area */}
        <div className="space-y-3">
          <label className="text-sm font-semibold text-gray-800">Sentence Editor</label>
          <p className="text-sm text-gray-500 mb-2">
            Type your sentence below. Highlight a word and click "Create Blank" to convert it.
          </p>

          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-white relative overflow-hidden flex flex-col">
            {/* Toolbar */}
            <div className="flex items-center justify-between p-2 px-4 border-b bg-gray-50">
               <button 
                 onClick={handleCreateBlank}
                 className="flex items-center gap-2 text-sm text-blue-600 font-medium hover:text-blue-700 bg-blue-50 px-3 py-1.5 rounded-md border border-blue-200"
               >
                 <Edit2 size={14} /> Create Blank from Selection
               </button>
               
               <button 
                 onClick={() => setIsEditing(!isEditing)}
                 className="text-sm text-gray-600 hover:text-gray-800 underline"
               >
                 {isEditing ? 'View Preview' : 'Edit Raw Text'}
               </button>
            </div>

            {/* Editor body */}
            <div className="relative min-h-[120px] p-4 bg-white text-base">
               {isEditing ? (
                 <textarea
                    ref={textareaRef}
                    className="w-full h-full min-h-[120px] outline-none resize-none bg-transparent"
                    value={template}
                    onChange={(e) => syncBlanksWithTemplate(e.target.value)}
                    placeholder="Type a sentence here..."
                 />
               ) : (
                 <div 
                   className="w-full h-full min-h-[120px] cursor-text" 
                   onClick={() => setIsEditing(true)}
                 >
                   {renderTemplateTokens()}
                 </div>
               )}
            </div>
          </div>
        </div>

        {/* Answer Options Display (Correct answers and distractors) */}
        <div className="space-y-4 pt-4 border-t border-dashed">
          <label className="text-sm font-semibold text-gray-800">Answer Pool & Options</label>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
             {/* Core Blanks List */}
             <div className="space-y-3">
               <h4 className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Blanks (Correct Answers)</h4>
               {Object.entries(blanks).map(([id, blankData]) => {
                 const num = id.replace('blank', '');
                 return (
                   <div key={id} className="flex items-center gap-2 bg-gray-50 border rounded-md p-2 group">
                      <div className="bg-white border rounded-full w-6 h-6 flex items-center justify-center text-xs font-bold text-gray-500 shadow-sm shrink-0">
                        {num}
                      </div>
                      <input 
                         className="flex-1 bg-transparent outline-none text-sm text-gray-800 font-medium"
                         value={blankData.correct[0]}
                         onChange={(e) => handleUpdateBlankLabel(id, e.target.value)}
                         placeholder="Correct answer..."
                      />
                      {!isTeacher && (
                        <button 
                          onClick={() => handleDeleteBlank(id)}
                          className="opacity-0 group-hover:opacity-100 text-gray-400 hover:text-red-500 p-1"
                        >
                          <Trash2 size={16} />
                        </button>
                      )}
                   </div>
                 );
               })}
               {Object.keys(blanks).length === 0 && (
                 <p className="text-sm text-gray-400 italic">No blanks created yet.</p>
               )}
             </div>

             {/* Distractors List */}
             <div className="space-y-3">
               <h4 className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Distractors (Incorrect)</h4>
               {answerPool.map((distractor, index) => (
                 <div key={`distractor-${index}`} className="flex items-center gap-2 bg-gray-50 border rounded-md p-2 group border-orange-100 bg-orange-50/30">
                    <div className="w-6 h-6 shrink-0 flex items-center justify-center text-orange-400">
                      <span className="w-1.5 h-1.5 rounded-full bg-orange-400"></span>
                    </div>
                    <input 
                       className="flex-1 bg-transparent outline-none text-sm text-gray-800 font-medium"
                       value={distractor}
                       onChange={(e) => handleUpdateDistractor(index, e.target.value)}
                       placeholder="Incorrect answer..."
                    />
                    {!isTeacher && (
                      <button 
                        onClick={() => handleDeleteDistractor(index)}
                        className="opacity-0 group-hover:opacity-100 text-gray-400 hover:text-red-500 p-1"
                      >
                        <Trash2 size={16} />
                      </button>
                    )}
                 </div>
               ))}
               
               <button 
                 onClick={handleAddDistractor}
                 className="flex items-center gap-1 text-sm text-orange-600 font-medium hover:text-orange-700 mt-2"
               >
                 <Plus size={16} /> Add incorrect answer
               </button>
             </div>
          </div>
        </div>

        {/* Explanation Input */}
        <div className="space-y-2 pt-4 border-t border-dashed">
          <label className="text-sm font-semibold text-gray-800">Explanation (Optional)</label>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-white">
            <textarea
              className="w-full p-4 border-none focus:ring-0 resize-none min-h-[80px] outline-none"
              placeholder="Provide an explanation for the correct answers..."
              value={explanation}
              onChange={(e) => setExplanation(e.target.value)}
            />
          </div>
        </div>
      </div>

      {/* Footer Settings */}
      <div className="bg-gray-50 p-4 border-t flex items-center justify-end">
        <div>
           <button 
             onClick={handleSave}
             className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
           >
             Save Question
           </button>
        </div>
      </div>
    </div>
  );
};
