import React from 'react';
import { Question, MultipleChoiceData } from '../types';
import { CheckCircle2, XCircle } from 'lucide-react';

interface RendererProps {
  question: Question;
  userAnswer: any;
  setUserAnswer: (val: any) => void;
  showFeedback: boolean;
}

export const TFNGRenderer: React.FC<RendererProps> = ({ question, userAnswer, setUserAnswer, showFeedback }) => {
  const data = question.data as MultipleChoiceData;
  const selected = (userAnswer as string[]) || [];

  const options = [
    { id: '1', label: 'TRUE' },
    { id: '2', label: 'FALSE' },
    { id: '3', label: 'NOT GIVEN' }
  ];

  const handleToggle = (id: string) => {
    if (showFeedback) return;
    setUserAnswer([id]); // TFNG is always single select
  };

  return (
    <div className="space-y-6">
      <div className="bg-blue-50/50 p-4 rounded-xl border border-blue-100 mb-4">
        <p className="text-sm text-blue-700 font-medium">
          Do the following statements agree with the information given in the Reading Passage?
        </p>
        <div className="mt-2 text-xs text-blue-600 flex gap-4">
          <span><strong>TRUE</strong> if the statement agrees with the information</span>
          <span><strong>FALSE</strong> if the statement contradicts the information</span>
          <span><strong>NOT GIVEN</strong> if there is no information on this</span>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-4">
        {options.map((opt) => {
          const isSelected = selected.includes(opt.id);
          const isCorrect = data.correct_ids.includes(opt.id);
          
          let statusClass = "border-gray-200 bg-white hover:border-blue-300";
          if (showFeedback) {
            if (isSelected && isCorrect) statusClass = "border-green-500 bg-green-50 ring-2 ring-green-500";
            else if (isSelected && !isCorrect) statusClass = "border-red-500 bg-red-50 ring-2 ring-red-500";
            else if (!isSelected && isCorrect) statusClass = "border-green-200 bg-green-50/30 border-dashed";
          } else if (isSelected) {
            statusClass = "border-blue-500 bg-blue-50 ring-2 ring-blue-500";
          }

          return (
            <button
              key={opt.id}
              disabled={showFeedback}
              onClick={() => handleToggle(opt.id)}
              className={`p-4 rounded-xl border font-bold transition-all flex flex-col items-center gap-2 ${statusClass}`}
            >
              <span className={isSelected ? 'text-blue-700' : 'text-gray-600'}>{opt.label}</span>
              {showFeedback && isCorrect && <CheckCircle2 size={20} className="text-green-600" />}
              {showFeedback && isSelected && !isCorrect && <XCircle size={20} className="text-red-600" />}
            </button>
          );
        })}
      </div>
    </div>
  );
};

export const QuestionRenderer: React.FC<RendererProps> = (props) => {
  const { question } = props;
  
  const hasTag = (tagStr: string) => 
    question.tags?.some(t => `${t.namespace}:${t.name}`.toUpperCase() === tagStr.toUpperCase());

  // Abstraction mapping
  if (hasTag('UI:TFNG')) {
    return <TFNGRenderer {...props} />;
  }
  
  // Add more mappings here as implemented (e.g., UI:YNNG, UI:MatchHeadings)
  
  return null; // Fallback to handle manually in StudentPreview or here
};
