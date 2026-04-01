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
