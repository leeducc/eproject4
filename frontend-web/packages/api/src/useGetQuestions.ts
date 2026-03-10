import { useQuery } from "@tanstack/react-query";
import { apiClient } from "./apiClient";
import type { Question } from "@english-learning/types";

export const fetchQuestions = async (): Promise<Question[]> => {
    const { data } = await apiClient.get("/questions");
    return data;
};

export const useGetQuestions = () => {
    return useQuery({
        queryKey: ["questions"],
        queryFn: fetchQuestions,
    });
};
