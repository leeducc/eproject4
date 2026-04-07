import { apiClient } from "./apiClient";

export interface Tag {
    id: number;
    name: string;
    namespace: string;
    color: string;
}

export interface AppScreenSection {
    id: number;
    skill: string;
    sectionName: string;
    difficultyBand: string;
    displayOrder: number;
    tags?: Tag[];
    guideContent: string;
}

export interface AppScreenSectionRequest {
    skill: string;
    sectionName: string;
    difficultyBand: string;
    displayOrder: number;
    tagIds?: number[];
    guideContent: string;
}

export interface Policy {
    id: number;
    type: "TERMS" | "PRIVACY" | "DELETE_ACCOUNT";
    titleEn: string;
    titleVi: string;
    titleZh: string;
    contentEn: string;
    contentVi: string;
    contentZh: string;
    updatedAt: string;
}

export interface PolicyHistory extends Omit<Policy, "id" | "updatedAt"> {
    id: number;
    adminId: number;
    adminEmail: string;
    changedAt: string;
}

export type PolicyRequest = Omit<Policy, "id" | "updatedAt">;

export const getTags = async (): Promise<Tag[]> => {
    console.log("[appConfigApi] Fetching all tags from /v1/quizbank/tags");
    const response = await apiClient.get('/v1/quizbank/tags');
    console.log(`[appConfigApi] Successfully fetched ${response.data.length} tags`);
    return response.data;
};

export const getAppSections = async (skill?: string, difficultyBand?: string): Promise<AppScreenSection[]> => {
    const params = new URLSearchParams();
    if (skill) params.append('skill', skill);
    if (difficultyBand) params.append('difficultyBand', difficultyBand);
    
    const response = await apiClient.get(`/v1/app-sections?${params.toString()}`);
    return response.data;
};

export const createAppSection = async (data: AppScreenSectionRequest): Promise<AppScreenSection> => {
    const response = await apiClient.post('/v1/app-sections', data);
    return response.data;
};

export const updateAppSection = async (id: number, data: AppScreenSectionRequest): Promise<AppScreenSection> => {
    const response = await apiClient.put(`/v1/app-sections/${id}`, data);
    return response.data;
};

export const deleteAppSection = async (id: number): Promise<void> => {
    await apiClient.delete(`/v1/app-sections/${id}`);
};

export const getAllPolicies = async (): Promise<Policy[]> => {
    const response = await apiClient.get('/v1/admin/policies');
    return response.data;
};

export const updatePolicy = async (data: Partial<Policy>): Promise<Policy> => {
    const response = await apiClient.put('/v1/admin/policies', data);
    return response.data;
};

export const getPublicPolicy = async (type: string): Promise<Policy> => {
    const response = await apiClient.get(`/v1/policies?type=${type}`);
    return response.data;
};

export const createSystemNotification = async (data: { title: string; content: string; type?: string }): Promise<any> => {
    const response = await apiClient.post('/v1/system-notifications/admin', data);
    return response.data;
};

export const getPolicyHistory = async (type: string): Promise<PolicyHistory[]> => {
    const response = await apiClient.get(`/v1/admin/policies/${type}/history`);
    return response.data;
};
