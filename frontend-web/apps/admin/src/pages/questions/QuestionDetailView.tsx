import React, { useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { Question, MultipleChoiceData, MatchingData, FillBlankData } from '../../features/quiz-bank/types';
import { DashboardLayout, NavItem, toast } from '@english-learning/ui';
import { ArrowLeft, Edit2, Home, Database, Briefcase, Users, Settings, CheckCircle2, Eye, XCircle } from 'lucide-react';
import { StudentPreview } from '../../features/quiz-bank/components/StudentPreview';

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

export const QuestionDetailView: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { fetchQuestionById, currentUser, isLoading } = useQuizBankStore();
    const [question, setQuestion] = useState<Question | null>(null);
    const [viewMode, setViewMode] = useState<'ADMIN' | 'STUDENT'>('ADMIN');

    useEffect(() => {
        if (id) {
            console.log(`[QuestionDetailView] Fetching question ID: ${id}`);
            fetchQuestionById(parseInt(id)).then(q => {
                if (q) setQuestion(q);
                else {
                    toast.error("Question not found");
                    navigate('/admin/questions/vocabulary'); // Fallback
                }
            });
        }
    }, [id, fetchQuestionById, navigate]);

    if (isLoading && !question) {
        return (
            <DashboardLayout sidebarItems={sidebarItems} userName={currentUser.name} userRole={currentUser.role === 'ADMIN' ? 'System Admin' : 'Teacher'}>
                <div className="flex items-center justify-center h-64">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                </div>
            </DashboardLayout>
        );
    }

    if (!question) return null;

    const renderData = () => {
        switch (question.type) {
            case 'MULTIPLE_CHOICE': {
                const data = question.data as MultipleChoiceData;
                return (
                    <div className="space-y-4">
                        <h3 className="font-semibold text-gray-700">Options ({data.multiple_select ? 'Multiple Answers' : 'Single Answer'}):</h3>
                        <div className="grid gap-3">
                            {data.options.map((opt, idx) => {
                                const isCorrect = data.correct_ids.includes(opt.id);
                                return (
                                    <div key={opt.id} className={`p-4 rounded-lg border flex items-center gap-3 ${isCorrect ? 'bg-green-50 border-green-200' : 'bg-gray-50 border-gray-100'}`}>
                                        <span className="font-bold text-gray-400 w-6">{String.fromCharCode(65 + idx)}.</span>
                                        <div className="flex-1 flex items-center gap-3">
                                            {opt.image && (
                                                <img 
                                                    src={`http://localhost:8080${opt.image}`} 
                                                    alt={`Option ${idx + 1}`} 
                                                    className="w-12 h-12 object-cover rounded shadow-sm border border-gray-200"
                                                />
                                            )}
                                            <span className={`${isCorrect ? 'text-green-800 font-medium' : 'text-gray-700'}`}>{opt.label}</span>
                                        </div>
                                        {isCorrect && <CheckCircle2 className="text-green-500" size={20} />}
                                    </div>
                                );
                            })}
                        </div>
                    </div>
                );
            }
            case 'MATCHING': {
                const data = question.data as MatchingData;
                return (
                    <div className="space-y-4">
                        <h3 className="font-semibold text-gray-700">Matching Pairs:</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            {data.left_items.map((left) => {
                                const rightId = data.solution[left.id];
                                const right = data.right_items.find(r => r.id.toString() === rightId.toString());
                                return (
                                    <div key={left.id} className="flex items-center gap-4">
                                        <div className="flex-1 p-3 bg-white border border-gray-200 rounded-lg text-sm flex items-center gap-3">
                                            {left.image && <img src={`http://localhost:8080${left.image}`} className="w-10 h-10 object-cover rounded" />}
                                            <span>{left.text}</span>
                                        </div>
                                        <div className="text-gray-400">→</div>
                                        <div className="flex-1 p-3 bg-green-50 border border-green-100 rounded-lg text-sm text-green-800 font-medium flex items-center gap-3">
                                            {right?.image && <img src={`http://localhost:8080${right.image}`} className="w-10 h-10 object-cover rounded" />}
                                            <span>{right?.text || 'N/A'}</span>
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    </div>
                );
            }
            case 'FILL_BLANK': {
                const data = question.data as FillBlankData;
                // Simple highlighter for blanks in template
                const highlightedTemplate = data.template.replace(/\[blank(\d+)\]/g, (match) => {
                    const blank = data.blanks[match];
                    return `<span class="bg-blue-100 text-blue-800 px-2 py-0.5 rounded border border-blue-200 font-medium" title="Correct: ${blank?.correct.join(', ')}">${blank?.correct[0] || '___'}</span>`;
                });

                return (
                    <div className="space-y-4">
                        <h3 className="font-semibold text-gray-700">Template Preview:</h3>
                        <div 
                            className="p-6 bg-gray-50 rounded-xl border border-gray-100 text-lg leading-relaxed text-gray-800"
                            dangerouslySetInnerHTML={{ __html: highlightedTemplate }}
                        />
                        <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <h4 className="text-sm font-semibold text-gray-500 mb-2">Blanks & Correct Answers:</h4>
                                <div className="grid gap-2">
                                    {Object.entries(data.blanks).map(([key, value]) => (
                                        <div key={key} className="flex items-center gap-2 text-sm bg-blue-50/50 p-2 rounded-lg border border-blue-100">
                                            <span className="font-mono bg-blue-100 px-2 py-0.5 rounded text-blue-700 text-xs">{key}:</span>
                                            <span className="font-medium text-gray-800">{value.correct.join(' | ')}</span>
                                            <span className="text-gray-400 text-[10px]">(Max {value.max_words} words)</span>
                                        </div>
                                    ))}
                                </div>
                            </div>
                            
                            {data.answer_pool && data.answer_pool.length > 0 && (
                                <div>
                                    <h4 className="text-sm font-semibold text-orange-500 mb-2 flex items-center gap-1">
                                        <XCircle size={14} /> Distractors:
                                    </h4>
                                    <div className="flex flex-wrap gap-2">
                                        {data.answer_pool.map((word, i) => (
                                            <span key={i} className="text-sm bg-orange-50 text-orange-700 border border-orange-100 px-2 py-1 rounded font-medium">
                                                {word}
                                            </span>
                                        ))}
                                    </div>
                                    <p className="text-[10px] text-gray-400 mt-2">These words appear in the student word bank but are incorrect.</p>
                                </div>
                            )}
                        </div>
                    </div>
                );
            }
            case 'ESSAY':
                return (
                    <div className="p-4 bg-gray-50 rounded-lg border border-gray-100 italic text-gray-500">
                        This is an open writing task. No structured options to display.
                    </div>
                );
            default:
                return null;
        }
    };

    return (
        <DashboardLayout sidebarItems={sidebarItems} userName={currentUser.name} userRole={currentUser.role === 'ADMIN' ? 'System Admin' : 'Teacher'}>
            <div className="max-w-5xl mx-auto py-8 px-4">
                {/* Header / Breadcrumbs */}
                <div className="mb-8 flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <button 
                            onClick={() => navigate(-1)}
                            className="flex items-center gap-1 text-sm text-blue-600 hover:text-blue-700 font-medium mb-2"
                        >
                            <ArrowLeft size={16} /> Back to List
                        </button>
                        <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
                            Question Details 
                            <span className="text-sm font-normal text-gray-400 bg-gray-100 px-2 py-0.5 rounded">ID: #{question.id.toString().slice(-6)}</span>
                        </h1>
                    </div>
                    <div className="flex gap-3">
                        <button 
                            onClick={() => setViewMode(viewMode === 'ADMIN' ? 'STUDENT' : 'ADMIN')}
                            className={`flex items-center gap-2 px-5 py-2.5 rounded-lg shadow-sm transition-all font-medium border ${viewMode === 'STUDENT' ? 'bg-amber-600 border-amber-600 text-white hover:bg-amber-700' : 'bg-white border-gray-200 text-gray-700 hover:bg-gray-50'}`}
                        >
                            <Eye size={18} /> {viewMode === 'ADMIN' ? 'Student Preview' : 'Back to Admin View'}
                        </button>
                        <Link 
                            to={`/admin/questions/${question.id}/edit`}
                            className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-lg shadow-sm transition-all font-medium"
                        >
                            <Edit2 size={18} /> Edit Question
                        </Link>
                    </div>
                </div>

                {viewMode === 'STUDENT' ? (
                    <StudentPreview question={question} />
                ) : (
                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                        {/* Main Content */}
                        <div className="lg:col-span-2 space-y-8">
                            {/* Instruction Section */}
                            <section className="bg-white p-8 rounded-2xl border border-gray-200 shadow-sm">
                                <h2 className="text-xs uppercase tracking-widest font-bold text-gray-400 mb-4">Prompt / Instruction</h2>
                                <div className="prose max-w-none text-gray-800 text-lg">
                                    {question.instruction || "No instruction provided."}
                                </div>

                                {/* Media Display */}
                                {question.mediaUrls && question.mediaUrls.length > 0 && (
                                    <div className="mt-8 pt-8 border-t border-gray-100">
                                        <h3 className="text-xs uppercase tracking-widest font-bold text-gray-400 mb-4">Attachments</h3>
                                        <div className="flex flex-wrap gap-4">
                                            {question.mediaUrls.map((url, idx) => {
                                                const type = question.mediaTypes?.[idx] || '';
                                                return (
                                                    <div key={idx} className="border rounded-xl overflow-hidden shadow-sm bg-gray-50 max-w-xs">
                                                        {type.startsWith('image/') ? (
                                                            <img src={`http://localhost:8080${url}`} alt="Media" className="max-h-48 w-full object-cover" />
                                                        ) : type.startsWith('video/') ? (
                                                            <video src={`http://localhost:8080${url}`} controls className="max-h-48" />
                                                        ) : type.startsWith('audio/') ? (
                                                            <div className="p-4"><audio src={`http://localhost:8080${url}`} controls className="w-full" /></div>
                                                        ) : (
                                                            <div className="p-4 text-sm text-blue-600 underline">
                                                                <a href={`http://localhost:8080${url}`} target="_blank" rel="noreferrer">Download Attachment</a>
                                                            </div>
                                                        )}
                                                    </div>
                                                );
                                            })}
                                        </div>
                                    </div>
                                )}
                            </section>

                            {/* Interactive Content Section */}
                            <section className="bg-white p-8 rounded-2xl border border-gray-200 shadow-sm">
                                <h2 className="text-xs uppercase tracking-widest font-bold text-gray-400 mb-6">Structured Content</h2>
                                {renderData()}
                            </section>

                            {/* Explanation Section */}
                            {question.explanation && (
                                <section className="bg-blue-50/50 p-8 rounded-2xl border border-blue-100">
                                    <h2 className="text-xs uppercase tracking-widest font-bold text-blue-400 mb-4">Explanation</h2>
                                    <div className="text-blue-900 leading-relaxed italic">
                                        {question.explanation}
                                    </div>
                                </section>
                            )}
                        </div>

                        {/* Sidebar / Meta Info */}
                        <div className="space-y-6">
                            <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                                <h3 className="text-sm font-bold text-gray-800 mb-4 border-b pb-2">Properties</h3>
                                <div className="space-y-4">
                                    <div>
                                        <label className="text-xs text-gray-400 block mb-1">SKILL</label>
                                        <span className="text-sm font-semibold text-gray-700 bg-gray-100 px-2 py-1 rounded">{question.skill}</span>
                                    </div>
                                    <div>
                                        <label className="text-xs text-gray-400 block mb-1">TYPE</label>
                                        <span className="text-sm font-semibold text-gray-700 bg-gray-100 px-2 py-1 rounded">{question.type}</span>
                                    </div>
                                    <div>
                                        <label className="text-xs text-gray-400 block mb-1">DIFFICULTY</label>
                                        <span className="text-sm font-semibold text-gray-700 bg-gray-100 px-2 py-1 rounded">Level {question.difficultyBand.replace('BAND_', '')}</span>
                                    </div>
                                    <div>
                                        <label className="text-xs text-gray-400 block mb-1">CONTENT ACCESS</label>
                                        <span className={`text-sm font-bold ${question.isPremiumContent ? 'text-amber-600' : 'text-blue-600'}`}>
                                            {question.isPremiumContent ? '★ PREMIUM (PRO ONLY)' : '✓ FREE CONTENT'}
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div className="bg-gray-50 p-6 rounded-2xl border border-gray-200">
                                 <p className="text-xs text-gray-500 leading-relaxed">
                                     Ready to modify this question? Click the edit button at the top of the page to enter builder mode.
                                 </p>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </DashboardLayout>
    );
};
