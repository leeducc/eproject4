import React from "react";
import { EssayStatus, EssaySubmission } from "./types";
import { Lock, CheckCircle2, Clock, UserCheck } from "lucide-react";
import { Button } from "@english-learning/ui";

interface GradingDashboardViewProps {
    essays: EssaySubmission[];
    onClaim: (essay: EssaySubmission) => void;
    onUnclaim: (essayId: string) => void;
    currentUserId: string;
}

export const GradingDashboardView: React.FC<GradingDashboardViewProps> = ({ essays, onClaim, onUnclaim, currentUserId }) => {
    const getStatusBadge = (status: EssayStatus, lockedBy?: string, lockedById?: string) => {
        switch (status) {
            case EssayStatus.PENDING:
                return (
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700">
                        <Clock size={12} /> Pending
                    </span>
                );
            case EssayStatus.IN_PROGRESS:
                const isMine = lockedById?.toString() === currentUserId;
                return (
                    <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium ${isMine ? 'bg-indigo-100 text-indigo-700' : 'bg-amber-100 text-amber-700'}`}>
                        <UserCheck size={12} /> {isMine ? 'Locked by You' : `Locked by ${lockedBy || "Teacher"}`}
                    </span>
                );
            case EssayStatus.GRADED:
                return (
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-700">
                        <CheckCircle2 size={12} /> Graded
                    </span>
                );
            default:
                return null;
        }
    };

    return (
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
            <div className="p-6 border-b border-gray-100 flex justify-between items-center">
                <div>
                    <h2 className="text-xl font-bold text-gray-800">Essay Grading Queue</h2>
                    <p className="text-sm text-gray-500 mt-1">Manage and grade student submissions</p>
                </div>
                <div className="flex gap-4 items-center text-sm">
                    <div className="flex items-center gap-2">
                        <span className="w-3 h-3 rounded-full bg-emerald-400"></span> Pending
                    </div>
                    <div className="flex items-center gap-2">
                        <span className="w-3 h-3 rounded-full bg-amber-400"></span> In Progress
                    </div>
                    <div className="flex items-center gap-2">
                        <span className="w-3 h-3 rounded-full bg-blue-400"></span> Graded
                    </div>
                </div>
            </div>

            <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-gray-50 text-gray-500 text-xs uppercase tracking-wider font-semibold">
                            <th className="px-6 py-4">Student Name</th>
                            <th className="px-6 py-4">Task Type</th>
                            <th className="px-6 py-4">Submitted Date</th>
                            <th className="px-6 py-4">Status</th>
                            <th className="px-6 py-4 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-50 text-sm">
                        {essays.map((essay) => {
                            const isLockedByMe = essay.status === EssayStatus.IN_PROGRESS && essay.lockedById?.toString() === currentUserId;
                            const isLockedByOthers = essay.status === EssayStatus.IN_PROGRESS && essay.lockedById?.toString() !== currentUserId;
                            const isGraded = essay.status === EssayStatus.GRADED;

                            return (
                                <tr 
                                    key={essay.id} 
                                    className={`hover:bg-gray-50/50 transition-colors ${isLockedByOthers ? 'opacity-60 bg-gray-50/30' : ''}`}
                                >
                                    <td className="px-6 py-5 font-medium text-gray-900">{essay.studentName}</td>
                                    <td className="px-6 py-5">
                                        <span className={`px-2 py-0.5 rounded text-[11px] font-bold ${
                                            essay.taskType === 'TASK_1' ? 'bg-slate-100 text-slate-600' : 'bg-indigo-50 text-indigo-600'
                                        }`}>
                                            {essay.taskType === 'TASK_1' ? 'TASK 1' : 'TASK 2'}
                                        </span>
                                    </td>
                                    <td className="px-6 py-5 text-gray-500">
                                        {new Date(essay.submissionDate).toLocaleDateString()} at {new Date(essay.submissionDate).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                    </td>
                                    <td className="px-6 py-5">
                                        {getStatusBadge(essay.status, essay.lockedBy, essay.lockedById)}
                                    </td>
                                    <td className="px-6 py-5 text-right">
                                        {isLockedByMe ? (
                                            <div className="flex justify-end gap-2">
                                                <Button variant="outline" size="sm" onClick={() => onUnclaim(essay.id)} className="text-amber-600 border-amber-200 hover:bg-amber-50">
                                                    Unlock
                                                </Button>
                                                <Button size="sm" onClick={() => onClaim(essay)}>
                                                    Continue
                                                </Button>
                                            </div>
                                        ) : isLockedByOthers ? (
                                            <div className="flex items-center justify-end gap-2 text-gray-400 italic text-xs">
                                                <Lock size={14} /> Locked
                                            </div>
                                        ) : isGraded ? (
                                            <Button variant="outline" size="sm" onClick={() => onClaim(essay)}>
                                                View Results
                                            </Button>
                                        ) : (
                                            <Button size="sm" onClick={() => onClaim(essay)}>
                                                Claim & Grade
                                            </Button>
                                        )}
                                    </td>
                                </tr>
                            );
                        })}
                    </tbody>
                </table>
            </div>

            {essays.length === 0 && (
                <div className="p-12 text-center text-gray-400">
                    <p>No essays found in the queue.</p>
                </div>
            )}
        </div>
    );
};
