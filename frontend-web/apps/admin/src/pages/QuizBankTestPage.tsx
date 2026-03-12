import React from 'react';
import { useQuizBankStore } from '../features/quiz-bank/store';
import { MultipleChoiceBuilder } from '../features/quiz-bank/components/MultipleChoiceBuilder';
import { FillInTheBlankBuilder } from '../features/quiz-bank/components/FillInTheBlankBuilder';
import { MatchingBuilder } from '../features/quiz-bank/components/MatchingBuilder';

export const QuizBankTestPage: React.FC = () => {
  const { currentUser, switchRole, questions } = useQuizBankStore();

  return (
    <div className="min-h-screen bg-gray-100 p-8 font-sans">
      <div className="max-w-5xl mx-auto space-y-8">
        
        {/* Testing Controls Header */}
        <div className="bg-white p-6 rounded-lg shadow-sm border border-blue-200">
          <h1 className="text-2xl font-bold text-gray-800 mb-4">Quiz Bank Development Sandbox</h1>
          
          <div className="flex items-center justify-between">
            <div className="space-y-2">
              <span className="text-sm font-semibold text-gray-600 block">Simulate Role (RBAC Testing):</span>
              <div className="flex gap-4">
                <button 
                  onClick={() => switchRole('ADMIN')}
                  className={`px-4 py-2 rounded-md font-medium text-sm transition-colors ${currentUser.role === 'ADMIN' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700 hover:bg-gray-300'}`}
                >
                  Admin Mode (Full Access)
                </button>
                <button 
                  onClick={() => switchRole('TEACHER')}
                  className={`px-4 py-2 rounded-md font-medium text-sm transition-colors ${currentUser.role === 'TEACHER' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700 hover:bg-gray-300'}`}
                >
                  Teacher Mode (No Deletes)
                </button>
              </div>
            </div>

            <div className="text-right">
              <span className="block text-sm text-gray-500">Current Role</span>
              <span className={`inline-block px-3 py-1 rounded-full text-xs font-bold ${currentUser.role === 'ADMIN' ? 'bg-purple-100 text-purple-700' : 'bg-orange-100 text-orange-700'}`}>
                {currentUser.role}
              </span>
            </div>
          </div>
        </div>

        {/* Builders Container */}
        <div className="space-y-12">
          
          <section>
             <h2 className="text-xl font-bold text-gray-800 mb-4 pl-2 border-l-4 border-blue-500">1. Multiple Choice Builder</h2>
             <MultipleChoiceBuilder />
          </section>

          <section>
             <h2 className="text-xl font-bold text-gray-800 mb-4 pl-2 border-l-4 border-green-500">2. Fill in the Blank Builder</h2>
             <FillInTheBlankBuilder />
          </section>

          <section>
             <h2 className="text-xl font-bold text-gray-800 mb-4 pl-2 border-l-4 border-pink-500">3. Matching Builder</h2>
             <MatchingBuilder />
          </section>

        </div>

        {/* Saved Output */}
        <div className="bg-gray-800 text-green-400 p-6 rounded-lg font-mono text-sm overflow-x-auto">
           <h3 className="text-white font-bold mb-4">Store State Dump (Saved Questions): {questions.length} total</h3>
           <pre>{JSON.stringify(questions, null, 2)}</pre>
        </div>

      </div>
    </div>
  );
};
