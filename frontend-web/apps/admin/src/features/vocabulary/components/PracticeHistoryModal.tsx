import React, { useEffect, useState } from 'react';
import { X, History as HistoryIcon, User, Clock, FileJson, RotateCcw } from 'lucide-react';
import { useVocabularyStore } from '../store';
import { PracticeHistory } from '../types';
import { toast, ConfirmDialog } from '@english-learning/ui';

interface PracticeHistoryModalProps {
    isOpen: boolean;
    onClose: () => void;
    practiceId: number;
}

export const PracticeHistoryModal: React.FC<PracticeHistoryModalProps> = ({
    isOpen,
    onClose,
    practiceId
}) => {
    const [histories, setHistories] = useState<PracticeHistory[]>([]);
    const [selectedSnapshot, setSelectedSnapshot] = useState<string | null>(null);
    const [rollbackId, setRollbackId] = useState<number | null>(null);

    const { fetchPracticeHistory, rollbackPracticeToVersion, isLoading } = useVocabularyStore();

    useEffect(() => {
        if (isOpen && practiceId) {
            const loadHistory = async () => {
                try {
                    const data = await fetchPracticeHistory(practiceId);
                    setHistories(data);
                } catch (err: any) {
                    toast.error('Failed to load history');
                }
            };
            loadHistory();
        }
    }, [isOpen, practiceId, fetchPracticeHistory]);

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
                            <h3 className="text-xl font-bold dark:text-slate-100">Practice Question History</h3>
                        </div>

                        <div className="max-h-[60vh] overflow-y-auto pr-2">
                            {isLoading && histories.length === 0 && <div className="text-center py-8">Loading...</div>}
                            
                            {!isLoading && histories.length === 0 && <div className="text-center py-8 text-gray-500">No history found.</div>}

                            <div className="space-y-4">
                                {histories.map((h) => (
                                    <div key={h.id} className="p-4 rounded-xl border dark:border-slate-800 bg-gray-50/50 dark:bg-slate-800/30">
                                        <div className="flex items-start justify-between">
                                            <div className="flex gap-3 text-xs">
                                                <Clock size={14} className="text-gray-400" />
                                                <span className="dark:text-slate-300 font-medium">{new Date(h.createdAt).toLocaleString()}</span>
                                                <span className="text-gray-500">Editor: {h.editorName || `ID ${h.editorId}`}</span>
                                            </div>
                                            <span className="px-2 py-0.5 bg-blue-100 text-blue-700 text-[10px] font-bold rounded uppercase">{h.action}</span>
                                        </div>

                                        <div className="mt-3 flex justify-end gap-2 text-xs font-medium">
                                            <button onClick={() => setRollbackId(h.id)} className="text-orange-500 hover:text-orange-600 flex items-center gap-1">
                                                <RotateCcw size={14} /> Rollback
                                            </button>
                                            <button onClick={() => setSelectedSnapshot(h.snapshot)} className="text-indigo-500 hover:text-indigo-600 flex items-center gap-1">
                                                <FileJson size={14} /> View Snapshot
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
                    <div className="bg-white dark:bg-slate-900 rounded-xl max-w-4xl w-full max-h-[80vh] overflow-auto p-6 shadow-2xl" onClick={(e) => e.stopPropagation()}>
                        <pre className="text-xs text-gray-700 dark:text-slate-300 font-mono bg-gray-50 dark:bg-slate-950 p-4 rounded-lg overflow-x-auto whitespace-pre-wrap">
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
                            await rollbackPracticeToVersion(rollbackId);
                            toast.success('Question rolled back successfully');
                            onClose();
                        } catch (err) {
                            toast.error('Failed to rollback');
                        }
                    }
                }}
                title="Confirm Rollback"
                message="Are you sure you want to restore this question to this version?"
                confirmText="Rollback"
            />
        </>
    );
};
