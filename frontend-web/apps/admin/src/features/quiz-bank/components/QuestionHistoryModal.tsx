import React, { useEffect, useState } from 'react';
import { X, History as HistoryIcon, User, Clock, FileJson, Edit as EditIcon, RotateCcw } from 'lucide-react';
import { useQuizBankStore } from '../store';
import { QuestionHistory } from '../types';
import { toast, ConfirmDialog } from '@english-learning/ui';

interface QuestionHistoryModalProps {
    isOpen: boolean;
    onClose: () => void;
    questionId: number;
}

export const QuestionHistoryModal: React.FC<QuestionHistoryModalProps> = ({
    isOpen,
    onClose,
    questionId
}) => {
    const [histories, setHistories] = useState<QuestionHistory[]>([]);
    const [error, setError] = useState<string | null>(null);
    const [selectedSnapshot, setSelectedSnapshot] = useState<string | null>(null);
    const [rollbackId, setRollbackId] = useState<number | null>(null);

    const { fetchQuestionHistory, fetchQuestionById, rollbackToVersion, isLoading, currentUser } = useQuizBankStore();
    const isTeacher = currentUser.role === 'TEACHER';

    useEffect(() => {
        if (isOpen && questionId) {
            const loadHistory = async () => {
                try {
                    const data = await fetchQuestionHistory(questionId);
                    setHistories(data);
                } catch (err: any) {
                    setError(err.message || 'Failed to load history');
                }
            };
            loadHistory();
        }
    }, [isOpen, questionId, fetchQuestionHistory]);

    if (!isOpen) return null;

    return (
        <>
            <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-in fade-in duration-200" onClick={onClose}>
                <div 
                    className="bg-white dark:bg-slate-900 rounded-xl shadow-2xl max-w-2xl w-full overflow-hidden animate-in zoom-in-95 duration-200 border border-transparent dark:border-slate-800"
                    onClick={(e) => e.stopPropagation()}
                >
                    <div className="relative p-6">
                        <button 
                            onClick={onClose}
                            className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 transition-colors"
                        >
                            <X size={20} />
                        </button>

                        <div className="flex items-center gap-3 mb-6">
                            <div className="p-2 bg-indigo-100 dark:bg-indigo-900/30 text-indigo-600 dark:text-indigo-400 rounded-lg">
                                <HistoryIcon size={24} />
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 dark:text-slate-100">Question Edit History</h3>
                        </div>

                        <div className="mt-4 max-h-[60vh] overflow-y-auto pr-2">
                            {isLoading && histories.length === 0 && (
                                <div className="flex justify-center py-8">
                                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
                                </div>
                            )}

                            {error && (
                                <div className="p-4 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 rounded-lg border border-red-100 dark:border-red-800/50">
                                    {error}
                                </div>
                            )}

                            {!isLoading && histories.length === 0 && !error && (
                                <div className="text-center py-8 text-gray-500 dark:text-slate-400">
                                    No history records found for this question.
                                </div>
                            )}

                            <div className="space-y-4">
                                {histories.map((history) => (
                                    <div key={history.id} className="p-4 rounded-xl border border-gray-100 dark:border-slate-800 bg-gray-50/50 dark:bg-slate-800/30 hover:bg-gray-50 dark:hover:bg-slate-800/50 transition-colors">
                                        <div className="flex items-start justify-between">
                                            <div className="flex gap-3">
                                                <div className="mt-1 p-1.5 bg-white dark:bg-slate-900 rounded-full border border-gray-100 dark:border-slate-700 shadow-sm">
                                                    <User size={14} className="text-gray-400" />
                                                </div>
                                                <div>
                                                    <p className="text-sm font-semibold text-gray-900 dark:text-slate-200">{history.editorEmail}</p>
                                                    <div className="flex items-center gap-2 mt-1 text-xs text-gray-500 dark:text-slate-400">
                                                        <Clock size={12} />
                                                        <span>{new Date(history.createdAt).toLocaleString()}</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider ${
                                                history.action === 'CREATED' 
                                                    ? 'bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400' 
                                                    : 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400'
                                            }`}>
                                                {history.action}
                                            </span>
                                        </div>

                                        {}
                                        {history.changes && (
                                            <div className="mt-4 p-4 bg-indigo-50/50 dark:bg-indigo-950/20 rounded-xl border border-indigo-100/50 dark:border-indigo-800/30">
                                                <p className="text-[10px] font-bold text-indigo-400 dark:text-indigo-500 uppercase tracking-widest mb-3 flex items-center gap-1.5">
                                                    <EditIcon size={12} /> Specific Changes
                                                </p>
                                                <div className="space-y-3">
                                                    {(() => {
                                                        try {
                                                            const changes = JSON.parse(history.changes!);
                                                            return Object.entries(changes).map(([key, value]: [string, any]) => (
                                                                <div key={key} className="space-y-1.5 text-[11px]">
                                                                    <span className="font-bold text-gray-700 dark:text-slate-300 capitalize flex items-center gap-1">
                                                                        <div className="w-1 h-1 bg-indigo-400 dark:bg-indigo-600 rounded-full" />
                                                                        {key.replace(/([A-Z])/g, ' $1')}
                                                                    </span>
                                                                    <div className="grid grid-cols-2 gap-2 pl-2">
                                                                        <div className="p-2 bg-red-50/50 dark:bg-red-950/20 rounded-lg border border-red-100/30 dark:border-red-900/30 text-red-700 dark:text-red-400 italic opacity-70" title={value.from}>
                                                                            {typeof value.from === 'object' ? 'Config Content' : value.from || '(empty)'}
                                                                        </div>
                                                                        <div className="p-2 bg-emerald-50/50 dark:bg-emerald-950/20 rounded-lg border border-emerald-100/30 dark:border-emerald-900/30 text-emerald-800 dark:text-emerald-400 font-medium" title={value.to}>
                                                                            {typeof value.to === 'object' ? 'Config Content' : value.to || '(empty)'}
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            ));
                                                        } catch (e) {
                                                            return <p className="text-xs text-gray-400 italic">Could not read change details.</p>;
                                                        }
                                                    })()}
                                                </div>
                                            </div>
                                        )}
                                        
                                        <div className="mt-3 flex justify-end gap-2">
                                            {!isTeacher && (
                                                <button 
                                                    onClick={() => setRollbackId(history.id)}
                                                    className="flex items-center gap-1.5 text-xs text-orange-600 hover:text-orange-700 font-medium transition-colors"
                                                >
                                                    <div className="flex items-center gap-1.5">
                                                        <RotateCcw size={14} />
                                                        Rollback to this version
                                                    </div>
                                                </button>
                                            )}
                                            <button 
                                                onClick={() => setSelectedSnapshot(history.snapshot)}
                                                className="flex items-center gap-1.5 text-xs text-indigo-600 hover:text-indigo-700 font-medium transition-colors"
                                            >
                                                <FileJson size={14} />
                                                View Data Snapshot
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>

                        <div className="mt-8 flex justify-end">
                            <button
                                onClick={onClose}
                                className="px-6 py-2 bg-gray-900 dark:bg-slate-100 text-white dark:text-slate-900 font-semibold rounded-lg hover:bg-gray-800 dark:hover:bg-white transition-colors shadow-sm"
                            >
                                Close
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            {}
            {selectedSnapshot && (
                <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200" onClick={() => setSelectedSnapshot(null)}>
                    <div 
                        className="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] flex flex-col overflow-hidden animate-in zoom-in-95 duration-200"
                        onClick={(e) => e.stopPropagation()}
                    >
                        <div className="p-6 border-b border-gray-100 dark:border-slate-800 flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <div className="p-2 bg-indigo-100 dark:bg-indigo-900/30 text-indigo-600 dark:text-indigo-400 rounded-lg">
                                    <FileJson size={20} />
                                </div>
                                <h4 className="text-lg font-bold text-gray-900 dark:text-slate-100">Data Snapshot Details</h4>
                            </div>
                            <button 
                                onClick={() => setSelectedSnapshot(null)}
                                className="text-gray-400 hover:text-gray-600 dark:hover:text-slate-300 transition-colors"
                            >
                                <X size={20} />
                            </button>
                        </div>
                        <div className="flex-1 overflow-auto p-6 bg-gray-50 dark:bg-slate-950">
                            <pre className="text-[11px] leading-relaxed text-gray-700 dark:text-slate-300 font-mono p-4 bg-white dark:bg-slate-900 rounded-lg border border-gray-200 dark:border-slate-800 overflow-x-auto shadow-inner">
                                {JSON.stringify(JSON.parse(selectedSnapshot), null, 4)}
                            </pre>
                        </div>
                        <div className="p-4 border-t border-gray-100 dark:border-slate-800 flex justify-end bg-gray-50/50 dark:bg-slate-900/50">
                            <button
                                onClick={() => setSelectedSnapshot(null)}
                                className="px-5 py-2 bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 text-gray-700 dark:text-slate-200 font-semibold rounded-lg hover:bg-gray-50 dark:hover:bg-slate-700 transition-colors shadow-sm"
                            >
                                Done
                            </button>
                        </div>
                    </div>
                </div>
            )}

            <ConfirmDialog 
                isOpen={rollbackId !== null}
                onClose={() => setRollbackId(null)}
                onConfirm={async () => {
                    if (rollbackId) {
                        try {
                            await rollbackToVersion(rollbackId);
                            toast.success('Question rolled back successfully');
                            
                            await fetchQuestionById(questionId);
                            const updatedHistory = await fetchQuestionHistory(questionId);
                            setHistories(updatedHistory);
                            setRollbackId(null);
                        } catch (err) {
                            toast.error('Failed to rollback question');
                        }
                    }
                }}
                title="Confirm Rollback"
                message="Are you sure you want to restore the question to this version? The current version will be overwritten, and a new 'ROLLBACK' entry will be added to the history."
                confirmText="Rollback"
                variant="warning"
            />
        </>
    );
};
