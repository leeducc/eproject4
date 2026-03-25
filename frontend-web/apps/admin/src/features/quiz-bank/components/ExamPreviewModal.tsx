import React, { useMemo } from 'react';
import { Question, QuestionGroup } from '../types';
import { StudentPreview } from './StudentPreview';
import { X, Clock, AlertCircle, Layers, FileText } from 'lucide-react';

interface ExamPreviewModalProps {
  examTitle: string;
  groups: QuestionGroup[];
  questions: Question[];
  onClose: () => void;
}

export const ExamPreviewModal: React.FC<ExamPreviewModalProps> = ({ examTitle, groups, questions, onClose }) => {
  const contentBySkill = useMemo(() => {
    const skills = ['LISTENING', 'READING', 'WRITING', 'SPEAKING', 'VOCABULARY'];
    
    return skills.map(skill => {
      const g = groups.filter(x => x.skill === skill);
      const q = questions.filter(x => x.skill === skill);
      
      return {
        skill,
        groups: g,
        questions: q,
        hasContent: g.length > 0 || q.length > 0
      };
    }).filter(s => s.hasContent);
  }, [groups, questions]);

  return (
    <div className="fixed inset-0 z-[100] flex flex-col bg-gray-50/95 backdrop-blur-sm animate-in fade-in duration-200">
      
      {/* Header Pipeline */}
      <div className="bg-white border-b shadow-sm sticky top-0 z-10 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="bg-blue-600 w-10 h-10 rounded-xl flex items-center justify-center text-white font-bold shadow-lg shadow-blue-500/30">
            EP
          </div>
          <div>
            <h2 className="text-xl font-bold text-gray-900">{examTitle || 'Untitled Exam'}</h2>
            <p className="text-sm text-gray-500 font-medium">Student Exam Preview Simulation</p>
          </div>
        </div>

        <div className="flex items-center gap-6">
           <div className="flex items-center gap-2 bg-amber-50 text-amber-700 px-4 py-2 rounded-full border border-amber-200 text-sm font-bold">
              <AlertCircle size={16} /> Look/Feel Only
           </div>
           
           <div className="flex items-center gap-2 bg-gray-100 text-gray-700 px-4 py-2 rounded-lg font-mono font-bold">
             <Clock size={16} /> 00:00:00
           </div>

           <button 
             onClick={onClose}
             className="bg-gray-800 hover:bg-black text-white px-6 py-2 rounded-xl text-sm font-bold shadow-lg transition-colors flex items-center gap-2"
           >
             <X size={16} /> Exit Preview
           </button>
        </div>
      </div>

      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar Navigation */}
        <div className="w-64 bg-white border-r border-gray-100 flex flex-col hidden md:flex shadow-sm z-10">
           <div className="p-4 border-b border-gray-100 bg-gray-50/50">
              <h3 className="text-xs font-bold text-gray-500 uppercase tracking-widest">Exam Contents</h3>
           </div>
           <div className="flex-1 overflow-y-auto py-4 space-y-8 custom-scrollbar">
              {contentBySkill.map((section) => (
                <div key={`nav-section-${section.skill}`} className="space-y-1">
                  <h4 className="px-4 text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-2 flex items-center gap-2">
                    <span className={`w-1.5 h-1.5 rounded-full ${section.skill === 'READING' ? 'bg-blue-400' : section.skill === 'LISTENING' ? 'bg-purple-400' : 'bg-amber-400'}`}></span>
                    {section.skill} SECTION
                  </h4>
                  {section.groups.map((g, idx) => (
                    <button 
                      key={`nav-g-${g.id}`}
                      onClick={() => document.getElementById(`part-${g.id}`)?.scrollIntoView({ behavior: 'smooth' })}
                      className="w-full text-left px-4 py-2 hover:bg-gray-50 text-gray-700 transition-colors flex items-center justify-between group"
                    >
                       <div className="flex items-center gap-2">
                         <Layers size={14} className="text-gray-400 group-hover:text-blue-500" />
                         <span className="text-sm font-semibold truncate group-hover:text-blue-600">Part {idx + 1}</span>
                       </div>
                       <span className="text-[10px] text-gray-400 font-bold px-1.5 py-0.5 rounded-full bg-gray-100 group-hover:bg-blue-100 group-hover:text-blue-600">
                         {g.questions?.length || 0} Qs
                       </span>
                    </button>
                  ))}
                  
                  {section.questions.length > 0 && (
                    <button 
                      onClick={() => document.getElementById(`indep-${section.skill}`)?.scrollIntoView({ behavior: 'smooth' })}
                      className="w-full text-left px-4 py-2 hover:bg-gray-50 text-gray-700 transition-colors flex items-center justify-between group mt-1"
                    >
                       <div className="flex items-center gap-2">
                         <FileText size={14} className="text-gray-400 group-hover:text-indigo-500" />
                         <span className="text-sm font-semibold truncate group-hover:text-indigo-600">Independent Tasks</span>
                       </div>
                       <span className="text-[10px] text-gray-400 font-bold px-1.5 py-0.5 rounded-full bg-gray-100 group-hover:bg-indigo-100 group-hover:text-indigo-600">
                         {section.questions.length} Qs
                       </span>
                    </button>
                  )}
                </div>
              ))}
           </div>
        </div>

      {/* Main Content Scroll */}
      <div className="flex-1 overflow-y-auto p-4 md:p-8 custom-scrollbar scroll-smooth">
         <div className="max-w-4xl mx-auto space-y-12 pb-24">
            
            {groups.length === 0 && questions.length === 0 && (
              <div className="text-center py-20 bg-white rounded-3xl border border-dashed border-gray-300">
                 <p className="text-gray-500 font-medium text-lg">This exam has no content yet.</p>
                 <p className="text-sm text-gray-400 mt-2">Add passages or standalone questions to preview them here.</p>
              </div>
            )}

            {contentBySkill.map((section) => (
              <div key={`content-section-${section.skill}`} className="space-y-12 mb-16 relative">
                 
                 <div className="flex items-center gap-4 sticky top-0 z-10 bg-gray-50/95 py-4 backdrop-blur-md">
                    <h2 className="text-2xl font-black text-gray-800 uppercase tracking-widest flex items-center gap-3">
                       <span className={`w-4 h-4 rounded-full ${section.skill === 'READING' ? 'bg-blue-500 shadow-blue-500/50' : section.skill === 'LISTENING' ? 'bg-purple-500 shadow-purple-500/50' : 'bg-amber-500 shadow-amber-500/50'} shadow-lg`}></span>
                       {section.skill} SECTION
                    </h2>
                    <div className="h-px bg-gray-200 flex-1"></div>
                 </div>

                 {/* Render Groups */}
                 {section.groups.map((group, gIdx) => (
                    <div id={`part-${group.id}`} key={`group-${group.id}`} className="bg-white rounded-3xl border border-gray-100 shadow-xl shadow-gray-200/40 overflow-hidden break-inside-avoid scroll-mt-32">
                       {/* Group Header */}
                       <div className="bg-slate-900 px-8 py-5 flex items-center justify-between">
                          <h3 className="text-xl font-bold text-white flex items-center gap-3">
                             <span className="bg-white/20 text-white px-3 py-1 rounded-lg text-sm tracking-widest uppercase">
                                Part {gIdx + 1}
                             </span>
                             {group.title}
                          </h3>
                       </div>

                       {/* Group Content */}
                       <div className="p-8 border-b border-gray-100 bg-gray-50/50">
                          <div className="prose max-w-none text-gray-800 text-lg leading-relaxed font-serif whitespace-pre-wrap">
                             {group.content}
                          </div>
                       </div>

                       {/* Group Questions */}
                       <div className="p-8 space-y-10 bg-white">
                          {group.questions?.map((q, qIdx) => (
                            <div key={q.id} className="pt-6 first:pt-0">
                               <div className="mb-4">
                                 <span className="inline-block bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-widest mb-3">
                                    Question {qIdx + 1}
                                 </span>
                               </div>
                               <StudentPreview question={q as any} />
                            </div>
                          ))}
                          {(!group.questions || group.questions.length === 0) && (
                            <p className="text-gray-400 italic">No questions linked to this passage.</p>
                          )}
                       </div>
                    </div>
                 ))}

                 {/* Render Independent Questions */}
                 {section.questions.length > 0 && (
                    <div id={`indep-${section.skill}`} className="bg-white rounded-3xl border border-gray-100 shadow-xl shadow-gray-200/40 overflow-hidden scroll-mt-32">
                       <div className="bg-indigo-900 px-8 py-5 flex items-center justify-between">
                          <h3 className="text-xl font-bold text-white flex items-center gap-3">
                             <span className="bg-white/20 text-white px-3 py-1 rounded-lg text-sm tracking-widest uppercase">
                                Independent Tasks
                             </span>
                          </h3>
                       </div>

                       <div className="p-8 space-y-10 bg-white">
                          {section.questions.map((q, qIdx) => (
                            <div key={q.id} className="pt-6 border-t border-gray-100 first:border-0 first:pt-0">
                               <div className="mb-4 flex items-center justify-between">
                                 <span className="inline-block bg-indigo-100 text-indigo-700 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-widest mb-3">
                                    Task {qIdx + 1}
                                 </span>
                               </div>
                               <StudentPreview question={q as any} />
                            </div>
                          ))}
                       </div>
                    </div>
                 )}
              </div>
            ))}

         </div>
      </div>
      </div>
    </div>
  );
};
