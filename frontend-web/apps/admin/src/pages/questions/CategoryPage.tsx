import React, { useState, useEffect } from 'react';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { SkillType, Question } from '../../features/quiz-bank/types';
import { ConfirmDialog, toast } from '@english-learning/ui';
import { Plus, Trash2, Edit2, FileText, Eye, ChevronLeft, ChevronRight, Filter, RefreshCcw, Search } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { MultipleChoiceBuilder } from '../../features/quiz-bank/components/MultipleChoiceBuilder';
import { FillInTheBlankBuilder } from '../../features/quiz-bank/components/FillInTheBlankBuilder';
import { MatchingBuilder } from '../../features/quiz-bank/components/MatchingBuilder';
import { WritingBuilder } from '../../features/quiz-bank/components/WritingBuilder';
import { AdminLayout } from '../../components/AdminLayout';

export const CategoryPage: React.FC<{ 
  skill: SkillType, 
  title: string,
  Layout?: React.ComponentType<{ children: React.ReactNode }>
}> = ({ skill, title, Layout = AdminLayout }) => {
  const navigate = useNavigate();
  const { questions, currentUser, deleteQuestion, fetchQuestionsPaginated, isLoading } = useQuizBankStore();
  const [isCreating, setIsCreating] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState<Question | null>(null);
  const [questionToDelete, setQuestionToDelete] = useState<number | null>(null);

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
  }, [filterType, filterDifficulty, pageSize, skill, debouncedSearch]);

  const loadQuestions = async (cursor: number | null, append: boolean) => {
    try {
      const limit = pageSize === 'All' ? 50 : pageSize;
      const res: any = await fetchQuestionsPaginated({
        skill,
        type: filterType || undefined,
        difficulty: filterDifficulty || undefined,
        search: debouncedSearch || undefined,
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
  const [builderType, setBuilderType] = useState<'MULTIPLE_CHOICE' | 'FILL_BLANK' | 'MATCHING' | 'WRITING'>('MULTIPLE_CHOICE');

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
    <Layout>
      <div className="flex flex-col gap-6 max-w-6xl mx-auto py-6">
        
        <div className="flex items-center justify-between">
            <div>
                <h1 className="text-2xl font-bold text-gray-800">{title} Question Bank</h1>
                <p className="text-sm text-gray-500 mt-1">Manage and create {title.toLowerCase()} questions.</p>
            </div>
            {!isCreating && !editingQuestion && (
                <div className="flex items-center gap-3">
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
          <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-sm flex flex-wrap items-center gap-6">
            <div className="flex items-center gap-2">
              <Filter size={16} className="text-gray-400" />
              <span className="text-xs font-bold text-gray-400 uppercase tracking-wider">Filters</span>
            </div>
            
            <div className="flex items-center gap-4 flex-1">
              {/* Search Bar */}
              <div className="relative flex-1 max-w-sm">
                <input 
                  type="text" 
                  placeholder="Search questions..." 
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full bg-gray-50 border border-gray-200 rounded-lg pl-10 pr-4 py-2 text-sm focus:ring-2 focus:ring-blue-100 outline-none transition-all"
                />
                <Search size={16} className="absolute left-3 top-2.5 text-gray-400" />
              </div>

              <div className="flex flex-col gap-1">
                <label className="text-[10px] font-bold text-gray-400 uppercase">Question Type</label>
                <select 
                  value={filterType} 
                  onChange={(e) => setFilterType(e.target.value)}
                  className="bg-gray-50 border border-gray-200 rounded-md px-3 py-1.5 text-sm focus:ring-2 focus:ring-blue-100 outline-none transition-all"
                >
                  <option value="">All Types</option>
                  <option value="MULTIPLE_CHOICE">Multiple Choice</option>
                  <option value="FILL_BLANK">Fill Blank</option>
                  <option value="MATCHING">Matching</option>
                  <option value="ESSAY">Essay</option>
                </select>
              </div>

              <div className="flex flex-col gap-1">
                <label className="text-[10px] font-bold text-gray-400 uppercase">Difficulty</label>
                <select 
                  value={filterDifficulty} 
                  onChange={(e) => setFilterDifficulty(e.target.value)}
                  className="bg-gray-50 border border-gray-200 rounded-md px-3 py-1.5 text-sm focus:ring-2 focus:ring-blue-100 outline-none transition-all"
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
                  className="bg-gray-50 border border-gray-200 rounded-md px-3 py-1.5 text-sm focus:ring-2 focus:ring-blue-100 outline-none transition-all"
                >
                  <option value="10">10 per page</option>
                  <option value="20">20 per page</option>
                  <option value="50">50 per page</option>
                  <option value="All">Infinite Scroll</option>
                </select>
              </div>

              <button 
                onClick={() => {
                  setFilterType('');
                  setFilterDifficulty('');
                  setPageSize(10);
                  setSearchTerm('');
                }}
                className="mt-4 text-xs font-medium text-gray-400 hover:text-blue-600 flex items-center gap-1 transition-colors"
              >
                <RefreshCcw size={12} /> Reset
              </button>
            </div>
          </div>
        )}

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
                        {questions.length === 0 ? (
                            <tr>
                                <td colSpan={5} className="p-8 text-center text-gray-500">
                                    <FileText className="mx-auto h-12 w-12 text-gray-300 mb-3" />
                                    <p>No {title.toLowerCase()} questions found.</p>
                                    <p className="text-sm mt-1">Try adjusting your filters or click "Create Question".</p>
                                </td>
                            </tr>
                        ) : (
                            questions.map((q) => (
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
                
                {/* Standard Pagination Controls */}
                {pageSize !== 'All' && !isCreating && !editingQuestion && (
                    <div className="p-4 bg-gray-50 border-t border-gray-100 flex items-center justify-between font-medium text-xs text-gray-500">
                        <div>
                            Showing <span className="text-gray-900">{questions.length}</span> results
                        </div>
                        <div className="flex items-center gap-2">
                            <button 
                                onClick={handlePrevious}
                                disabled={cursorStack.length === 0 || isLoading}
                                className="px-3 py-1.5 rounded bg-white border shadow-sm flex items-center gap-1 hover:text-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
                            >
                                <ChevronLeft size={14} /> Previous
                            </button>
                            <button 
                                onClick={handleNext}
                                disabled={!hasMore || isLoading}
                                className="px-3 py-1.5 rounded bg-white border shadow-sm flex items-center gap-1 hover:text-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
                            >
                                Next <ChevronRight size={14} />
                            </button>
                        </div>
                    </div>
                )}

                {/* Infinite Scroll Trigger */}
                {pageSize === 'All' && hasMore && (
                    <div ref={observerTarget} className="p-8 flex justify-center border-t border-gray-100">
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
    </Layout>
  );
};
