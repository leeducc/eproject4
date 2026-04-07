import { useState } from "react";
import { TeacherLayout } from "../components/TeacherLayout";
import { 
    GradingDashboardView, 
    GradingWorkspaceView, 
    EssaySubmission, 
    IELTSScores,
    Correction,
    gradingService
} from "../features/grading";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";

export default function GradingQueuePage() {
    const queryClient = useQueryClient();
    const [activeSubmission, setActiveSubmission] = useState<EssaySubmission | null>(null);

    const userJson = localStorage.getItem("teacher_user");
    const currentUser = userJson ? JSON.parse(userJson) : null;
    const currentUserId = currentUser?.id?.toString() || "";

    console.log("[GradingQueuePage] currentUserId:", currentUserId);

    const { data: essays = [], isLoading } = useQuery<EssaySubmission[]>({
        queryKey: ["essays"],
        queryFn: async () => {
            const data = await gradingService.getSubmissions();
            console.log("[GradingQueuePage] Fetched essays:", data.length);
            return data;
        },
    });

    const claimMutation = useMutation<EssaySubmission, Error, string>({
        mutationFn: (id: string) => gradingService.claimSubmission(id),
        onSuccess: (updatedEssay: EssaySubmission) => {
            queryClient.invalidateQueries({ queryKey: ["essays"] });
            setActiveSubmission(updatedEssay);
            
            if (updatedEssay.status !== 'IN_PROGRESS') {
                toast.success(`Claimed essay for ${updatedEssay.studentName}`);
            }
        },
        onError: () => toast.error("Failed to claim essay."),
    });

    const unclaimMutation = useMutation<EssaySubmission, Error, string>({
        mutationFn: (id: string) => gradingService.unclaimSubmission(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["essays"] });
            toast.success("Essay unlocked and returned to queue.");
        },
        onError: () => toast.error("Failed to unlock essay."),
    });

    const submitMutation = useMutation<EssaySubmission, Error, { id: string; scores: IELTSScores; feedback: string; corrections: Correction[] }>({
        mutationFn: (data) => 
            gradingService.submitGrade(data.id, data.scores, data.feedback, data.corrections),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["essays"] });
            setActiveSubmission(null);
            toast.success("Submission completed successfully!");
        },
        onError: () => toast.error("Failed to submit grade."),
    });

    const handleClaim = (essay: EssaySubmission) => {
        if (essay.status === 'IN_PROGRESS' && essay.lockedById?.toString() !== currentUserId) { 
            toast.error("This essay is already being graded by another teacher.");
            return;
        }
        claimMutation.mutate(essay.id);
    };

    const handleUnclaim = (id: string) => {
        unclaimMutation.mutate(id);
    };

    const handleSaveDraft = () => {
        toast.info("Draft feature coming soon.");
    };

    const handleSubmitGrade = (id: string, scores: IELTSScores, feedback: string, corrections: Correction[]) => {
        submitMutation.mutate({ id, scores, feedback, corrections });
    };

    if (isLoading) {
        return (
            <TeacherLayout>
                <div className="flex items-center justify-center min-h-[400px]">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
                </div>
            </TeacherLayout>
        );
    }

    return (
        <TeacherLayout>
            {activeSubmission ? (
                <GradingWorkspaceView 
                    essay={activeSubmission}
                    onBack={() => setActiveSubmission(null)}
                    onSave={handleSaveDraft}
                    onSubmit={handleSubmitGrade}
                />
            ) : (
                <div className="space-y-6">
                    <GradingDashboardView 
                        essays={essays}
                        onClaim={handleClaim}
                        onUnclaim={handleUnclaim}
                        currentUserId={currentUserId}
                    />
                </div>
            )}
        </TeacherLayout>
    );
}
