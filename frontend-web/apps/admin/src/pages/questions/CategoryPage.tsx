import React, { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { SkillType, Question } from '../../features/quiz-bank/types';
import { DashboardLayout, NavItem, ConfirmDialog, toast } from '@english-learning/ui';
import { Home, Database, Users, Settings, Briefcase, Plus, Trash2, Edit2, FileText, Eye } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { MultipleChoiceBuilder } from '../../features/quiz-bank/components/MultipleChoiceBuilder';
import { FillInTheBlankBuilder } from '../../features/quiz-bank/components/FillInTheBlankBuilder';
import { MatchingBuilder } from '../../features/quiz-bank/components/MatchingBuilder';
import { WritingBuilder } from '../../features/quiz-bank/components/WritingBuilder';

// Reusing same sidebar for consistency across admin pages
const sidebarItems: NavItem[] = [
    { title: "Dashboard Overview", href: "/admin/dashboard", icon: <Home size={20} /> },
    {
        title: "Questions Bank",
        icon: <Database size={20} />,
        children: [
            { title: "Vocabulary", href: "/admin/questions/vocabulary" },
            { title: "Listening", href: "/admin/questions/listening" },
            { title: "Reading", href: "/admin/questions/reading" },
            { title: "Writing", href: "/admin/questions/writing" },
            { title: "Exam", href: "/admin/questions/exam" },
        ],
    },
    {
        title: "Teacher Management",
        icon: <Briefcase size={20} />,
        children: [
            { title: "Teacher List", href: "/admin/teachers/list" },
            { title: "Performance & Logs", href: "/admin/teachers/logs" },
        ],
    },
    {
        title: "Customer Management",
        icon: <Users size={20} />,
        children: [
            { title: "Customer List", href: "/admin/customers/list" },
            { title: "Messages", href: "/admin/customers/messages" },
            { title: "Reports", href: "/admin/customers/reports" },
            { title: "Requests", href: "/admin/customers/requests" },
            { title: "iCoin Transactions", href: "/admin/customer-management/icoin" },
        ],
    },
    { title: "App Management", href: "/admin/settings", icon: <Settings size={20} /> },
];

export const CategoryPage: React.FC<{ skill: SkillType, title: string }> = ({ skill, title }) => {
  const location = useLocation();
  const navigate = useNavigate();
  const { questions, currentUser, deleteQuestion, fetchQuestions } = useQuizBankStore();
  const [isCreating, setIsCreating] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState<Question | null>(null);
  const [questionToDelete, setQuestionToDelete] = useState<number | null>(null);

  useEffect(() => {
    console.log(`[CategoryPage] Route changed (${location.pathname}), resetting view state.`);
    setIsCreating(false);
    setEditingQuestion(null);
    fetchQuestions(skill);
  }, [skill, fetchQuestions, location.key]);
  const [builderType, setBuilderType] = useState<'MULTIPLE_CHOICE' | 'FILL_BLANK' | 'MATCHING' | 'WRITING'>('MULTIPLE_CHOICE');

  const filteredQuestions = questions.filter(q => q.skill === skill || (skill === 'WRITING' && q.skill === 'WRITING'));
  const isTeacher = currentUser.role === 'TEACHER';

  const handleConfirmDelete = async () => {
    if (questionToDelete) {
      try {
        await deleteQuestion(questionToDelete);
        toast.success("Question deleted successfully");
      } catch (error) {
        toast.error("Failed to delete question");
      } finally {
        setQuestionToDelete(null);
      }
    }
  };

  return (
    <DashboardLayout sidebarItems={sidebarItems} userName={currentUser.name} userRole={currentUser.role === 'ADMIN' ? 'System Admin' : 'Teacher'}>
      <div className="flex flex-col gap-6 max-w-6xl mx-auto py-6">
        
        <div className="flex items-center justify-between">
            <div>
                <h1 className="text-2xl font-bold text-gray-800">{title} Question Bank</h1>
                <p className="text-sm text-gray-500 mt-1">Manage and create {title.toLowerCase()} questions.</p>
            </div>
            {!isCreating && !editingQuestion && (
                <button 
                  onClick={() => {
                      setEditingQuestion(null);
                      setIsCreating(true);
                  }}
                  className="bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 transition-colors"
                >
                  <Plus size={16} /> Create Question
                </button>
            )}
        </div>

        {isCreating || editingQuestion ? (
            <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div className="flex items-center justify-between mb-6">
                    <h2 className="text-lg font-bold text-gray-800">{editingQuestion ? `Edit ${title} Question` : `New ${title} Question`}</h2>
                    <button 
                        onClick={() => {
                            setIsCreating(false);
                            setEditingQuestion(null);
                        }}
                        className="text-sm text-gray-500 hover:text-gray-700 underline"
                    >
                        Cancel & Return
                    </button>
                </div>

                {skill !== 'WRITING' && !editingQuestion && (
                  <div className="mb-6">
                    <label className="text-sm font-semibold text-gray-700 block mb-2">Select Builder Mode</label>
                    <div className="flex gap-2">
                        <button onClick={() => setBuilderType('MULTIPLE_CHOICE')} className={`px-4 py-2 rounded-md text-sm font-medium ${builderType === 'MULTIPLE_CHOICE' ? 'bg-blue-100 text-blue-700 border-blue-200 border' : 'bg-gray-50 text-gray-600 border'}`}>Multiple Choice</button>
                        <button onClick={() => setBuilderType('FILL_BLANK')} className={`px-4 py-2 rounded-md text-sm font-medium ${builderType === 'FILL_BLANK' ? 'bg-green-100 text-green-700 border-green-200 border' : 'bg-gray-50 text-gray-600 border'}`}>Fill in the Blanks</button>
                        <button onClick={() => setBuilderType('MATCHING')} className={`px-4 py-2 rounded-md text-sm font-medium ${builderType === 'MATCHING' ? 'bg-pink-100 text-pink-700 border-pink-200 border' : 'bg-gray-50 text-gray-600 border'}`}>Matching</button>
                    </div>
                  </div>
                )}

                <div className="mt-8 border-t pt-8 border-dashed">
                    {skill === 'WRITING' ? <WritingBuilder initialQuestion={editingQuestion} onSave={() => { setIsCreating(false); setEditingQuestion(null); }} /> : 
                     (editingQuestion ? editingQuestion.type === 'MULTIPLE_CHOICE' : builderType === 'MULTIPLE_CHOICE') ? <MultipleChoiceBuilder skill={skill} initialQuestion={editingQuestion} onSave={() => { setIsCreating(false); setEditingQuestion(null); }} /> :
                     (editingQuestion ? editingQuestion.type === 'MATCHING' : builderType === 'MATCHING') ? <MatchingBuilder skill={skill} initialQuestion={editingQuestion} onSave={() => { setIsCreating(false); setEditingQuestion(null); }} /> :
                     <FillInTheBlankBuilder skill={skill} initialQuestion={editingQuestion} onSave={() => { setIsCreating(false); setEditingQuestion(null); }} />
                    }
                </div>
            </div>
        ) : (
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-gray-50 border-b border-gray-100 text-gray-500 text-xs uppercase tracking-wider">
                            <th className="p-4 font-semibold">ID</th>
                            <th className="p-4 font-semibold">Type</th>
                            <th className="p-4 font-semibold">Prompt / Setup</th>
                            <th className="p-4 font-semibold">Difficulty</th>
                            <th className="p-4 font-semibold text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {filteredQuestions.length === 0 ? (
                            <tr>
                                <td colSpan={5} className="p-8 text-center text-gray-500">
                                    <FileText className="mx-auto h-12 w-12 text-gray-300 mb-3" />
                                    <p>No {title.toLowerCase()} questions found.</p>
                                    <p className="text-sm mt-1">Click the "Create Question" button to add one.</p>
                                </td>
                            </tr>
                        ) : (
                            filteredQuestions.map((q) => (
                                <tr key={q.id} className="hover:bg-gray-50/50 transition-colors">
                                    <td className="p-4 text-sm font-medium text-gray-900 border-b border-gray-100">
                                        <Link to={`/admin/questions/${q.id}`} className="hover:text-blue-600 transition-colors">
                                            #{q.id.toString().slice(-4)}
                                        </Link>
                                    </td>
                                    <td className="p-4 text-sm text-gray-600 border-b border-gray-100">
                                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${q.isPremiumContent ? 'bg-amber-100 text-amber-800 border border-amber-200' : 'bg-blue-100 text-blue-800 border border-blue-200'}`}>
                                            {q.type.replace('_', ' ')}
                                            {q.isPremiumContent && ' (PRO)'}
                                        </span>
                                    </td>
                                    <td className="p-4 text-sm text-gray-800 border-b border-gray-100 max-w-xs truncate" title={q.instruction}>
                                        <Link to={`/admin/questions/${q.id}`} className="hover:text-blue-600 transition-colors font-medium">
                                            {q.instruction || (q.data as any).template || "Open Task"}
                                        </Link>
                                    </td>
                                    <td className="p-4 text-sm text-gray-600 border-b border-gray-100">
                                       <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium border border-gray-200 bg-gray-50">
                                            {q.difficultyBand.replace('BAND_', 'Level ')}
                                       </span>
                                    </td>
                                    <td className="p-4 text-right border-b border-gray-100">
                                        <div className="flex items-center justify-end gap-2">
                                            <button 
                                                onClick={() => navigate(`/admin/questions/${q.id}`)}
                                                className="p-1.5 text-gray-400 hover:text-blue-600 rounded bg-white border shadow-sm transition-colors"
                                                title="View Details"
                                            >
                                                <Eye size={16} />
                                            </button>
                                            <button 
                                                onClick={() => navigate(`/admin/questions/${q.id}/edit`)}
                                                className="p-1.5 text-gray-400 hover:text-blue-600 rounded bg-white border shadow-sm transition-colors"
                                                title="Edit Question"
                                            >
                                                <Edit2 size={16} />
                                            </button>
                                            {/* RBAC: Hide Delete if Teacher */}
                                            {!isTeacher && (
                                                <button 
                                                    onClick={() => setQuestionToDelete(q.id)}
                                                    className="p-1.5 text-gray-400 hover:text-red-600 rounded bg-white border shadow-sm transition-colors"
                                                >
                                                    <Trash2 size={16} />
                                                </button>
                                            )}
                                        </div>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        )}

      </div>

      <ConfirmDialog
        isOpen={questionToDelete !== null}
        onClose={() => setQuestionToDelete(null)}
        onConfirm={handleConfirmDelete}
        title="Delete Question"
        message="Are you sure you want to delete this question? This action cannot be undone."
        confirmText="Delete"
        variant="danger"
      />
    </DashboardLayout>
  );
};
