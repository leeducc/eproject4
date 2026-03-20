import React, { useEffect, useState } from 'react';
import { X, History as HistoryIcon, User, Clock, FileJson, Edit as EditIcon, RotateCcw } from 'lucide-react';
import { useVocabularyStore } from '../store';
import { VocabularyHistory } from '../types';
import { toast, ConfirmDialog } from '@english-learning/ui';

interface VocabularyHistoryModalProps {
    isOpen: boolean;
    onClose: () => void;
    vocabularyId: number;
}

export const VocabularyHistoryModal: React.FC<VocabularyHistoryModalProps> = ({
    isOpen,
    onClose,
    vocabularyId
}) => {
    const [histories, setHistories] = useState<VocabularyHistory[]>([]);
    const [error, setError] = useState<string | null>(null);
    const [selectedSnapshot, setSelectedSnapshot] = useState<string | null>(null);
    const [rollbackId, setRollbackId] = useState<number | null>(null);

    const { fetchWordHistory, rollbackWordToVersion, isLoading } = useVocabularyStore();

    useEffect(() => {
        if (isOpen && vocabularyId) {
            const loadHistory = async () => {
                try {
                    const data = await fetchWordHistory(vocabularyId);
                    setHistories(data);
                } catch (err: any) {
                    setError(err.message || 'Failed to load history');
                }
            };
            loadHistory();
        }
    }, [isOpen, vocabularyId, fetchWordHistory]);

    if (!isOpen) return null;

    return (
        <>
            <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md" onClick={onClose}>
                <div 
                    className="bg-white dark:bg-slate-900 rounded-xl shadow-2xl max-w-2xl w-full overflow-hidden border dark:border-slate-800"
                    onClick={(e) => e.stopPropagation()}
                >
                    <div className="relative p-6">
                        <button onClick={onClose} className="absolute top-4 right-4 text-gray-400 hover:text-gray-600">
                            <X size={20} />
                        </button>

                        <div className="flex items-center gap-3 mb-6">
                            <div className="p-2 bg-indigo-100 dark:bg-indigo-900/30 text-indigo-600 dark:text-indigo-400 rounded-lg">
                                <HistoryIcon size={24} />
                            </div>
                            <h3 className="text-xl font-bold dark:text-slate-100">Vocabulary Edit History</h3>
                        </div>

                        <div className="mt-4 max-h-[60vh] overflow-y-auto pr-2">
                            {isLoading && histories.length === 0 && (
                                <div className="flex justify-center py-8">
                                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
                                </div>
                            )}

                            {!isLoading && histories.length === 0 && (
                                <div className="text-center py-8 text-gray-500">No history found.</div>
                            )}

                            <div className="space-y-4">
                                {histories.map((h) => (
                                    <div key={h.id} className="p-4 rounded-xl border dark:border-slate-800 bg-gray-50/50 dark:bg-slate-800/30 hover:bg-gray-50 dark:hover:bg-slate-800/50 transition-colors">
                                        <div className="flex items-start justify-between">
                                            <div className="flex gap-3">
                                                <div className="mt-1 p-1.5 bg-white dark:bg-slate-900 rounded-full border dark:border-slate-700 shadow-sm">
                                                    <User size={14} className="text-gray-400" />
                                                </div>
                                                <div>
                                                    <p className="text-sm font-semibold dark:text-slate-200">
                                                        Editor: {h.editorName || `ID ${h.editorId}`}
                                                    </p>
                                                    <div className="flex items-center gap-2 mt-1 text-xs text-gray-500">
                                                        <Clock size={12} />
                                                        <span>{new Date(h.createdAt).toLocaleString()}</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider ${
                                                h.action === 'CREATED' ? 'bg-emerald-100 text-emerald-700' : 'bg-blue-100 text-blue-700'
                                            }`}>
                                                {h.action}
                                            </span>
                                        </div>

                                        {h.changes && (
                                            <div className="mt-3 p-3 bg-indigo-50/50 dark:bg-indigo-950/20 rounded-lg border border-indigo-100/50">
                                                <p className="text-[10px] font-bold text-indigo-400 uppercase tracking-widest mb-2 flex items-center gap-1.5">
                                                    <EditIcon size={12} /> Changes
                                                </p>
                                                <div className="space-y-1 text-xs">
                                                    {(() => {
                                                        try {
                                                            const changes = JSON.parse(h.changes!);
                                                            return Object.entries(changes).map(([k, v]: [string, any]) => (
                                                                <div key={k} className="flex gap-2">
                                                                    <span className="text-gray-500">{k}:</span>
                                                                    <span className="text-red-400 line-through">{v.from}</span>
                                                                    <span className="text-emerald-400">{v.to}</span>
                                                                </div>
                                                            ));
                                                        } catch (e) { return null; }
                                                    })()}
                                                </div>
                                            </div>
                                        )}
                                        
                                        <div className="mt-3 flex justify-end gap-2 text-xs font-medium">
                                            <button onClick={() => setRollbackId(h.id)} className="text-orange-500 hover:text-orange-600 flex items-center gap-1">
                                                <RotateCcw size={14} /> Rollback
                                            </button>
                                            <button onClick={() => setSelectedSnapshot(h.snapshot)} className="text-indigo-500 hover:text-indigo-600 flex items-center gap-1">
                                                <FileJson size={14} /> View
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {selectedSnapshot && (
                <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm" onClick={() => setSelectedSnapshot(null)}>
                    <div className="bg-white dark:bg-slate-900 rounded-xl max-w-2xl w-full max-h-[80vh] overflow-auto p-6 shadow-2xl" onClick={(e) => e.stopPropagation()}>
                        <pre className="text-xs text-gray-700 dark:text-slate-300 font-mono bg-gray-50 dark:bg-slate-950 p-4 rounded-lg overflow-x-auto">
                            {JSON.stringify(JSON.parse(selectedSnapshot), null, 2)}
                        </pre>
                    </div>
                </div>
            )}

            <ConfirmDialog 
                isOpen={rollbackId !== null}
                onClose={() => setRollbackId(null)}
                onConfirm={async () => {
                    if (rollbackId) {
                        try {
                            await rollbackWordToVersion(rollbackId);
                            toast.success('Vocabulary rolled back successfully');
                            onClose();
                        } catch (err) {
                            toast.error('Failed to rollback');
                        }
                    }
                }}
                title="Confirm Rollback"
                message="Are you sure you want to restore the vocabulary to this version? This action will overwrite the current data."
                confirmText="Rollback"
            />
        </>
    );
};
