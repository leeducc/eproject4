import React, { useState } from 'react';
import { useQuizBankStore } from '../store';
import { DifficultyBand, Question } from '../types';
import { 
  Image as ImageIcon, 
  Video, 
  Mic
} from 'lucide-react';

export interface WritingBuilderProps {
  initialQuestion?: Question | null;
  onSave?: () => void;
}

export const WritingBuilder: React.FC<WritingBuilderProps> = ({ initialQuestion, onSave }) => {
  const { createQuestion, updateQuestion } = useQuizBankStore();
  
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialQuestion?.difficultyBand || 'BAND_5_6');
  const [instruction, setInstruction] = useState(initialQuestion?.instruction || 'Write an essay about the following topic...');
  const [explanation, setExplanation] = useState(initialQuestion?.explanation || '');
  const [isPremium, setIsPremium] = useState<boolean>(initialQuestion?.isPremiumContent || false);
  


  const handleSave = () => {
    if (!instruction.trim()) {
      alert("Please provide the writing prompt.");
      return;
    }

    // There's no specific answers data needed for a writing question, keeping it generic.
    const payload = {
      skill: 'WRITING' as const, // Special type technically
      type: 'FILL_BLANK' as const, // Storing purely as text, re-using interface generically where it doesn't matter
      difficultyBand: difficultyBand,
      instruction,
      explanation,
      data: initialQuestion?.data || { template: '', blanks: {} }, // Mock payload for typing
      isPremiumContent: isPremium
    };
    if (initialQuestion) {
      console.log('[WritingBuilder] Updating a writing question', { instruction });
      updateQuestion(initialQuestion.id, payload);
    } else {
      console.log('[WritingBuilder] Saving a writing question', { instruction });
      createQuestion(payload);
    }
    if (onSave) onSave();
  };

  return (
    <div className="bg-white border rounded-lg shadow-sm w-full max-w-4xl mx-auto p-0 overflow-hidden font-sans">
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
            id="premium-writing"
            checked={isPremium}
            onChange={(e) => setIsPremium(e.target.checked)}
            className="w-4 h-4 text-amber-500 rounded border-gray-300 focus:ring-amber-500"
          />
          <label htmlFor="premium-writing" className="text-sm font-medium text-gray-700 flex items-center gap-1">Premium Content</label>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6 space-y-6">
        <div className="space-y-3">
          <label className="text-sm font-semibold text-gray-800">Writing Prompt / Task Description</label>
          <p className="text-sm text-gray-500 mb-2">
            Provide the topic, images, or stimulus material for the writing task here. There are no "correct answers" to set as this requires manual or AI grading later.
          </p>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-gray-50/50 flex flex-col justify-between">
            <div className="flex justify-between p-2 pb-0">
               <textarea
                 className="w-full p-2 bg-transparent border-none focus:ring-0 resize-none outline-none font-medium text-gray-800 min-h-[150px]"
                 placeholder="Type your prompt here..."
                 value={instruction}
                 onChange={(e) => setInstruction(e.target.value)}
               />
               <div className="flex items-start gap-1 p-2 text-gray-500 shrink-0">
                 <button className="p-1.5 hover:bg-gray-200 border bg-white rounded shadow-sm"><ImageIcon size={16} /></button>
                 <button className="p-1.5 hover:bg-gray-200 border bg-white rounded shadow-sm"><Video size={16} /></button>
                 <button className="p-1.5 hover:bg-gray-200 border bg-white rounded shadow-sm"><Mic size={16} /></button>
               </div>
            </div>
          </div>
        </div>

        {/* Explanation Input */}
        <div className="space-y-2 pt-4 border-t border-dashed">
          <label className="text-sm font-semibold text-gray-800">Explanation / Grading Rubric (Optional)</label>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-white">
            <textarea
              className="w-full p-4 border-none focus:ring-0 resize-none min-h-[80px] outline-none"
              placeholder="Provide an explanation or grading rubric for this writing task..."
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
