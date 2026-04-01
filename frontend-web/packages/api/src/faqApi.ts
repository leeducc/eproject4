import { apiClient } from "./apiClient";

export interface FAQ {
    id: number;
    questionEn: string;
    questionVi: string;
    questionZh: string;
    answerEn: string;
    answerVi: string;
    answerZh: string;
    displayOrder: number;
    isActive: boolean;
    createdAt?: string;
    updatedAt?: string;
}

export type FAQRequest = Omit<FAQ, 'id' | 'createdAt' | 'updatedAt'>;

export const getAdminFAQs = async (): Promise<FAQ[]> => {
    const response = await apiClient.get('/v1/admin/faqs');
    return response.data;
};

export const createFAQ = async (data: FAQRequest): Promise<FAQ> => {
    const response = await apiClient.post('/v1/admin/faqs', data);
    return response.data;
};

export const updateFAQ = async (id: number, data: FAQRequest): Promise<FAQ> => {
    const response = await apiClient.put(`/v1/admin/faqs/${id}`, data);
    return response.data;
};

export const deleteFAQ = async (id: number): Promise<void> => {
    await apiClient.delete(`/v1/admin/faqs/${id}`);
};

// Public endpoint for mobile use (if needed in web as well)
export const getPublicFAQs = async (): Promise<FAQ[]> => {
    const response = await apiClient.get('/v1/faqs');
    return response.data;
};
