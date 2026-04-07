import React, { useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { Question, QuestionGroup } from '../../features/quiz-bank/types';
import { toast } from '@english-learning/ui';
import { AdminLayout } from '../../components/AdminLayout';
import { ArrowLeft, Edit2, Eye, FileText, ChevronRight, BookOpen, Music } from 'lucide-react';
import { getMediaUrl } from '../../features/quiz-bank/utils';

import { StudentPreview } from '../../features/quiz-bank/components/StudentPreview';

export const ComprehensionDetailView: React.FC<{ basePath?: string, Layout?: React.ComponentType<{ children: React.ReactNode }> }> = ({ basePath = '/admin', Layout = AdminLayout }) => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { fetchGroupById, isLoading } = useQuizBankStore();
    const [group, setGroup] = useState<QuestionGroup | null>(null);
    const [viewMode, setViewMode] = useState<'ADMIN' | 'STUDENT'>('ADMIN');

    useEffect(() => {
        if (id) {
            fetchGroupById(parseInt(id)).then(g => {
                if (g) setGroup(g);
                else {
                    toast.error("Comprehension not found");
                    navigate(`${basePath}/questions/reading`);
                }
            });
        }
    }, [id, fetchGroupById, navigate]);

    if (isLoading && !group) {
        return (
            <Layout>
                <div className="flex items-center justify-center h-64">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                </div>
            </Layout>
        );
    }

    if (!group) return null;

    const childQuestions = group.questions || [];

    return (
        <Layout>
            <div className="max-w-6xl mx-auto py-8 px-4">
                {}
                <div className="mb-8 flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <button 
                            onClick={() => navigate(-1)}
                            className="flex items-center gap-1 text-sm text-blue-600 hover:text-blue-700 font-medium mb-2"
                        >
                            <ArrowLeft size={16} /> Back to List
                        </button>
                        <h1 className="text-3xl font-bold text-gray-900 dark:text-slate-100 flex items-center gap-3">
                            <BookOpen className="text-purple-600" />
                            {group.title}
                            <span className="text-sm font-normal text-gray-400 dark:text-slate-500 bg-gray-100 dark:bg-slate-800 px-2 py-0.5 rounded">ID: #{group.id}</span>
                        </h1>
                    </div>
                    <div className="flex gap-3">
                        <button 
                            onClick={() => setViewMode(viewMode === 'ADMIN' ? 'STUDENT' : 'ADMIN')}
                            className={`flex items-center gap-2 px-5 py-2.5 rounded-lg shadow-sm transition-all font-medium border ${viewMode === 'STUDENT' ? 'bg-amber-600 border-amber-600 text-white hover:bg-amber-700' : 'bg-white dark:bg-slate-800 border-gray-200 dark:border-slate-700 text-gray-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700'}`}
                        >
                            <Eye size={18} /> {viewMode === 'ADMIN' ? 'Student Preview' : 'Back to Admin View'}
                        </button>
                        <Link 
                            to={`${basePath}/comprehensions/${group.id}/edit`}
                            className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-lg shadow-sm transition-all font-medium"
                        >
                            <Edit2 size={18} /> Edit Comprehension
                        </Link>
                    </div>
                </div>

                {viewMode === 'STUDENT' ? (
                    <StudentPreview question={group as any} />
                ) : (
                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                        {}
                        <div className="lg:col-span-2 space-y-8">
                            <section className="bg-white dark:bg-slate-900 p-8 rounded-2xl border border-gray-200 dark:border-slate-800 shadow-sm transition-colors">
                                <h2 className="text-xs uppercase tracking-widest font-bold text-gray-400 dark:text-slate-500 mb-6 flex items-center gap-2">
                                    <FileText size={16} /> Reading/Listening Passage
                                </h2>
                                
                                {group.mediaUrl && (
                                    <div className="mb-8 p-4 bg-gray-50 dark:bg-slate-800/50 rounded-xl border border-gray-100 dark:border-slate-800">
                                        {group.mediaType?.startsWith('audio/') ? (
                                            <div className="flex items-center gap-4">
                                                <div className="w-12 h-12 rounded-full bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center text-purple-600 dark:text-purple-400">
                                                    <Music size={24} />
                                                </div>
                                                <audio src={getMediaUrl(group.mediaUrl)} controls className="flex-1" />
                                            </div>
                                        ) : (
                                            <img 
                                                src={getMediaUrl(group.mediaUrl)} 
                                                alt="Passage" 
                                                className="max-h-96 w-full object-contain rounded-lg shadow-sm bg-white"
                                            />
                                        )}
                                    </div>
                                )}

                                <div className="prose dark:prose-invert max-w-none text-gray-800 dark:text-slate-200 text-lg leading-relaxed whitespace-pre-wrap">
                                    {group.content || "No content provided."}
                                </div>
                            </section>

                            {}
                            <section className="space-y-4">
                                <h2 className="text-xl font-bold text-gray-900 dark:text-slate-100 px-2 flex items-center justify-between">
                                    <span>Questions ({childQuestions.length})</span>
                                </h2>
                                <div className="grid gap-4">
                                    {childQuestions.map((q: Question, idx: number) => (
                                        <div key={q.id} className="bg-white dark:bg-slate-900 p-6 rounded-xl border border-gray-200 dark:border-slate-800 shadow-sm hover:border-blue-300 dark:hover:border-blue-800 transition-all group">
                                            <div className="flex items-start justify-between">
                                                <div className="flex-1">
                                                    <div className="flex items-center gap-2 mb-2">
                                                        <span className="text-xs font-bold text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/20 px-2 py-0.5 rounded">Question {idx + 1}</span>
                                                        <span className="text-xs font-medium text-gray-400 dark:text-slate-500">• {q.type.replace('_', ' ')}</span>
                                                    </div>
                                                    <p className="text-gray-800 dark:text-slate-200 font-medium line-clamp-2">{q.instruction}</p>
                                                </div>
                                                <Link 
                                                    to={`${basePath}/questions/${q.id}`}
                                                    className="p-2 text-gray-400 hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
                                                >
                                                    <ChevronRight size={20} />
                                                </Link>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </section>
                        </div>

                        {}
                        <div className="space-y-6">
                            <div className="bg-white dark:bg-slate-900 p-6 rounded-2xl border border-gray-200 dark:border-slate-800 shadow-sm transition-colors">
                                <h3 className="text-sm font-bold text-gray-800 dark:text-slate-200 mb-4 border-b dark:border-slate-800 pb-2">Properties</h3>
                                <div className="space-y-4">
                                    <div>
                                        <label className="text-xs text-gray-400 dark:text-slate-500 block mb-1">SKILL</label>
                                        <span className="text-sm font-semibold text-gray-700 dark:text-slate-300 bg-gray-100 dark:bg-slate-800 px-2 py-1 rounded">{group.skill}</span>
                                    </div>
                                    <div>
                                        <label className="text-xs text-gray-400 dark:text-slate-500 block mb-1">DIFFICULTY</label>
                                        <span className="text-sm font-semibold text-gray-700 dark:text-slate-300 bg-gray-100 dark:bg-slate-800 px-2 py-1 rounded">Level {group.difficultyBand.replace('BAND_', '')}</span>
                                    </div>
                                    <div className="pt-4 border-t dark:border-slate-800 mt-4">
                                        <div className="flex items-center justify-between text-xs text-gray-500 dark:text-slate-400">
                                            <span>Author ID</span>
                                            <span className="font-mono text-gray-700 dark:text-slate-300">#{group.authorId}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div className="bg-gradient-to-br from-blue-600 to-indigo-700 p-6 rounded-2xl text-white shadow-lg">
                                <h3 className="font-bold mb-2 flex items-center gap-2">
                                    <Edit2 size={16} /> Batch Editing
                                </h3>
                                <p className="text-xs text-blue-100 leading-relaxed mb-4">
                                    Need to add more questions or change the passage text? Use the edit button to manage all content at once.
                                </p>
                                <Link 
                                    to={`${basePath}/comprehensions/${group.id}/edit`}
                                    className="block w-full text-center bg-white text-blue-600 py-2 rounded-lg text-sm font-bold hover:bg-blue-50 transition-colors"
                                >
                                    Manage Content
                                </Link>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </Layout>
    );
};
