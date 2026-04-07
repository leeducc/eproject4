import { useState, useEffect, useRef } from "react";
import { EssaySubmission, IELTSScores, Correction } from "./types";
import { ChevronLeft, Save, Send, AlertCircle, Info, Highlighter, X, Check } from "lucide-react";
import { Button } from "@english-learning/ui";

interface GradingWorkspaceViewProps {
    essay: EssaySubmission;
    onBack: () => void;
    onSave: (id: string, scores: IELTSScores, feedback: string, corrections: Correction[]) => void;
    onSubmit: (id: string, scores: IELTSScores, feedback: string, corrections: Correction[]) => void;
}

export const GradingWorkspaceView: React.FC<GradingWorkspaceViewProps> = ({ essay, onBack, onSave, onSubmit }) => {
    const [scores, setScores] = useState<IELTSScores>(essay.scores || {
        taskAchievement: 0,
        taskAchievementReason: "",
        cohesionCoherence: 0,
        cohesionCoherenceReason: "",
        lexicalResource: 0,
        lexicalResourceReason: "",
        grammaticalRange: 0,
        grammaticalRangeReason: "",
    });
    const [feedback, setFeedback] = useState(essay.feedback || "");
    const [overallBand, setOverallBand] = useState(essay.overallBand || 0);
    const [corrections, setCorrections] = useState<Correction[]>(essay.corrections || []);
    
    
    const [selection, setSelection] = useState<{ start: number; end: number; text: string } | null>(null);
    const [showCorrectionModal, setShowCorrectionModal] = useState(false);
    const [newCorrection, setNewCorrection] = useState({ suggestion: "", note: "" });
    const essayRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        const avg = (scores.taskAchievement + scores.cohesionCoherence + scores.lexicalResource + scores.grammaticalRange) / 4;
        const rounded = Math.round(avg * 2) / 2;
        setOverallBand(rounded);
    }, [scores.taskAchievement, scores.cohesionCoherence, scores.lexicalResource, scores.grammaticalRange]);

    const handleScoreChange = (criterion: keyof IELTSScores, value: number | string) => {
        if (typeof value === "number") {
            setScores(prev => ({ ...prev, [criterion]: value }));
        } else {
            setScores(prev => ({ ...prev, [criterion]: value }));
        }
    };

    const handleTextSelection = () => {
        const selectionObj = window.getSelection();
        if (!selectionObj || selectionObj.isCollapsed) {
            setSelection(null);
            return;
        }

        const range = selectionObj.getRangeAt(0);
        const text = selectionObj.toString().trim();
        
        if (text && essayRef.current && essayRef.current.contains(range.commonAncestorContainer)) {
            
            
            const start = essay.content.indexOf(text); 
            if (start !== -1) {
                setSelection({ start, end: start + text.length, text });
            }
        }
    };

    const addCorrection = () => {
        if (!selection) return;
        const correction: Correction = {
            id: Math.random().toString(36).substr(2, 9),
            start: selection.start,
            end: selection.end,
            text: selection.text,
            suggestion: newCorrection.suggestion,
            note: newCorrection.note
        };
        setCorrections([...corrections, correction]);
        setSelection(null);
        setShowCorrectionModal(false);
        setNewCorrection({ suggestion: "", note: "" });
        window.getSelection()?.removeAllRanges();
    };

    const removeCorrection = (id: string) => {
        setCorrections(corrections.filter(c => c.id !== id));
    };

    const numericCriteria: Array<{ key: keyof IELTSScores; reasonKey: keyof IELTSScores; label: string }> = [
        { key: "taskAchievement", reasonKey: "taskAchievementReason", label: "Task Achievement / Response" },
        { key: "cohesionCoherence", reasonKey: "cohesionCoherenceReason", label: "Cohesion & Coherence" },
        { key: "lexicalResource", reasonKey: "lexicalResourceReason", label: "Lexical Resource" },
        { key: "grammaticalRange", reasonKey: "grammaticalRangeReason", label: "Grammatical Range & Accuracy" },
    ];

    
    const renderEssayWithHighlights = () => {
        if (corrections.length === 0) return essay.content;

        const sorted = [...corrections].sort((a, b) => a.start - b.start);
        const result = [];
        let lastIdx = 0;

        sorted.forEach((c) => {
            result.push(essay.content.substring(lastIdx, c.start));
            result.push(
                <span 
                    key={c.id} 
                    className="bg-amber-100 border-b-2 border-amber-400 group relative cursor-help px-0.5 rounded-sm transition-colors hover:bg-amber-200"
                    title={c.note}
                >
                    {essay.content.substring(c.start, c.end)}
                    <span className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 w-48 p-2 bg-gray-900 text-white text-[10px] rounded shadow-xl opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity z-50 leading-tight">
                        {c.suggestion && <div className="font-bold text-emerald-400 mb-1">Suggest: {c.suggestion}</div>}
                        {c.note}
                        <div className="mt-2 text-gray-400 pt-1 border-t border-gray-700">Click icon in sidebar to remove</div>
                    </span>
                </span>
            );
            lastIdx = c.end;
        });
        result.push(essay.content.substring(lastIdx));
        return result;
    };

    return (
        <div className="flex flex-col h-[calc(100vh-120px)] bg-gray-50 dark:bg-slate-950 rounded-2xl overflow-hidden border border-gray-100 dark:border-slate-800 shadow-sm transition-colors duration-300">
            {}
            <div className="bg-white dark:bg-slate-900 px-6 py-4 border-b border-gray-100 dark:border-slate-800 flex items-center justify-between z-10">
                <div className="flex items-center gap-4">
                    <button onClick={onBack} className="p-2 hover:bg-gray-100 dark:hover:bg-slate-800 rounded-lg transition-colors text-gray-500 dark:text-slate-400">
                        <ChevronLeft size={20} />
                    </button>
                    <div>
                        <h2 className="text-lg font-bold text-gray-800 dark:text-slate-100">Grading: {essay.studentName}</h2>
                        <p className="text-xs text-gray-500 dark:text-slate-400">{essay.taskType === 'TASK_1' ? 'Academic Task 1' : 'General/Academic Task 2'}</p>
                    </div>
                </div>
                <div className="flex gap-3">
                    <Button variant="outline" size="sm" onClick={() => onSave(essay.id, scores, feedback, corrections)} className="gap-2">
                        <Save size={16} /> Save Draft
                    </Button>
                    <Button size="sm" onClick={() => onSubmit(essay.id, scores, feedback, corrections)} className="gap-2">
                        <Send size={16} /> Submit Final Grade
                    </Button>
                </div>
            </div>

            <div className="flex flex-1 overflow-hidden relative">
                {}
                {selection && (
                    <div 
                        className="absolute z-50 bg-white shadow-2xl border border-gray-100 rounded-full px-4 py-2 flex items-center gap-2 transform -translate-x-1/2 animate-in fade-in zoom-in duration-200"
                        style={{ 
                            top: '20%', 
                            left: '30%' 
                        }}
                    >
                        <span className="text-xs font-semibold text-gray-500 line-clamp-1 max-w-[100px]">"{selection.text}"</span>
                        <div className="w-px h-4 bg-gray-200 mx-1"></div>
                        <button 
                            onClick={() => setShowCorrectionModal(true)}
                            className="flex items-center gap-1.5 text-xs font-bold text-indigo-600 hover:text-indigo-700"
                        >
                            <Highlighter size={14} /> Mark Error
                        </button>
                    </div>
                )}

                {}
                <div className="flex-[0.6] overflow-y-auto bg-white dark:bg-slate-900 p-10 border-r border-gray-100 dark:border-slate-800 transition-colors" onMouseUp={handleTextSelection}>
                    <div className="max-w-2xl mx-auto">
                        <div className="bg-slate-50 dark:bg-slate-800/50 rounded-xl p-6 mb-8 border border-slate-100 dark:border-slate-700">
                            <h3 className="text-sm font-bold text-slate-800 dark:text-slate-200 uppercase tracking-wider mb-3 flex items-center gap-2">
                                <Info size={16} className="text-indigo-500" /> Topic / Question
                            </h3>
                            <p className="text-gray-700 dark:text-slate-300 leading-relaxed italic">"{essay.prompt}"</p>
                        </div>

                        <div ref={essayRef} className="essay-content text-gray-800 dark:text-slate-200 leading-loose text-lg whitespace-pre-wrap select-text selection:bg-indigo-100 dark:selection:bg-indigo-900/50">
                            {renderEssayWithHighlights()}
                        </div>
                    </div>
                </div>

                {}
                <div className="flex-[0.4] overflow-y-auto p-8 bg-gray-50/50 dark:bg-slate-950/50 transition-colors">
                    <div className="space-y-8">
                        {}
                        <div className="bg-indigo-600 rounded-2xl p-6 text-white shadow-lg shadow-indigo-100 flex items-center justify-between">
                            <div>
                                <h4 className="text-indigo-100 text-sm font-medium uppercase tracking-widest">Overall Band Score</h4>
                                <div className="flex items-center gap-3 mt-1">
                                    <div className="text-5xl font-black">{overallBand.toFixed(1)}</div>
                                    <div className="h-10 w-px bg-white/20"></div>
                                    <div className="text-[10px] text-indigo-200 leading-tight">
                                        Component average<br/>rounded to nearest 0.5
                                    </div>
                                </div>
                            </div>
                        </div>

                        {}
                        {corrections.length > 0 && (
                            <div className="bg-white dark:bg-slate-900 rounded-2xl p-6 border border-gray-100 dark:border-slate-800 shadow-sm space-y-4">
                                <h4 className="font-bold text-gray-800 dark:text-slate-100 flex items-center gap-2">
                                    <Highlighter size={18} className="text-amber-500" /> Inline Corrections ({corrections.length})
                                </h4>
                                <div className="space-y-3 max-h-60 overflow-y-auto pr-2 custom-scrollbar">
                                    {corrections.map((c) => (
                                        <div key={c.id} className="p-3 bg-gray-50 dark:bg-slate-800 rounded-xl border border-gray-100 dark:border-slate-700 group">
                                            <div className="flex justify-between items-start gap-4">
                                                <div className="text-xs text-gray-400 dark:text-slate-500 font-medium">Original: <span className="text-gray-600 dark:text-slate-300 underline">"{c.text}"</span></div>
                                                <button onClick={() => removeCorrection(c.id)} className="text-gray-400 hover:text-red-500 transition-colors opacity-0 group-hover:opacity-100">
                                                    <X size={14} />
                                                </button>
                                            </div>
                                            {c.suggestion && <div className="text-xs font-bold text-emerald-600 dark:text-emerald-400 mt-1">Suggest: {c.suggestion}</div>}
                                            <p className="text-xs text-gray-600 dark:text-slate-400 mt-2 bg-white dark:bg-slate-900 px-2 py-1.5 rounded border border-gray-50 dark:border-slate-800">{c.note}</p>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        )}

                        {}
                        <div className="space-y-6">
                            <h4 className="font-bold text-gray-800 dark:text-slate-100 flex items-center gap-2 px-1">
                                <AlertCircle size={18} className="text-amber-500" /> IELTS Assessment Criteria
                            </h4>
                            
                            {numericCriteria.map((item) => (
                                <div key={item.key} className="bg-white dark:bg-slate-900 rounded-2xl p-6 border border-gray-100 dark:border-slate-800 shadow-sm space-y-4 transition-all hover:shadow-md">
                                    <div className="flex justify-between items-center">
                                        <label className="text-sm font-bold text-gray-700 dark:text-slate-300">{item.label}</label>
                                        <span className="text-lg font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-900/30 px-3 py-1 rounded-lg min-w-[44px] text-center">
                                            {(scores[item.key] as number).toFixed(1)}
                                        </span>
                                    </div>
                                    <input 
                                        type="range" 
                                        min="0" max="9" step="0.5" 
                                        value={scores[item.key] as number}
                                        onChange={(e) => handleScoreChange(item.key, parseFloat(e.target.value))}
                                        className="w-full h-2 bg-gray-100 dark:bg-slate-800 rounded-lg appearance-none cursor-pointer accent-indigo-600"
                                    />
                                    <div className="space-y-2">
                                        <div className="text-[11px] font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider">Reasoning</div>
                                        <textarea 
                                            value={scores[item.reasonKey] as string}
                                            onChange={(e) => handleScoreChange(item.reasonKey, e.target.value)}
                                            placeholder={`Why did you give this score for ${item.label}?`}
                                            className="w-full h-24 p-3 text-xs bg-gray-50 dark:bg-slate-800 rounded-xl border border-transparent focus:bg-white dark:focus:bg-slate-800 focus:border-indigo-500 transition-all resize-none text-gray-700 dark:text-slate-300"
                                        />
                                    </div>
                                </div>
                            ))}
                        </div>

                        {}
                        <div className="bg-white dark:bg-slate-900 rounded-2xl p-6 border border-gray-100 dark:border-slate-800 shadow-sm">
                            <h4 className="font-bold text-gray-800 dark:text-slate-100 mb-4">Overall Feedback for Student</h4>
                            <textarea 
                                value={feedback}
                                onChange={(e) => setFeedback(e.target.value)}
                                placeholder="Summary of strengths and path to improvement..."
                                className="w-full h-40 p-4 rounded-xl border border-gray-100 dark:border-slate-800 bg-gray-50 dark:bg-slate-800 focus:bg-white dark:focus:bg-slate-800 focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all resize-none text-sm leading-relaxed text-gray-700 dark:text-slate-300"
                            />
                        </div>
                    </div>
                </div>
            </div>

            {}
            {showCorrectionModal && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/40 backdrop-blur-sm animate-in fade-in duration-200">
                    <div className="bg-white dark:bg-slate-900 rounded-2xl w-full max-w-md shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200 border dark:border-slate-800">
                        <div className="p-6 border-b border-gray-100 dark:border-slate-800 flex justify-between items-center bg-amber-50/50 dark:bg-amber-900/10">
                            <h3 className="font-bold text-gray-800 dark:text-slate-100 flex items-center gap-2">
                                <Highlighter size={18} className="text-amber-500" /> Add Inline Feedback
                            </h3>
                            <button onClick={() => setShowCorrectionModal(false)} className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"><X size={20}/></button>
                        </div>
                        <div className="p-6 space-y-4">
                            <div className="space-y-1">
                                <label className="text-[11px] font-bold text-gray-400 dark:text-slate-500 uppercase">Selected Text</label>
                                <p className="p-3 bg-gray-50 dark:bg-slate-800 rounded-lg text-sm text-gray-700 dark:text-slate-300 font-medium italic">"{selection?.text}"</p>
                            </div>
                            <div className="space-y-1">
                                <label className="text-[11px] font-bold text-gray-400 dark:text-slate-500 uppercase">Suggestion (Optional)</label>
                                <input 
                                    className="w-full p-3 bg-gray-50 dark:bg-slate-800 rounded-lg text-sm border-transparent focus:bg-white dark:focus:bg-slate-700 focus:border-indigo-500 outline-none transition-all text-gray-700 dark:text-slate-200"
                                    placeholder="e.g. 'however' instead of 'but'"
                                    value={newCorrection.suggestion}
                                    onChange={(e) => setNewCorrection({...newCorrection, suggestion: e.target.value})}
                                />
                            </div>
                            <div className="space-y-1">
                                <label className="text-[11px] font-bold text-gray-400 dark:text-slate-500 uppercase">Note / Explanation</label>
                                <textarea 
                                    className="w-full h-24 p-3 bg-gray-50 dark:bg-slate-800 rounded-lg text-sm border-transparent focus:bg-white dark:focus:bg-slate-700 focus:border-indigo-500 outline-none transition-all resize-none text-gray-700 dark:text-slate-200"
                                    placeholder="Explain why this is an error or how to improve it..."
                                    value={newCorrection.note}
                                    onChange={(e) => setNewCorrection({...newCorrection, note: e.target.value})}
                                />
                            </div>
                        </div>
                        <div className="p-4 bg-gray-50 dark:bg-slate-800/50 flex gap-3">
                            <Button variant="outline" className="flex-1 dark:border-slate-700 dark:hover:bg-slate-700" onClick={() => setShowCorrectionModal(false)}>Cancel</Button>
                            <Button className="flex-1 gap-2" onClick={addCorrection} disabled={!newCorrection.note && !newCorrection.suggestion}>
                                <Check size={18} /> Apply Feedback
                            </Button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};
