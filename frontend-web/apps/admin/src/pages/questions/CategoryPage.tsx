import React, { useState, useEffect } from 'react';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { SkillType, Question } from '../../features/quiz-bank/types';
import { ConfirmDialog, toast } from '@english-learning/ui';
import { Download, Upload, FileJson, Plus, Search, Filter, RefreshCcw, Eye, Edit2, Trash2, History as HistoryIcon, ChevronLeft, ChevronRight, User } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { AdminLayout } from '../../components/AdminLayout';
import { MultipleChoiceBuilder } from '../../features/quiz-bank/components/MultipleChoiceBuilder';
import { FillInTheBlankBuilder } from '../../features/quiz-bank/components/FillInTheBlankBuilder';
import { MatchingBuilder } from '../../features/quiz-bank/components/MatchingBuilder';
import { ComprehensionBuilder } from '../../features/quiz-bank/components/ComprehensionBuilder';
import { WritingBuilder } from '../../features/quiz-bank/components/WritingBuilder';
import { QuestionHistoryModal } from '../../features/quiz-bank/components/QuestionHistoryModal';

interface CategoryPageProps {
  skill: SkillType;
  title: string;
  basePath?: string;
  Layout?: React.ComponentType<{ children: React.ReactNode }>;
}

export const CategoryPage: React.FC<CategoryPageProps> = ({ 
  skill, 
  title,
  basePath = '/admin',
  Layout = AdminLayout
}) => {
  const navigate = useNavigate();
  const { 
    questions, 
    currentUser, 
    deleteQuestion, 
    fetchQuestionsPaginated, 
    isLoading,
    importQuestions,
    exportQuestions,
    downloadSampleExcel
  } = useQuizBankStore();
  const [isCreating, setIsCreating] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState<Question | null>(null);
  const [questionToDelete, setQuestionToDelete] = useState<number | null>(null);
  const [questionHistoryId, setQuestionHistoryId] = useState<number | null>(null);

  // Filter & Pagination State
  const [filterType, setFilterType] = useState<string>('');
  const [filterDifficulty, setFilterDifficulty] = useState<string>('');
  const [pageSize, setPageSize] = useState<number | 'All'>(10);
  const [searchTerm, setSearchTerm] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [currentCursor, setCurrentCursor] = useState<number | null>(null);
  const [cursorStack, setCursorStack] = useState<(number | null)[]>([]);
  const [hasMore, setHasMore] = useState(false);
  const [nextCursor, setNextCursor] = useState<number | null>(null);
  const [madeByMeOnly, setMadeByMeOnly] = useState(false);

  // Debounce search term
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(searchTerm);
    }, 500);
    return () => clearTimeout(timer);
  }, [searchTerm]);

  // React to filter changes
  useEffect(() => {
    const triggerFilterUpdate = async () => {
      setCurrentCursor(null);
      setCursorStack([]);
      loadQuestions(null, false);
    };
    triggerFilterUpdate();
  }, [filterType, filterDifficulty, pageSize, skill, debouncedSearch, madeByMeOnly]);

  const loadQuestions = async (cursor: number | null, append: boolean) => {
    try {
      const limit = pageSize === 'All' ? 50 : pageSize;
      const res: any = await fetchQuestionsPaginated({
        skill,
        type: filterType || undefined,
        difficulty: filterDifficulty || undefined,
        search: debouncedSearch || undefined,
        authorId: madeByMeOnly ? currentUser.id : undefined,
        limit,
        lastSeenId: cursor,
        append
      });
      setHasMore(res.hasMore);
      setNextCursor(res.nextCursor);
    } catch (err) {
      toast.error("Failed to load questions");
    }
  };

  const handleNext = async () => {
    if (nextCursor) {
      setCursorStack([...cursorStack, currentCursor]);
      setCurrentCursor(nextCursor);
      await loadQuestions(nextCursor, false);
    }
  };

  const handlePrevious = async () => {
    if (cursorStack.length > 0) {
      const prevCursor = cursorStack[cursorStack.length - 1];
      const newStack = cursorStack.slice(0, -1);
      setCursorStack(newStack);
      setCurrentCursor(prevCursor);
      await loadQuestions(prevCursor, false);
    }
  };

  // Infinite Scroll Observer
  const observerTarget = React.useRef(null);
  useEffect(() => {
    if (pageSize !== 'All' || !hasMore || isLoading) return;

    const observer = new IntersectionObserver(
      entries => {
        if (entries[0].isIntersecting) {
          loadQuestions(nextCursor, true);
        }
      },
      { threshold: 1.0 }
    );

    if (observerTarget.current) {
      observer.observe(observerTarget.current);
    }

    return () => observer.disconnect();
  }, [pageSize, hasMore, nextCursor, isLoading]);
  const isTeacher = currentUser.role === 'TEACHER';
  const [builderType, setBuilderType] = useState<'MULTIPLE_CHOICE' | 'FILL_BLANK' | 'MATCHING' | 'WRITING' | 'COMPREHENSION'>('MULTIPLE_CHOICE');

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

  const fileInputRef = React.useRef<HTMLInputElement>(null);

  const handleImportClick = () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      try {
        await importQuestions(file);
        toast.success("Questions imported successfully");
        // Reload current page
        await loadQuestions(currentCursor, false);
      } catch (error) {
        toast.error("Failed to import questions");
      } finally {
        // Reset input
        if (fileInputRef.current) fileInputRef.current.value = '';
      }
    }
  };

  const handleExportClick = async () => {
    try {
      await exportQuestions();
      toast.success("Questions exported successfully");
    } catch (error) {
      toast.error("Failed to export questions");
    }
  };

  const handleDownloadSample = async () => {
    try {
      await downloadSampleExcel();
      toast.success("Sample template downloaded");
    } catch (error) {
      toast.error("Failed to download sample template");
    }
  };

  const handleAction = (type: 'view' | 'edit' | 'delete', q: Question) => {
    if (type === 'view') {
      if (q.isGroup) navigate(`${basePath}/comprehensions/${q.id}`);
      else navigate(`${basePath}/questions/${q.id}`);
    }
    else if (type === 'edit') {
      if (q.isGroup) {
        navigate(`${basePath}/comprehensions/${q.id}/edit`);
      } else {
        setEditingQuestion(q);
        setBuilderType(q.type as any);
      }
    }
    else if (type === 'delete') setQuestionToDelete(q.id);
  };

  return (
    <Layout>
      <div className="max-w-7xl mx-auto py-8 px-4 h-full flex flex-col min-h-screen">
        
        <div className="flex items-end justify-between">
            <div className="pb-1">
                <h1 className="text-2xl font-bold text-gray-800 dark:text-slate-100">{title} Question Bank</h1>
                <p className="text-sm text-gray-500 dark:text-slate-400 mt-1">Manage and create {title.toLowerCase()} questions.</p>
            </div>
            {!isCreating && !editingQuestion && (
                <div className="flex items-center gap-3">
                    <input 
                      type="file" 
                      ref={fileInputRef} 
                      onChange={handleFileChange} 
                      accept=".xlsx, .xls" 
                      className="hidden" 
                    />
                    {!isTeacher && (
                      <button 
                        onClick={handleExportClick}
                        className="bg-white dark:bg-slate-800 hover:bg-gray-50 dark:hover:bg-slate-700 text-gray-700 dark:text-slate-200 px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 transition-colors border border-gray-200 dark:border-slate-700 shadow-sm"
                        title="Export all questions to Excel"
                      >
                        <Download size={16} /> Export
                      </button>
                    )}
                    {!isTeacher && (
                      <button 
                        onClick={handleImportClick}
                        className="bg-white dark:bg-slate-800 hover:bg-gray-50 dark:hover:bg-slate-700 text-gray-700 dark:text-slate-200 px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 transition-colors border border-gray-200 dark:border-slate-700 shadow-sm"
                        title="Import questions from Excel"
                      >
                        <Upload size={16} /> Import
                      </button>
                    )}
                    {!isTeacher && (
                      <button 
                        onClick={handleDownloadSample}
                        className="bg-white dark:bg-slate-800 hover:bg-gray-50 dark:hover:bg-slate-700 text-gray-700 dark:text-slate-200 px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 transition-colors border border-gray-200 dark:border-slate-700 shadow-sm"
                        title="Download Excel template"
                      >
                        <FileJson size={16} className="text-blue-500" /> Sample
                      </button>
                    )}
                    {isTeacher && (
                      <button 
                        onClick={() => setMadeByMeOnly(!madeByMeOnly)}
                        className={`px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 transition-all border shadow-sm ${madeByMeOnly ? 'bg-blue-600 text-white border-blue-600 hover:bg-blue-700' : 'bg-white dark:bg-slate-800 text-gray-700 dark:text-slate-200 border-gray-200 dark:border-slate-700 hover:text-blue-600 dark:hover:text-blue-400'}`}
                      >
                        <User size={16} /> Made by me
                      </button>
                    )}
                    <button 
                      onClick={() => {
                          setEditingQuestion(null);
                          setIsCreating(true);
                      }}
                      className="bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 transition-colors shadow-sm"
                    >
                      <Plus size={16} /> Create Question
                    </button>
                </div>
            )}
        </div>

        {!isCreating && !editingQuestion && (
          <div className="bg-white dark:bg-slate-900 p-4 rounded-xl border border-gray-200 dark:border-slate-800 shadow-sm flex flex-wrap items-end gap-6 mt-6">
            <div className="flex items-center gap-2 mb-2.5">
              <Filter size={16} className="text-gray-400" />
              <span className="text-xs font-bold text-gray-400 uppercase tracking-wider">Filters</span>
            </div>
            
            <div className="flex items-end gap-4 flex-1">
              {/* Search Bar */}
              <div className="flex flex-col gap-1 flex-1 max-w-sm">
                <label className="text-[10px] font-bold text-gray-400 uppercase">Search</label>
                <div className="relative">
                  <input 
                    type="text" 
                    placeholder="Search questions..." 
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full bg-gray-50 dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg pl-10 pr-4 py-2 text-sm focus:ring-2 focus:ring-blue-100 dark:focus:ring-slate-700 outline-none transition-all text-gray-700 dark:text-slate-200"
                  />
                  <Search size={16} className="absolute left-3 top-2.5 text-gray-400" />
                </div>
              </div>

              <div className="flex flex-col gap-1">
                <label className="text-[10px] font-bold text-gray-400 uppercase">Question Type</label>
                <select 
                  value={filterType} 
                  onChange={(e) => setFilterType(e.target.value)}
                  className="bg-gray-50 dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-md px-3 py-1.5 text-sm focus:ring-2 focus:ring-blue-100 dark:focus:ring-slate-700 outline-none transition-all text-gray-700 dark:text-slate-200"
                >
                  <option value="">All Types</option>
                  {skill === 'WRITING' ? (
                    <option value="ESSAY">Essay</option>
                  ) : (
                    <>
                      <option value="MULTIPLE_CHOICE">Multiple Choice</option>
                      <option value="FILL_BLANK">Fill Blank</option>
                      <option value="MATCHING">Matching</option>
                      <option value="ESSAY">Essay</option>
                      <option value="COMPREHENSION">Comprehension</option>
                    </>
                  )}
                </select>
              </div>

              <div className="flex flex-col gap-1">
                <label className="text-[10px] font-bold text-gray-400 uppercase">Difficulty</label>
                <select 
                  value={filterDifficulty} 
                  onChange={(e) => setFilterDifficulty(e.target.value)}
                  className="bg-gray-50 dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-md px-3 py-1.5 text-sm focus:ring-2 focus:ring-blue-100 dark:focus:ring-slate-700 outline-none transition-all text-gray-700 dark:text-slate-200"
                >
                  <option value="">All Levels</option>
                  <option value="BAND_0_4">Level 0-4</option>
                  <option value="BAND_5_6">Level 5-6</option>
                  <option value="BAND_7_8">Level 7-8</option>
                  <option value="BAND_9">Level 9</option>
                </select>
              </div>

              <div className="flex flex-col gap-1">
                <label className="text-[10px] font-bold text-gray-400 uppercase">Page Size</label>
                <select 
                  value={pageSize.toString()} 
                  onChange={(e) => { 
                    const val = e.target.value === 'All' ? 'All' : parseInt(e.target.value);
                    setPageSize(val as any); 
                  }}
                  className="bg-gray-50 dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-md px-3 py-1.5 text-sm focus:ring-2 focus:ring-blue-100 dark:focus:ring-slate-700 outline-none transition-all text-gray-700 dark:text-slate-200"
                >
                  <option value="10">10 per page</option>
                  <option value="20">20 per page</option>
                  <option value="50">50 per page</option>
                  <option value="All">Infinite Scroll</option>
                </select>
              </div>

              <button 
                onClick={() => {
                  console.log("[CategoryPage] Resetting filters.");
                  setFilterType('');
                  setFilterDifficulty('');
                  setPageSize(10);
                  setSearchTerm('');
                  setMadeByMeOnly(false);
                }}
                className="p-2 text-gray-400 hover:text-blue-600 dark:hover:text-blue-400 hover:bg-gray-100 dark:hover:bg-slate-800 rounded-full transition-all mb-0.5"
                title="Reset Filters"
              >
                <RefreshCcw size={18} />
              </button>
            </div>
          </div>
        )}

        {isCreating || editingQuestion ? (
            <div className="bg-white dark:bg-slate-950 p-6 rounded-xl border border-gray-200 dark:border-slate-800 shadow-sm">
                <div className="flex items-center justify-between mb-6">
                    <h2 className="text-lg font-bold text-gray-800 dark:text-slate-100">{editingQuestion ? `Edit ${title} Question` : `New ${title} Question`}</h2>
                        <button 
                            onClick={() => {
                                setIsCreating(false);
                                setEditingQuestion(null);
                            }}
                            className="text-sm text-gray-500 dark:text-slate-400 hover:text-gray-700 dark:hover:text-slate-200 underline"
                        >
                            Cancel & Return
                        </button>
                </div>

                {skill !== 'WRITING' && !editingQuestion && (
                  <div className="mb-6">
                    <label className="text-sm font-semibold text-gray-700 dark:text-slate-200 block mb-2">Select Builder Mode</label>
                    <div className="flex gap-2">
                        <button onClick={() => setBuilderType('MULTIPLE_CHOICE')} className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${builderType === 'MULTIPLE_CHOICE' ? 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400 border-blue-200 dark:border-blue-800 border' : 'bg-gray-50 dark:bg-slate-800 text-gray-600 dark:text-slate-400 border dark:border-slate-700'}`}>Multiple Choice</button>
                        <button onClick={() => setBuilderType('FILL_BLANK')} className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${builderType === 'FILL_BLANK' ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 border-green-200 dark:border-green-800 border' : 'bg-gray-50 dark:bg-slate-800 text-gray-600 dark:text-slate-400 border dark:border-slate-700'}`}>Fill in the Blanks</button>
                        <button onClick={() => setBuilderType('MATCHING')} className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${builderType === 'MATCHING' ? 'bg-pink-100 dark:bg-pink-900/30 text-pink-700 dark:text-pink-400 border-pink-200 dark:border-pink-800 border' : 'bg-gray-50 dark:bg-slate-800 text-gray-600 dark:text-slate-400 border dark:border-slate-700'}`}>Matching</button>
                        {(skill === 'READING' || skill === 'LISTENING') && (
                          <button onClick={() => setBuilderType('COMPREHENSION')} className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${builderType === 'COMPREHENSION' ? 'bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400 border-purple-200 dark:border-purple-800 border' : 'bg-gray-50 dark:bg-slate-800 text-gray-600 dark:text-slate-400 border dark:border-slate-700'}`}>Comprehension</button>
                        )}
                    </div>
                  </div>
                )}

                <div className="mt-8 border-t dark:border-slate-800 pt-8 border-dashed">
                    {skill === 'WRITING' ? <WritingBuilder initialQuestion={editingQuestion} onSave={() => { setIsCreating(false); setEditingQuestion(null); }} /> : 
                      (editingQuestion ? (editingQuestion.type === 'MULTIPLE_CHOICE' && !editingQuestion.isGroup) : builderType === 'MULTIPLE_CHOICE') ? <MultipleChoiceBuilder skill={skill} initialQuestion={editingQuestion} onSave={() => { setIsCreating(false); setEditingQuestion(null); }} /> :
                      (editingQuestion ? (editingQuestion.type === 'MATCHING' && !editingQuestion.isGroup) : builderType === 'MATCHING') ? <MatchingBuilder skill={skill} initialQuestion={editingQuestion} onSave={() => { setIsCreating(false); setEditingQuestion(null); }} /> :
                      (editingQuestion ? (editingQuestion.type === 'COMPREHENSION' || editingQuestion.isGroup) : builderType === 'COMPREHENSION') ? 
                      <ComprehensionBuilder 
                        skill={skill} 
                        initialGroup={editingQuestion?.isGroup ? {
                          id: editingQuestion.id,
                          title: editingQuestion.instruction || '',
                          content: (editingQuestion.data as any)?.content || '',
                          mediaUrl: editingQuestion.mediaUrls?.[0],
                          mediaType: editingQuestion.mediaTypes?.[0],
                          difficultyBand: editingQuestion.difficultyBand,
                          skill: editingQuestion.skill,
                          questions: (editingQuestion.data as any)?.questions || []
                        } as any : null}
                        onSave={() => { setIsCreating(false); setEditingQuestion(null); }} 
                      /> :
                      <FillInTheBlankBuilder skill={skill} initialQuestion={editingQuestion} onSave={() => { setIsCreating(false); setEditingQuestion(null); }} />
                    }
                </div>
            </div>
        ) : (
            <div className="bg-white dark:bg-slate-900 rounded-xl border border-gray-200 dark:border-slate-800 shadow-sm flex flex-col overflow-hidden flex-grow mt-6">
                <div className="overflow-x-auto flex-grow">
                  <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-gray-50 dark:bg-slate-800/50 border-b border-gray-100 dark:border-slate-800 text-gray-500 dark:text-slate-400 text-xs uppercase tracking-wider">
                            <th className="p-4 font-semibold">ID</th>
                            <th className="p-4 font-semibold">Type</th>
                            <th className="p-4 font-semibold">Prompt / Setup</th>
                            <th className="p-4 font-semibold">Difficulty</th>
                            <th className="p-4 font-semibold text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {questions.length === 0 ? (
                            <tr>
                                <td colSpan={5} className="p-8 text-center text-gray-500">
                                    <FileJson className="mx-auto h-12 w-12 text-gray-300 mb-3" />
                                    <p>No {title.toLowerCase()} questions found.</p>
                                    <p className="text-sm mt-1">Try adjusting your filters or click "Create Question".</p>
                                </td>
                            </tr>
                        ) : (
                            questions.map((q) => (
                                <tr 
                                  key={q.id} 
                                  className={`hover:bg-gray-50/50 dark:hover:bg-slate-800/40 transition-colors relative ${
                                    q.authorId === currentUser.id ? 'bg-orange-100/70 dark:bg-orange-900/30' : ''
                                  }`}
                                >
                                    <td className="p-4 text-sm font-medium text-gray-900 dark:text-slate-200 border-b border-gray-100 dark:border-slate-800">
                                        {q.authorId === currentUser.id && (
                                            <div className="w-1.5 h-full bg-orange-600 rounded-full absolute left-0 top-0" title="Created by you" />
                                        )}
                                        <Link 
                                          to={q.isGroup ? `${basePath}/comprehensions/${q.id}` : `${basePath}/questions/${q.id}`} 
                                          className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
                                        >
                                            #{q.id.toString().slice(-4)}
                                        </Link>
                                    </td>
                                    <td className="p-4 text-sm text-gray-600 dark:text-slate-400 border-b border-gray-100 dark:border-slate-800">
                                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${q.isPremiumContent ? 'bg-amber-100 dark:bg-amber-900/30 text-amber-800 dark:text-amber-400 border border-amber-200 dark:border-amber-800' : 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-400 border border-blue-200 dark:border-blue-800'}`}>
                                            {q.type.replace('_', ' ')}
                                            {q.isPremiumContent && ' (PRO)'}
                                        </span>
                                        {q.isGroup && <span className="ml-2 text-[10px] text-purple-500 font-bold uppercase ring-1 ring-purple-200 dark:ring-purple-900/50 px-1 rounded">Group ({q.childCount})</span>}
                                    </td>
                                    <td className="p-4 text-sm text-gray-800 dark:text-slate-300 border-b border-gray-100 dark:border-slate-800 max-w-xs truncate" title={q.instruction}>
                                        <Link 
                                          to={q.isGroup ? `${basePath}/comprehensions/${q.id}` : `${basePath}/questions/${q.id}`} 
                                          className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors font-medium"
                                        >
                                            {q.instruction || (q.data as any).template || "Open Task"}
                                        </Link>
                                    </td>
                                    <td className="p-4 text-sm text-gray-600 dark:text-slate-400 border-b border-gray-100 dark:border-slate-800">
                                       <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium border border-gray-200 dark:border-slate-700 bg-gray-50 dark:bg-slate-800">
                                            {q.difficultyBand.replace('BAND_', 'Level ')}
                                       </span>
                                    </td>
                                    <td className="p-4 border-b border-gray-100 dark:border-slate-800">
                                        <div className="flex items-center justify-center gap-2">
                                            <button 
                                                onClick={() => handleAction('view', q)}
                                                className="p-1.5 text-gray-400 hover:text-blue-600 dark:hover:text-blue-400 rounded bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 shadow-sm transition-colors"
                                                title="View Details"
                                            >
                                                <Eye size={16} />
                                            </button>
                                            <button 
                                                onClick={() => handleAction('edit', q)}
                                                className="p-1.5 text-gray-400 hover:text-blue-600 dark:hover:text-blue-400 rounded bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 shadow-sm transition-colors"
                                                title="Edit Question"
                                            >
                                                <Edit2 size={16} />
                                            </button>
                                            <button 
                                                onClick={() => setQuestionHistoryId(q.id)}
                                                className="p-1.5 text-gray-400 hover:text-indigo-600 dark:hover:text-indigo-400 rounded bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 shadow-sm transition-colors"
                                                title="View Edit History"
                                            >
                                                <HistoryIcon size={16} />
                                            </button>
                                            {!isTeacher && (
                                                <button 
                                                    onClick={() => handleAction('delete', q)}
                                                    className="p-1.5 text-gray-400 hover:text-red-600 dark:hover:text-red-400 rounded bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 shadow-sm transition-colors"
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
                
                {/* Standard Pagination Controls */}
                {pageSize !== 'All' && !isCreating && !editingQuestion && (
                    <div className="p-4 bg-gray-50 dark:bg-slate-800/50 border-t border-gray-100 dark:border-slate-800 flex items-center justify-between font-medium text-xs text-gray-500 dark:text-slate-400">
                        <div>
                            Showing <span className="text-gray-900 dark:text-slate-200">{questions.length}</span> results
                        </div>
                        <div className="flex items-center gap-2">
                            <button 
                                onClick={handlePrevious}
                                disabled={cursorStack.length === 0 || isLoading}
                                className="px-3 py-1.5 rounded bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 shadow-sm flex items-center gap-1 hover:text-blue-600 dark:hover:text-blue-400 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
                            >
                                <ChevronLeft size={14} /> Previous
                            </button>
                            <button 
                                onClick={handleNext}
                                disabled={!hasMore || isLoading}
                                className="px-3 py-1.5 rounded bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 shadow-sm flex items-center gap-1 hover:text-blue-600 dark:hover:text-blue-400 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
                            >
                                Next <ChevronRight size={14} />
                            </button>
                        </div>
                    </div>
                )}

                {/* Infinite Scroll Trigger */}
                {pageSize === 'All' && hasMore && (
                    <div ref={observerTarget} className="p-8 flex justify-center border-t border-gray-100 dark:border-slate-800">
                        {isLoading ? (
                            <div className="flex items-center gap-2 text-blue-600 font-bold animate-pulse text-sm">
                                <RefreshCcw size={16} className="animate-spin" />
                                Loading more questions...
                            </div>
                        ) : (
                            <div className="w-2 h-2 rounded-full bg-blue-400 animate-ping"></div>
                        )}
                    </div>
                )}
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

      <QuestionHistoryModal 
        isOpen={questionHistoryId !== null}
        onClose={() => setQuestionHistoryId(null)}
        questionId={questionHistoryId || 0}
      />
    </Layout>
  );
};
