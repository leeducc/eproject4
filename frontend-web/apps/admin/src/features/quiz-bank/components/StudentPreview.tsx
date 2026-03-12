import React, { useState } from 'react';
import { MultipleChoiceData, MatchingData, FillBlankData, Question } from '../types';
import { CheckCircle2, XCircle, RefreshCcw } from 'lucide-react';

interface StudentPreviewProps {
  question: Question;
}

export const StudentPreview: React.FC<StudentPreviewProps> = ({ question }) => {
  const [userAnswer, setUserAnswer] = useState<any>(null);
  const [showFeedback, setShowFeedback] = useState(false);
  const [essayContent, setEssayContent] = useState('');

  const resetPreview = () => {
    setUserAnswer(null);
    setShowFeedback(false);
    setEssayContent('');
  };

  const renderMultipleChoice = () => {
    const data = question.data as MultipleChoiceData;
    const selected = (userAnswer as string[]) || [];

    const handleToggle = (id: string) => {
      if (showFeedback) return;
      if (data.multiple_select) {
        setUserAnswer(selected.includes(id) ? selected.filter(i => i !== id) : [...selected, id]);
      } else {
        setUserAnswer([id]);
      }
    };

    return (
      <div className="space-y-4">
        <div className="grid gap-3">
          {data.options.map((opt, idx) => {
            const isSelected = selected.includes(opt.id);
            const isCorrect = data.correct_ids.includes(opt.id);
            
            let statusClass = "border-gray-200 bg-white hover:border-blue-300";
            if (showFeedback) {
              if (isSelected && isCorrect) statusClass = "border-green-500 bg-green-50 ring-1 ring-green-500";
              else if (isSelected && !isCorrect) statusClass = "border-red-500 bg-red-50 ring-1 ring-red-500";
              else if (!isSelected && isCorrect) statusClass = "border-green-200 bg-green-50/30 border-dashed";
            } else if (isSelected) {
              statusClass = "border-blue-500 bg-blue-50 ring-1 ring-blue-500";
            }

            return (
              <button
                key={opt.id}
                disabled={showFeedback}
                onClick={() => handleToggle(opt.id)}
                className={`p-4 rounded-xl border text-left flex items-center gap-4 transition-all ${statusClass}`}
              >
                <div className={`w-6 h-6 shrink-0 border flex items-center justify-center ${data.multiple_select ? 'rounded' : 'rounded-full'} ${isSelected ? 'bg-blue-600 border-blue-600' : 'border-gray-300'}`}>
                   {isSelected && <div className="w-2 h-2 bg-white rounded-full"></div>}
                </div>
                <span className="font-bold text-gray-400 w-4">{String.fromCharCode(65 + idx)}.</span>
                <div className="flex-1 flex items-center gap-3">
                    {opt.image && (
                        <img 
                            src={`http://localhost:8080${opt.image}`} 
                            alt={`Option ${idx + 1}`} 
                            className="w-10 h-10 object-cover rounded shadow-sm border border-gray-100"
                        />
                    )}
                    <span className="text-gray-700">{opt.label}</span>
                </div>
                {showFeedback && isCorrect && <CheckCircle2 size={18} className="text-green-600" />}
                {showFeedback && isSelected && !isCorrect && <XCircle size={18} className="text-red-600" />}
              </button>
            );
          })}
        </div>
      </div>
    );
  };

  const renderFillBlank = () => {
    const data = question.data as FillBlankData;
    const answers = (userAnswer as Record<string, string>) || {};
    const [focusedBlank, setFocusedBlank] = useState<string | null>(Object.keys(data.blanks)[0] || null);

    // Combine all correct answers (first one) and distractors for the pool
    const correctPool = Object.values(data.blanks).map(b => b.correct[0]);
    const distractorPool = data.answer_pool || [];
    const fullPool = Array.from(new Set([...correctPool, ...distractorPool])).sort(() => Math.random() - 0.5);

    const handleWordClick = (word: string) => {
      if (showFeedback || !focusedBlank) return;
      setUserAnswer({ ...answers, [focusedBlank]: word });
      
      // Auto-focus next empty blank
      const blankKeys = Object.keys(data.blanks);
      const nextEmpty = blankKeys.find(k => !answers[k] && k !== focusedBlank);
      if (nextEmpty) setFocusedBlank(nextEmpty);
      else setFocusedBlank(null);
    };

    const parts = data.template.split(/(\[blank\d+\])/g);

    return (
      <div className="space-y-8">
        {/* Sentence Area */}
        <div className="p-8 bg-white border border-gray-100 rounded-2xl leading-[3] text-xl text-gray-800 shadow-sm">
          {parts.map((part, i) => {
            if (part.startsWith('[blank')) {
              const selectedWord = answers[part];
              const isCorrect = data.blanks[part]?.correct.some(c => c.toLowerCase() === (selectedWord || '').trim().toLowerCase());
              const isFocused = focusedBlank === part;
              
              let statusClass = "border-gray-200 bg-gray-50/50 text-gray-400";
              if (showFeedback) {
                statusClass = isCorrect ? "border-green-500 bg-green-50 text-green-700 font-bold" : "border-red-500 bg-red-50 text-red-700 font-bold";
              } else if (selectedWord) {
                statusClass = "border-blue-500 bg-blue-50 text-blue-700 font-bold shadow-sm";
              } else if (isFocused) {
                statusClass = "border-blue-400 bg-blue-50/50 ring-2 ring-blue-100";
              }

              return (
                <span key={part} className="inline-block px-1 h-[44px] align-middle">
                  <button
                    disabled={showFeedback}
                    onClick={() => setFocusedBlank(part)}
                    className={`px-4 h-full flex items-center justify-center border-b-4 transition-all min-w-[140px] rounded-t-xl text-lg ${statusClass}`}
                  >
                    {selectedWord || "___"}
                  </button>
                  {showFeedback && !isCorrect && (
                    <div className="text-[10px] text-green-600 font-bold text-center leading-none mt-1 animate-in fade-in slide-in-from-top-1">
                      {data.blanks[part]?.correct[0]}
                    </div>
                  )}
                </span>
              );
            }
            return <span key={i} className="align-middle">{part}</span>;
          })}
        </div>

        {/* Word Bank Area */}
        <div className="bg-gray-100/50 p-6 rounded-2xl border border-dashed border-gray-200">
           <div className="flex items-center justify-between mb-4">
              <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest flex items-center gap-2">
                <div className="w-1.5 h-1.5 rounded-full bg-blue-400"></div>
                Word Bank (Click a word to fill the active blank)
              </h4>
              <div className="flex gap-4 items-center">
                 {focusedBlank && (
                   <span className="text-[10px] bg-blue-100 text-blue-700 px-2 py-0.5 rounded font-bold uppercase">
                     Focusing: {focusedBlank.replace('blank', 'Blank ')}
                   </span>
                 )}
                 {Object.keys(answers).length > 0 && !showFeedback && (
                   <button 
                     onClick={() => { setUserAnswer({}); setFocusedBlank(Object.keys(data.blanks)[0]); }}
                     className="text-[10px] font-bold text-gray-400 hover:text-red-500 uppercase tracking-widest flex items-center gap-1 transition-colors"
                   >
                     <RefreshCcw size={10} /> Clear All
                   </button>
                 )}
              </div>
           </div>
           
           <div className="flex flex-wrap gap-3">
              {fullPool.map((word, i) => {
                const isUsed = Object.values(answers).includes(word);
                return (
                  <button
                     key={i}
                     disabled={showFeedback || isUsed || !focusedBlank}
                     onClick={() => handleWordClick(word)}
                     className={`bg-white border border-gray-200 px-5 py-2.5 rounded-xl text-sm font-bold shadow-sm transition-all ${isUsed ? 'opacity-30 grayscale cursor-not-allowed' : 'hover:border-blue-400 hover:scale-105 hover:shadow-md hover:text-blue-600 active:scale-95'} ${!focusedBlank && !isUsed ? 'opacity-60 grayscale' : ''}`}
                  >
                     {word}
                  </button>
                );
              })}
           </div>
        </div>
      </div>
    );
  };

  const renderMatching = () => {
    const data = question.data as MatchingData;
    const pairs = (userAnswer as Record<string, string>) || {};
    const [selectedLeft, setSelectedLeft] = useState<string | null>(null);

    const handleLeftClick = (id: string) => {
      if (showFeedback) return;
      setSelectedLeft(id === selectedLeft ? null : id);
    };

    const handleRightClick = (id: string) => {
      if (showFeedback || !selectedLeft) return;
      setUserAnswer({ ...pairs, [selectedLeft]: id });
      setSelectedLeft(null);
    };

    return (
      <div className="space-y-6">
        <div className="grid grid-cols-2 gap-8">
          <div className="space-y-3">
            <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest px-1">Column A</h4>
            {data.left_items.map((left) => {
              const matchedRightId = pairs[left.id];
              const isSelected = selectedLeft === left.id.toString();
              const isCorrect = data.solution[left.id].toString() === matchedRightId?.toString();
              
              let statusClass = "border-gray-200 bg-white hover:border-blue-300";
              if (showFeedback) {
                statusClass = isCorrect ? "border-green-200 bg-green-50 text-green-800" : "border-red-200 bg-red-50 text-red-800";
              } else if (isSelected) {
                statusClass = "border-blue-500 bg-blue-50 ring-1 ring-blue-500";
              } else if (matchedRightId) {
                statusClass = "border-gray-400 bg-gray-50 opacity-60";
              }

              return (
                <button
                  key={left.id}
                  disabled={showFeedback}
                  onClick={() => handleLeftClick(left.id.toString())}
                  className={`w-full p-2 rounded-lg border text-sm text-left transition-all flex items-center gap-2 ${statusClass}`}
                >
                  {left.image && <img src={`http://localhost:8080${left.image}`} className="w-8 h-8 object-cover rounded" />}
                  <span className="flex-1">{left.text}</span>
                </button>
              );
            })}
          </div>

          <div className="space-y-3">
            <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest px-1">Column B</h4>
            {data.right_items.map((right) => {
              const isUsed = Object.values(pairs).includes(right.id.toString());
              const isTargeted = !!selectedLeft;
              
              let statusClass = "border-gray-200 bg-white" + (isTargeted && !isUsed ? " hover:border-blue-300 cursor-pointer" : "");
              if (isUsed) {
                statusClass = "bg-gray-100 border-gray-300 opacity-60";
              }

              return (
                <button
                  key={right.id}
                  disabled={showFeedback || isUsed || !isTargeted}
                  onClick={() => handleRightClick(right.id.toString())}
                  className={`w-full p-2 rounded-lg border text-sm text-left transition-all flex items-center gap-2 ${statusClass}`}
                >
                  {right.image && <img src={`http://localhost:8080${right.image}`} className="w-8 h-8 object-cover rounded" />}
                  <span className="flex-1">{right.text}</span>
                </button>
              );
            })}
          </div>
        </div>

        {Object.keys(pairs).length > 0 && !showFeedback && (
          <div className="mt-4 p-4 bg-gray-50 rounded-xl border border-gray-100">
            <h4 className="text-xs font-bold text-gray-400 uppercase mb-3 text-center">Your Matches</h4>
            <div className="flex flex-wrap gap-2 justify-center">
               {Object.entries(pairs).map(([leftId, rightId]) => {
                  const left = data.left_items.find(l => l.id.toString() === leftId);
                  const right = data.right_items.find(r => r.id.toString() === rightId);
                  return (
                    <div key={leftId} className="bg-white px-3 py-1.5 rounded-full border text-xs flex items-center gap-2">
                       <span className="font-medium text-gray-700">{left?.text}</span>
                       <span className="text-gray-300">|</span>
                       <span className="text-blue-600 font-bold">{right?.text}</span>
                       <button 
                         onClick={() => {
                           const newPairs = { ...pairs };
                           delete newPairs[leftId];
                           setUserAnswer(newPairs);
                         }}
                         className="text-gray-400 hover:text-red-500 ml-1"
                       >
                         <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
                       </button>
                    </div>
                  );
               })}
            </div>
          </div>
        )}
      </div>
    );
  };

  const renderEssay = () => {
    return (
      <div className="space-y-4">
        <label className="text-sm font-semibold text-gray-600 block">Your Response:</label>
        <div className="border border-gray-200 rounded-xl overflow-hidden focus-within:ring-2 focus-within:ring-blue-500/20 focus-within:border-blue-500 transition-all">
          <textarea
            className="w-full p-6 outline-none bg-white min-h-[300px] leading-relaxed text-gray-800"
            placeholder="Write your answer here..."
            value={essayContent}
            onChange={(e) => setEssayContent(e.target.value)}
          />
          <div className="bg-gray-50 px-4 py-2 border-t flex justify-between items-center text-[10px] text-gray-400 font-mono tracking-widest uppercase">
             <span>Character Count: {essayContent.length}</span>
             <span>Word Count: {essayContent.trim() ? essayContent.trim().split(/\s+/).length : 0}</span>
          </div>
        </div>
        {showFeedback && (
          <div className="bg-blue-50 border border-blue-100 p-6 rounded-xl">
             <h4 className="text-blue-800 font-bold text-sm mb-2">Simulated Feedback:</h4>
             <p className="text-blue-700 text-sm leading-relaxed italic">
               "{question.explanation}"
             </p>
             <p className="mt-4 text-[11px] text-blue-500 font-medium">
               Note: Essays require manual grading or AI assessment. In this preview, we show your instruction/explanation as feedback.
             </p>
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="bg-gray-50 rounded-2xl border border-gray-200 overflow-hidden shadow-inner">
      <div className="bg-white p-4 border-b flex items-center justify-between">
         <span className="text-xs font-bold text-blue-600 bg-blue-50 px-3 py-1 rounded-full uppercase tracking-widest">Student View Mode</span>
         <div className="flex gap-2">
            <button 
              onClick={resetPreview}
              className="p-1.5 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
              title="Reset Preview"
            >
              <RefreshCcw size={16} />
            </button>
         </div>
      </div>
      
      <div className="p-8 max-w-4xl mx-auto space-y-8">
        <div className="space-y-4">
          <h3 className="text-xs font-bold text-gray-400 uppercase tracking-widest">Question Prompt</h3>
          <div className="text-gray-900 text-xl font-medium leading-relaxed">
            {question.instruction}
          </div>
        </div>

        {/* Media simulation */}
        {question.mediaUrls && question.mediaUrls.length > 0 && (
          <div className="flex flex-wrap gap-4 py-4 border-y border-gray-100">
             {question.mediaUrls.map((url, i) => (
               <div key={i} className="max-w-xs rounded-xl overflow-hidden border border-gray-200 shadow-sm">
                  {question.mediaTypes?.[i].startsWith('image/') ? (
                    <img src={`http://localhost:8080${url}`} className="max-h-48 object-cover" alt="Stimulus" />
                  ) : question.mediaTypes?.[i].startsWith('video/') ? (
                    <video src={`http://localhost:8080${url}`} className="max-h-48" controls />
                  ) : (
                    <div className="p-4 bg-white"><audio src={`http://localhost:8080${url}`} controls /></div>
                  )}
               </div>
             ))}
          </div>
        )}

        <div className="pt-2">
            {question.type === 'MULTIPLE_CHOICE' ? renderMultipleChoice() :
             question.type === 'MATCHING' ? renderMatching() :
             question.type === 'FILL_BLANK' ? renderFillBlank() :
             renderEssay()
            }
        </div>

        <div className="flex justify-center pt-8">
           {!showFeedback ? (
             <button 
               onClick={() => setShowFeedback(true)}
               className="bg-blue-600 hover:bg-blue-700 text-white px-10 py-3 rounded-xl font-bold shadow-lg shadow-blue-500/20 transition-all active:scale-95"
             >
               Check Answer
             </button>
           ) : (
             <button 
               onClick={resetPreview}
               className="bg-gray-800 hover:bg-gray-900 text-white px-10 py-3 rounded-xl font-bold shadow-lg shadow-gray-500/20 transition-all active:scale-95 flex items-center gap-2"
             >
               <RefreshCcw size={18} /> Try Again
             </button>
           )}
        </div>
      </div>

      <div className="p-4 bg-amber-50 border-t border-amber-100 flex items-center gap-3">
         <div className="w-8 h-8 rounded-full bg-amber-100 flex items-center justify-center text-amber-600">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
         </div>
         <p className="text-[11px] text-amber-800 leading-tight">
           <strong>Previewing Student UX:</strong> This view simulates how students interact with the content. Interactivity and feedback are local only and do not affect the database.
         </p>
      </div>
    </div>
  );
};
