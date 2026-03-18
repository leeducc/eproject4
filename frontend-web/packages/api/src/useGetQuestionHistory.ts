import { useQuery } from "@tanstack/react-query";
import { apiClient } from "./apiClient";
import type { QuestionHistory } from "@english-learning/types";

export const fetchQuestionHistory = async (id: number): Promise<QuestionHistory[]> => {
    const { data } = await apiClient.get(`/questions/${id}/history`);
    return data;
};

export const useGetQuestionHistory = (id: number) => {
    return useQuery({
        queryKey: ["questionHistory", id],
        queryFn: () => fetchQuestionHistory(id),
        enabled: !!id,
    });
};
