import { apiClient } from "./apiClient";

export enum ReportStatus {
    NEW = "NEW",
    SPAM = "SPAM",
    RESOLVED = "RESOLVED"
}

export enum ReportedItemType {
    QUESTION = "QUESTION",
    VOCABULARY = "VOCABULARY"
}

export interface Report {
    id: number;
    reporter: {
        id: number;
        fullName: string;
        email: string;
    };
    itemType: ReportedItemType;
    itemId: number;
    reason: string;
    status: ReportStatus;
    adminResponse?: string;
    createdAt: string;
    updatedAt: string;
}

export interface ReportNotification {
    id: number;
    message: string;
    isRead: boolean;
    createdAt: string;
}

export interface ReportRequest {
    itemType: ReportedItemType;
    itemId: number;
    reason: string;
}

export interface ResolveRequest {
    adminResponse: string;
    disableContent: boolean;
}

export const submitReport = async (data: ReportRequest): Promise<Report> => {
    const response = await apiClient.post('/v1/moderation/report', data);
    return response.data;
};

export const getReports = async (status: ReportStatus): Promise<Report[]> => {
    const response = await apiClient.get(`/v1/moderation/admin/reports?status=${status}`);
    return response.data;
};

export const resolveReport = async (id: number, data: ResolveRequest): Promise<Report> => {
    const response = await apiClient.post(`/v1/moderation/admin/resolve/${id}`, data);
    return response.data;
};

export const dismissReport = async (id: number): Promise<void> => {
    await apiClient.post(`/v1/moderation/admin/dismiss/${id}`);
};

export const getModerationNotifications = async (): Promise<ReportNotification[]> => {
    const response = await apiClient.get('/v1/moderation/notifications');
    return response.data;
};

export const markNotificationRead = async (id: number): Promise<void> => {
    await apiClient.post(`/v1/moderation/notifications/${id}/read`);
};

export const getQuestionDetail = async (id: number): Promise<any> => {
    const response = await apiClient.get(`/v1/questions/${id}`);
    return response.data;
};

export const getQuestionHistory = async (id: number): Promise<any[]> => {
    const response = await apiClient.get(`/v1/questions/${id}/history`);
    return response.data;
};

export const getVocabularyDetail = async (id: number): Promise<any> => {
    const response = await apiClient.get(`/v1/vocabulary/${id}`);
    return response.data;
};

export const getVocabularyHistory = async (id: number): Promise<any[]> => {
    const response = await apiClient.get(`/v1/vocabulary/${id}/history`);
    return response.data;
};
