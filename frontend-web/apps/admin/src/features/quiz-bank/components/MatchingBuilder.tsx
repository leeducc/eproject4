import React, { useState } from 'react';
import { useQuizBankStore } from '../store';
import { MatchingData, DifficultyBand, SkillType, Question } from '../types';
import { 
  Image as ImageIcon, 
  Video, 
  Mic, 
  GripVertical, 
  Trash2, 
  Plus
} from 'lucide-react';

interface MatchingPair {
  id: string;
  leftText: string;
  rightText: string;
}

export interface MatchingBuilderProps {
  skill?: SkillType;
  initialQuestion?: Question | null;
  onSave?: () => void;
}

export const MatchingBuilder: React.FC<MatchingBuilderProps> = ({ skill = 'READING', initialQuestion, onSave }) => {
  const { currentUser, createQuestion, updateQuestion } = useQuizBankStore();
  
  // Local state for the form
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialQuestion?.difficultyBand || 'BAND_5_6');
  const [instruction, setInstruction] = useState(initialQuestion?.instruction || 'Match the following items.');
  const [explanation, setExplanation] = useState(initialQuestion?.explanation || '');
  const [isPremium, setIsPremium] = useState<boolean>(initialQuestion?.isPremiumContent || false);
  
  const existingData = initialQuestion?.data as MatchingData | undefined;
  
  // Reconstruct pairs from existing data if editing
  const initialPairs = existingData ? existingData.left_items.map((left) => ({
      id: left.id.toString(),
      leftText: left.text,
      rightText: existingData.right_items.find(r => r.id.toString() === existingData.solution[left.id.toString()])?.text || ''
  })) : [
    { id: '1', leftText: 'Icon Button', rightText: 'Initiate a direct action' },
    { id: '2', leftText: 'Data Grid', rightText: 'Present tabular data for display and manipulation' }
  ];

  const [pairs, setPairs] = useState<MatchingPair[]>(initialPairs);
  


  const isTeacher = currentUser.role === 'TEACHER';

  const handleAddPair = () => {
    console.log('[MatchingBuilder] Adding new pair');
    const newId = Date.now().toString();
    setPairs([...pairs, { id: newId, leftText: '', rightText: '' }]);
  };

  const handleRemovePair = (id: string) => {
    if (isTeacher) return; // Role check
    console.log(`[MatchingBuilder] Removing pair ${id}`);
    setPairs(pairs.filter(p => p.id !== id));
  };

  const handleOptionChange = (id: string, side: 'left' | 'right', newText: string) => {
    setPairs(pairs.map(p => {
      if (p.id === id) {
        return side === 'left' ? { ...p, leftText: newText } : { ...p, rightText: newText };
      }
      return p;
    }));
  };

  const handleSave = () => {
    if (!instruction.trim()) {
      alert("Please provide an instruction.");
      return;
    }
    if (pairs.length < 2) {
      alert("Please provide at least two matching pairs.");
      return;
    }
    if (pairs.some(p => !p.leftText.trim() || !p.rightText.trim())) {
      alert("Please fill in both sides for all matching pairs.");
      return;
    }

    // Transform pairs state to MatchingData payload structure
    const left_items = pairs.map((p) => ({ id: p.id, text: p.leftText }));
    const right_items = pairs.map((p) => ({ id: p.id, text: p.rightText }));
    
    // Default solution is 1:1 mapping of their IDs since they are inputted in rows
    const solution = pairs.reduce((acc, curr) => ({ ...acc, [curr.id]: curr.id }), {} as Record<string, string>);

    const data: MatchingData = {
      left_items,
      right_items,
      solution
    };
    
    const payload = {
      skill,
      type: 'MATCHING' as const,
      difficultyBand: difficultyBand,
      instruction,
      explanation,
      data,
      isPremiumContent: isPremium
    };
    
    if (initialQuestion) {
      console.log('[MatchingBuilder] Updating matching question', { instruction, data });
      updateQuestion(initialQuestion.id, payload);
    } else {
      console.log('[MatchingBuilder] Saving matching question', { instruction, data });
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
            id="premium-matching"
            checked={isPremium}
            onChange={(e) => setIsPremium(e.target.checked)}
            className="w-4 h-4 text-amber-500 rounded border-gray-300 focus:ring-amber-500"
          />
          <label htmlFor="premium-matching" className="text-sm font-medium text-gray-700 flex items-center gap-1">Premium Content</label>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6 space-y-6">
        {/* Question Input */}
        <div className="space-y-2">
          <div className="flex items-center gap-2 text-sm font-bold text-gray-800 bg-gray-100 w-max px-2 py-1 rounded">
             <span className="bg-gray-800 text-white rounded w-4 h-4 flex items-center justify-center text-[10px]">?</span>
             Question
          </div>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-gray-50/50 flex flex-col justify-between group">
            <div className="flex justify-between p-2">
               <textarea
                 className="w-full p-2 bg-transparent border-none focus:ring-0 resize-none outline-none font-medium text-gray-800 min-h-[50px]"
                 placeholder="Type your instruction..."
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

        {/* Pairs List List */}
        <div className="space-y-3 pt-2">
          
          <div className="flex items-center gap-4 mb-2 pl-8">
            <div className="flex-1 font-semibold text-sm text-gray-800">
               Column A: UI Element <span className="text-red-500">*</span> <span className="text-gray-500 font-normal">(Text or Image)</span>
            </div>
            <div className="flex-1 font-semibold text-sm text-gray-800">
               Column B: Core Function <span className="text-gray-500 font-normal">(Text or Image)</span>
            </div>
            {!isTeacher && <div className="w-8"></div>}
          </div>
              
          {pairs.map((pair) => (
            <div key={pair.id} className="flex items-center gap-3 group">
              <div className="flex items-center gap-2 cursor-grab text-gray-400 hover:text-gray-600">
                <GripVertical size={16} />
              </div>
              
              <div className="flex items-center justify-center w-8 h-8 rounded shrink-0 bg-pink-100 border border-pink-400 text-pink-700 font-bold">
                 {/* No index since removed */}
              </div>
              
              <div className="flex-1 flex items-center border rounded-md px-3 py-2 bg-gray-50 focus-within:bg-white focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500">
                 <input 
                   type="text"
                   className="flex-1 outline-none text-gray-700 bg-transparent"
                   value={pair.leftText}
                   onChange={(e) => handleOptionChange(pair.id, 'left', e.target.value)}
                   placeholder="Type left item..."
                 />
                 <button className="text-gray-400 hover:text-gray-600 ml-2">
                    <ImageIcon size={16} />
                 </button>
              </div>

              <div className="text-gray-400 font-bold px-1">—</div>

              <div className="flex-1 flex items-center border rounded-md px-3 py-2 bg-gray-50 focus-within:bg-white focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500">
                 <input 
                   type="text"
                   className="flex-1 outline-none text-gray-700 bg-transparent"
                   value={pair.rightText}
                   onChange={(e) => handleOptionChange(pair.id, 'right', e.target.value)}
                   placeholder="Type right matching item..."
                 />
                 <button className="text-gray-400 hover:text-gray-600 ml-2">
                    <ImageIcon size={16} />
                 </button>
              </div>

              {!isTeacher && (
                <button 
                  className="p-1.5 text-gray-400 hover:text-red-500 border bg-white rounded shadow-sm opacity-50 hover:opacity-100 transition-opacity"
                  onClick={() => handleRemovePair(pair.id)}
                  title="Delete pair"
                >
                  <Trash2 size={16} />
                </button>
              )}
            </div>
          ))}
          
          <div className="pl-[3.5rem] mt-4">
             <button 
               onClick={handleAddPair}
               className="flex items-center gap-2 text-gray-700 hover:text-gray-900 border rounded-md px-3 py-1.5 text-sm font-medium bg-white shadow-sm hover:bg-gray-50 transition-colors"
             >
               <ImageIcon size={16} /> <Plus size={16} className="-ml-1" /> Add Pair
             </button>
          </div>
        </div>

        {/* Explanation Input */}
        <div className="space-y-2 pt-4 border-t border-dashed">
          <label className="text-sm font-semibold text-gray-800">Explanation (Optional)</label>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-white">
            <textarea
              className="w-full p-4 border-none focus:ring-0 resize-none min-h-[80px] outline-none"
              placeholder="Provide an explanation for the matching pairs..."
              value={explanation}
              onChange={(e) => setExplanation(e.target.value)}
            />
          </div>
        </div>
      </div>

      {/* Footer Settings */}
      <div className="bg-white p-4 border-t flex items-center justify-end">
        <div>
           <button 
             onClick={handleSave}
             className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
           >
             Save Question
           </button>
        </div>
      </div>
    </div>
  );
};
