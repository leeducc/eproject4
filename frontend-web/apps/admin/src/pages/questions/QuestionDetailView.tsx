import React, { useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { Question, MultipleChoiceData, MatchingData, FillBlankData } from '../../features/quiz-bank/types';
import { toast } from '@english-learning/ui';
import { ArrowLeft, Edit2, CheckCircle2, Eye, XCircle, X, History as HistoryIcon, Clock, User, ChevronRight, Plus, Tag as TagIcon } from 'lucide-react';
import { StudentPreview } from '../../features/quiz-bank/components/StudentPreview';
import { AdminLayout } from '../../components/AdminLayout';
import { getMediaUrl } from '../../features/quiz-bank/utils';
import { QuestionHistoryModal } from '../../features/quiz-bank/components/QuestionHistoryModal';
import { QuestionHistory } from '../../features/quiz-bank/types';

interface QuestionDetailViewProps {
    basePath?: string;
    Layout?: React.ComponentType<{ children: React.ReactNode }>;
}

export const QuestionDetailView: React.FC<QuestionDetailViewProps> = ({
    basePath = '/admin',
    Layout = AdminLayout
}) => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { fetchQuestionById, updateQuestion, fetchQuestionHistory, fetchTags, isLoading } = useQuizBankStore();
    const [question, setQuestion] = useState<Question | null>(null);
    const [viewMode, setViewMode] = useState<'ADMIN' | 'STUDENT'>('ADMIN');
    const [previewImageUrl, setPreviewImageUrl] = useState<string | null>(null);
    const [histories, setHistories] = useState<QuestionHistory[]>([]);
    const [isHistoryModalOpen, setIsHistoryModalOpen] = useState(false);
    const [allTags, setAllTags] = useState<any[]>([]);
    const [isAddingTag, setIsAddingTag] = useState(false);
    const [newTagStr, setNewTagStr] = useState('');

    useEffect(() => {
        if (id) {
            console.log(`[QuestionDetailView] Fetching question ID: ${id}`);
            const questionId = parseInt(id);
            fetchQuestionById(questionId).then(q => {
                if (q) setQuestion(q);
                else {
                    toast.error("Question not found");
                    navigate(`${basePath}/questions/vocabulary`); // Fallback
                }
            });

            // Fetch history
            fetchQuestionHistory(questionId).then(h => {
                setHistories(h);
            });

            // Fetch all tags for suggestions
            fetchTags().then(tags => setAllTags(tags));
        }
    }, [id, fetchQuestionById, fetchQuestionHistory, fetchTags, navigate]);

    if (isLoading && !question) {
        return (
            <Layout>
                <div className="flex items-center justify-center h-64">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                </div>
            </Layout>
        );
    }

    if (!question) return null;

    const handleAddTag = async (explicitTag?: string) => {
        const tagToAdd = explicitTag || newTagStr;
        if (!tagToAdd.trim()) return;

        try {
            const currentTagStrings = (question.tags || []).map(t => `${t.namespace}:${t.name}`);
            if (currentTagStrings.includes(tagToAdd)) {
                toast.error("Tag already exists");
                return;
            }

            const updatedTags = [...currentTagStrings, tagToAdd];
            const updatedQuestion = await updateQuestion(question.id, { tags: updatedTags } as any);
            if (updatedQuestion) {
                setQuestion(updatedQuestion);
                setNewTagStr('');
                setIsAddingTag(false);
                toast.success("Tag added");
            }
        } catch (err) {
            toast.error("Failed to add tag");
        }
    };

    const handleRemoveTag = async (tagId: number) => {
        try {
            const updatedTags = (question.tags || [])
                .filter(t => t.id !== tagId)
                .map(t => `${t.namespace}:${t.name}`);
            
            const updatedQuestion = await updateQuestion(question.id, { tags: updatedTags } as any);
            if (updatedQuestion) {
                setQuestion(updatedQuestion);
                toast.success("Tag removed");
            }
        } catch (err) {
            toast.error("Failed to remove tag");
        }
    };

    const renderData = () => {
        switch (question.type) {
            case 'MULTIPLE_CHOICE': {
                const data = question.data as MultipleChoiceData;
                return (
                    <div className="space-y-4">
                        <h3 className="font-semibold text-gray-700 dark:text-slate-300">Options ({data.multiple_select ? 'Multiple Answers' : 'Single Answer'}):</h3>
                        <div className="grid gap-3">
                            {data.options?.map((opt, idx) => {
                                const isCorrect = data.correct_ids?.includes(opt.id) || false;
                                return (
                                    <div key={opt.id} className={`p-4 rounded-lg border flex items-center gap-3 transition-colors ${isCorrect ? 'bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800' : 'bg-gray-50 dark:bg-slate-800/40 border-gray-100 dark:border-slate-800'}`}>
                                        <span className="font-bold text-gray-400 dark:text-slate-500 w-6">{String.fromCharCode(65 + idx)}.</span>
                                        <div className="flex-1 flex items-center gap-3">
                                            {opt.image && (
                                                <div className="relative group cursor-pointer shrink-0" onClick={() => setPreviewImageUrl(getMediaUrl(opt.image))}>
                                                    <img 
                                                        src={getMediaUrl(opt.image)} 
                                                        alt="Option" 
                                                        className="w-16 h-16 object-cover rounded-lg border border-gray-200 dark:border-slate-700 bg-white dark:bg-slate-800 shadow-sm"
                                                    />
                                                    <div className="absolute inset-0 bg-black/5 dark:bg-white/5 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center rounded-lg">
                                                        <Eye size={16} className="text-blue-600 dark:text-blue-400" />
                                                    </div>
                                                </div>
                                            )}
                                            <span className={`${isCorrect ? 'text-green-800 dark:text-green-400 font-medium' : 'text-gray-700 dark:text-slate-300'}`}>{opt.label}</span>
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
                        <h3 className="font-semibold text-gray-700 dark:text-slate-300">Matching Pairs:</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            {data.left_items?.map((left) => {
                                const rightId = data.solution?.[left.id];
                                const right = data.right_items?.find(r => r.id.toString() === rightId?.toString());
                                return (
                                    <div key={left.id} className="flex items-center gap-4">
                                        <div className="flex-1 p-3 bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg text-sm flex items-center gap-3 shadow-sm transition-colors">
                                            {left.image && (
                                                <div 
                                                    className="relative group cursor-pointer shrink-0" 
                                                    onClick={() => setPreviewImageUrl(getMediaUrl(left.image))}
                                                >
                                                    <img 
                                                        src={getMediaUrl(left.image)} 
                                                        alt="Left item" 
                                                        className="w-10 h-10 object-cover rounded border border-gray-100 dark:border-slate-700 shadow-sm"
                                                    />
                                                    <div className="absolute inset-0 bg-black/5 dark:bg-white/5 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center rounded">
                                                        <Eye size={12} className="text-blue-600 dark:text-blue-400" />
                                                    </div>
                                                </div>
                                            )}
                                            <span>{left.text}</span>
                                        </div>
                                        <div className="text-gray-400 dark:text-slate-600">→</div>
                                        <div className="flex-1 p-3 bg-green-50 dark:bg-green-900/20 border border-green-100 dark:border-green-800 rounded-lg text-sm text-green-800 dark:text-green-400 font-medium flex items-center gap-3 shadow-sm transition-colors">
                                            {right?.image && (
                                                <div 
                                                    className="relative group cursor-pointer shrink-0" 
                                                    onClick={() => setPreviewImageUrl(getMediaUrl(right.image))}
                                                >
                                                    <img 
                                                        src={getMediaUrl(right.image)} 
                                                        alt="Right item" 
                                                        className="w-10 h-10 object-cover rounded border border-green-100 dark:border-green-800 shadow-sm bg-white dark:bg-slate-800"
                                                    />
                                                    <div className="absolute inset-0 bg-black/5 dark:bg-white/5 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center rounded">
                                                        <Eye size={12} className="text-green-600 dark:text-green-400" />
                                                    </div>
                                                </div>
                                            )}
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
                    return `<span class="bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-400 px-2 py-0.5 rounded border border-blue-200 dark:border-blue-800 font-medium" title="Correct: ${blank?.correct.join(', ')}">${blank?.correct[0] || '___'}</span>`;
                });

                return (
                    <div className="space-y-4">
                        <h3 className="font-semibold text-gray-700 dark:text-slate-300">Template Preview:</h3>
                        <div 
                            className="p-6 bg-gray-50 dark:bg-slate-800/40 rounded-xl border border-gray-100 dark:border-slate-800 text-lg leading-relaxed text-gray-800 dark:text-slate-200 transition-colors"
                            dangerouslySetInnerHTML={{ __html: highlightedTemplate }}
                        />
                        <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <h4 className="text-sm font-semibold text-gray-500 dark:text-slate-400 mb-2">Blanks & Correct Answers:</h4>
                                <div className="grid gap-2">
                                    {Object.entries(data.blanks || {}).map(([key, value]) => (
                                        <div key={key} className="flex items-center gap-2 text-sm bg-blue-50/50 dark:bg-blue-900/10 p-2 rounded-lg border border-blue-100 dark:border-blue-900/30">
                                            <span className="font-mono bg-blue-100 dark:bg-blue-900/40 px-2 py-0.5 rounded text-blue-700 dark:text-blue-400 text-xs">{key}:</span>
                                            <span className="font-medium text-gray-800 dark:text-slate-200">{value.correct.join(' | ')}</span>
                                            <span className="text-gray-400 dark:text-slate-500 text-[10px]">(Max {value.max_words} words)</span>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            {data.answer_pool && data.answer_pool.length > 0 && (
                                <div>
                                    <h4 className="text-sm font-semibold text-orange-500 dark:text-orange-400 mb-2 flex items-center gap-1">
                                        <XCircle size={14} /> Distractors:
                                    </h4>
                                    <div className="flex flex-wrap gap-2">
                                        {data.answer_pool.map((word, i) => (
                                            <span key={i} className="text-sm bg-orange-50 dark:bg-orange-900/20 text-orange-700 dark:text-orange-400 border border-orange-100 dark:border-orange-800 px-2 py-1 rounded font-medium transition-colors">
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
                    <div className="p-4 bg-gray-50 dark:bg-slate-800/40 rounded-lg border border-gray-100 dark:border-slate-800 italic text-gray-500 dark:text-slate-400 transition-colors">
                        This is an open writing task. No structured options to display.
                    </div>
                );
            default:
                return null;
        }
    };

    return (
        <Layout>
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
                        <h1 className="text-3xl font-bold text-gray-900 dark:text-slate-100 flex items-center gap-3">
                            Question Details 
                            <span className="text-sm font-normal text-gray-400 dark:text-slate-500 bg-gray-100 dark:bg-slate-800 px-2 py-0.5 rounded">ID: #{question.id.toString().slice(-6)}</span>
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
                            to={`${basePath}/questions/${question.id}/edit`}
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
                            <section className="bg-white dark:bg-slate-900 p-8 rounded-2xl border border-gray-200 dark:border-slate-800 shadow-sm transition-colors">
                                <h2 className="text-xs uppercase tracking-widest font-bold text-gray-400 dark:text-slate-500 mb-4">Prompt / Instruction</h2>
                                <div className="prose dark:prose-invert max-w-none text-gray-800 dark:text-slate-200 text-lg">
                                    {question.instruction || "No instruction provided."}
                                </div>

                                 {/* Media Display */}
                                {question.mediaUrls && question.mediaUrls.length > 0 && (
                                    <div className="mt-8 pt-8 border-t border-gray-100 dark:border-slate-800">
                                        <h2 className="text-xs uppercase tracking-widest font-bold text-gray-400 dark:text-slate-500 mb-4">Attachments</h2>
                                        <div className="flex flex-wrap gap-4">
                                            {question.mediaUrls
                                                .map((url, idx) => ({ url, type: question.mediaTypes?.[idx] || '' }))
                                                .filter(item => !item.url.includes('/media/answers/'))
                                                .map((item, idx) => {
                                                return (
                                                    <div key={idx} className="rounded-xl overflow-hidden border border-gray-100 dark:border-slate-800 shadow-sm bg-white dark:bg-slate-900 max-w-sm transition-colors">
                                                        {item.type.startsWith('image/') ? (
                                                            <div className="relative group cursor-pointer" onClick={() => setPreviewImageUrl(getMediaUrl(item.url))}>
                                                                <img 
                                                                    src={getMediaUrl(item.url)} 
                                                                    alt="Stimulus" 
                                                                    className="w-full h-auto max-h-64 object-contain bg-gray-50"
                                                                />
                                                                <div className="absolute inset-0 bg-black/5 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                                                    <div className="bg-white/90 p-2 rounded-full shadow-lg text-blue-600">
                                                                        <Eye size={20} />
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        ) : item.type.startsWith('video/') ? (
                                                            <div className="p-1 bg-black rounded-lg">
                                                                <video src={getMediaUrl(item.url)} controls className="w-full max-h-64 rounded" />
                                                            </div>
                                                        ) : item.type.startsWith('audio/') ? (
                                                            <div className="p-4 bg-gray-50 dark:bg-slate-800 border-t border-gray-100 dark:border-slate-700 italic flex flex-col gap-2 transition-colors">
                                                                <span className="text-[10px] font-bold text-gray-400 dark:text-slate-500 uppercase tracking-widest">Audio Content</span>
                                                                <audio src={getMediaUrl(item.url)} controls className="w-full" />
                                                            </div>
                                                        ) : (
                                                            <div className="p-4 flex items-center gap-3 bg-white dark:bg-slate-900 transition-colors">
                                                                <div className="w-10 h-10 rounded-lg bg-blue-50 dark:bg-blue-900/20 flex items-center justify-center text-blue-600 dark:text-blue-400">
                                                                    <Eye size={20} />
                                                                </div>
                                                                <div className="flex-1 overflow-hidden">
                                                                    <div className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider mb-1 line-clamp-1">Other Attachment</div>
                                                                    <a 
                                                                        href={getMediaUrl(item.url)} 
                                                                        target="_blank" 
                                                                        rel="noreferrer"
                                                                        className="text-sm font-medium text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 underline truncate block"
                                                                    >
                                                                        Download File
                                                                    </a>
                                                                </div>
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
                            <section className="bg-white dark:bg-slate-900 p-8 rounded-2xl border border-gray-200 dark:border-slate-800 shadow-sm transition-colors">
                                <h2 className="text-xs uppercase tracking-widest font-bold text-gray-400 dark:text-slate-500 mb-6">Structured Content</h2>
                                {renderData()}
                            </section>

                            {/* Explanation Section */}
                            {question.explanation && (
                                <section className="bg-blue-50/50 dark:bg-blue-900/10 p-8 rounded-2xl border border-blue-100 dark:border-blue-800/50 transition-colors">
                                    <h2 className="text-xs uppercase tracking-widest font-bold text-blue-400 dark:text-blue-500 mb-4">Explanation</h2>
                                    <div className="text-blue-900 dark:text-blue-300 leading-relaxed italic">
                                        {question.explanation}
                                    </div>
                                </section>
                            )}
                        </div>

                        {/* Sidebar / Meta Info */}
                        <div className="space-y-6">
                            <div className="bg-white dark:bg-slate-900 p-6 rounded-2xl border border-gray-200 dark:border-slate-800 shadow-sm transition-colors">
                                <h3 className="text-sm font-bold text-gray-800 dark:text-slate-200 mb-4 border-b dark:border-slate-800 pb-2">Properties</h3>
                                <div className="space-y-4">
                                    <div>
                                        <label className="text-xs text-gray-400 dark:text-slate-500 block mb-1">SKILL</label>
                                        <span className="text-sm font-semibold text-gray-700 dark:text-slate-300 bg-gray-100 dark:bg-slate-800 px-2 py-1 rounded">{question.skill}</span>
                                    </div>
                                    <div>
                                        <label className="text-xs text-gray-400 dark:text-slate-500 block mb-1">TYPE</label>
                                        <span className="text-sm font-semibold text-gray-700 dark:text-slate-300 bg-gray-100 dark:bg-slate-800 px-2 py-1 rounded">{question.type}</span>
                                    </div>
                                    <div>
                                        <label className="text-xs text-gray-400 dark:text-slate-500 block mb-1">DIFFICULTY</label>
                                        <span className="text-sm font-semibold text-gray-700 dark:text-slate-300 bg-gray-100 dark:bg-slate-800 px-2 py-1 rounded">Level {question.difficultyBand.replace('BAND_', '')}</span>
                                    </div>
                                    <div>
                                        <label className="text-xs text-gray-400 dark:text-slate-500 block mb-1">CONTENT ACCESS</label>
                                        <span className={`text-sm font-bold ${question.isPremiumContent ? 'text-amber-600 dark:text-amber-500' : 'text-blue-600 dark:text-blue-400'}`}>
                                            {question.isPremiumContent ? '★ PREMIUM (PRO ONLY)' : '✓ FREE CONTENT'}
                                        </span>
                                    </div>

                                    {/* Tag Section */}
                                    <div className="pt-2 border-t dark:border-slate-800">
                                        <div className="flex items-center justify-between mb-2">
                                            <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider flex items-center gap-1">
                                                <TagIcon size={12} /> Tags
                                            </label>
                                            <button 
                                                onClick={() => setIsAddingTag(!isAddingTag)}
                                                className="text-blue-600 hover:text-blue-700 p-1 rounded-md hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-colors"
                                            >
                                                {isAddingTag ? <X size={14} /> : <Plus size={14} />}
                                            </button>
                                        </div>

                                        <div className="flex flex-wrap gap-2 mb-3">
                                            {question.tags && question.tags.length > 0 ? (
                                                question.tags.map((tag) => (
                                                    <span 
                                                        key={tag.id} 
                                                        className="group flex items-center gap-1 px-2 py-1 bg-gray-100 dark:bg-slate-800 text-gray-700 dark:text-slate-300 rounded text-[10px] font-medium border border-gray-200 dark:border-slate-700 transition-all hover:border-red-200 dark:hover:border-red-900/50"
                                                    >
                                                        <span className="opacity-50 font-bold uppercase mr-1">{tag.namespace}:</span>
                                                        {tag.name}
                                                        <button 
                                                            onClick={() => handleRemoveTag(tag.id)}
                                                            className="opacity-0 group-hover:opacity-100 text-gray-400 hover:text-red-500 transition-opacity"
                                                        >
                                                            <X size={10} />
                                                        </button>
                                                    </span>
                                                ))
                                            ) : (
                                                <span className="text-[10px] text-gray-400 italic">No tags applied</span>
                                            )}
                                        </div>

                                        {isAddingTag && (
                                            <div className="space-y-2 animate-in fade-in slide-in-from-top-1 duration-200">
                                                <div className="relative">
                                                    <input 
                                                        type="text"
                                                        placeholder="Namespace:Name or Name"
                                                        className="w-full bg-gray-50 dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg py-2 px-3 text-xs outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all"
                                                        value={newTagStr}
                                                        onChange={(e) => setNewTagStr(e.target.value)}
                                                        onKeyDown={(e) => e.key === 'Enter' && handleAddTag()}
                                                        autoFocus
                                                    />
                                                    {newTagStr && (
                                                        <div className="absolute top-full left-0 w-full mt-1 bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg shadow-xl z-50 max-h-32 overflow-y-auto">
                                                            {allTags
                                                                .filter(t => `${t.namespace}:${t.name}`.toLowerCase().includes(newTagStr.toLowerCase()))
                                                                .map(t => (
                                                                    <button 
                                                                        key={t.id}
                                                                        onClick={() => {
                                                                            setNewTagStr(`${t.namespace}:${t.name}`);
                                                                            handleAddTag(`${t.namespace}:${t.name}`);
                                                                        }}
                                                                        className="w-full text-left px-3 py-1.5 text-[10px] hover:bg-blue-50 dark:hover:bg-blue-900/20 text-gray-600 dark:text-slate-400 border-b border-gray-100 dark:border-slate-700 last:border-none"
                                                                    >
                                                                        <span className="font-bold opacity-50 uppercase">{t.namespace}:</span> {t.name}
                                                                    </button>
                                                                ))
                                                            }
                                                        </div>
                                                    )}
                                                </div>
                                                <button 
                                                    onClick={() => handleAddTag()}
                                                    className="w-full py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-xs font-bold transition-all"
                                                >
                                                    Add Tag
                                                </button>
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>

                            <div className="bg-gray-50 dark:bg-slate-800/40 p-6 rounded-2xl border border-gray-200 dark:border-slate-800 transition-colors">
                                 <p className="text-xs text-gray-500 dark:text-slate-400 leading-relaxed text-center">
                                     Ready to modify this question? Click the edit button at the top of the page to enter builder mode.
                                 </p>
                            </div>

                            {/* History Section */}
                            <div className="bg-white dark:bg-slate-900 p-6 rounded-2xl border border-gray-200 dark:border-slate-800 shadow-sm overflow-hidden transition-colors">
                                <div className="flex items-center justify-between mb-4 border-b dark:border-slate-800 pb-2">
                                    <h3 className="text-sm font-bold text-gray-800 dark:text-slate-200 flex items-center gap-2">
                                        <HistoryIcon size={16} className="text-indigo-600 dark:text-indigo-400" />
                                        Edit History
                                    </h3>
                                    <button 
                                        onClick={() => setIsHistoryModalOpen(true)}
                                        className="text-[10px] font-bold text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300 uppercase tracking-wider"
                                    >
                                        View All
                                    </button>
                                </div>

                                <div className="space-y-4">
                                    {histories.length === 0 ? (
                                        <p className="text-xs text-gray-400 dark:text-slate-500 italic py-2 text-center">No history records yet.</p>
                                    ) : (
                                        histories.slice(0, 3).map((h) => (
                                            <div key={h.id} className="flex gap-3 leading-tight group">
                                                <div className="mt-0.5 p-1 bg-gray-50 dark:bg-slate-800 rounded-full border border-gray-100 dark:border-slate-700 group-hover:bg-indigo-50 dark:group-hover:bg-indigo-900/30 group-hover:border-indigo-100 dark:group-hover:border-indigo-800 transition-colors">
                                                    <User size={10} className="text-gray-400 group-hover:text-indigo-500 dark:group-hover:text-indigo-400" />
                                                </div>
                                                <div className="flex-1 min-w-0">
                                                    <p className="text-xs font-semibold text-gray-800 truncate" title={h.editorEmail}>
                                                        {h.editorEmail}
                                                    </p>
                                                    <div className="flex items-center justify-between mt-1">
                                                        <span className="text-[10px] text-gray-400 flex items-center gap-1">
                                                            <Clock size={8} />
                                                            {new Date(h.createdAt).toLocaleDateString()}
                                                        </span>
                                                        <span className={`text-[8px] font-bold px-1.5 py-0.5 rounded ${
                                                            h.action === 'CREATED' ? 'bg-emerald-50 text-emerald-600' : 'bg-blue-50 text-blue-600'
                                                        }`}>
                                                            {h.action}
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        ))
                                    )}
                                    
                                    {histories.length > 3 && (
                                        <button 
                                            onClick={() => setIsHistoryModalOpen(true)}
                                            className="w-full mt-2 py-2 text-[10px] font-medium text-gray-400 dark:text-slate-500 hover:text-indigo-600 dark:hover:text-indigo-400 border-t border-dashed dark:border-slate-800 flex items-center justify-center gap-1 transition-colors"
                                        >
                                            + {histories.length - 3} more entries <ChevronRight size={10} />
                                        </button>
                                    )}
                                </div>
                            </div>
                        </div>
                    </div>
                )}
            </div>

            <QuestionHistoryModal 
                isOpen={isHistoryModalOpen}
                onClose={() => setIsHistoryModalOpen(false)}
                questionId={question.id}
            />

            {/* Full Size Image Preview Modal */}
            {previewImageUrl && (
                <div 
                    className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/70 backdrop-blur-md p-4 animate-in fade-in duration-200"
                    onClick={() => setPreviewImageUrl(null)}
                >
                    <div className="relative max-w-4xl max-h-[90vh] bg-white dark:bg-slate-900 rounded-xl p-2 shadow-2xl scale-in border border-transparent dark:border-slate-800" onClick={(e) => e.stopPropagation()}>
                        <button 
                            onClick={() => setPreviewImageUrl(null)}
                            className="absolute -top-4 -right-4 bg-white dark:bg-slate-800 text-gray-800 dark:text-slate-200 rounded-full p-2 shadow-lg hover:bg-gray-100 dark:hover:bg-slate-700 transition-colors border dark:border-slate-700"
                        >
                            <X size={20} />
                        </button>
                        <img 
                            src={previewImageUrl} 
                            alt="Full Size Preview" 
                            className="max-w-full max-h-[85vh] object-contain rounded-lg"
                        />
                    </div>
                </div>
            )}
        </Layout>
    );
};
