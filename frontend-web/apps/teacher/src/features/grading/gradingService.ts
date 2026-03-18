import { apiClient } from "@english-learning/api";
import { EssaySubmission, IELTSScores, Correction } from "./types";

export interface GradingRequest {
    taskAchievement: number;
    cohesionCoherence: number;
    lexicalResource: number;
    grammaticalRange: number;
    teacherFeedback: string;
    taskAchievementReason: string;
    cohesionCoherenceReason: string;
    lexicalResourceReason: string;
    grammaticalRangeReason: string;
    correctionsJson: string;
}

export const gradingService = {
    getSubmissions: async (): Promise<EssaySubmission[]> => {
        const response = await apiClient.get("/teacher/grading/submissions");
        return response.data;
    },

    claimSubmission: async (id: string): Promise<EssaySubmission> => {
        const response = await apiClient.post(`/teacher/grading/submissions/${id}/claim`);
        return response.data;
    },
    
    unclaimSubmission: async (id: string): Promise<EssaySubmission> => {
        const response = await apiClient.post(`/teacher/grading/submissions/${id}/unclaim`);
        return response.data;
    },

    submitGrade: async (id: string, scores: IELTSScores, feedback: string, corrections: Correction[]): Promise<EssaySubmission> => {
        const request: GradingRequest = {
            taskAchievement: scores.taskAchievement,
            cohesionCoherence: scores.cohesionCoherence,
            lexicalResource: scores.lexicalResource,
            grammaticalRange: scores.grammaticalRange,
            teacherFeedback: feedback,
            taskAchievementReason: scores.taskAchievementReason || "",
            cohesionCoherenceReason: scores.cohesionCoherenceReason || "",
            lexicalResourceReason: scores.lexicalResourceReason || "",
            grammaticalRangeReason: scores.grammaticalRangeReason || "",
            correctionsJson: JSON.stringify(corrections)
        };
        const response = await apiClient.post(`/teacher/grading/submissions/${id}/grade`, request);
        return response.data;
    }
};
