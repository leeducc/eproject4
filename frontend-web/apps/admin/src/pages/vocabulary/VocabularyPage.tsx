import React, { useState, useEffect } from 'react';
import { useVocabularyStore } from '../../features/vocabulary/store';
import { ConfirmDialog, toast } from '@english-learning/ui';
import { Plus, Search, Filter, Eye, Trash2, ChevronLeft, ChevronRight, RefreshCw, FileUp, Download } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { AdminLayout } from '../../components/AdminLayout';
import { VocabularyHistoryModal } from '../../features/vocabulary/components/VocabularyHistoryModal';

export const VocabularyPage: React.FC = () => {
  const navigate = useNavigate();
  const { 
    items, 
    isLoading, 
    fetchVocabularyPaginated, 
    deleteWord,
    importVocabulary,
    downloadSampleExcel
  } = useVocabularyStore();

  const [filterType, setFilterType] = useState<'words' | 'phrases'>('words');
  const [filterLevel, setFilterLevel] = useState<string>('');
  const [searchTerm, setSearchTerm] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [pageSize, setPageSize] = useState<number>(10);
  
  const [currentCursor, setCurrentCursor] = useState<number | null>(null);
  const [cursorStack, setCursorStack] = useState<(number | null)[]>([]);
  const fileInputRef = React.useRef<HTMLInputElement>(null);
  
  const handleImport = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      const result = await importVocabulary(file);
      toast.success(result.message);
      fetchVocabularyPaginated({ limit: pageSize });
    } catch (err) {
      toast.error("Failed to import vocabulary.");
    } finally {
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  const handleDownloadSample = async () => {
    try {
      await downloadSampleExcel();
      toast.success("Sample file downloaded.");
    } catch (err) {
      toast.error("Failed to download sample file.");
    }
  };

  // Initial load
  const [hasMore, setHasMore] = useState(false);
  const [nextCursor, setNextCursor] = useState<number | null>(null);

  const [wordToDelete, setWordToDelete] = useState<number | null>(null);
  const [historyWordId, setHistoryWordId] = useState<number | null>(null);

  // Debounce search
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(searchTerm);
    }, 500);
    return () => clearTimeout(timer);
  }, [searchTerm]);

  // Reset pagination on filter change
  useEffect(() => {
    setCurrentCursor(null);
    setCursorStack([]);
    loadData(null);
  }, [filterType, filterLevel, pageSize, debouncedSearch]);

  const loadData = async (cursor: number | null) => {
    try {
      const res = await fetchVocabularyPaginated({
        type: filterType,
        levelGroup: filterLevel || undefined,
        search: debouncedSearch || undefined,
        limit: pageSize,
        lastSeenId: cursor
      });
      setHasMore(res.hasMore);
      setNextCursor(res.nextCursor);
    } catch (err) {
      toast.error("Failed to load vocabulary");
    }
  };

  const handleNext = async () => {
    if (nextCursor) {
      setCursorStack([...cursorStack, currentCursor]);
      setCurrentCursor(nextCursor);
      await loadData(nextCursor);
    }
  };

  const handlePrev = async () => {
    if (cursorStack.length > 0) {
      const prevCursor = cursorStack[cursorStack.length - 1];
      const newStack = cursorStack.slice(0, -1);
      setCursorStack(newStack);
      setCurrentCursor(prevCursor);
      await loadData(prevCursor);
    }
  };

  const handleDelete = async () => {
    if (wordToDelete) {
      try {
        await deleteWord(wordToDelete);
        toast.success("Word deleted successfully");
        setWordToDelete(null);
      } catch (err) {
        toast.error("Failed to delete word");
      }
    }
  };

  return (
    <AdminLayout>
      <div className="p-8 space-y-6 bg-[#0B0F1A] min-h-screen text-white">
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-4xl font-black uppercase tracking-tighter text-white mb-2">
              Vocabulary <span className="text-blue-500">Management</span>
            </h1>
            <p className="text-gray-400 font-medium">Manage dictionary entries, definitions, and AI practice.</p>
          </div>
          <div className="flex items-center gap-3">
             <input 
              type="file" 
              ref={fileInputRef} 
              onChange={handleImport} 
              accept=".xlsx,.xls" 
              className="hidden" 
            />
            <button 
              onClick={handleDownloadSample}
              className="flex items-center gap-2 px-4 py-2 bg-gray-800 hover:bg-gray-700 text-gray-300 rounded-xl transition-all font-bold text-sm border border-gray-700"
            >
              <Download size={18} />
              Sample
            </button>
            <button 
              onClick={() => fileInputRef.current?.click()}
              className="flex items-center gap-2 px-4 py-2 bg-emerald-600/20 hover:bg-emerald-600/30 text-emerald-400 rounded-xl transition-all font-bold text-sm border border-emerald-600/30"
            >
              <FileUp size={18} />
              Import
            </button>
            <button 
              onClick={() => navigate('/admin/vocabulary/new')}
              className="flex items-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-500 text-white rounded-2xl transition-all font-bold shadow-lg shadow-blue-500/25 active:scale-95"
            >
              <Plus size={20} />
              Add New Entry
            </button>
          </div>
        </div>

        {/* Filters & Search */}
        <div className="flex items-center gap-6 bg-[#151B2B] p-5 rounded-2xl border border-gray-800 shadow-xl backdrop-blur-sm">
          <div className="flex items-center gap-2 text-gray-400 border-r border-gray-700 pr-6 mr-2">
            <Filter size={20} />
            <span className="text-sm font-bold uppercase tracking-widest">Filters</span>
          </div>

          <div className="flex flex-grow gap-6">
            <div className="flex-grow space-y-1.5">
              <label className="text-[10px] font-bold text-gray-500 uppercase ml-1">Search</label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" size={16} />
                <input
                  type="text"
                  placeholder="Search questions..."
                  className="w-full pl-10 pr-4 py-2 bg-[#0B0F1A] border border-gray-700 rounded-xl focus:ring-1 focus:ring-blue-500 outline-none transition-all text-sm"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
            </div>

            <div className="w-48 space-y-1.5">
              <label className="text-[10px] font-bold text-gray-500 uppercase ml-1">Question Type</label>
              <select
                className="w-full px-4 py-2 bg-[#0B0F1A] border border-gray-700 rounded-xl focus:ring-1 focus:ring-blue-500 outline-none transition-all text-sm appearance-none bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2224%22%20height%3D%2224%22%20viewBox%3D%220%200%2024%2024%22%20fill%3D%22none%22%20stroke%3D%22%236b7280%22%20stroke-width%3D%222%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%3E%3Cpolyline%20points%3D%226%209%2012%2015%2018%209%22%3E%3C%2Fpolyline%3E%3C%2Fsvg%3E')] bg-[length:1.25rem] bg-[right_0.75rem_center] bg-no-repeat"
                value={filterType}
                onChange={(e) => setFilterType(e.target.value as any)}
              >
                <option value="words">Words</option>
                <option value="phrases">Phrases</option>
              </select>
            </div>

            <div className="w-48 space-y-1.5">
              <label className="text-[10px] font-bold text-gray-500 uppercase ml-1">Difficulty</label>
              <select
                className="w-full px-4 py-2 bg-[#0B0F1A] border border-gray-700 rounded-xl focus:ring-1 focus:ring-blue-500 outline-none transition-all text-sm appearance-none bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2224%22%20height%3D%2224%22%20viewBox%3D%220%200%2024%2024%22%20fill%3D%22none%22%20stroke%3D%22%236b7280%22%20stroke-width%3D%222%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%3E%3Cpolyline%20points%3D%226%209%2012%2015%2018%209%22%3E%3C%2Fpolyline%3E%3C%2Fsvg%3E')] bg-[length:1.25rem] bg-[right_0.75rem_center] bg-no-repeat"
                value={filterLevel}
                onChange={(e) => setFilterLevel(e.target.value)}
              >
                <option value="">All Levels</option>
                <option value="0-4">Beginner (A1-A2)</option>
                <option value="5-6">Intermediate (B1-B2)</option>
                <option value="7-8">Advanced (C1)</option>
                <option value="9">Mastery (C2)</option>
              </select>
            </div>

            <div className="w-48 space-y-1.5">
              <label className="text-[10px] font-bold text-gray-500 uppercase ml-1">Page Size</label>
              <select
                className="w-full px-4 py-2 bg-[#0B0F1A] border border-gray-700 rounded-xl focus:ring-1 focus:ring-blue-500 outline-none transition-all text-sm appearance-none bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2224%22%20height%3D%2224%22%20viewBox%3D%220%200%2024%2024%22%20fill%3D%22none%22%20stroke%3D%22%236b7280%22%20stroke-width%3D%222%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%3E%3Cpolyline%20points%3D%226%209%2012%2015%2018%209%22%3E%3C%2Fpolyline%3E%3C%2Fsvg%3E')] bg-[length:1.25rem] bg-[right_0.75rem_center] bg-no-repeat"
                value={pageSize}
                onChange={(e) => setPageSize(Number(e.target.value))}
              >
                <option value={10}>10 per page</option>
                <option value={20}>20 per page</option>
                <option value={50}>50 per page</option>
              </select>
            </div>
            
            <button 
              onClick={() => loadData(currentCursor)}
              className="mt-6 p-2 text-gray-400 hover:text-white transition-colors"
            >
              <RefreshCw size={20} className={isLoading ? 'animate-spin' : ''} />
            </button>
          </div>
        </div>

        {/* Table */}
        <div className="bg-[#151B2B] rounded-2xl border border-gray-800 shadow-2xl overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="border-b border-gray-800 bg-[#1A2235]">
                  <th className="px-6 py-4 text-gray-400 font-bold text-[10px] uppercase tracking-wider">WORD / PHRASE</th>
                  <th className="px-6 py-4 text-gray-400 font-bold text-[10px] uppercase tracking-wider text-center">LEVEL</th>
                  <th className="px-6 py-4 text-gray-400 font-bold text-[10px] uppercase tracking-wider">POS</th>
                  <th className="px-6 py-4 text-gray-400 font-bold text-[10px] uppercase tracking-wider">TYPE</th>
                  <th className="px-6 py-4 text-gray-400 font-bold text-[10px] uppercase tracking-wider text-center">ACTIONS</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-800">
                {isLoading ? (
                  <tr>
                    <td colSpan={5} className="px-6 py-8 text-center text-gray-500 italic">
                      Loading data...
                    </td>
                  </tr>
                ) : items.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="px-6 py-8 text-center text-gray-500 italic">
                      No matching records found.
                    </td>
                  </tr>
                ) : (
                  items.map((item) => (
                    <tr key={item.id} className="hover:bg-blue-600/5 transition-colors group">
                      <td className="px-6 py-4">
                        <div className="font-semibold text-lg text-blue-100 group-hover:text-blue-400 transition-colors">
                          {item.word}
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex justify-center">
                          <span className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider ${
                            item.levelGroup === '0-4' ? 'bg-green-500/10 text-green-400 border border-green-500/20' :
                            item.levelGroup === '5-6' ? 'bg-orange-500/10 text-orange-400 border border-orange-500/20' :
                            item.levelGroup === '7-8' ? 'bg-red-500/10 text-red-400 border border-red-500/20' :
                            'bg-purple-500/10 text-purple-400 border border-purple-500/20'
                          }`}>
                            {item.levelGroup}
                          </span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-gray-300 font-medium">{item.pos}</td>
                      <td className="px-6 py-4">
                        <span className="text-gray-400 text-sm italic">{item.type}</span>
                      </td>
                          <td className="px-6 py-4">
                            <div className="flex justify-center gap-4">
                              <button 
                                onClick={() => navigate(`/admin/vocabulary/${item.id}`)}
                                className="p-2 text-blue-400 hover:bg-blue-900/30 rounded-full transition-all border border-transparent hover:border-blue-800"
                                title="View Details"
                              >
                                <Eye size={18} />
                              </button>
                              <button 
                                onClick={() => setWordToDelete(item.id!)}
                                className="p-2 text-red-500 hover:bg-red-900/30 rounded-full transition-all border border-transparent hover:border-red-900"
                                title="Delete"
                              >
                                <Trash2 size={18} />
                              </button>
                            </div>
                          </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination and Modals */}
          <div className="px-6 py-4 bg-[#1A2235] border-t border-gray-800 flex justify-end items-center">
            <div className="flex gap-3">
              <button
                disabled={cursorStack.length === 0 || isLoading}
                onClick={handlePrev}
                className="flex items-center gap-2 px-4 py-2 bg-[#0B0F1A] hover:bg-[#151B2B] disabled:opacity-30 disabled:cursor-not-allowed rounded-xl border border-gray-700 transition-all font-medium"
              >
                <ChevronLeft size={18} /> Prev
              </button>
              <button
                disabled={!hasMore || isLoading}
                onClick={handleNext}
                className="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:opacity-30 disabled:cursor-not-allowed rounded-xl transition-all shadow-lg shadow-blue-900/20 font-medium"
              >
                Next <ChevronRight size={18} />
              </button>
            </div>
          </div>
        </div>

        <ConfirmDialog
          isOpen={wordToDelete !== null}
          onClose={() => setWordToDelete(null)}
          onConfirm={handleDelete}
          title="Delete Word"
          message="Are you sure you want to delete this word? This will remove all associated AI generated practice questions and details as well."
        />

        <VocabularyHistoryModal 
          isOpen={historyWordId !== null}
          onClose={() => setHistoryWordId(null)}
          vocabularyId={historyWordId!}
        />
      </div>
    </AdminLayout>
  );
};
